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
on(jsbuttons.btn3) do val
    if val println("Button 3 pressed!") end
end
on(jsbuttons.btn4) do val
    if val println("Button 4 pressed!") end
end
on(jsbuttons.btn5) do val
    if val println("Button 5 pressed!") end
end
on(jsbuttons.btn6) do val
    if val println("Button 6 pressed!") end
end

nothing