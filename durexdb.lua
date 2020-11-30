local internet = require("internet")
local serialization = require("serialization")
DurexDatabase = {}

function DurexDatabase:new(token)

	local obj= {}
        obj.token = token
	obj.url = "http://durex77.pythonanywhere.com/users/"

	function obj:setToken(token)
		self.token = token
	end

	function obj:get(nick)
		for temp in internet.request(self.url.."get?name="..nick.."&token="..self.token) do      
			return tonumber(temp)
		end
	end

	function obj:getTime()
		for temp in internet.request("http://durex77.pythonanywhere.com/get/time") do      
			return tonumber(temp)
		end
	end

	function obj:pay(nick,money)
		for temp in internet.request(self.url.."pay?name="..nick.."&token="..self.token.."&money="..money) do
			return temp == "True"
		end
	end

	function obj:give(nick,money)
		for temp in internet.request(self.url.."give?name="..nick.."&token="..self.token.."&money="..money) do
			return temp == "True"
		end
	end
  
  function obj:top()
		for temp in internet.request(self.url.."top") do
			return serialization.unserialize(temp)
		end
	end
  
	setmetatable(obj, self)
	self.__index = self; return obj
end
