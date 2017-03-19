SSID='wifi-name'
PASSWORD='wifi-password'

--

if START_S then print('START#1') time_loop() return end  
START_S=1
LOG=nil
GP={}
GP.x=4
GP.y=160
GP.v=-1
gpio.mode(1,gpio.INT,gpio.PULLUP)
gpio.mode(3, gpio.OUTPUT)
--node.setcpufreq (node.CPU160MHZ)
OLD_VAL={}

wifi.sta.sethostname("co2-sensor")
wifi.setmode(wifi.STATION)
tmr.delay(1000000)
wifi.sta.config(SSID, PASSWORD)
tmr.delay(1000000)

function rec(s,c) 
    LCD_STR.wifi=1 
    snd=dofile("SendUPD.lua")(s,c) 
    snd=nil  
    collectgarbage() 
end

local initM = dofile('InitModule.lua')() initM = nil

function drawGraf()
end;


function printLCD1()
end;

collectgarbage() 

local function graph(vol)

 
if GP.x>310 then
  drawGraf()
  GP.x=4
end;

local y=198-(vol*12/180)

GP.x=GP.x+2
GP.y=y
print('y',y)




if vol<901 then
 
 if GP.v~=0 then

 end;
 GP.v=0
elseif  vol<1501 then

if GP.v~=1 then
 end;
 GP.v=1
else  

if GP.v~=2 then
end;
GP.v=2
end


end


function printLCD()
end;


function time_loop()
            local tm=tmr.now()
            

             local ds18 = dofile('ds18run.lua')(2,0)  ds18=nil             
             
      --       local lt=ListTime[2].data
      --       ListTime[2].data=ListTime[1].data
      --       ListTime[1].data=lt
             ListTime[5]={time=tmr.time(),  data=wifi.getmode()}
             ListTime[4]={time=tmr.time(), data=wifi.sta.status()}

             if wifi.sta.getip() then
                ListTime[4]={time=tmr.time(),  data=wifi.sta.getip()}
             else ListTime[4]={time=tmr.time(),  data='NOT'}
             end
             
             local ppm= dofile('ppmrun.lua')()  ppm=nil   
           
             ListTime.time=(tmr.time()/3600)..':'..(tmr.time()/60)..':'..tmr.time()%60;
          
             local filedata = dofile('filedata.lua')()  filedata = nil 
          
             collectgarbage()   
            
             printLCD()
             print('mem',node.heap())
             if Fs then  tmr.alarm(2, 10000, 0,function() time_loop()end )              
             else 
                tmr.alarm(2, 1000, 0,function() time_loop()end )              
                Fs=1
             end
              
             
end            
time_loop()
for i=1,1023 do 
    pwm.setup(3,500,i) 
    pwm.start (3)
    tmr.delay(4500) 
end   
gpio.write(3,gpio.HIGH)


 
