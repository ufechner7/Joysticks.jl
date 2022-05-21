using Joysticks

const jsdevice = open_joystick()
const jsaxes   = JSAxisState()

try
    println("Press CTRL + C to terminate!")
    while true
        event = read_event(jsdevice)
        if ! isnothing(event)
            if event.type == Int(JS_EVENT_BUTTON)
                println("Button ", event.number, " ", event.value != 0 ? "pressed" : "released")
            elseif event.type == Int(JS_EVENT_AXIS)
                axis = axis_state!(jsaxes, event)
                if axis <= 6
                    println("axis: $axis, ", jsaxes)
                end
            end
        else
            sleep(0.01)
        end
    end
catch e
    if typeof(e) <: InterruptException
        println("Terminated program!")
    else
        rethrow()
    end
end


