#define anypad_internal_functions
// Anypad Internal Functions

// Hopefully you shouldn't need to see these.

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
    return gamepad_is_connected(index);
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
#define anypad_gca_map_axis
///anypad_map_gca_axis(axis)
// map GM axis to GCA axis

var axis = argument0;

if (axis == gp_axislh)
    return gca_axis.lstick_x;
if (axis == gp_axislv)
    return gca_axis.lstick_y;
if (axis == gp_axisrh)
    return gca_axis.cstick_x;
if (axis == gp_axisrv)
    return gca_axis.cstick_y;
if (axis == gp_shoulderlb)
    return gca_axis.l_analog;
if (axis == gp_shoulderrb)
    return gca_axis.r_analog;
    
return -1;

#define anypad_gca_map_button
///anypad_gca_map_button(button)
// map GM button to GCA button.

var button = argument0;

if (button == gp_face1)
    return gca_btn.a;
if (button == gp_face2)
    return gca_btn.b;
if (button == gp_face3)
    return gca_btn.x;
if (button == gp_face4)
    return gca_btn.y;
if (button == gp_shoulderr)
    return gca_btn.z;
if (button == start)
    return gca_btn.start;
if (button == gp_padu)
    return gca_btn.dp_up;
if (button == gp_padr)
    return gca_btn.dp_right;
if (button == gp_padd)
    return gca_btn.dp_down;
if (button == gp_padl)
    return gca_btn.dp_left;
    
// polling analog triggers as digital inputs returns the digital
// press rather than applying a threshold to the analog input
// presumably this is desirable, also 2x easier to implement

if (button == gp_shoulderrb)
    return gca_btn.r_digital;
if (button == gp_shoulderlb)
    return gca_btn.l_digital;
    
return -1; //button provided has no mapping; need to handle as special case