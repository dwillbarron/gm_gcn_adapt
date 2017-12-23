// GM_GCN_ADAPT.cpp : Defines the exported functions for the DLL application.
//
// todo: figure out if I can just remove this...
#include "stdafx.h"
#include <string>
#include <chrono>
#include <thread>
#include "libusb.h"
#include "GM_GCN_ADAPT.h"

// 0x81 and 0x2, repsectively...
// these are intrinsic to the hardware and can be hardcoded.
const unsigned char READ_ENDPOINT = 129;
const unsigned char WRITE_ENDPOINT = 2;

bool driver_connected = false;
libusb_device_handle *adapter_handle = NULL;
// huge hack to manage memory easier
std::string returnbuf = "";

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
		// the odds of this failing are low, but this could still
		// make for some misleading errors down the line...

		// taking the risk as I don't forsee this being common
		return NULL;
	}
	int i = 0;
	while ((dev = dev_list[i++]) != NULL) {
		struct libusb_device_descriptor dev_desc;
		int result = libusb_get_device_descriptor(dev, &dev_desc);
		if (result < 0) {
			// ditto above
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

GM_GCN_ADAPT_API const char *init_adapter(void)
{
	libusb_device *adapter = NULL;
	libusb_device_handle *prospective_handle = NULL;
	if (driver_connected) {
		return "Driver already connected!";
	}
	libusb_init(NULL);
	adapter = find_adapter();
	int open_result = libusb_open(adapter, &prospective_handle);
	if (open_result < 0) {
		return libusb_strerror((libusb_error)open_result);
	}
	libusb_unref_device(adapter);
	int claim_result = libusb_claim_interface(prospective_handle, 0);
	if (claim_result < 0) {
		return libusb_strerror((libusb_error)claim_result);
	}
	unsigned char magic_sequence[] = { 19, 0 };
	int xfer_length = 0;
	int xfer_result =
		libusb_interrupt_transfer(
			prospective_handle,
			WRITE_ENDPOINT,
			magic_sequence,
			1,
			&xfer_length,
			10
		);
	if (claim_result < 0) {
		libusb_release_interface(prospective_handle, 0);
		return libusb_strerror((libusb_error)claim_result);
	}
	adapter_handle = prospective_handle;
	driver_connected = true;
	// TODO: work out standard success indicator
	return "SUCCESS!";
}

GM_GCN_ADAPT_API char *release_adapter(void)
{
	driver_connected = false;
	adapter_handle = NULL;
	libusb_release_interface(adapter_handle, 0);
	libusb_close(adapter_handle);
	libusb_exit(NULL);
	// TODO: work out standard success indicator

	return NULL;
}

GM_GCN_ADAPT_API char *update_rumble(char * rumble_states)
{
	unsigned char write_buf[] = { 17, 0, 0, 0, 0 };
	int xfer_length;
	
	for (int i = 0; i < min(strlen(rumble_states), 4); i++) {
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
	return nullptr;
}

GM_GCN_ADAPT_API const char *read_adapter()
{
	if (!driver_connected) {
		// TODO: work out protocol for error statuses, return an error
		return NULL;
	}
	const int FRAME_SIZE = 37;
	unsigned char buf[FRAME_SIZE];
	returnbuf = "";
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
		return libusb_strerror((libusb_error)read_result);
	}
	
	for (int i = 0; i < FRAME_SIZE; i++) {
		returnbuf += std::to_string((int)buf[i]) + ',';
	}
	return (returnbuf.c_str());
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