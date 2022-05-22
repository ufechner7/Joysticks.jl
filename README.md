# Joysticks

Joystick drivers for Julia, for now only on Linux. Contributions
for Windows and Mac welcome!

## Installation
```julia
using Pkg
pkg"add https://github.com/ufechner7/Joysticks.jl"
```

## Constants
```
JS_EVENT_BUTTON, JS_EVENT_AXIS, JS_EVENT_INIT
```

## Types
```
JSEvent, JSEvents, JSAxisState, JSButtonState, JSState
```

## Functions

```julia
open_joystick(filename="/dev/input/js0")
read_event(js::JSDevice)
axis_state!(axes::JSAxisState, event::JSEvent)
axis_state!(axes::JSState, event::JSEvent)
async_read_jsaxes!(js::JSDevice, jsaxes)
async_read_jsbuttons!(js::JSDevice, jsbuttons)
```

## Example
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

## High level interface for reading the axes
```julia
using Joysticks

const js       = open_joystick()
const jsaxes   = JSState()

async_read_jsaxes!(js, jsaxes)

while true
    println(jsaxes)
    sleep(0.05)
end
```
After you called the function `async_read_jsaxes!` the struct
jsaxes will be updated every milli-second and will automatically
reflect the state of the (max) 6 axis. 

The values are of type Float64 in the range of -1.00 to 1.00.

The members of the struct are x, y, z and u, v, w.

## High level interface reacting on button events
```julia
using Joysticks, Observables

const js        = open_joystick()
const jsbuttons = JSButtonState()

async_read_jsbuttons!(js, jsbuttons)

obs_func1 = on(jsbuttons.btn1) do val
    if val println("Button 1 pressed!") end
end
obs_func2 = on(jsbuttons.btn2) do val
    if ! val println("Button 2 released!") end
end
```
The struct jsbuttons contains 12 observables, one for each possible button. 
Using the function `on` can be used to bind an action to a change of the
button state. When pressed `val` is true, when release `val` is false.

The function `async_read_jsbuttons!` must be called once to start the
event loop for processing button events.

## Remark
The word `axes` is the plural of `axis`.