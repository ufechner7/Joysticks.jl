#= MIT License

Copyright (c) 2022 Uwe Fechner, José Joaquín Zubieta Rico

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. =#

module Joysticks

using Observables, Reexport, LinearAlgebra

export JSEvents, JSEvent, JSAxisState, JSButtonState, JSState # types
export JS_EVENT_BUTTON, JS_EVENT_AXIS, JS_EVENT_INIT          # constants
export open_joystick, read_event, axis_state!                 # functions
export async_read!                                            # high level interface
@reexport using GLFW: JOYSTICK_1, JOYSTICK_2, JOYSTICK_3
import GLFW

const JSIOCGAXES    = UInt(2147576337)
const JSIOCGBUTTONS = UInt(2147576338)
const O_RDONLY = 0
const O_NONBLOCK = 2048
const MAX_VALUE = 32767

@enum JSEvents begin
    JS_EVENT_BUTTON = 0x1
    JS_EVENT_AXIS   = 0x02
    JS_EVENT_INIT   = 0x80
end

mutable struct JSDevice
    filename::String
    device::GLFW.Joystick
    fd::Int32
    axis_count::Int32
    button_count::Int32
end

struct JSEvent
    time::UInt32
    value::Int16
    type::UInt8
    number::UInt8
end

mutable struct JSAxisState
    x::Int16
    y::Int16
    z::Int16
    u::Int16
    v::Int16
    w::Int16
end
function JSAxisState()
    JSAxisState(0, 0, 0, 0, 0, 0)
end

mutable struct JSState
    x::Float64
    y::Float64
    z::Float64
    u::Float64
    v::Float64
    w::Float64
end
function JSState()
    JSState(0, 0, 0, 0, 0, 0)
end
function set_state!(state::JSState, axes)
    i = 1
    for axis in axes
        ax = dead_zone(axis)
        if i == 1
            state.x = ax
        elseif i == 2
            state.y = ax
        elseif i == 3
            state.z = ax
        elseif i == 4
            state.u = ax
        elseif i == 5
            state.v = ax
        elseif i == 6
            state.w = ax
        end
        i+=1
        if i > 6 break end
    end
end

function dead_zone(axis, deadzone=0.07)
    if norm(axis) < deadzone
        return zero(axis)
    elseif axis > 0
        return (axis - deadzone)/(1-deadzone)
    else
        return (axis + deadzone)/(1-deadzone)
    end
end

mutable struct JSButtonState
    btn1::Observable{Bool}
    btn2::Observable{Bool}
    btn3::Observable{Bool}
    btn4::Observable{Bool}
    btn5::Observable{Bool}
    btn6::Observable{Bool}
    btn7::Observable{Bool}
    btn8::Observable{Bool}
    btn9::Observable{Bool}
    btn10::Observable{Bool}
    btn11::Observable{Bool}
    btn12::Observable{Bool}
end
function JSButtonState()
    JSButtonState(false, false, false, false, false, false, false, false, false, false, false, false)
end

# read all axis of the joystick and update jsaxis
function async_read!(js::JSDevice, jsaxes=nothing, jsbuttons=nothing)
    @async while true
        if js.filename != ""
            event = read_event(js)
            if ! isnothing(event)
                if ! isnothing(jsaxes)
                    if event.type == Int(JS_EVENT_AXIS)
                        axis_state!(jsaxes, event)
                    end
                end
                if ! isnothing(jsbuttons)
                    if event.type == Int(JS_EVENT_BUTTON)
                        if event.number == 0
                            jsbuttons.btn1[] = event.value != 0
                        elseif event.number == 1
                            jsbuttons.btn2[] = event.value != 0
                        elseif event.number == 2
                            jsbuttons.btn3[] = event.value != 0
                        elseif event.number == 3
                            jsbuttons.btn4[] = event.value != 0
                        elseif event.number == 4
                            jsbuttons.btn5[] = event.value != 0
                        elseif event.number == 5
                            jsbuttons.btn6[] = event.value != 0
                        elseif event.number == 6
                            jsbuttons.btn7[] = event.value != 0
                        elseif event.number == 7
                            jsbuttons.btn8[] = event.value != 0
                        elseif event.number == 8
                            jsbuttons.btn9[] = event.value != 0
                        elseif event.number == 9
                            jsbuttons.btn10[] = event.value != 0
                        elseif event.number == 10
                            jsbuttons.btn11[] = event.value != 0
                        else event.number ==11
                            jsbuttons.btn12[] = event.value != 0
                        end
                    end
                end
            else
                sleep(0.005)
            end
        else
            if ! isnothing(jsaxes)
                axes = GLFW.GetJoystickAxes(js.device)
                set_state!(jsaxes, axes)
            end
            if ! isnothing(jsbuttons)
                buttons = GLFW.GetJoystickButtons(js.device)
                if js.button_count >= 1  
                    if jsbuttons.btn1[] != (buttons[1]  != 0)
                        jsbuttons.btn1[] = (buttons[1]  != 0)
                    end
                end
                if js.button_count >= 2  
                    if jsbuttons.btn2[] != (buttons[2]  != 0)
                        jsbuttons.btn2[] = (buttons[2]  != 0)
                    end
                end
                if js.button_count >= 3  
                    if jsbuttons.btn3[] != (buttons[3]  != 0)
                        jsbuttons.btn3[] = (buttons[3]  != 0)
                    end
                end
                if js.button_count >= 4  
                    if jsbuttons.btn4[] != (buttons[4]  != 0)
                        jsbuttons.btn4[] = (buttons[4]  != 0)
                    end
                end
                if js.button_count >= 5  
                    if jsbuttons.btn5[] != (buttons[5]  != 0)
                        jsbuttons.btn5[] = (buttons[5]  != 0)
                    end
                end
                if js.button_count >= 6  
                    if jsbuttons.btn6[] != (buttons[6]  != 0)
                        jsbuttons.btn6[] = (buttons[6]  != 0)
                    end
                end
                if js.button_count >= 7  
                    if jsbuttons.btn7[] != (buttons[7]  != 0)
                        jsbuttons.btn7[] = (buttons[7]  != 0)
                    end
                end
                if js.button_count >= 8  
                    if jsbuttons.btn8[] != (buttons[8]  != 0)
                        jsbuttons.btn8[] = (buttons[8]  != 0)
                    end
                end
                if js.button_count >= 9  
                    if jsbuttons.btn9[] != (buttons[9]  != 0)
                        jsbuttons.btn9[] = (buttons[9]  != 0)
                    end
                end
                if js.button_count >= 10  
                    if jsbuttons.btn10[] != (buttons[10]  != 0)
                        jsbuttons.btn10[] = (buttons[10]  != 0)
                    end
                end
                if js.button_count >= 11 
                    if jsbuttons.btn11[] != (buttons[11]  != 0)
                        jsbuttons.btn11[] = (buttons[11]  != 0)
                    end
                end
                if js.button_count >= 12 
                    if jsbuttons.btn12[] != (buttons[12]  != 0)
                        jsbuttons.btn12[] = (buttons[12]  != 0)
                    end
                end
            end
            sleep(0.01)
        end
    end
end

function open_joystick(filename = "/dev/input/js0", device=JOYSTICK_1; glfw=false)
    if  Sys.islinux() && ! glfw
        if ispath(filename)
            jfd = ccall(:open, Cint, (Cstring, Cint), filename, O_RDONLY|O_NONBLOCK)
            js = JSDevice(filename, device, jfd, 0, 0)
            js.axis_count = axis_count(js)
            js.button_count = button_count(js)
            return js
        else
            println("ERROR: The device $filename does not exist!")
            return nothing
        end
    else
        if GLFW.JoystickPresent(device)
            js = JSDevice("", device, 0, 0, 0)
            js.filename=""
            js.axis_count = length(GLFW.GetJoystickAxes(device))
            js.button_count = length(GLFW.GetJoystickButtons(device))
            return js
        else
            println("ERROR: The device $device is not present!")
            return nothing
        end
    end
end

function axis_count(js::JSDevice)
    if js.filename != ""
        axes = Ref{UInt8}()
        if @ccall(ioctl(js.fd::Cint, JSIOCGAXES::Culong; axes::Ref{UInt8})::Cint) == -1
            return -1
        end
            return Int64(axes[])
    else
        return js.axis_count
    end
end

function button_count(js::JSDevice)
    if js.filename != ""
        buttons = Ref{UInt8}()
        if @ccall(ioctl(js.fd::Cint, JSIOCGBUTTONS::Culong; buttons::Ref{UInt8})::Cint) == -1
            return -1
        end
        Int64(buttons[])
    else
        return js.button_count
    end
end

function read_event(js::JSDevice)
    @assert js.filename != ""
    event = Vector{UInt8}(undef, sizeof(JSEvent))
    res = ccall(:read, Cssize_t, (Cint, Ptr{Cuchar}, Csize_t), js.fd, event, sizeof(JSEvent))
    if res == -1    
        return nothing
    end
    reinterpret(JSEvent, event)[]
end

function axis_state!(axes::JSAxisState, event::JSEvent)
    axis = event.number+1
    if axis == 1
        axes.x = event.value
    elseif axis == 2
        axes.y = event.value
    elseif axis == 3
        axes.z = event.value
    elseif axis == 4
        axes.u = event.value
    elseif axis == 5
        axes.v = event.value
    elseif axis == 6
        axes.w = event.value
    end
    axis
end

function axis_state!(axes::JSState, event::JSEvent)
    axis = event.number+1
    if axis == 1
        axes.x = event.value/MAX_VALUE
    elseif axis == 2
        axes.y = event.value/MAX_VALUE
    elseif axis == 3
        axes.z = event.value/MAX_VALUE
    elseif axis == 4
        axes.u = event.value/MAX_VALUE
    elseif axis == 5
        axes.v = event.value/MAX_VALUE
    elseif axis == 6
        axes.w = event.value/MAX_VALUE
    end
    axis
end

end
