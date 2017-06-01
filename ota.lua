local function http_response(conn, code, content)
    local codes = { [200] = "OK", [400] = "Bad Request", [404] = "Not Found", [500] = "Internal Server Error", }
    conn:send("HTTP/1.0 "..code.." "..codes[code].."\r\nServer: nodemcu-ota\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n"..content)
    --
end

local function ota_controller(conn, req, args)
    collectgarbage()
    local resp = ""
    --print("before request:", node.heap())
    local data = req.getRequestData()
    --print("after request:", node.heap())
   
    print("received OTA request:")
    local filename = data.filename
    local content = data.content
    local chunk_num = data.chunk

    print("filename:", filename)
    if chunk_num then
        print("chunk:", chunk_num)
    end

    --print("content:", content)
    if filename and content then
        local fmode = "w"
        if chunk_num and chunk_num ~= "1" then fmode = "a+" end

        local f = file.open(filename, fmode)
        if f then
            --print("content:", content)
            file.write(content)
            file.close()
            print("OK")
            http_response(conn, 200, "OK")
            return
        else
            print("write file failed")
            http_response(conn, 500, "ERROR")
            return
        end
    end
    http_response(conn, 400, "Invalid arguments, use POST filename and content")
end


local function restart_controller(conn, req, args)
    http_response(conn, 200, "restarting...")
    print("received restart signal over http")
    tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function()
        conn:close()
        node.restart()
    end)
end


local function health_controller(conn, req, args)
    local resp = "# General: \n"
    resp = resp .. "Device name: " .. dev_name .. "\n"
    resp = resp .. "Chip ID: " .. node.chipid() .. "\n"
    resp = resp .. "Uptime: " .. tmr.time() .. "\n\n"

    local free, used, total = file.fsinfo()
    resp = resp .. "# File system:\n"
    resp = resp .. "Total: " .. total .. "\n"
    resp = resp .. "Used:  " .. used .. "\n"
    resp = resp .. "Free:  " .. free .. "\n\n"

    resp = resp .. "# Files (name, size):\n"
    local l = file.list();
    for k,v in pairs(l) do
        resp = resp .. k..", "..v.."\n"
    end
    l = nil

    resp = resp .. "\n"
    resp = resp .. "Heap: " .. node.heap() .. "\n"

    http_response(conn, 200, resp)
    resp = nil
    collectgarbage()
end


local function onReceive(conn, payload)
    local req = dofile('http-request.lc')(conn, payload)
    if req == false then
        return -- not all body received
    end

    if req.uri.file == "http/ota" then
        ota_controller(conn, req, req.uri.args)
    end

    if req.uri.file == "http/restart" and req.method == "POST" then
        restart_controller(conn, req, req.uri.args)
    end

    if req.uri.file == "http/health" then
        health_controller(conn, req, req.uri.args)
    end

    req = nil
    collectgarbage()
end


local function onSent(conn, payload)
    conn:close()
end


return function()
    local s = net.createServer(net.TCP, 10)
    s:listen(80, function(conn)
        conn:on("receive", onReceive)
        conn:on("sent", onSent)
    end)
end
