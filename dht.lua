return function(dht_pin)
    local status, temp, hum, temp_decimal, hum_decimal = dht.read(dht_pin)
    temp = math.floor(temp)
    hum = math.floor(hum)
    print("temp:", temp)
    print("hum:", hum)
    print("status:", status)

    if status ~= 0 then return end

    if temp ~= -12.9 then
        mqttClient:publish('temp', temp)
    end
    if hum < 100 then
        mqttClient:publish('hum', hum)
    else
        print("status:", status)
    end
end
