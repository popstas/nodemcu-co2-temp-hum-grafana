print("START")
startup_timeout = 1000

uart.setup(0, 9600, 8, 0, 1, 1 )
gpio.mode(3, gpio.OUTPUT)
gpio.write(3,gpio.LOW)
SETUP_PARAM={SDA=4, SCL=3, OW_PIN=2, OW_COUNT=2, PWR_PIN=6}
--tmr.alarm(0, 10000, 0, function()  dofile("start.lua") end)

function abortInit()
    -- initailize abort boolean flag
    abort = false
    print('Send any data to abort startup')
    -- if <CR> is pressed, call abortTest
    uart.on('data', 0, abortTest)
    -- start timer to execute startup function in 5 seconds
    tmr.alarm(0,startup_timeout,0,startup)
    end
    
function abortTest(data)
    -- user requested abort
    abort = true
    -- turns off uart scanning
    uart.on('data')
end

function startup()
    uart.on('data')   -- if user requested abort, exit
    if abort == true then
        print('startup aborted')
        return
        end
    -- otherwise, start up
    print('in startup')
    dofile('start.lua')
end

tmr.alarm(0,1000,0,abortInit)           -- call abortInit after 1s
