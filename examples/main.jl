using Joystick


jsdevice = open_joystick()

jsaxes = ntuple(i->JSAxisState(0,0), 3)

while (true)
    event = read_event(jsdevice)
    if ! isnothing(event) 
        if event.type == Int(JS_EVENT_BUTTON)
            println("Button ", event.number, " ", event.value != 0 ? "pressed" : "released")
        elseif event.type == Int(JS_EVENT_AXIS)
            axis, axes = axis_state(event, jsaxes)
            if axis < 3
                println("axis: ", axis)
                # println("Axis ", axes, " at (", axes[axis+1].x, ", ", axes[axis+1].y, ")")
            end
        end
    end
end
