local Scope = require "lunar.compiler.semantic.scope"
local Symbol = require "lunar.compiler.semantic.symbol"
local ProjectEnvironment = require "lunar.compiler.semantic.project_environment"

local BaseBinder = {}
BaseBinder.__index = {}

--[[
    A binder should take in an AST and mutate its nodes by binding symbols
]]

function BaseBinder.constructor(self, environment, file_path)
  self.scope = nil
  self.level = 0
  self.last_vararg = nil
  self.default_env_cache = nil
  self.environment = environment or ProjectEnvironment.new()
  self.file_path = self.file_path or "src"
end

function BaseBinder.new(...)
  local self = setmetatable({}, BaseBinder)
  BaseBinder.constructor(self, ...)
  return self
end

--[[ Adds to the linked list of scopes ]]
function BaseBinder.__index:push_scope(incrementLevel, reset_varargs)
  if incrementLevel then
    self.level = self.level + 1
  end
  self.scope = Scope.new(self.level, self.scope, self.environment)
  if self.reset_varargs then
    self.last_vararg = nil
  end

  return self.scope
end

--[[ Registers a vararg parameter declaration ]]
function BaseBinder.__index:declare_varargs(symbol, declaration)
  symbol.is_assigned = true
  symbol.declaration = declaration
  self.last_vararg = symbol
end

--[[ Determines whether varargs can be accessed in the current scope ]]
function BaseBinder.__index:get_last_vararg_symbol()
  return self.last_vararg
end

--[[ Removes all scopes at the current level ]]
function BaseBinder.__index:pop_level_scopes()
  local removed_scopes = {}
  repeat
    table.insert(removed_scopes, self.scope)
    self.scope = self.scope.parent
  until not self.scope or self.scope.level < self.level
  self.level = self.level - 1

  return removed_scopes
end

--[[ Creates a new symbol in the current scope if it does not exist, and binds it to a given node ]]
function BaseBinder.__index:bind_local_value_symbol(node, name)
  local existing = self.scope:get_value(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.scope:add_value(symbol)
  
    return symbol
  end
end

--[[ Creates a new symbol in the global scope if it does not exist, and binds it to a given node ]]
function BaseBinder.__index:bind_global_value_symbol(node, name)
  local existing = self.environment.globals:get_value(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.environment.globals:add_value(symbol)
  
    return symbol
  end
end

--[[ Creates a new symbol in the current scope if it does not exist, and binds it to a given node.
Returns the registered symbol ]]
function BaseBinder.__index:bind_local_type_symbol(node, name)
  local existing = self.scope:get_type(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.scope:add_type(symbol)
  
    return symbol
  end
end

--[[ Creates a new symbol in the global scope if it does not exist, and binds it to a given node.
Returns the registered symbol ]]
function BaseBinder.__index:bind_global_type_symbol(node, name)
  local existing = self.environment.globals:get_type(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.environment.globals:add_type(symbol)
  
    return symbol
  end
end

return BaseBinder
