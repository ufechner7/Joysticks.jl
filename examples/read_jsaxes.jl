using Joysticks

const js       = open_joystick()
const jsaxes   = JSState()

async_read!(js, jsaxes)

try
    println("Press CTRL + C to terminate!")
    while true
        println(jsaxes)
        sleep(0.05)
    end
catch e
    if typeof(e) <: InterruptException
        println("Terminated program!")
    else
        rethrow()
    end
end