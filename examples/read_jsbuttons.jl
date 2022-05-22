using Joysticks, Observables

const js        = open_joystick()
const jsbuttons = JSButtonState()

async_read!(js, nothing, jsbuttons)

on(jsbuttons.btn1) do val
    if val println("Button 1 pressed!") end
end
on(jsbuttons.btn2) do val
    if val println("Button 2 pressed!") end
end

nothing