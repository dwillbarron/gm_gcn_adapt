// GM_GCN_ADAPT.cpp : Code for exported functions lives here.
//
// Note: Each function written in here assumes it is being run
// atomically (i.e. only one function is called at a time).
// If you are accessing this library from a multithreaded application,
// it is YOUR responsibility to properly set/release locks on this library.
#include "stdafx.h"
#include <string>
#include <chrono>
#include <thread>
#include "libusb.h"
#include "GM_GCN_ADAPT.h"

// 0x81 and 0x2, repsectively...
// these are hardware specific and shouldn't change.
const unsigned char READ_ENDPOINT = 129;
const unsigned char WRITE_ENDPOINT = 2;

/* ============
Shared Variables
   ============ */
// maintain connected state
bool driver_connected = false;
libusb_device_handle *adapter_handle = NULL;

// retain most recently read formatted information
std::string last_read = "blurg";

// for unknown/uncommon errors, retain code to
// fetch information about later.
int last_error = 0;

/* ===========
Debug Functions
   =========== */
GM_GCN_ADAPT_API const char *last_err_string() {
	return libusb_strerror((libusb_error)last_error);
}

/* ===================
(De)Initialization Functions
   ===================  */

// Configure the extension to call this on launch
GM_GCN_ADAPT_API double init_libusb(void)
{
	libusb_init(NULL);
	return 0.0;
}

GM_GCN_ADAPT_API double cleanup_libusb(void)
{
	if (driver_connected) {
		release_adapter();
	}
	libusb_exit(NULL);

	return 0.0;
}

/* ==============
Adapter Functions
   ============== */

/// <summary>
/// Return a libusb_device corresponding to the first found gamecube adapter
/// </summary>
libusb_device *find_adapter()
{
	// pointer for list of devices
	libusb_device **dev_list;
	// current device
	libusb_device *dev;
	// this is probably the adapter
	libusb_device *adapter = NULL;

	int list_result;
	list_result = libusb_get_device_list(NULL, &dev_list);
	if (list_result < 0) {
		last_error = list_result;
		return NULL;
	}
	int i = 0;
	while ((dev = dev_list[i++]) != NULL) {
		struct libusb_device_descriptor dev_desc;
		int desc_result = libusb_get_device_descriptor(dev, &dev_desc);
		if (desc_result < 0) {
			last_error = desc_result;
			return NULL;
		}
		// hardcoded vendor and product for the adapter
		if ((dev_desc.idVendor == 0x057E)
				&& (dev_desc.idProduct == 0x0337)) {
			// add a reference to the device so we can free the rest easily
			libusb_ref_device(dev);
			adapter = dev;
			break;
		}
	}
	libusb_free_device_list(dev_list, 1);
	return adapter;
}


GM_GCN_ADAPT_API double attach_adapter(void) 
{
	// Errors:
	// -1: no adapter found (or disconnected while trying)
	// -2: couldn't open (probably needs zadig to install winusb driver)
	// -3: adapter opened by another application
	// -4: other errors
	libusb_device *adapter = NULL;
	libusb_device_handle *prospective_handle = NULL;

	if (driver_connected) {
		return 1.0;
	}

	adapter = find_adapter();
	if (adapter == NULL) {
		return -1.0;
	}
	int open_result = libusb_open(adapter, &prospective_handle);
	if (open_result < 0) {
		last_error = open_result;
		if (open_result == LIBUSB_ERROR_NO_DEVICE) {
			return -1.0;
		}
		else if (open_result == LIBUSB_ERROR_ACCESS) {
			return -2.0;
		}
		else {
			return -99.0;
		}
	}
	libusb_unref_device(adapter);
	int claim_result = libusb_claim_interface(prospective_handle, 0);
	if (claim_result < 0) {
		last_error = claim_result;
		if (claim_result == LIBUSB_ERROR_NO_DEVICE) {
			return -1.0;
		}
		else if (claim_result == LIBUSB_ERROR_BUSY) {
			return -3.0;
		}
		else {
			return -99.0;
		}
	}
	unsigned char magic_sequence[] = { 19, 0 }; // only the 19 is sent; 0 is there just for null termination
	int write_length = 0;
	int write_result =
		libusb_interrupt_transfer(
			prospective_handle,
			WRITE_ENDPOINT,
			magic_sequence,
			1,
			&write_length,
			10
		);
	if (write_result < 0) {
		int last_error = write_result;
		// failure at this point should be rare...
		return -99.0;
	}
	adapter_handle = prospective_handle;
	driver_connected = true;
	return 0.0;
}

GM_GCN_ADAPT_API double release_adapter(void) 
{
	update_rumble("0000");
	driver_connected = false;
	if (adapter_handle != NULL) {
		// don't forget to turn off all rumbles
		libusb_release_interface(adapter_handle, 0);
		libusb_close(adapter_handle);
	}
	adapter_handle = NULL;

	return 0.0;
}


GM_GCN_ADAPT_API double update_rumble(char * rumble_states)
{
	if (!driver_connected || adapter_handle == NULL) {
		return -1.0;
	}
	unsigned char write_buf[] = { 17, 0, 0, 0, 0 };
	int xfer_length;
	
	for (unsigned int i = 0; i < min(strlen(rumble_states), 4); i++) {
		if (rumble_states[i] == '1') {
			write_buf[i + 1] = 1;
		}
	}
	int write_result =
		libusb_interrupt_transfer(
			adapter_handle,
			WRITE_ENDPOINT,
			write_buf,
			5,
			&xfer_length,
			10
		);
	if (write_result < 0) {
		last_error = write_result;
		if (write_result == LIBUSB_ERROR_NO_DEVICE) {
			return -1.0;
		}
		else {
			return -99.0;
		}
	}
	return 0.0;
}

// Poll the adapter for most recent controller state
GM_GCN_ADAPT_API double poll_adapter()
{
	if (!driver_connected) {
		return -1.0;
	}
	const int FRAME_SIZE = 37;
	unsigned char buf[FRAME_SIZE];
	int xfer_length;
	int read_result = 
		libusb_interrupt_transfer(
			adapter_handle,
			READ_ENDPOINT,
			buf,
			FRAME_SIZE,
			&xfer_length,
			10
		);
	if (read_result < 0) {
		last_error = read_result;
		if (read_result == LIBUSB_ERROR_NO_DEVICE) {
			return -1.0;
		}
		else {
			return -99.0;
		}
	}
	// wait to clear this until we know we have error-free data
	last_read = "";
	// represent each byte as a 3 digit zero-padded integer.
	// this is the simplest format to read into game maker.
	for (int i = 0; i < FRAME_SIZE; i++) {
		std::string num = std::to_string((int)buf[i]);
		int zeroes_to_add = 3 - num.length();
		for (int j = 0; j < zeroes_to_add; j++) {
			num = "0" + num;
		}
		last_read += num;
	}
	return 0.0;
}

GM_GCN_ADAPT_API const char *get_frame() {
	// we're assuming GM makes a copy of the string when it comes in
	// (if not, we'll make GM make a copy)
	return last_read.c_str();
}


// Test functions to ensure the library exists and is working properly.
// These can be removed without violating the correctness of the library.
GM_GCN_ADAPT_API double just42(void)
{
    return 42.0;
}

GM_GCN_ADAPT_API double doubler(double d)
{
   return d * 2;
}