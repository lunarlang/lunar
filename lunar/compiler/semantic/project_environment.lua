local SymbolTable = require "lunar.compiler.semantic.symbol_table"
local Symbol = require "lunar.compiler.semantic.symbol"
local CoreGlobals = require "lunar.compiler.semantic.core_globals"

local ProjectEnvironment = {}
ProjectEnvironment.__index = {}
--[[
interface ReturnsMap {
  symbol?: Symbol -- The symbol for all of the module's returns
    & statics: {
      values?: Map<string, Symbol> -- A map of exported symbols for the module's returns
      types: Map<string, Symbol>
    }
}
]]

function ProjectEnvironment.constructor(self)
  self.globals = SymbolTable.new()
  self:inject_globals(CoreGlobals)
  self.returns_map = {} -- public returns_map: ReturnsMap
  
end

function ProjectEnvironment.new(...)
  local self = setmetatable({}, ProjectEnvironment)
  ProjectEnvironment.constructor(self, ...)
  return self
end

function ProjectEnvironment.__index:inject_globals(globals)
  for name, symbol in pairs(globals.values) do
    self.globals.values[name] = symbol
  end
  for name, symbol in pairs(globals.types) do
    self.globals.types[name] = symbol
  end
end

function ProjectEnvironment.__index:add_exports_value(source_path, symbol)
  local existing = self.returns_map[source_path]
  if existing then
    if existing.declaration then
      error("Cannot export and return values at the same time")
    end
    existing.statics:add_value(symbol)
  else
    local returns = Symbol.new()
    returns.statics = SymbolTable.new()
    returns.statics:add_value(symbol)
    self.returns_map[source_path] = returns
  end
end

function ProjectEnvironment.__index:add_exports_type(source_path, symbol)
  local existing = self.returns_map[source_path]
  if existing then
    existing.statics:add_type(symbol)
  else
    local returns = Symbol.new()
    returns.statics = SymbolTable.new()
    returns.statics:add_value(symbol)
    self.returns_map[source_path] = returns
  end
end

function ProjectEnvironment.__index:create_returns_symbol(source_path)
  local existing = self.returns_map[source_path]
  if existing then
    error("Cannot re-declare source file returns")
  else
    local returns = Symbol.new()
    returns.statics = SymbolTable.new()
    self.returns_map[source_path] = returns

    return returns
  end
end

function ProjectEnvironment.__index:get_returns_symbol(source_path)
  return self.returns_map[source_path] and self.returns_map[source_path]
end

function ProjectEnvironment.__index:get_exports_value(source_path, value_name)
  return self.returns_map[source_path] and self.returns_map[source_path]:get_value(value_name)
end

function ProjectEnvironment.__index:get_exports_type(source_path, type_name)
  return self.returns_map[source_path] and self.returns_map[source_path]:get_type(type_name)
end

return ProjectEnvironment