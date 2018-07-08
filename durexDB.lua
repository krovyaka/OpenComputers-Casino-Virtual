local internet = require("internet")
local serialization = require("serialization")
DurexDatabase = {}

function DurexDatabase:new(token)

	local obj= {}
        obj.token = token
	obj.url = "http://durex77.pythonanywhere.com/"

	function obj:setToken(token)
		self.token = token
	end

	function obj:get(nick)
		for temp in internet.request(self.url.."users/get?name="..nick.."&token="..self.token) do      
			return tonumber(temp)
		end
	end

	function obj:pay(nick,money)
		for temp in internet.request(self.url.."users/pay?name="..nick.."&token="..self.token.."&money="..money) do
			return temp == "True"
		end
	end

	function obj:give(nick,money)
		for temp in internet.request(self.url.."users/give?name="..nick.."&token="..self.token.."&money="..money) do
			return temp == "True"
		end
	end

  function obj:top()
    local result = ""
		for temp in internet.request(self.url.."krov/users/top") do
			result = result .. temp
		end
    result = serialization.unserialize(result)
    return result
	end

  function obj:time()
    for temp in internet.request(self.url.."krov/get/time") do
			return tonumber(temp)
		end
	end

	setmetatable(obj, self)
	self.__index = self; return obj
end