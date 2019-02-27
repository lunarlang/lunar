local SymbolTable = require "lunar.compiler.semantic.symbol_table"
local SourceFileReturns = require "lunar.compiler.semantic.source_file_returns"
local CoreGlobals = require "lunar.compiler.semantic.core_globals"

local ProjectEnvironment = {}
ProjectEnvironment.__index = {}

function ProjectEnvironment.constructor(self)
  self.globals = SymbolTable.new()
  self:inject_globals(CoreGlobals)
  self.returns_map = {}
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

function ProjectEnvironment.__index:add_returns_value(source_path, symbol)
  local existing = self.returns_map[source_path]
  if existing then
    if existing.is_ast then
      error("Cannot export and return values at the same time")
    end
    if not existing.values then
      existing.values = {}
    end
    existing.values[symbol.name] = symbol
  else
    local returns = SourceFileReturns.new()
    returns.values = {[symbol.name] = symbol}
    self.returns_map[source_path] = returns
  end
end

function ProjectEnvironment.__index:add_returns_type(source_path, symbol)
  local returns = self.returns_map[source_path]
  if not returns then
    returns = SourceFileReturns.new()
    self.returns_map[source_path] = returns
  end

  returns.types[symbol.name] = symbol
end

function ProjectEnvironment.__index:set_returns_expression(source_path, ast)
  local existing = self.returns_map[source_path]
  if existing then
    if existing.ast then
      error("Cannot re-declare return values")
    elseif existing.values then
      error("Cannot export and return values at the same time")
    end
    existing.ast = ast
  else
    local returns = SourceFileReturns.new()
    returns.ast = ast
    self.returns_map[source_path] = returns
  end
end

function ProjectEnvironment.__index:get_returns_expression(source_path)
  return self.returns_map[source_path] and self.returns_map[source_path].ast
end

function ProjectEnvironment.__index:get_returns_value(source_path, value_name)
  return self.returns_map[source_path] and self.returns_map[source_path].values and self.returns_map[source_path][value_name]
end

function ProjectEnvironment.__index:get_returns_type(source_path, type_name)
  return self.returns_map[source_path] and self.returns_map[source_path].types[type_name]
end

return ProjectEnvironment