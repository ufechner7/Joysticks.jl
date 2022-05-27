# Joysticks

Joystick drivers for Julia, tested on Linux and Windows, should also work on Mac.

## Installation
```julia
using Pkg
pkg"add https://github.com/ufechner7/Joysticks.jl"
```

## High level interface for reading the axes
```julia
using Joysticks

const js       = open_joystick()
const jsaxes   = JSState()

async_read!(js, jsaxes)

while true
    println(jsaxes)
    sleep(0.05)
end
```
After you called the function `async_read!` the struct
jsaxes will be updated every few milli-seconds and will automatically
reflect the state of the (max) 6 axis. 

The values are of type Float64 in the range of -1.00 to 1.00.

The members of the struct are x, y, z and u, v, w.

## High level interface reacting on button events
```julia
using Joysticks, Observables

const js        = open_joystick()
const jsbuttons = JSButtonState()

async_read!(js, nothing, jsbuttons)

on(jsbuttons.btn1) do val
    if val println("Button 1 pressed!") end
end
on(jsbuttons.btn2) do val
    if ! val println("Button 2 released!") end
end
```
The struct jsbuttons contains 12 observables, one for each possible button. 
Using the function `on` can be used to bind an action to a change of the
button state. When pressed `val` is true, when released `val` is false.

The function `async_read!` must be called once to start the
event loop for processing button events.

## Reading both axes and buttons
```julia
using Joysticks, Observables

const js        = open_joystick()
const jsaxes    = JSState()
const jsbuttons = JSButtonState()

async_read!(js, jsaxes, jsbuttons)
```
The function `async_read!` must be called once to start the
event loop for processing button events. 

You can then access the axes values and assign events to buttons as in the examples above.

## Using the second Joystick
### Windows and Mac
```julia
using Joysticks, Observables
const js        = open_joystick("", JOYSTICK_2)
```
The counting starts at one.

### Linux
```julia
using Joysticks, Observables
const js        = open_joystick("/dev/input/js1")
```
The counting starts at zero.

## Reference
### Constants
```julia
JS_EVENT_BUTTON, JS_EVENT_AXIS, JS_EVENT_INIT
```

### Types
```julia
JSEvent, JSEvents, JSAxisState, JSButtonState, JSState
```

### Functions

```julia
open_joystick(filename = "/dev/input/js0", device=JOYSTICK_1; glfw=false)
read_event(js::JSDevice)
axis_state!(axes::JSAxisState, event::JSEvent)
axis_state!(axes::JSState, event::JSEvent)
async_read!(js::JSDevice, jsaxes=nothing, jsbuttons=nothing)
```

## Example of using the low-level interface (Linux only)
```julia
using Joystick

jsd = open_joystick()
axis_count   = jsd.axis_count
button_count = jsd.button_count
println(axis_count, " ", button_count)
```

Example for printing all events:
```julia
using Joystick

const jsdevice = open_joystick()
const jsaxes   = JSAxisState()

while (true)
    event = read_event(jsdevice)
    if ! isnothing(event) 
        if event.type == Int(JS_EVENT_BUTTON)
            println("Button ", event.number, " ", event.value != 0 ? "pressed" : "released")
        elseif event.type == Int(JS_EVENT_AXIS)
            axis = axis_state!(jsaxes, event)
            if axis <= 6
                println("axis: ", axis)
                println(jsaxes)
            end
        end
    end
    sleep(0.001)
end
```

## Remark
The word `axes` is the plural of `axis`.