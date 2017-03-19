local M
do

ppm=0
local h = 0
  local l=0
  local tl=0  
  local th = 0
  local c = 0 
local function pin1cb(level)
      
  local tt = tmr.now()/1000;
 
if level == 1 then 

      h = tt;
      tl = h - l;
      ppm = 5000 * (th - 2) / (th + tl - 4)
   --   print('pp0',ppm)
     if ppm>300 then ListTime[3]={time=tmr.time(),  data=ppm} end;
 else
      l = tt;
      th = l - h;
      ppm = 5000 * (th - 2) / (th + tl - 4)
    --  print('pp2',ppm)
      
 end     
     if c>3 then gpio.mode(1,gpio.INPUT)  print('pp1',ppm) return ppm end
     c=c+1
     if level == 1 then gpio.trig(1, "down") else  gpio.trig(1, "up") end
     
end
  
    
local function getco2()

gpio.mode(1,gpio.INT)
  
 
  gpio.trig(1, "up",pin1cb)
--[[
local i=0
  repeat
  tmr.delay(1000) 
   i=i+1;
   print('I',i)
  until (ppm>300) or (i>1000)
--]]  
return ppm
  
end

M=getco2
end
return M
