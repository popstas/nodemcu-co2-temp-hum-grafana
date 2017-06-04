return function(dht_pin)
    local status, temp, hum, temp_decimal, hum_decimal = dht.read(dht_pin)
    print("temp:", temp, "hum:", hum)
    mqttClient:publish('temp', temp)
    mqttClient:publish('hum', hum)
end
