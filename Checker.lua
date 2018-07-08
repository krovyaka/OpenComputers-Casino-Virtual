local component = require("component")
local term = require("term")
local gpu = component.gpu
local unicode = require("unicode")
local event = require("event")
local computer = require("computer")
local serialization = require("serialization")

if not require("filesystem").exists("/lib/durexdb.lua") then
  if not require("component").isAvailable("internet") then 
  io.stderr:write("Для первого запуска необходима Интернет карта!") 
  return
  else 
  require("shell").execute("wget -q https://pastebin.com/raw/akWrDjEa /lib/durexdb.lua") end
end

require("durexdb")
io.write("Токен-код (скрыт): ") gpu.setForeground(0x000000) Connector = DurexDatabase:new(io.read())
gpu.setForeground(0xffffff)

event.shouldInterrupt = function () return false end

function drawInterface(nick)
  money_of_player = Connector:get(nick)
  gpu.setResolution(32,16)
  gpu.setBackground(0xa0a0a0)
  term.clear()
  gpu.setBackground(0x000000)
  gpu.fill(3,2,28,14," ")
  gpu.set(16-math.floor(unicode.len(nick)/2),6,nick)
  gpu.set(6,7,"   На вашем счету ")
  gpu.set(16-math.floor(unicode.len(money_of_player..'')/2),8,money_of_player..'')
  gpu.set(6,9,"      дюрексиков ")
  

  gpu.setBackground(0xaa0000)
  gpu.fill(3,13,28,3," ")
  gpu.set(13,14,"Click me")
  login = true
  player = nick
end

drawInterface("Durex77")

while true do 
  local _,_,_,_,_,p =event.pull("touch")
  drawInterface(p)
end

