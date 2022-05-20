module Joystick

export JSEvents, JSAxisState                              # types
export JS_EVENT_BUTTON, JS_EVENT_AXIS, JS_EVENT_INIT      # constants
export open_joystick, read_event, axis_state!             # functions

const JSIOCGAXES    = UInt(2147576337)
const JSIOCGBUTTONS = UInt(2147576338)

@enum JSEvents begin
    JS_EVENT_BUTTON = 0x1
    JS_EVENT_AXIS   = 0x02
    JS_EVENT_INIT   = 0x80
end

mutable struct JSDevice
    device::IOStream
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

function open_joystick(filename = "/dev/input/js0")
    file = open(filename, "r+")
    device = JSDevice(file, fd(file), 0, 0)
    device.axis_count = axis_count(device) 
    device.button_count = button_count(device)
    device
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

end
