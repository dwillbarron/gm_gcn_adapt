#define anypad_config_functions
// Anypad Config Functions

// These functions alter the internal state of Anypad
// and should be called with care.


#define anypad_init
// anypad_init()
// call this once on startup. don't call it again.
// calling it again will disappoint your parents.

// gcn adapter state
global.__anypad_enable_gca = false;
global.__anypad_gca_status = 0;
// gc controllers live in 12-15
global.__anypad_gca_offset = 12;

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

#define anypad_set_enable_gca
// anypad_set_enable_gca(bool): int result
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