return function (ssid, password)
    print("connect to wifi "..ssid.."...")
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, password)
    wifi.sta.sethostname("nodemcu-d1")
end
