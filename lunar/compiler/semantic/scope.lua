local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local Scope = {}
Scope.__index = {}

function Scope.constructor(self, level, parent)
  self.level = level
	self.parent = parent
	self.symbol_table = SymbolTable.new()
end

function Scope.__index:get(name)
	return self.symbol_table:get(name) or self.parent and self.parent:get(name)
end

function Scope.__index:has(name)
	return self.symbol_table:has(name) or self.parent and self.parent:has(name)
end

function Scope.__index:add(symbol)
  self.symbol_table:add(symbol)
end

function Scope.new(...)
	local self = setmetatable({}, Scope)
	Scope.constructor(self, ...)
	return self
end

return Scope