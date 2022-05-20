# Joystick

Joystick driver for Julia, for now only on Linux.

## Installation
```julia
using Pkg
pkg"add https://github.com/ufechner7/Joystick.jl"
```

## Constants
```
JS_EVENT_BUTTON, JS_EVENT_AXIS, JS_EVENT_INIT
```

## Types
```
JSEvents, JSAxisState
```

## Functions

```julia
open_joystick(filename="/dev/input/js0")
read_event(js::JSDevice)
axis_state!(axes::JSAxisState, event::JSEvent)
```

## Example
```julia
using Joystick

jsd = open_joystick()
axis_count   = jsd.axis_count
button_count = jsd.button_count
println(axis_count, " ", button_count)
```

Examples for an example how to print all events:
```julia
using Joystick

jsdevice = open_joystick()
jsaxes   = JSAxisState()

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

