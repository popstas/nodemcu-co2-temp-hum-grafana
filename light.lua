 return function ()
    local min = 0
    local max = 1024
    local total = max - min
    local a = adc.read(0);
    local light = math.floor((a - min) / total * 100)
    print("light:", light)
    mqttClient:publish('light', light)
end
