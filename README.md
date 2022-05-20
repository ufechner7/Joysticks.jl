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
```

## Example
```julia
using Joystick

jsd = open_joystick()
axis_count   = jsd.axis_count
button_count = jsd.button_count
println(axis_count, " ", button_count)
```

See the file ```main.jl``` in the folder examples for an example
how to print all events.