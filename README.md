# Joystick

Joystick driver for Julia, for now only on Linux.

## Installation
```
using Pkg
pkg"add https://github.com/ufechner7/Joystick.jl"
```

## Functions

```
open_joystick(filename="/dev/input/js0")
get_axis_count(fd::Cint)
```

## Example
```
using Joystick

fd = open_joystick()
axis_count = get_axis_count(fd)
println(axis_count)
```