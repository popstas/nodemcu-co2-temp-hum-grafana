return function()
    alt = 320
    T, P, H, QNH = bme280.read(alt)
    print('T', T)
    print('P', P)
    print('H', H)
    if T == nil then return end
    local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
    print(string.format("T=%s%d.%01d", Tsgn<0 and "-" or "", T/100, T%100))
    print(string.format("humidity=%d.%01d%%", H/1000, H%1000))
    print(string.format("QFE=%d.%01d", P/1000, P%1000))
    print(string.format("QNH=%d.%01d", QNH/1000, QNH%1000))
    mqttClient:publish('temp', math.floor(T/100))
    mqttClient:publish('hum', math.floor(H/1000))
    mqttClient:publish('pressure', math.floor(QNH/1000))
end