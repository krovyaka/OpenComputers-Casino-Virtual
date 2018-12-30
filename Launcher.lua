local gpu = require("component").gpu
local computer = require("computer")
local term = require("term")
event = require("event")

local admins = {"Durex77", "krovyaka"}

if not require("filesystem").exists("/lib/casinoConnector.lua") then
  if not require("component").isAvailable("internet") then 
  io.stderr:write("Для первого запуска необходима Интернет карта!") 
  return
  else 
  require("shell").execute("wget -q https://pastebin.com/raw/YTyKCubV /lib/casinoConnector.lua") end
end

local removeUsers = function(...)
  for i = 1,select("#",...) do
    computer.removeUser(select(i, ...), nil)
  end
end

require("casinoConnector")
event.shouldInterrupt = function () return false end

while true do
  io.write("Адрес микросервиса: ")
  local ip = io.read()
  io.write("Токен-код (скрыт): ")
  removeUsers(computer.users())
  gpu.setForeground(0x000000)  
  Connector = CasinoConnector:new(io.read(), ip)
  gpu.setForeground(0xffffff)
  result,errorMsg = pcall(loadfile("/home/app.lua"))
  gpu.setBackground(0)
  gpu.setForeground(0xffffff)
  term.clear()
  print("Приложение завершило свою работу по причине: ")
  print(errorMsg)
end