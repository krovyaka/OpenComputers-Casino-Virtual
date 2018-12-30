local internet = require("internet")
local serialization = require("serialization")
CasinoConnector = {}

function CasinoConnector:new(token, ip)

	local obj= {}
        obj.token = token
	obj.url = "http://" .. ip ..":8080/openComputersCasino/api/"

	function obj:setToken(token)
		self.token = token
	end

	function obj:get(nick)
		for temp in internet.request(self.url.."money/get?name="..nick.."&token="..self.token) do      
			return tonumber(temp)
		end
	end

	function obj:pay(nick,money)
		for temp in internet.request(self.url.."money/pay?name="..nick.."&token="..self.token.."&qty="..money) do
			return temp == "true"
		end
	end

	function obj:give(nick,money)
		for temp in internet.request(self.url.."money/add?name="..nick.."&token="..self.token.."&qty="..money) do
			return temp == "true"
		end
	end

  function obj:top(qty,isReverse)
    if (isReverse) then
        isReverse = "true"
    else
        isReverse = "false"
    end
    local result = ""
		for temp in internet.request(self.url.."money/top?qty="..qty.."&reverse="..isReverse.."&token="..self.token) do
			result = result .. temp
		end
    result = serialization.unserialize(result)
    return result
	end

	setmetatable(obj, self)
	self.__index = self; return obj
end