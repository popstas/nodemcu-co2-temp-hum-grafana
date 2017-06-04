# nodemcu-co2-temp-hum-grafana

Sensor that outputs:

- co2 from MH-Z19 sensor
- temperature and humidity from DHT11 sensor
- light from GL5528 resistor

This is modification of project [http://www.crystalairfresh.ucoz.net](http://www.crystalairfresh.ucoz.net/publ/dlja_samostojatelnoj_sborki/opisanie_pribora/prostoj_pribor_izmerenija_so2_temperatury_i_vlazhnosti/6-1-0-12)

![sensors](sensors-grafana.png)

# Wiring
- Connect MH-Z19 to pin 1 and 5v
- Connect DHT11 to pin 2 and 5v
- Connect light resistor to A0 (not so easy, don't want to explain)

# Setup nodemcu

## Flash firmware
Get firmware from https://nodemcu-build.com/ with modules:

- adc
- dht
- file
- gpio
- mqtt
- net
- node
- pwm
- tmr
- uart
- wifi

```
esptool.py --port COM3 write_flash 0x00000 /path/to/nodemcu_float.bin
```

Or compile it, using `user_modules.h`.


## Set Wifi and MQTT credentials
Copy `config-secrets.default.lua` to `config-secrets.lua` and fill your credentials.

## Upload 
I am just open all lua files in ESPlorer and upload it, `init.lua` should be uploaded last.

Or you can install `nodemcu-tool`, change port address in `Makefile` and call `make` from project root:
```
make upload_all
```

# Setup other
All docs below is obsolete after @418f481.

I am using it with Grafana, Telegraf and InfluxDB.

## Generate json
Put file in cron:

```
#!/bin/bash

output_path="/path/to/co2-temp-hum-sensor.json"
location="room"

get_s() {
	echo "$1" | grep -oE "S$2=[0-9]+" | cut -d'=' -f2
}

line="$(nc -u -l 6650 -w 5 | grep -oE "S1=.+")"
echo '{"temp":'$(get_s "$line" 1)',"hum":'$(get_s "$line" 2)',"co2":'$(get_s "$line" 3)',"location":"$location"}' > "$output_path"
```

It should generate file such:
``` json
{"temp":25,"hum":32,"co2":452,"location":"room"}
```

## Setup nginx
```
server {
   listen 80;
   server_name sensors.myhome;
   root /path/to/sensors/output_dir;
}
```

## Setup Telegraf
Add to `/etc/telegraf/telegraf.conf`:
```
[[inputs.httpjson]]
    servers = [ "http://sensors.myhome/co2-temp-hum-sensor.json" ]
    name = "home"
    tag_keys = [ "location" ]
```

## Setup Grafana
Import [grafana-sensors-dashboard.json](grafana-sensors-dashboard.json) to Grafana.
