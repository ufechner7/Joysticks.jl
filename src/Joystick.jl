module Joystick

using Setfield

export open_joystick, axis_count, button_count, read_event, axis_state, JSEvents

const JSIOCGAXES = UInt(2147576337)
const JSIOCGBUTTONS = UInt(2147576338)

@enum JSEvents begin
    JS_EVENT_BUTTON = 0x1
    JS_EVENT_AXIS = 0x02
    JS_EVENT_INIT = 0x80
end

struct JSDevice
    device::IOStream
    fd::Int32
end

struct JSEvent
    time::UInt32
    value::Int16
    type::UInt8
    number::UInt8
end

struct JSAxisState
    x::Int16
    y::Int16
end

const JSAxis = NTuple{3, JSAxisState}

function open_joystick(filename = "/dev/input/js0")
    file = open(filename, "r+")
    JSDevice(file, fd(file))
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
    event = read(js.device, sizeof(JSEvent); all = false)
    if sizeof(event) != sizeof(JSEvent)
        return nothing
    end
    reinterpret(JSEvent, event)[]
end

function axis_state(event::JSEvent, axes::JSAxis)
    axis = event.number ÷ 2
    if axis < 3
        if event.number % 2 == 0
            axes = @set axes[axis].x = event.value
        else
            axes = @set axes[axis].y = event.value
        end
    end

    return axis, axes
end

end
