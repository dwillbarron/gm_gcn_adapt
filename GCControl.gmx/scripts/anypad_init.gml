#define anypad_init
// anypad_init()
// call this once on startup. don't call it again.
// calling it again will disappoint your parents.

// gcn adapter state
global.__anypad_enable_gca = false;
global.__anypad_gca_status = 0;

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
enum anypad_glyph_sets {
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




#define anypad_detect_glyph_set
// __anypad_detect_glyph_set(index)
// attempts to detect the most likely glyph set of a controller
// given its device description

var index = argument0;

var desc = anypad_get_description(index);

if (desc = "Gamecube Controller (Native)") {
    return anypad_glyph_sets.GAMECUBE;
}
// TODO: controller detection logic goes here
else {
    return anypad_glyph_sets.XBOX_360;
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
