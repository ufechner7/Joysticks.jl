using Joysticks

const js       = open_joystick()
const jsaxis   = JSState()

async_read_jsaxes!(js, jsaxis)

try
    println("Press CTRL + C to terminate!")
    while true
        println(jsaxis)
        sleep(0.05)
    end
catch e
    if typeof(e) <: InterruptException
        println("Terminated program!")
    else
        rethrow()
    end
end