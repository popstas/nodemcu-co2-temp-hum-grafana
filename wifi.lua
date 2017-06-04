return function (ssid, password, hostname)
    print("connect to wifi "..ssid.."...")
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, password)
    wifi.sta.sethostname(hostname)
end
