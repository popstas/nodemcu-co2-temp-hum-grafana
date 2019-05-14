local function change_color(r, g, b, segment)
    if segment then
        local s = segments[segment]
        if not s then segment = nil end
        local from, to = s:match('(.*)-(.*)')
        from = tonumber(from)
        to = tonumber(to)
        local size = to - from + 1
        local sbuffer = ws2812.newBuffer(size, 3)
        sbuffer:fill(g, r, b)
        buffer:replace(sbuffer:sub(1), from)
    end

    if not segment then
        buffer:fill(g, r, b)
    end

    ws2812.write(buffer)

    local power = dofile('ws2812-power.lc')(buffer)
    print('power: ', power.a .. ' A, ', power.percent .. '%, ', power.power .. ' W')
    mqttClient:publish('power', power.power)

    set_state(buffer:dump())
end

local function newyear_on()
    dofile('ws2812-newyear.lc')()
end

local function newyear_off()
    tmr.unregister(0)
end

-- TODO: remove
local function http_response(conn, code, content)
    local codes = { [200] = 'OK', [400] = 'Bad Request', [404] = 'Not Found', [500] = 'Internal Server Error', }
    conn:send('HTTP/1.0 '..code..' '..codes[code]..'\r\nAccess-Control-Allow-Origin: *\r\nServer: nodemcu-ota\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n'..content)
    --
end

local function is_black(r, g, b)
    return r == 0 and g == 0 and b == 0
end

return function (conn, req, args)
    if args.action == 'newyear' then
        newyear_on()
    else
        newyear_off()
    end

    if args.action == 'last' then
        change_color_state('1')
    end

    if args.action == 'switch' then
        if buffer:power() > 0 then
            print('On/off last color: off')
            change_color(0, 0, 0, args.s)
        else
            change_color_state('2')
        end
    end

    if not args.action then
        print('Color changing to', args.r, args.g, args.b, 'segment:', args.s)
        if args.r and args.g and args.b then
            change_color(args.r, args.g, args.b, args.s)
        end
    end

    http_response(conn, 200, 'OK');
end
