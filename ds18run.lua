local M
do
local function run(pin,ind)

  if not DS18_ADDR then print('DS18_ADDR is null') return end
  if not ow then return end
  local j=1
 -- print('DS18_ADDR I',i, DS18_ADDR[i])
  ow.setup(pin)
  
  while (DS18_ADDR[j] and DS18_START) do
      local addr=DS18_ADDR[j];
      local present = ow.reset(pin)
      ow.write(pin,0x55,1)
      local i
      for i=1,8 do
        ow.write(pin,addr:byte(i),1)
      end
      ow.write(pin,0xBE,1)
--      print("P="..present)
      local data = nil
      data = string.char(ow.read(pin))
      for i = 1, 8 do
        data = data .. string.char(ow.read(pin))
         tmr.wdclr()
      end
      local crc = ow.crc8(string.sub(data,1,8))
 --     print("CRC="..crc)
      if (crc == data:byte(9)) then
       local t = (data:byte(1) + data:byte(2) * 256)
        if (t > 32767) then
          t = t - 65536
        end
        t = (t * 625)/100
       if LOG then print(j,"Temperature="..(t / 100).."."..(t % 100)) end
        ListTime[ind+j]={time=tmr.time(),  data=t}
      end
      tmr.wdclr()
      j=j+1
  end
      DS18_START=1
      ow.reset(pin)
      ow.write(pin,0xCC,1)
      ow.write(pin, 0x44, 1)
      tmr.wdclr()
        
  ow.depower (pin) 
  
end
M=run
end
return M  
