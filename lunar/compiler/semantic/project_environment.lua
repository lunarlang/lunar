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
  self.returns_map = {} -- public returns_map: ReturnsMap
  self.visited_sources_map = {} -- Map<string, boolean> - A map determining whether or not a source file in the project
                                -- environment was visited to the binding stage
  self.globals = SymbolTable.new()
  self:inject_globals(CoreGlobals)
end

function ProjectEnvironment.new(...)
  local self = setmetatable({}, ProjectEnvironment)
  ProjectEnvironment.constructor(self, ...)
  return self
end

function ProjectEnvironment.__index:declare_visited_source(source_path_dot)
  if self.visited_sources_map[source_path_dot] then
    error("Multiple files found at the same path: '" .. source_path_dot .. "'")
  end
  self.visited_sources_map[source_path_dot] = true
end

function ProjectEnvironment.__index:get_unvisited_sources()
  local unvisited_sources = {}
  for path, was_visited in pairs(self.visited_sources_map) do
    if not was_visited then
      table.insert(unvisited_sources, path)
    end
  end

  return unvisited_sources
end

function ProjectEnvironment.__index:inject_globals(globals)
  for name, symbol in pairs(globals.values) do
    self.globals.values[name] = symbol
  end
  for name, symbol in pairs(globals.types) do
    self.globals.types[name] = symbol
  end
end

function ProjectEnvironment.__index:add_exports_value(source_path_dot, symbol)
  local existing = self.returns_map[source_path_dot]
  if existing then
    if existing.declaration then
      error("Cannot export and return values at the same time")
    end
    existing.exports:add_value(symbol)
  else
    local returns = Symbol.new()
    returns.exports = SymbolTable.new()
    returns.exports:add_value(symbol)
    self.returns_map[source_path_dot] = returns
    
    -- Mark as unbound reference
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end
  end
end

function ProjectEnvironment.__index:add_exports_type(source_path_dot, symbol)
  local existing = self.returns_map[source_path_dot]
  if existing then
    existing.exports:add_type(symbol)
  else
    local returns = Symbol.new()
    returns.exports = SymbolTable.new()
    returns.exports:add_value(symbol)
    self.returns_map[source_path_dot] = returns
    
    -- Mark as unbound reference
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end
  end
end

function ProjectEnvironment.__index:create_returns_symbol(source_path_dot)
  local existing = self.returns_map[source_path_dot]
  if existing then
    error("Cannot re-declare source file returns")
  else
    local returns = Symbol.new()
    returns.exports = SymbolTable.new()
    self.returns_map[source_path_dot] = returns
    
    -- Mark as unbound reference
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end

    return returns
  end
end

function ProjectEnvironment.__index:get_returns_symbol(source_path_dot)
  return self.returns_map[source_path_dot] and self.returns_map[source_path_dot]
end

function ProjectEnvironment.__index:get_exports_value(source_path_dot, value_name)
  return self.returns_map[source_path_dot] and self.returns_map[source_path_dot].exports:get_value(value_name)
end

function ProjectEnvironment.__index:get_exports_type(source_path_dot, type_name)
  return self.returns_map[source_path_dot] and self.returns_map[source_path_dot].exports:get_type(type_name)
end

return ProjectEnvironment