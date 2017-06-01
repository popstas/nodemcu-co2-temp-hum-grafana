ppm = 0
local h = 0
local l = 0
local tl = 0
local th = 0
local c = 0

local function pin1cb(level)
    local tt = tmr.now() / 1000;

    if level == 1 then
        h = tt;
        tl = h - l;
        ppm = 5000 * (th - 2) / (th + tl - 4)
    else
        l = tt;
        th = l - h;
        ppm = 5000 * (th - 2) / (th + tl - 4)
    end

    if c > 3 then gpio.mode(1, gpio.INPUT)
        print('co2:', ppm)
        mqttClient:publish('co2', math.floor(ppm))
        return ppm
    end
    c = c + 1

    if level == 1 then gpio.trig(1, "down") else gpio.trig(1, "up") end
end

return function(co2_pin)
    gpio.mode(co2_pin, gpio.INT)
    gpio.trig(co2_pin, "up", pin1cb)
    return ppm
end
