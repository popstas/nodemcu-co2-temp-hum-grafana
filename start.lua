-- Variables --
dev_name         = "Temperature, humidity, CO2, light, move sensor"
mqtt_topic       = "home/room"
mqtt_name        = "home/room sensor"
mqtt_host        = "home.popstas.ru"
sensor_interval  = 10000
dht_pin          = 2
co2_pin          = 1
hostname         = "esp8266-room1-sensors"

xyc_pin          = 0
xyc_scan_period  = 60
--xyc_off_delay    = 10
xyc_on_threshold = 5
xyc_off_threshold = 20

-- balcony
sensors = {['dht'] = true, ['co2'] = true, ['light'] = true, ['move'] = false, ['bme'] = false}

-- room
--sensors = {['dht'] = true, ['co2'] = false, ['light'] = false, ['move'] = true, ['bme'] = false}

-- kitchen
--sensors = {['dht'] = false, ['co2'] = false, ['light'] = false, ['move'] = false, ['bme'] = true}

buffer = nil

dofile("config-secrets.lc")
mqttClient = dofile('mqtt.lc')

if node_started then node.restart() end -- restart when included after start

--local init_led = function()
--    ws2812.init()
--    buffer = ws2812.newBuffer(1, 3) -- count, mode
--    buffer:fill(0, 0, 0)
--    ws2812.write(buffer)
--end
--
--init_led()

dofile('wifi.lc')(wifi_ssid, wifi_password, hostname)
collectgarbage()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("http://" .. T.IP)
    mqttClient:connect()
    mqttClient.client:on("connect", function(client)
        print("mqtt connected")
        if sensors.move then dofile('move.lc')(xyc_pin, xyc_off_delay, xyc_scan_period, xyc_on_threshold, xyc_off_threshold, on_callback, off_callback) end
        if sensors.bme then
            sda, scl = 3, 4
            i2c.setup(0, sda, scl, i2c.SLOW)
            bme280.setup()
        end
        tmr.alarm(0, sensor_interval, tmr.ALARM_AUTO, function()
            if sensors.co2 then dofile('co2.lc')(co2_pin) end
            if sensors.dht then dofile('dht.lc')(dht_pin) end
            if sensors.light then dofile('light.lc')() end
            if sensors.bme then dofile('bme280.lua')() end
        end)
    end)
    dofile('ota.lc')()
    collectgarbage()
    print("free after wifi connected:", node.heap())
end)

node_started = true

