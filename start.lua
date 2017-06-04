-- Variables --
dev_name         = "Temperature, humidity, CO2, light sensor"
mqtt_topic       = "home/room"
mqtt_name        = "temp-hum-co2-light-room"
mqtt_host        = "home.popstas.ru"
sensor_interval  = 10000
dht_pin          = 2
co2_pin          = 1
hostname         = "room-sensors"

dofile("config-secrets.lc")
mqttClient = dofile('mqtt.lc')

if node_started then node.restart() end -- restart when included after start

dofile('wifi.lc')(wifi_ssid, wifi_password, hostname)
collectgarbage()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("http://" .. T.IP)
    mqttClient:connect()
    mqttClient.client:on("connect", function(client)
        print("mqtt connected")
        tmr.alarm(0, sensor_interval, tmr.ALARM_AUTO, function()
            dofile('co2.lc')(co2_pin)
            dofile('dht.lc')(dht_pin)
            dofile('light.lc')()
        end)
    end)
    dofile('ota.lc')()
    collectgarbage()
    print("free after wifi connected:", node.heap())
end)

node_started = true
