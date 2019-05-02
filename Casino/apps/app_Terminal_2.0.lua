if not require("filesystem").exists("/lib/durexdb.lua") then
if not require("component").isAvailable("internet") then 
	io.stderr:write("Для первого запуска необходима Интернет карта!") 
	return
else 
	require("shell").execute("wget -q https://pastebin.com/raw/bK7wx8wB /lib/durexdb.lua") end
end

require("durexdb") 
Connector = DurexDatabase:new('40b074cdd9ce49e5b60651ada335ef41')

local component = require("component")
local gpu = component.gpu
local unicode = require("unicode")
local chest_input = component.proxy("7469d49d-14e8-4f70-9b0e-75836f5b26d4")
local sensor = component.openperipheral_sensor
local me_interface = component.me_interface

local MONEY_ITEM = {id="minecraft:cobblestone"}
local X_OFFSET, Y_OFFSET, Z_OFFSET = -2, -2, 2
local OUTPUT_BUTTONS = {
  {57, 15, 1},
  {57, 19, 10},
  {57, 23, 100},
  {69, 15, 16},
  {69, 19, 64},
  {69, 23, 512}
}

function middleTextAlign(x, y, text)
  local indent = math.floor(unicode.len(text) / 2)
  gpu.set(x - indent, y , text)
end

function filledText(x, y, text, len)
  gpu.set(x, y, text .. string.rep(' ', len - unicode.len(text)))
end

function suckMoney()
  chest_input.condenseItems()
  local sum = 0
  for i = 1, 108 do
    local item = chest_input.getStackInSlot(i)
    if not item then return sum end
    if item.id == "customnpcs:npcMoney" then
      sum = sum + chest_input.pushItem('NORTH', i)
    end
  end
  return sum
end

function initDraw()
  gpu.setResolution(80, 25)
  gpu.setBackground(0x00ff00)
  gpu.fill(1, 13, 25, 13, ' ')
  gpu.setBackground(0)
  gpu.fill(3, 14, 21, 11, ' ')
  gpu.setForeground(0xffffff)
  middleTextAlign(13, 19, "Внести всё")
  for i = 1, #OUTPUT_BUTTONS do 
    local b = OUTPUT_BUTTONS[i]
    gpu.setBackground(0x822f82)
    gpu.fill(b[1], b[2], 10, 3, ' ')
    middleTextAlign(b[1] + 5, b[2] + 1, b[3] .. '$')
  end
  gpu.setBackground(0)
  gpu.set(29, 13, 'Текущий пользователь:')
  gpu.set(29, 16, 'Деньги на счету:')
  gpu.set(29, 19, 'Деньги в терминале:')
  middleTextAlign(68, 13, "ВЫВОД СРЕДСТВ")
end

function getPositionedPlayers()
  local players = sensor.getPlayers()
  local positioned = {}
  for i = 1, #players do
    local executed, pos = pcall(function() return sensor.getPlayerByName(players[i].name).basic().position end)
    if executed and math.floor(pos.x) == X_OFFSET and math.floor(pos.y) == Y_OFFSET and math.floor(pos.z) == Z_OFFSET then
      table.insert(positioned, players[i].name)
    end
  end
  return positioned
end

initDraw()
local currentPlayer = nil
while true do
  os.sleep(0.5)
  p = getPositionedPlayers()[1]
  
  if currentPlayer ~= p then
    currentPlayer = p
    gpu.setForeground(0xffff00)
    filledText(29, 14, p or '', 28)
    filledText(29, 17, p and tostring(Connector:get(p)) or '', 28)
    filledText(29, 20, me_interface.getItemDetail(MONEY_ITEM).basic().qty)
  end
end