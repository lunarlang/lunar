local Symbol = {}
Symbol.__index = {}

function Symbol.constructor(self, name)
	self.name = name
	self.is_referenced = false
	self.is_assigned = false

	self.members = nil -- SymbolTable | nil
end

Symbol.__tostring = function(self)
	return "Symbol (" .. self.name .. ")"
end

function Symbol.new(...)
	local self = setmetatable({}, Symbol)
	Symbol.constructor(self, ...)
	return self
end

return Symbol