local M
do
--print(status, temp, humi, temp_decimal, humi_decimal)
local function GetStrData()
    status,temp,humi,temp_decimal,humi_decimal = dht.read(2)
    ListTime[1].data = temp
    ListTime[2].data = humi
 local s='CO2DAT#'..ListTime.time..'*'  local i
 for i=1,5 do
    if ListTime[i] then
         s=s..'S'..i..'='..ListTime[i].data
         s=s..'*'
    end
  end 
  return s 
end 

local function saveData()
local s=GetStrData()
if s then
    print('WIFI>',s)
    CLIENT:connect(6650,wifi.sta.getbroadcast()) 
    CLIENT:send(s)
end    

end

 

M=saveData
end
return M
