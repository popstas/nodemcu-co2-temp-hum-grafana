######################################################################
# User configuration
######################################################################
# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
NODEMCU-UPLOADER=nodemcu-tool
# Serial port
PORT=/dev/tty.wchusbserial14310
SPEED=115200

######################################################################
# End of user config
######################################################################
LUA_FILES := \
    init.lua \
    config-secrets.lua \
    wifi.lua \
    http-request.lua \
    ota.lua \
    start.lua \
    mqtt.lua \
    dht.lua \
    co2.lua \

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_all           to upload all"

# Upload one files only
upload:
	$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(FILE)

# Upload all
upload_all: $(LUA_FILES)
	$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(foreach f, $^, $(f))
