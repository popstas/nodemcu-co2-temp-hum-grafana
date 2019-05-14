print("free:", node.heap())
startup_timeout = 1000

--uart.setup(0, 115200, 8, 0, 1, 1 )

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
    compileFiles()
    dofile('start.lc')
end

function compileFiles()
    local compileAndRemoveIfNeeded = function(f)
       if file.open(f) then
          file.close()
          print('Compiling:', f)
          node.compile(f)
          file.remove(f)
          collectgarbage()
       end
    end
    
    local serverFiles = {
        'http-request.lua',
        'start.lua',
        'ota.lua',
        'config-secrets.lua',
        'wifi.lua',
        'mqtt.lua',
        'co2.lua',
        'dht.lua',
        'light.lua'
        --'bme280.lua'
    }
    for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

    compileAndRemoveIfNeeded = nil
    serverFiles = nil
    collectgarbage()
end

tmr.alarm(0,1000,0,abortInit)           -- call abortInit after 1s
