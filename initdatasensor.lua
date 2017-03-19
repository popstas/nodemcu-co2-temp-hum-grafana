local M
do
local function initdata()
if not ListTime then ListTime={} end
 local t=tmr.time()
 for i=1,5 do
   if ListTime[i] then ListTime[i]=nil end
   ListTime[i]={time=t ,data=-1}
 end
 ListTime[1]={time=t ,data=0}
 ListTime[2]={time=t ,data=0}
 ListTime[3]={time=t ,data=0}
end

local function GetStrData()
 DataStr=nil
 local s='CO2DAT#'  local t   local d  local i
 initdata()
 for i=1,5 do
    if ListTime[i] then
         s=s..ListTime[i].time ..'='..ListTime[i].data
    end
    s=s..'*'
 end 
 DataStr=s
 end
 M=GetStrData
end
return M
