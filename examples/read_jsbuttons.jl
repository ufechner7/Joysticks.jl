using Joysticks, Observables

const js        = open_joystick()
const jsbuttons = JSButtonState()

async_read_jsbuttons!(js, jsbuttons)

obs_func1 = on(jsbuttons.btn1) do val
    if val println("Button 1 pressed!") end
end
obs_func2 = on(jsbuttons.btn2) do val
    if val println("Button 2 pressed!") end
end

nothing