local SymbolTable = {}
SymbolTable.__index = {}

function SymbolTable.constructor(self)
	self.values = {}
	self.types = {}
end

function SymbolTable.__index:get_value(name)
	return self.values[name]
end

function SymbolTable.__index:get_type(name)
	return self.types[name]
end

function SymbolTable.__index:has_value(name)
	return self.values[name] ~= nil
end

function SymbolTable.__index:has_type(name)
	return self.types[name] ~= nil
end

function SymbolTable.__index:add_value(symbol)
	if self.values[symbol.name] then
		error("Duplicate value symbol '" .. symbol.name .. "' was declared in the same scope")
	else
		self.values[symbol.name] = symbol
	end
end

function SymbolTable.__index:add_type(symbol)
	if self.types[symbol.name] then
		error("Duplicate type symbol '" .. symbol.name .. "' was declared in the same scope")
	else
		self.types[symbol.name] = symbol
	end
end

function SymbolTable.new(...)
	local self = setmetatable({}, SymbolTable)
	SymbolTable.constructor(self, ...)
	return self
end

return SymbolTable