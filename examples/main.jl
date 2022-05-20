using Joystick


jsdevice = open_joystick()

axes = Joystick.JSAxis()

while (true)
    event = read_event(jsdevice)
    isnothing(event) || break
    if event.type == Int(JS_EVENT_BUTTON)
        println("Button ", event.number, " ", event.value != 0 ? "pressed" : "released")
    elseif event.type == Int(JS_EVENT_AXIS)
        axis, axes = axis_state(event, axes)
        if axis < 3
            println("Axis ", axis, " at (", axes[axis].x, ", ", axes[axis].y, ")")
        end
    end
end
