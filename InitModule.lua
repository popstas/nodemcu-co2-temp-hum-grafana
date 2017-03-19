local M
do







local init= function() 
 local ids= dofile("initdatasensor.lua")() ids = nil

 SERVER=net.createServer(net.UDP, 180,wifi.ap.getip())
 SERVER:on("receive", function(SERVER,c1) rec(SERVER,c1)  end)
 SERVER:listen(6651)
 print("start UDP server")
 
 CLIENT=net.createConnection(net.UDP) 
end 
M=init
end
return M
