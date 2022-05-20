module Joystick

export open_joystick, get_axis_count, get_button_count

const JSIOCGAXES    = 2147576337
const JSIOCGBUTTONS = 2147576338

function open_joystick(filename="/dev/input/js0")
   file = open(filename,"r+")
   Cint(fd(file))
end

function get_axis_count(fd::Cint)
    axes = Ref{UInt8}()
    if @ccall(ioctl(fd::Cint, JSIOCGAXES::Culong; axes::Ref{UInt8})::Cint) == -1
        return -1
    end
    Int64(axes[])
end

function get_button_count(fd::Cint)
    buttons = Ref{UInt8}()
    if @ccall(ioctl(fd::Cint, JSIOCGBUTTONS::Culong; buttons::Ref{UInt8})::Cint) == -1
        return -1
    end
    Int64(buttons[])
end

# /**
#  * Returns the number of buttons on the controller or 0 if an error occurs.
#  */
# size_t get_button_count(int fd)
# {
#     __u8 buttons;
#     if (ioctl(fd, JSIOCGBUTTONS, &buttons) == -1)
#         return 0;

#     return buttons;
# }

# int read_event(int fd, struct js_event *event)
# {
#     ssize_t bytes;

#     bytes = read(fd, event, sizeof(*event));

#     if (bytes == sizeof(*event))
#         return 0;

#     /* Error, could not read full event. */
#     return -1;
# }

end
