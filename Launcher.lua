local gpu = require("component").gpu
local computer = require("computer")
local term = require("term")
event = require("event")

if not require("filesystem").exists("/lib/durexdb.lua") then
  if not require("component").isAvailable("internet") then 
  io.stderr:write("Для первого запуска необходима Интернет карта!") 
  return
  else 
  require("shell").execute("wget -q https://pastebin.com/raw/akWrDjEa /lib/durexdb.lua") end
end

local removeUsers = function(...)
  for i = 1,select("#",...) do
    computer.removeUser(select(i, ...), nil)
  end
end

require("durexdb")

event.shouldInterrupt = function () return false end

while true do
  removeUsers(computer.users())
  io.write("Токен-код (скрыт): ")
  gpu.setForeground(0x000000)
  Connector = DurexDatabase:new(io.read())
  gpu.setForeground(0xffffff)
  result,errorMsg = pcall(loadfile("/home/app.lua"))
  gpu.setBackground(0)
  gpu.setForeground(0xffffff)
  term.clear()
  print("Приложение завершило свою работу по причине: ")
  print(errorMsg)
end