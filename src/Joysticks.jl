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

using Observables

export JSEvents, JSEvent, JSAxisState, JSButtonState, JSState # types
export JS_EVENT_BUTTON, JS_EVENT_AXIS, JS_EVENT_INIT          # constants
export open_joystick, read_event, axis_state!                 # functions
export async_read_jsaxes!, async_read_jsbuttons!              # high level interface

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
    device::String
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
function async_read_jsaxes!(js::JSDevice, jsaxes)
    @async while true
        event = read_event(js)
        if ! isnothing(event)
            if event.type == Int(JS_EVENT_AXIS)
                axis_state!(jsaxes, event)
            end
        else
            sleep(0.002)
        end
    end
end

# read all axis of the joystick and update jsaxis
function async_read_jsbuttons!(js::JSDevice, jsbuttons)
    @async while true
        event = read_event(js)
        if ! isnothing(event)
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
        else
            sleep(0.005)
        end
    end
end

function open_joystick(filename = "/dev/input/js0")
    if  Sys.islinux()
        if ispath(filename)
            jfd = ccall(:open, Cint, (Cstring, Cint), filename, O_RDONLY|O_NONBLOCK)
            device = JSDevice(filename, jfd, 0, 0)
            device.axis_count = axis_count(device)
            device.button_count = button_count(device)
            return device
        else
            println("ERROR: The device $filename does not exist!")
            return nothing
        end
    else
        error("Currently Joystick.jl supports only Linux!")
        nothing
    end
end

function axis_count(js::JSDevice)
    axes = Ref{UInt8}()
    if @ccall(ioctl(js.fd::Cint, JSIOCGAXES::Culong; axes::Ref{UInt8})::Cint) == -1
        return -1
    end
    Int64(axes[])
end

function button_count(js::JSDevice)
    buttons = Ref{UInt8}()
    if @ccall(ioctl(js.fd::Cint, JSIOCGBUTTONS::Culong; buttons::Ref{UInt8})::Cint) == -1
        return -1
    end
    Int64(buttons[])
end

function read_event(js::JSDevice)
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
