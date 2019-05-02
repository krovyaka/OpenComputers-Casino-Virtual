if not require("filesystem").exists("/lib/durexdb.lua") then
if not require("component").isAvailable("internet") then 
	io.stderr:write("Для первого запуска необходима Интернет карта!") 
	return
else 
	require("shell").execute("wget -q https://pastebin.com/raw/bK7wx8wB /lib/durexdb.lua") end
end

require("durexdb") 
Connector = DurexDatabase:new('8bc882f914fc4f74996712c00f860787')

local component = require("component")
local gpu = component.gpu
local unicode = require("unicode")
local event = require("event")
local chest_input = component.crystal
local sensor = component.openperipheral_sensor
local me_interface = component.me_interface
local redstone = component.redstone

local MONEY_ITEM = {id="minecraft:cobblestone"}
local X_OFFSET, Y_OFFSET, Z_OFFSET = -2, -2, 2
local REDSTONE_OUTPUT_SIDE = 5
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
  local sum = 0
  for i = 1, 108 do
    local item = chest_input.getStackInSlot(i)
    if item and item.id == MONEY_ITEM.id then -- ПРОВЕРЯТЬ ТЩАТЕЛЬНЕЕ
      sum = sum + chest_input.pushItem('DOWN', i)
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
  middleTextAlign(38, 3, "Терминал для перевода эмов в дюрексики 2.0")
  middleTextAlign(38, 4, "Новая версия запущена в тестовом режиме из-за запрета PIM")
end

function message(text)
  gpu.setForeground(0x00ff00)
  middleTextAlign(38, 6, text)
  os.sleep(1.5)
  gpu.fill(1, 6, 80, 1, ' ')
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

function handleClick(x, y, player)
  if (x > 3 and x <= 24 and y >= 14 and y <= 25) then
    local money = suckMoney()
    Connector:give(player, money)
    message(money .. "$ успешно добавлены на Ваш счёт.")
    return
  end
  
  for i = 1, #OUTPUT_BUTTONS do
    local button = OUTPUT_BUTTONS[i]
    if x >= button[1] and x <= button[1] + 10 and y >= button[2] and y <= button[2] + 3 then
      local money = giveMoney(player, button[3])
      message(money .. "$ успешно снято с Вашего счёта.")
      return
    end
  end
end

function dynamicDraw(player)
  gpu.setForeground(0xffff00)
  filledText(29, 14, player or '', 28)
  filledText(29, 17, player and tostring(Connector:get(player)) or '', 28)
  
  local executed, qty = pcall(function() return me_interface.getItemDetail(MONEY_ITEM).basic().qty end)
  filledText(29, 20, executed and tostring(qty) or '0', 28)
end

function giveMoney(player, qty)
  if not Connector:pay(player, qty) then
    message('Недостаточно средств для вывода')
  end
  if qty == 0 then return 0 end
  
  local gived = 0
  while true do
    local executed, g = pcall(function() return me_interface.exportItem(MONEY_ITEM, "UP", qty < 64 and qty or 64).size end)
    g = executed and g or 0
    qty = qty - g
    gived = gived + g
    if g == 0 or qty == 0 then
      Connector:give(player, gived)
      return gived
    end
  end
end

function redstoneChangeState(state)
  if state then
    if redstone.getOutput(REDSTONE_OUTPUT_SIDE) == 0 then
      redstone.setOutput(REDSTONE_OUTPUT_SIDE, 15)
    end
  else
    if redstone.getOutput(REDSTONE_OUTPUT_SIDE) > 0 then
      redstone.setOutput(REDSTONE_OUTPUT_SIDE, 0)
    end
  end
end


initDraw()
local currentPlayer = nil
while true do
  local _, _, x, y, _, player = event.pull(0.5, "touch")
  if player and player == currentPlayer then
    handleClick(x, y, player)
    dynamicDraw(player)
  else
    local player = getPositionedPlayers()[1]
    if currentPlayer ~= player then
      currentPlayer = player
      dynamicDraw(player)
    end
  end
  redstoneChangeState(currentPlayer ~= nil)
end