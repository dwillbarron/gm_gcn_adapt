#define anypad_init
// anypad_init()
// call this once on startup.
// calling it again will disappoint your parents.

/*
    Initialization
*/
// initialize slots for 4 controllers (make configurable?)
global.__anypad_controllers = array_create(4);

// gcn adapter state
global.__anypad_enable_gcn = false;
global.__anypad_gca_status = 0;

// native state
global.__anypad_enable_native_xinput = false;
global.__anypad_enable_native_dinput = false;

/*
    Enums and Constants
*/

// dualshock4 inputs in comments
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
    back, // share on pc
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

// Form factor is a bit misleading--this classifies any controllers
// with significant divergence in featureset.

// Used internally to handle behaviors, can be used to determine default
// controls as well.
enum anypad_form_factors {
    STANDARD, // xbox, ps4, and similar
    STANDARD_DIGITAL_TRIGGERS, // wii u and switch controllers (why'd nintendo do this?)
    GAMECUBE,
    STEAM, // Only matters if we use the Steam Controller API; otherwise it's just STANDARD.
    DETACHED_JOYCON // Assuming you port to Switch somebody's bound to try this.
};

#define anypad_tick
// anypad_tick(): int result
// result = 0 for no error; nonzero indicates some error.

// Call this method once per frame; this updates the state of the GC adapter if enabled.

// TODO: GCA update state

// TODO: GCA recover from error/unplugged

#define anypad_set_enable_gcn
// anypad_set_enable_gcn(bool): int result
// Enable support for gamecube controllers

global.__anypad_enable_gcn = argument0;

#define anypad_set_enable_native_xinput
// anypad_set_enable_native_xinput(bool): int result
// enable native controllers 0 - 3, which corresponds to xinput devices

global.__anypad_enable_native_xinput = argument0;

#define anypad_set_enable_native_dinput
// anypad_set_enable_native_dinput(bool): int result
// enable native controllers 4 - 11, which corresponds to dinput devices

global.__anypad_enable_native_dinput = argument0;

#define anypad_get_controller_id
// anypad_get_controller_controller_id(slot: real)
// get the ID of the controller in a given slot

var slot = argument0;



#define __anypad_is_native
// __anypad_is_native(slot: real): boolean
// returns true if controller in given slot is accessed through GM's native APIs.

var slot = argument0;

#define __anypad_is_native_by_id
// __anypad_is_native_by_controller_id(controller_id: str): boolean
// returns true if the controller at ID is accessed through GM's native APIs.

var controller_controller_id = argument0;

#define __anypad_detect_glyph_set
// __anypad_detect_glyph_set(controller_id: str)
// for internal use only.
// given a controller ID, detect the glyph set

#define __anypad_split_id
// __anypad_split_controller_id(controller_id: str) -> [type, index]
// for internal usage
// splits an controller_id into its interface controller_identifier and the device index.

// anypad IDs are in the format "Str,Int" where Str controller_identifies the
// interface and the int controller_identifies the index on that interface.
// I don't suggest you manually make IDs, but it might be useful for debugging.

var controller_id = argument0;

// note that GM one-indexes strings (gross).
var commaIndex = 0;
var leftString = "";
var rightString = "";

commaIndex = string_pos(",", controller_id);
// 0 indicates no comma found
if (commaIndex == 0) {
    show_error(string_insert("ID provcontroller_ided has no comma: ", controller_id, 0), true);
}
if (commaIndex == 1) {
    show_error("left scontroller_ide of ID is empty!", true);
}

leftString = string_copy(controller_id, 1, commaIndex - 1);
rightString = string_copy(controller_id, commaIndex + 1, string_length(controller_id) - (commaIndex));

var returnArray = array_create(2);
returnArray[0] = leftString;
returnArray[1] = rightString;
return returnArray;