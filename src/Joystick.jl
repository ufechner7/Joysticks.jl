module Joystick

export open_joystick, get_axis_count

const JSIOCGAXES=2147576337

function open_joystick(filename="/dev/input/js0")
   file = open(filename,"r+")
   Cint(fd(file))
end

function get_axis_count(fd::Cint)
    axes = Ref{UInt8}()
    if @ccall(ioctl(fd::Cint, JSIOCGAXES::Clong; axes::Ref{UInt8})::Cint) == -1
        return -1
    end
    Int64(axes[])
end

end
