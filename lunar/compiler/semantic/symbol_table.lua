local SymbolTable = {}
SymbolTable.__index = {}

function SymbolTable.constructor(self)
	self.symbols = {}
end

function SymbolTable.__index:get(name)
	for i = #self.symbols, 1, -1 do
		if self.symbols[i].name == name then
			return self.symbols[i]
		end
	end
end

function SymbolTable.__index:has(name)
	for i = 1, #self.symbols do
		if self.symbols[i].name == name then
			return true
		end
	end
	return false
end

function SymbolTable.__index:add(symbol)
	table.insert(self.symbols, symbol)
end

function SymbolTable.new(...)
	local self = setmetatable({}, SymbolTable)
	SymbolTable.constructor(self, ...)
	return self
end

return SymbolTable