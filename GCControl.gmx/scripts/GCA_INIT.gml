#define gca_init
///gca_init()
// Returns: (real) (see below)
// Call this once to initialize the internal state of the library.
// Return Values:
// 0: success
// 1: already initialized

// Exit if init function has already been run
// (documentation calls this function obsolete but it still works.
// let me know if there's any other way to accomplish this behavior.)
if (variable_global_exists("__gca_initialized")) return 1;
global.__gca_initialized = 1;

// ================
//     Settings 
// ================
// Feel free to change variables here to suit your preferences.
// However, change them during runtime at your own peril.
// Nothing *should* break, but I'm not testing that.

// Whether to automatically detach from the adapter on an error.
// You will still need to reattach manually.
global.__gca_detach_on_error = true;

// If you would rather the first controller start at index 1,
// set this to 1 instead of 0.
global.__gca_one_indexed = 0;

// set to true at your own risk.
// can cause the adapter to fail if too many rumbles active
global.__gca_force_enable_rumble = true;

// time (in microseconds) until the controller is calibrated.
// At least one frame's time is needed to avoid miscalibration
// as the adapter will report all zeroes for its first frame.

// Longer time intervals allow capacitor-modded controllers
// to level out before centering. Users might prematurely
// push the sticks though.

// Default: 0 microseconds. Increase it if users complain.
global.__gca_calibration_time = 0;

// ================
//   End Settings
// ================
// ================
//    Constants
// ================

// The first byte of the controller data is some status info.
// From here, we have the device type and whether rumble is
// available. (note that it can be used anyway).
// TODO: Bongos might be something different.
enum gca_status {
    rumble = 4,
    wired = 16,
    wavebird = 32 // from some old notes; I can't test this currently.
}

enum gca_btn {
    a,
    b,
    x,
    y,
    l_digital,
    r_digital,
    z,
    start,
    dp_up,
    dp_right,
    dp_down,
    dp_left
}

enum gca_axis {
    lstick_x,
    lstick_y,
    cstick_x,
    cstick_y,
    l_analog,
    r_analog
}

enum gca_cal {
    NONE,
    WAIT,
    DONE
}


// Bitmasks for each button
global.__gca_bits[12] = 0; // preallocate some space
// TODO: Fill out bitmasks
global.__gca_bits[gca_btn.a] = 1;
global.__gca_bits[gca_btn.b] = 2;
global.__gca_bits[gca_btn.x] = 4;
global.__gca_bits[gca_btn.y] = 8;
global.__gca_bits[gca_btn.l_digital] = 2048;
global.__gca_bits[gca_btn.r_digital] = 1024;
global.__gca_bits[gca_btn.z] = 512;
global.__gca_bits[gca_btn.start] = 256;
global.__gca_bits[gca_btn.dp_up] = 128;
global.__gca_bits[gca_btn.dp_right] = 32;
global.__gca_bits[gca_btn.dp_left] = 16;
global.__gca_bits[gca_btn.dp_down] = 64;


// ================
//   End Constants
// ================

// ================
//       Init
// ================
// Initialize Internal State

global.__gca_last_frame = "";
var i;
for (i = 3; i >= 0; i--) {
    var controller;
    controller = ds_map_create();
    global.__gca_controllers[i] = controller;

    controller[? 'buttons_prev'] = 0;
    controller[? 'buttons'] = 0;
    controller[? 'rumble_state'] = false;
    controller[? 'device_status'] = 0;
    controller[? 'device_status_prev'] = 0; //to detect plug/unplug
    
    // Calibration states:
    controller[? 'calibration_state'] = 93;
    controller[? 'calibration_time'] = 0;
    // gml can't handle nested accessors. ugh.
    var j, axes, centers;
    for (j = 5; j >= 0; j--) {
        axes[j] = 0;
        centers[j] = 0;
    }
    controller[? 'axis'] = axes;
    controller[? 'axis_center'] = centers;
}



return 0;

#define gca_attach
///gca_attach()
// Returns: (real) see below

// Find the first connected gamecube adapter and connect to it.
// Needs to be called before using the adapter.

// Return Values:
// 1: Alreaady Attached
// 0: Success, now attached
// -1: not found (or in use by another process)
// -2: failed to open (likely that user needs to use zadig to install winusb driver)
// -3: interface in use [very rare]
// -99: unknown error
var result;

result = GM_GCN_ADAPT_Attach();

return result;

#define gca_detach
///gca_detach()
// Returns: 0

// Detach from a currently connected gamecube adapter.

var result;

result = GM_GCN_ADAPT_Release();

return result;

#define gca_begin_tick
///gca_begin_tick()
// Returns: (real) 0 for success, negative for any errors
// Call once per frame before using the controllers.
// Polls the adapter for updated input information.
// You may wish to wait as late as possible before calling this.

// Note: Errors indicate the adapter couldn't be read from.
// (i.e. the adapter has probably come unplugged).

// To recover from an error, call gca_detach
// before calling gca_attach again.

var result, raw_frame, frame;

// ================================
// Poll for frame and handle errors
// ================================

result = GM_GCN_ADAPT_Poll();

if (result < 0) {
    if (global.__gca_detach_on_error) {
        gca_detach();
    }
    // return early, don't attempt to process
    return result;
}
raw_frame = GM_GCN_ADAPT_Get_Frame();
global.__gca_last_frame = raw_frame;

// ================
// Preprocess frame
// ================

// process frame into several 8-byte ints
// there are 37 bytes in the message:
// byte 0 is some status or ID I don't care about...
// then 9 bytes for each controller.
var i;
for (i = 36; i >= 0; i--) {
    // each byte is encoded as a 3 digit (zero padded) decimal
    // by the dll. not efficient, but convenient to process.
    var substr = string_copy(raw_frame, i*3 + 1, 3);
    frame[i] = real(substr);
}

// ===============================
// Update state of all controllers
// ===============================

var i;
for (i = 0; i < 4; i++) {
    var controller, axes, centers, new_buttons;
    controller = global.__gca_controllers[i];
    // formula for alignment of frame addresses:
    // 1 + (i * 9) + (byte of controller data)
    
    // manually create otherwise only one array is created for all 4 controllers
    axes = array_create(6);
    axes[gca_axis.r_analog] = frame[1 + (i * 9) + 8];
    axes[gca_axis.l_analog] = frame[1 + (i * 9) + 7];
    axes[gca_axis.cstick_y] = frame[1 + (i * 9) + 6];
    axes[gca_axis.cstick_x] = frame[1 + (i * 9) + 5];
    axes[gca_axis.lstick_y] = frame[1 + (i * 9) + 4];
    axes[gca_axis.lstick_x] = frame[1 + (i * 9) + 3];
    
    // Is a controller plugged in here at all?
    if (!__gca_present_internal(i, false)) {
        // Reset the calibration state.
        controller[? 'calibration_state'] = gca_cal.NONE;
        controller[? 'calibration_time'] = 0;
    }
    
    // has the controller just been plugged in?
    // (x+y+start makes controller appear unplugged)
    // (checks !prev, then current state)
    if (!__gca_present_internal(i, true) && // check previous state
        __gca_present_internal(i, false))   // check current state
    { 
        // Begin calibration process
        
        controller[? 'calibration_state'] = gca_cal.WAIT;
        controller[? 'calibration_time'] = 0;
    }
    
    // Calibration currently in progress?
    if (controller[? 'calibration_state'] == gca_cal.WAIT) {
        // Are we done?
    
        if (controller[? 'calibration_time'] >= global.__gca_calibration_time) {
            centers = array_create(6);
            // triggers need special treatment since they're centered around 0 of 255
            centers[gca_axis.r_analog] = (-axes[gca_axis.r_analog] / 2) - 128;
            centers[gca_axis.l_analog] = (-axes[gca_axis.l_analog] / 2) - 128;
            centers[gca_axis.lstick_x] = -axes[gca_axis.lstick_x];
            centers[gca_axis.lstick_y] = -axes[gca_axis.lstick_y];
            centers[gca_axis.cstick_x] = -axes[gca_axis.cstick_x];
            centers[gca_axis.cstick_y] = -axes[gca_axis.cstick_y];
            controller[? 'axis_center'] = centers;
            controller[? 'calibration_state'] = gca_cal.DONE;
        }
        else {
            controller[? 'calibration_time'] += delta_time;
        }
    }
    
    // do the buttons in little endian order.
    // doesn't matter as long as I'm consistent
    new_buttons = frame[1 + (i * 9) + 2] * 256;
    new_buttons += frame[1 + (i * 9) + 1];
    
    controller[? 'axis'] = axes;
    controller[? 'device_status_prev'] = controller[? 'device_status'];
    controller[? 'device_status'] = frame[1 + (i * 9) + 0];
    
    
    
    controller[? 'buttons_prev'] = controller[? 'buttons'];
    controller[? 'buttons'] = new_buttons;
}


return result;

#define gca_end_tick
///gca_end_tick()
// Returns: (real) 0 for success, negative for any errors
// Call once at the end of each frame.
// Pushes updated rumble commands to each controller.

var result, rumble_str, controller;
var i;
rumble_str = "";
for (i = 0; i < 4; i++) {
    var num_str, state;
    controller = global.__gca_controllers[i];
    state = controller[? 'rumble_state'];
    if ((controller[? 'device_status'] & gca_status.rumble) == 0) {
        state = false;
    }
    num_str = string(state);
    rumble_str = string_insert(rumble_str, num_str, 0);
}

result = GM_GCN_ADAPT_Send_Rumble(rumble_str);
return result;

#define gca_set_rumble
///gca_set_rumble(device, state)
// device: (real) index of controller to change rumble state
// state: (boolean) true to rumble, false to stop
// Returns (real) 0 for success, negative value for any errors

// As far as I am aware, the adapter only supports
// binary rumble states. If you want more sensitivity,
// you will need to manually PWM it. A future update
// could do this on a separate thread with better precision.

var device, state, controller;
device = argument0 - global.__gca_one_indexed;
state = argument1;
if (!gca_rumble_available(argument0)) {
    state = false;
}
controller = global.__gca_controllers[device];
controller[? 'rumble_state'] = state;

#define gca_controller_present
///gca_controller_present(device)
// device: index of controller
// Returns: (boolean) true if controller plugged in, false otherwise.

// Keep in mind controllers are enumerated by the physical port they are
// plugged in to--therefore, absence of a controller in a lower port
// does not imply absence of all controllers in higher ports.

var device, controller;
device = argument0 - global.__gca_one_indexed;

controller = global.__gca_controllers[device];

return (controller[? 'device_status'] & gca_status.wired) != 0;

#define gca_get_button
///gca_button(device, button)
// device: (real) index of controller
// button: index of button or dpad direction, see below
// returns: (boolean) true if pressed, false if unpressed

// note: also returns 0 if controller is unplugged. To avoid
// confusion, please check if the controller is present first.

var device, controller, buttons, button;
device = argument0 - global.__gca_one_indexed;
button = argument1;
controller = global.__gca_controllers[device];
buttons = controller[? 'buttons'];

return (buttons & global.__gca_bits[button]) != 0;

#define gca_get_pressed
///gca_get_pressed(device, button)
// device: (real) index of controller
// button: index of button or dpad direction, see gca_button
// returns: (boolean) true if just pressed, else false.

// Check whether a button has just been pressed this tick.

var device, controller, button, buttons, buttons_prev;
device = argument0 - global.__gca_one_indexed;
controller = global.__gca_controllers[device];
buttons = controller[? 'buttons'];
buttons_prev = controller[? 'buttons_prev'];

button = argument1;
return (buttons & global.__gca_bits[button] != 0) && (buttons_prev & global.__gca_bits[button] == 0);

#define gca_get_released
///gca_get_released(device, button)
// device: (real) index of controller
// button: index of button or dpad direction, see gca_button
// returns: (boolean) true if just pressed, else false.

// Check whether a button has just been released this tick.

var device, controller, button, buttons, buttons_prev;
device = argument0 - global.__gca_one_indexed;
controller = global.__gca_controllers[device];
buttons = controller[? 'buttons'];
buttons_prev = controller[? 'buttons_prev'];

button = argument1;
return (buttons & global.__gca_bits[button] == 0) && (buttons_prev & global.__gca_bits[button] != 0);

#define gca_get_axis
///gca_get_axis(device, axis_index): real
// device: (real) index of controller
// axis_index: (real) index of axis (see below)
// Returns: (real) from -1 to 1

var device = argument0 - global.__gca_one_indexed;
var axis_index = argument1;
var controller = global.__gca_controllers[device];

if (controller[? 'calibration_state'] != gca_cal.DONE) {
    // the controller hasn't been calibrated yet.
    return 0;
}

var axes = controller[? 'axis'];
var centers = controller[? 'axis_center'];
var adjusted = axes[axis_index] + centers[axis_index];
var scaled = adjusted / 128;

return clamp(scaled, -1, 1);

#define gca_rumble_available
///gca_rumble_available(device)

// Check whether the given controller has sufficient power for rumble
// (This generally applies to all controllers at once, and
// is generally related to whether the grey plug is plugged in).

// Check out __gca_force_enable_rumble if you want to ignore
// this for some reason.

var device, controller;
device = argument0 - global.__gca_one_indexed;
controller = global.__gca_controllers[device];

return (controller[? 'device_status'] & gca_status.rumble != 0)

#define __gca_present_internal
///__gca_present_internal(index, prev)
// For internal use only (always zero indexed)
// Need to detect the presence of a controller?
// You might be looking for gca_controller_present.

var device = argument0;
var controller = global.__gca_controllers[device];
var prev = argument1;
var status;
if (prev == true) {
    status = controller[? 'device_status_prev'];
}
else {
    status = controller[? 'device_status'];
}
show_debug_message(((status & gca_status.wired) || (status & gca_status.wavebird)));
return ((status & gca_status.wired) || (status & gca_status.wavebird));
