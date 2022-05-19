using Joystick
using Test

@testset "Joystick.jl" begin
    fd=open_joystick()
    axis_count = get_axis_count(fd)
    @test axis_count > 0
end
