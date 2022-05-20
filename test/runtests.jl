using Joysticks
using Test

@testset "Joysticks.jl" begin
    jld = open_joystick()
    axis_count = jld.axis_count
    @test axis_count > 0
end
