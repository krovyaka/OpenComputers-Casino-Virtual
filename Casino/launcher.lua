local gpu = require("component").gpu
local computer = require("computer")
local term = require("term")
event = require("event")
local admins = {"Durex77", "krovyaka", "krovyak", "GoodGame", "GooodGame", "SkyDrive_"}

if not require("filesystem").exists("/lib/durexdb.lua") then
    if not require("component").isAvailable("internet") then io.stderr:write("Для первого запуска необходима Интернет карта!") return
    else require("shell").execute("wget -q https://pastebin.com/raw/bK7wx8wB /lib/durexdb.lua") end
end

local removeUsers = function(...)
  for i = 1,select("#",...) do
    computer.removeUser(select(i, ...), nil)
  end
end

function drawError(reason)
  gpu.setResolution(49,20)
  gpu.setBackground(0x705f5f)
  gpu.setForeground(0xffffff)
  term.clear()
  print('Приложение завершило свою работу по причине:')
  if(reason == nil)
    then reason = "Успешное завершение программы"
  end
  print(reason)
  gpu.setResolution(80,20)
  gpu.setBackground(0xFFB300)
  gpu.fill(50,6,31,15, ' ')
  gpu.setForeground(0)
  gpu.set(51,7,'Кнопка доступна для:')
  for i = 1,#admins do gpu.set(51,8+i,admins[i]) end
  gpu.setForeground(0xffffff)
  gpu.setBackground(0xa6743c)
  gpu.fill(50,1,31,5, ' ')
  gpu.set(60,3,'Перезапустить')
  gpu.setBackground(0)
  
  while true do
    local _,_,x,y,_,nickname = event.pull("touch")
    for i = 1,#admins do
      if(nickname == admins[i]) then
        if(x >= 50) and (y<=4) then 
          return
        end
      end
    end
  end
end

require("durexdb")
removeUsers(computer.users())
event.shouldInterrupt = function () return false end
io.write("Токен-код (скрыт): ")
removeUsers(computer.users())
gpu.setForeground(0x000000)  
Connector = DurexDatabase:new(io.read())
while true do
  gpu.setForeground(0xffffff)
  result,errorMsg = pcall(loadfile("/home/app.lua"))
  removeUsers(computer.users())
  drawError(errorMsg)
end