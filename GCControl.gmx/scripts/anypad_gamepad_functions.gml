#define anypad_gamepad_functions
// Anypad Gamepad Functions

// These functions (are intended to)
// map 1:1 to gamepad_* functions provided by GameMaker.

#define anypad_axis_value
// anypad_axis_value(device, axis)
// maps to gamepad_axis_value

var device = argument0;
var axis = argument1;

if (__anypad_range_native(device)) {
    return gamepad_axis_value(device, axis)
}
if (__anypad_range_gca(device)) {
    device -= global.__anypad_gca_offset;
    return gca_get_axis(device, anypad_map_gca_axis(axis));
}

#define anypad_axis_count
// anypad_axis_count(device)
// maps to gamepad_axis_count

var device = argument0;

if (__anypad_range_native(device)) {
    return gamepad_axis_count(device);
}
if (__anypad_range_gca(device)) {
    return 6;
}

#define anypad_button_check
// anypad_button_check(device, button)

// maps to gamepad_button_check

var device = argument0;
var button = argument1;

if (__anypad_range_native(device)) {
    gamepad_button_check(device, button);
}

if (__anypad_range_gca(device)) {
    var gindex = device - global.__anypad_gca_offset;
    return gca_get_button(gindex, anypad_map_gca_button(button));
}

#define anypad_button_check_pressed
// anypad_button_check_pressed(device, index)

// maps to gamepad_button_check_pressed

var device = argument0;
var button = argument1;

if (__anypad_range_native(device)) {
    gamepad_button_check_pressed(device, button);
}

if (__anypad_range_gca(device)) {
    var gindex = device - global.__anypad_gca_offset;
    return gca_get_pressed(gindex, anypad_map_gca_button(button));
}

#define anypad_button_check_released
// anypad_button_check_released(device, index)

// maps to gamepad_button_check_released

var device = argument0;
var button = argument1;

if (__anypad_range_native(device)) {
    gamepad_button_check_released(device, button);
}

if (__anypad_range_gca(device)) {
    var gindex = device - global.__anypad_gca_offset;
    return gca_get_released(gindex, anypad_map_gca_button(button));
}
