// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the GM_GCN_ADAPT_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// GM_GCN_ADAPT_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.

// note that I changed the definition here--only way I could get it to work on GM.

#ifdef GM_GCN_ADAPT_EXPORTS
#define GM_GCN_ADAPT_API extern "C" __declspec (dllexport)
#else
#define GM_GCN_ADAPT_API __declspec(dllimport)
#endif
#pragma once
#include "libusb.h"

// internal functions
libusb_device* find_adapter();

// exposed functions
GM_GCN_ADAPT_API const char* init_adapter(void);
GM_GCN_ADAPT_API char* release_adapter(void);
GM_GCN_ADAPT_API char* update_rumble(char* rumble_states);
GM_GCN_ADAPT_API const char* read_adapter();

// test commands to ensure the library actually exists
GM_GCN_ADAPT_API double just42(void);
GM_GCN_ADAPT_API double doubler(double d);

