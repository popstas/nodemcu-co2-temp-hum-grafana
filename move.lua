global_detected = 0

local function move_on_callback()
    mqttClient:publish("move/detected", 1)
    global_detected = 1
    print("move detected!")
    --http.get(xyc_on_url)
end

local function move_off_callback()
    mqttClient:publish("move/detected", 0)
    global_detected = 0
    print("move ended")
    --http.get(xyc_off_url)
end

return function(xyc_pin, off_delay, scan_period, on_threshold, off_threshold, on_callback, off_callback)
    local buffer = {}
    local move_detected = false
    local above_off_threshold = false
    gpio.mode(xyc_pin, gpio.INPUT)
    mqttClient:publish("move/detected", 0)
    tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
        local move = gpio.read(xyc_pin)
        table.insert(buffer, move)
        if #buffer > scan_period then
            table.remove(buffer, 1)
        end
    
        local sum = 0
        for i = 1, #buffer do
            sum = sum + buffer[i]
        end
        move_average = math.floor(sum / scan_period * 100)

        mqttClient:publish("move/avg", move_average)
        mqttClient:publish("move", move)
        print("move: ", move, "detected: ", global_detected, "avg: ", move_average, "above_off_threshold: ", above_off_threshold)

        -- current detect status
        -- в разные стороны 
        on_detect = global_detected==0 and (above_off_threshold and move_average >= off_threshold) or (not above_off_threshold and move_average >= on_threshold)
        off_detect = global_detected==1 and move_average >= on_threshold and (not above_off_threshold or move_average >= off_threshold)
        new_move_detected = on_detect or off_detect
        
        if move_average > off_threshold then above_off_threshold = true end
        if move_average < on_threshold then above_off_threshold = false end

        -- only on state change
        if new_move_detected ~= move_detected then
            print("change:", "move_detected", move_detected, "move_average", move_average)
            move_detected = new_move_detected
            if move_detected then
                move_on_callback()
            else
                -- todo: off_delay not used
                move_off_callback()
                above_off_threshold = true
            end
        end
    end)
end
