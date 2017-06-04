return function ()
    local min = 2950
    local max = 3800
    local total = max - min
    local a = adc.readvdd33(0);
    local light = math.floor((a - min) / total * 100)
    print("light:", light)
    mqttClient:publish('light', light)
end
