using Joysticks
using Test

@testset "Joysticks.jl" begin
    js = open_joystick()
    if ! isnothing(js)
        @test js.axis_count > 0
        @test js.button_count > 0
        event = read_event(js)
        @test event.type & Int(JS_EVENT_INIT) == Int(JS_EVENT_INIT)
    end
end
