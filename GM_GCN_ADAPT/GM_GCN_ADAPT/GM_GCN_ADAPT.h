#pragma once
#define GM_GCN_ADAPT_API extern "C" __declspec (dllexport)
#include "libusb.h"

// internal functions
libusb_device* find_adapter();

// exposed functions
// debug
GM_GCN_ADAPT_API const char *last_err_string();

// (de)init
GM_GCN_ADAPT_API double init_libusb(void);
GM_GCN_ADAPT_API double cleanup_libusb(void);

// attach/release
GM_GCN_ADAPT_API double attach_adapter(void);
GM_GCN_ADAPT_API double release_adapter(void);

// interact
GM_GCN_ADAPT_API double update_rumble(char* rumble_states);
GM_GCN_ADAPT_API double poll_adapter();
GM_GCN_ADAPT_API const char *get_frame();

// test commands to ensure the library actually exists
GM_GCN_ADAPT_API double just42(void);
GM_GCN_ADAPT_API double doubler(double d);

