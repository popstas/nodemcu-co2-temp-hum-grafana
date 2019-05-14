return function (ssid, password, hostname)
    print("connect to wifi "..ssid.."...")

    wifi.setmode(wifi.STATION)
    wifi.sta.sethostname(hostname)

    local cfg = {}
    cfg.ssid = ssid
    cfg.pwd = password
    wifi.sta.config({ ['ssid'] = ssid, ['pwd'] = password})
--    wifi.sta.config(ssid, password)
end
