# Joystick

Joystick driver for Julia, for now only on Linux.

## Installation
```julia
using Pkg
pkg"add https://github.com/ufechner7/Joystick.jl"
```

## Functions

```julia
open_joystick(filename="/dev/input/js0")
get_axis_count(fd::Cint)
get_button_count(fd::Cint)
```

## Example
```julia
using Joystick

fd = open_joystick()
axis_count = get_axis_count(fd)
button_count=get_button_count(fd)
println(axis_count, " ", button_count)
```