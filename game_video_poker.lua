local component = require("component")
local event = require("event")
local term = require("term")
local gpu = component.gpu
local unicode = require("unicode")
local computer = require("computer")
local chat = component.chat_box
local serialization = require("serialization")

if not require("filesystem").exists("/lib/durexdb.lua") then
if not require("component").isAvailable("internet") then 
	io.stderr:write("Для первого запуска необходима Интернет карта!") 
	return
else 
	require("shell").execute("wget -q https://pastebin.com/raw/akWrDjEa /lib/durexdb.lua") end
end

chat.setDistance(6)
chat.setName("§6Video_Poker§l")

--event.shouldInterrupt = function () return false end

local durexdb = require("durexdb")

local login,blackjack,player,value,players_cards,time_sleep,time_sleep_end = false,false,'PIDOR',1,{},0.2,1.5
--io.write("Токен-код (скрыт): ") gpu.setForeground(0x000000) Connector = DurexDatabase:new(io.read())

function localsay(msg) chat.say("§e".. msg) end

Deck = {}

function Deck:new()
	local obj ={}
	obj.cards = {{card = "2",suit = "♥"},{card = "2",suit = "♦"},{card = "2",suit = "♣"},{card = "2",suit = "♠"},{card = "3",suit = "♥"},{card = "3",suit = "♦"},{card = "3",suit = "♣"},{card = "3",suit = "♠"},{card = "4",suit = "♥"},{card = "4",suit = "♦"},{card = "4",suit = "♣"},{card = "4",suit = "♠"},{card = "5",suit = "♥"},{card = "5",suit = "♦"},{card = "5",suit = "♣"},{card = "5",suit = "♠"},{card = "6",suit = "♥"},{card = "6",suit = "♦"},{card = "6",suit = "♣"},{card = "6",suit = "♠"},{card = "7",suit = "♥"},{card = "7",suit = "♦"},{card = "7",suit = "♣"},{card = "7",suit = "♠"},{card = "8",suit = "♥"},{card = "8",suit = "♦"},{card = "8",suit = "♣"},{card = "8",suit = "♠"},{card = "9",suit = "♥"},{card = "9",suit = "♦"},{card = "9",suit = "♣"},{card = "9",suit = "♠"},{card = "10",suit = "♥"},{card = "10",suit = "♦"},{card = "10",suit = "♣"},{card = "10",suit = "♠"},{card = "J",suit = "♥"},{card = "J",suit = "♦"},{card = "J",suit = "♣"},{card = "J",suit = "♠"},{card = "Q",suit = "♥"},{card = "Q",suit = "♦"},{card = "Q",suit = "♣"},{card = "Q",suit = "♠"},{card = "K",suit = "♥"},{card = "K",suit = "♦"},{card = "K",suit = "♣"},{card = "K",suit = "♠"},{card = "T",suit = "♥"},{card = "T",suit = "♦"},{card = "T",suit = "♣"},{card = "T",suit = "♠"}}
  
	obj.index = 1
	
	function obj:get()
		local temp = self.cards[self.index]
		self.index = self.index + 1
		return temp
	end
	
	function obj:hinder()
		for first = 1,52 do 
			local second,firstCard = math.random(1,52),self.cards[first]
			self.cards[first]=self.cards[second]
			self.cards[second]=firstCard
		end
		self.index = 1
	end
	
	setmetatable(obj, self)
	self.__index = self; return obj
end

local deck = Deck:new()

gpu.setResolution(40,20)

function isFlush(cards)
	for i=2,#cards do if (cards[i].suit ~= cards[1].suit) then return false end end
	return true
end

function isExist(cards,card,suit)
	for i=1,#cards do if (cards[i].card == card and cards[i].suit == suit) then return true end end
	return false
end

function card_power(card)
	if card == '2' then return 2
	elseif card == '3' then return 3
	elseif card == '4' then return 4
	elseif card == '5' then	return 5
	elseif card == '6' then	return 6
	elseif card == '7' then	return 7
	elseif card == '8' then	return 8
	elseif card == '9' then	return 9
	elseif card == '10' then return 10
	elseif card == 'J' then	return 11
	elseif card == 'Q' then	return 12
	elseif card == 'K' then	return 13
	elseif card == 'T' then	return 14 end
end

function isCardWithPower(cards,power)
	for i=1,#cards do if (card_power(cards[i].card) == power) then return true end end
	return false
end

function getMaxCard(cards)
	local index = 1
	for i=2,#cards do if (card_power(cards[i]>card_power(cards[index].card))) then index = i end end
	return cards[index].card
end

function isStraight(cards)
	local temp_card = getMaxCard(cards)
	if (isCardWithPower(cards,2) and isCardWithPower(cards,3) and isCardWithPower(cards,4) and isCardWithPower(cards,5) and isCardWithPower(cards,14)) then return true end
	for i=1,4 do if (isCardWithPower(cards,card_power(temp_card)-i)==false) then return false end end
	return true
end

function isStraightFlush(cards)
	return (isStraight(cards) and isFlush(cards))
end

function isFlushRoyal(cards)
	return (isStraightFlush and isCardWithPower(cards,14) and isCardWithPower(cards,13))
end

function countOfCard(cards,card)
	local count = 0
	for i=1,#cards do if (cards[i].card == card) then count = count + 1 end end	return count
end

function isFourOfAKind(cards)
	for i=1,2 do if (countOfCard(cards,cards[i].card) == 4) return true end end
	return false
end

function isFullHous(cards)
	local trips,pair = false,false
	for i=1,4 do
		if (countOfCard(cards,cards[i].card) == 3) trips = true
		elseif (countOfCard(cards,cards[i].card) == 2) pair = true end end
	return (trips and pair)
end

function isTrips(cards)
	for i=1,3 do if (countOfCard(cards,cards[i].card) == 3)	return true	end	end
	return false
end

function isTwoPairs(cards)
	local count_of_pairs = 0
	for i=1,5 do if (countOfCard(cards,cards[i].card) == 2) count_of_pairs = count_of_pairs + 1 end end
	return (count_of_pairs == 4)
end

function isJackOrBetter(cards)
	for i=1,4 do if (countOfCard(cards,cards[i].card) == 2 and cards[i].card) return true end end
	return false
end

function get_combination(cards)
	if (isFlushRoyal(cards)) then return 1
	elseif(isStraightFlush(cards)) then return 2
	elseif(isFourOfAKind(cards)) then return 3
	elseif(isFullHous(cards)) then return 4
	elseif(isFlush(cards)) then return 5
	elseif(isStraight(cards)) then return 6
	elseif(isTrips(cards) then return 7
	elseif(isTwoPairs(cards) then return 8
	elseif(isJackOrBetter(cards)) then return 9
	else return 0 end
end

function drawDisplayForOneHand()
	gpu.setBackground(0x00221f)
	term.clear()
	gpu.setBackground(0x0000CD)
	gpu.setForeground(0xffffff)
	gpu.fill(3,2,36,18," ")
  
	gpu.setBackground(0x00221f)
	for i = 0,4 do gpu.fill(9+i*5,13,4,4,' ') end
	
	gpu.setBackground(0x0000CD)
	gpu.setForeground(0xffffff)
    gpu.set(10,3,'Флеш Рояль')
    gpu.set(10,4,'Стрит Флеш')
    gpu.set(10,5,'Каре')
    gpu.set(10,6,'Фул хаус')
    gpu.set(10,7,'Флеш')
    gpu.set(10,8,'Стрит')
    gpu.set(10,9,'Трипс')
    gpu.set(10,10,'Две пары')
    gpu.set(10,11,'Валеты и выше')
	
	gpu.setBackground(0x800000)
	local temp_x = 25
	gpu.set(temp_x,3,'    250')
    gpu.set(temp_x,4,'     50')
    gpu.set(temp_x,5,'     25')
    gpu.set(temp_x,6,'      9')
    gpu.set(temp_x,7,'      5')
    gpu.set(temp_x,8,'      4')
    gpu.set(temp_x,9,'      3')
    gpu.set(temp_x,10,'      2')
    gpu.set(temp_x,11,'      1')
	
	
	--ставка можна ставить ток 1 2 3 4 5
	

	
	gpu.setBackground(0x010101)
	gpu.set(3,18,'В меню')
	gpu.set(16,18,'Роздать')
	
	gpu.set(25,18,'1')
	gpu.set(27,18,'2')
	gpu.set(29,18,'3')
	gpu.set(31,18,'4')
	gpu.set(32,18,'5')

end

function startGame()
	blackjack = false
	players_cards = {}
	deck:hinder()
	
	drawDisplayForOneHand()
	give_card_player(0)
	give_card_player(1)
	give_card_player(2)
	give_card_player(3)
	give_card_player(4)

end

function give_card_player(id_card)
	gpu.setBackground(0xffffff)
	local card = deck:get()
	if card.suit == '♥' or card.suit == '♦' then
		gpu.setForeground(0xaa0000)
	else
		gpu.setForeground(0x000000)
	end
	if id_card == 0 then
		gpu.fill(9,13,4,4,' ')
		os.sleep(time_sleep)
		gpu.set(9,13,card.card)
		gpu.set(10,14,card.suit)
		gpu.set(11,15,card.suit)
		if card.card == '10' then
			gpu.set(11,16,card.card)
		else
			gpu.set(12,16,card.card)
		end
		os.sleep(time_sleep)
	elseif id_card == 1 then
		gpu.fill(14,13,4,4,' ')
		os.sleep(time_sleep)
		gpu.set(14,13,card.card)
		gpu.set(15,14,card.suit)
		gpu.set(16,15,card.suit)
		if card.card == '10' then
			gpu.set(16,16,card.card)
		else
			gpu.set(17,16,card.card)
		end
	elseif id_card == 2 then
		gpu.fill(19,13,4,4,' ')
		os.sleep(time_sleep)
		gpu.set(19,13,card.card)
		gpu.set(20,14,card.suit)
		gpu.set(21,15,card.suit)
		if card.card == '10' then
			gpu.set(21,16,card.card)
		else
			gpu.set(22,16,card.card)
		end
	elseif id_card == 3 then
		gpu.fill(24,13,4,4,' ')
		os.sleep(time_sleep)
		gpu.set(24,13,card.card)
		gpu.set(25,14,card.suit)
		gpu.set(26,15,card.suit)
		if card.card == '10' then
			gpu.set(26,16,card.card)
		else
			gpu.set(27,16,card.card)
		end
	elseif id_card == 4 then
		gpu.fill(29,13,4,4,' ')
		os.sleep(time_sleep)
		gpu.set(29,13,card.card)
		gpu.set(30,14,card.suit)
		gpu.set(31,15,card.suit)
		if card.card == '10' then
			gpu.set(31,16,card.card)
		else
			gpu.set(32,16,card.card)
		end
	end
	players_cards[id_card] = card
	os.sleep(time_sleep)
end

	
function drawDisplay()
	gpu.setBackground(0xe0e0e0)
	term.clear()
	gpu.setBackground(0x00aa00)
	gpu.fill(3,2,14,7,' ')
	gpu.setBackground(0xffffff)
	gpu.setForeground(0xaa0000)
	
	gpu.fill(5,3,4,4,' ')
	gpu.set(5,3,'J')
	gpu.set(6,4,'♥')
	gpu.set(7,5,'♥')
	gpu.set(8,6,'J')
	
	gpu.setForeground(0x000000)
	gpu.fill(11,4,4,4,' ')
	gpu.set(11,4,'T')
	gpu.set(12,5,'♠')
	gpu.set(13,6,'♠')
	gpu.set(14,7,'T')
	
	gpu.fill(3,10,36,10,' ')
	gpu.fill(19,2,20,7,' ')
	gpu.setForeground(0xffffff)						
	gpu.setBackground(0x00aa00)
	gpu.fill(32,5,6,3,' ')
	gpu.set(20,5,'1')
		value = 1
		gpu.set(32,6,'Начать')
		gpu.setForeground(0x000000)
		gpu.setBackground(0xffffff)

		gpu.set(21,3,'Выберите ставку')

	end
	
	function rewardPlayer(player,reward,msg)
	  localsay(msg)
	  localsay("Вы выиграли "..reward)
	  --Connector:give(player,reward)
	  os.sleep(time_sleep_end)
	  login = false
	  blackjack = false
	  drawDisplay()
	end
	
	drawDisplay()
	endtime = 0
	while true do
		::continue::
		local e,_,x,y,_,p = event.pull(3,"touch") 
		if (login) and os.time() > endtime then
				login = false
				blackjack = false
				drawDisplay()
				goto continue
		end
		if (login) and p == player then
			if blackjack then
				if (x>=9 and y==11 and x<=19) then rewardPlayer(player,value,"Black Jack!")
				elseif (x>=22 and y==11 and x<33) then

				end
			elseif x>=9 and y==11 and x<20 then
				give_card_player()
			elseif x>=22 and y==11 and x<33 then

			elseif x>=9 and y==13 and x<20 then
				if (#players_cards > 2) then
					localsay(p..", удвоить можна только с двумя картами на руках.")
				--elseif (Connector:pay(p,value)) then
					gpu.setBackground(0x00aa00)
					value=value*2
					gpu.setForeground(0xffffff)
					gpu.set(13,4,"Ставка: "..value)
					give_card_player()
					if (login) then

					end
				else
					localsay(p..", у вас нет столько денег. Пополните счёт в ближайшем терминале.")
				end
			end
		elseif login == false and e == 'touch' then    
			if (x >=32 and x<=37 and y >=5 and y<=7) then
				--if (Connector:pay(p,value)) then
				if (true) then
					player = p
					login = true
					endtime = os.time()+1640
					startGame()
				else
					localsay(p..", у вас нет столько денег. Пополните счёт в ближайшем терминале.")
				end
			end
		end
	end