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
JSEvent, JSEvents, JSAxisState
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

