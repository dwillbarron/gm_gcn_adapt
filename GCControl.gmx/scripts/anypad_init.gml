#define anypad_init
// anypad_init()
// call this once on startup. don't call it again.
// calling it again will disappoint your parents.

// gcn adapter state
global.__anypad_enable_gca = false;
global.__anypad_gca_status = 0;
// gc controllers live in 12-15
global.__anypad_gca_offset = 12;

// native state
global.__anypad_enable_native_xinput = false;
global.__anypad_enable_native_dinput = false;

/*
    GC Adapter Initialization
*/
gca_init();

/*
    Enums and Constants
*/

// dualshock4 inputs in comments
// Nintendo controllers swap A/B, X/Y. Not sure what to do here.
enum anypad_btn {
    a, // cross
    b, // circle
    x, // square
    y, // triangle
    lb, // l1
    rb, // r1
    ls_click, // l3
    rs_click, // r3
    start, // options
    back, // share (on PC at least)
    dp_up,
    dp_right,
    dp_down,
    dp_left
}

enum anypad_axis {
    lx, // left analog x
    ly, // left analog y
    rx, // right analog x
    ry, // right analog y
    lt, // l2
    rt  // r2
}

// These define every set of glyphs (button images)
// that we might be expected to display.
// The library should ultimately be responsible for determining
// what class each controller falls in to.
enum anypad_glyph {
    XBOX_ONE, // similar but slightly different to 360 controller.
    XBOX_360, // start/back buttons, slightly different face buttons
    PAIRED_JOYCONS, // two joycons together (nintendo switch)
    SINGLE_JOYCON, // detached joycon (switch)
    SWITCH_PRO, // switch pro controller
    WIIU_PRO, // wii u pro controller
    PS4, // ps4 controller (has the touchpad)
    PS3, // ps3 controller (has the select button)
    GAMECUBE, // gamecube controller (via adapter support)
    STEAM, // valve's controller that looks like darth vader
    GENERIC // an unknown controller, probably some weird DInput thing.
}

// This enum is for every device type that this library can handle.
// I've tried to get these numbers to match up to what's used elsewhere
// in your code--let me know if there's any flaws
enum anypad_type {
    XINPUT,
    GC_VJOY,
    GC_MAYFLASH,
    PS4, // and other imilar controllers
    GC_64, // not v3
    GC_GAME, // what is this?
    GC_64_V3,
    SWITCH_PRO,
    GC_NATIVE,
    UNKNOWN
}

#define anypad_tick
// anypad_tick(): int result
// result = 0 for no error; nonzero indicates some error.

// Call this method once per frame; this updates the state of the GC adapter if enabled.

if (global.__anypad_enable_gca) {
    global.__anypad_gca_status = gca_begin_tick();
    // check if error, attempt reconnect
    if (global.__anypad_gca_status != 0) {
        gca_detach();
        global.__anypad_gca_status  = gca_attach();
    }
}

#define anypad_set_enable_native_xinput
// anypad_set_enable_native_xinput(bool): int result
// enable native controllers 0 - 3, which corresponds to 
// xinput devices on windows

global.__anypad_enable_native_xinput = argument0;

#define anypad_set_enable_native_dinput
// anypad_set_enable_native_dinput(bool): int result
// enable native controllers 4 - 11, which corresponds to 
// dinput devices on windows

global.__anypad_enable_native_dinput = argument0;

#define anypad_set_enable_gca
// anypad_set_enable_gcn(bool): int result
// Enable support for gamecube controllers
// controllers are placed at slots 12-15

// If the adapter becomes unplugged, you can
// try to reconnect by calling this again.

var enable = argument0;

global.__anypad_enable_gca = enable;


if (enable) {
    global.__anypad_gca_status = gca_attach();
    return global.__anypad_gca_status;
}
else {
    // has no effect if not attached (in theory)
    global.__anypad_gca_status = gca_detach();
}




#define anypad_detect_controller_type
// __anypad_detect_controller_type(index)
// attempts to detect the button layout of a controller
// based on its name.

var index = argument0;

var desc = anypad_get_description(index);

if (desc == "Gamecube Controller (Native)") {
    return anypad_type.GC_NATIVE;
}

if (argument0 == -1) return 0;
var controller_name = string_lower(gamepad_get_description(argument0));

//show_debug_message("Found Controller of type " + controller_name);

if (
    controller_name == "wireless controller"
    || string_count("fighting stick",controller_name) > 0
    || string_count("qanba joystick",controller_name) > 0
    || string_count("usb joystick",controller_name) > 0
    || string_count("usb vibration joystick",controller_name) > 0
    || string_count("logitech cordless rumblepad",controller_name) > 0
    || string_count("logitech dual",controller_name) > 0
    || string_count("dual box w",controller_name) > 0
    || string_count("playstation",controller_name) > 0
    || string_count("usb joypad",controller_name) > 0
    || string_count("4 axis",controller_name) > 0
    || string_count("virtual game controller",controller_name) > 0
    || string_count("wiiu pro",controller_name) > 0 // This maybe should move
    || string_count("fighting commander",controller_name) > 0
    || string_count("cerberus",controller_name) > 0
    || string_count("real arcade pro",controller_name) > 0
    )
    return anypad_type.PS4;

else if (string_count("vjoy",controller_name) > 0)
    return anypad_type.GC_VJOY;

else if (string_count("no such device",controller_name) > 0){
    global.disconnected_wiiu_cont[argument0] = true;
    return anypad_type.GC_VJOY;
}
else if (
    string_count("may",controller_name) > 0
    || (string_count("usb gamepad",controller_name) > 0 && string_count("xusb",controller_name) <= 0)
    || string_count("gamecube",controller_name) > 0
    || string_count("6 axis 16 button",controller_name) > 0
    || string_count("hyperkin",controller_name) > 0
    || string_count("shinewave",controller_name) > 0
)
{
    return anypad_type.GC_MAYFLASH;
}
else if (string_count("gc/n64",controller_name) > 0){
    if (string_count("v3.",controller_name) > 0)
        return anypad_type.GC_64_V3;
    else
        return anypad_type.GC_64;
}
else if (string_count("gc game",controller_name) > 0){
    return anypad_type.GC_GAME;
}
else if (string_count("pro controller",controller_name) > 0){
    return anypad_type.SWITCH_PRO;
}
else { //default to unknown
    return anypad_type.UNKNOWN;
}

#define anypad_is_connected
// anypad_is_connected(index)
// returns true if a device is present at this index

var index = argument0;

// native range
if (index >= 0 && index <= 11) {
    if (global.__anypad_enable_native_xinput && index <= 3) {
        return gamepad_is_connected(index);
    }
    else if (global.__anypad_enable_native_dinput && index >= 4) {
        return gamepad_is_connected(index);
    }
}

// gca range
if (index >= 12 && index <= 15) {
    if (global.__anypad_enable_gca && 
        global.__anypad_gca_status >= 0) 
    {
        return gca_controller_present(index - 12);
    }
    else {
        return false;
    }
}

// no conditions met; index probably out of bounds
return false;

#define anypad_get_description
// anypad_get_description(index)

var index = argument0;

if (index >= 0 && index <= 11) {
    return gamepad_get_description(index);
}
if (index >= 12 && index <= 15) {
    return "Gamecube Controller (Native)";
}

return ""
#define __anypad_range_native
// __anypad_range_native(index)
// internal usage only
// for convenience if GM's numbers change (i.e. different platforms)

return (argument0 >= 0 && argument0 <= 11)

#define __anypad_range_gca
// __anypad_range_gca(index)
// internal use only

return (argument0 >= 12 && argument0 <= 15)