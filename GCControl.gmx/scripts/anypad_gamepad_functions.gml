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

#define script3
// anypad_axis_count(device)
// maps to gamepad_axis_count

var device = argument0;

if (__anypad_range_native(device)) {
    return gamepad_axis_count(device);
}
if (__anypad_range_gca(device)) {
    return 6;
}
