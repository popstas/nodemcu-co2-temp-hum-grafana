local M
do
local function addrs(pin,cd)
local addr 
 ow.setup(pin)
  DS18_ADDR = {}
  ow.reset_search(pin)
  local count = 0
  local N=0
  repeat
    count = count + 1
    addr = ow.search(pin)
    tmr.wdclr()
    if(addr ~= nil) then
        local crc = ow.crc8(string.sub(addr,1,7))
        if crc == addr:byte(8) then
            if (addr:byte(1) == 0x10) or (addr:byte(1) == 0x28) then
                table.insert(DS18_ADDR, addr)
                print('ADDR ADD',N,addr:byte(1,8))
               N=N+1
            end
        end          
    ---  print('ADDR N') 
    end
    tmr.wdclr()
  until ((count > 100) or (N>=cd))
end

M=addrs
end
return M
