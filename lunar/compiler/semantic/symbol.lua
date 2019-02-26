local Symbol = {}
Symbol.__index = {}

function Symbol.constructor(self, name)
	self.name = name
end

function Symbol.new(name)
	local self = setmetatable({}, Symbol)
	Symbol.constructor(self, name)
	return self
end

Symbol.__tostring = function(self)
	return "Symbol (" .. self.name .. ")"
end

return Symbol