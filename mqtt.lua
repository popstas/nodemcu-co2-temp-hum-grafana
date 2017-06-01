-- need mqtt_topic, mqtt_name, mqtt_login, mqtt_password
mqttClient = {}
mqttClient.client = mqtt.Client(mqtt_name, 30, mqtt_login, mqtt_password)

function mqttClient:connect()
    print("mqtt connect to "..mqtt_host.."...")
    mqttClient.client:connect(
        mqtt_host, 1883, 0, 1,
        function(client) print("mqtt connected") end,
        function(client, reason) print("mqtt connect failed, reason: "..reason) end
    )
    
    mqttClient.client:on("offline", function(client) print ("mqtt offline") end)
end

function mqttClient:publish(subtopic, value)
    mqttClient.client:publish(mqtt_topic.."/"..subtopic, value, 0, 0)
end

return mqttClient
