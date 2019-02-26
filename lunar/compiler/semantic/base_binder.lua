local BaseBinder = {}
BaseBinder.__index = {}

--[[
    A binder should take in an AST and mutate its nodes by binding symbols
]]

function BaseBinder.constructor(self)
  self.container = nil
end

function BaseBinder.new()
  local self = setmetatable({}, BaseBinder)
  BaseBinder.constructor(self)
  return self
end

--[[ Adds a node to the linked list of containers ]]
function BaseBinder.__index:push_container(node)
  node.last_symbol_container = self.container
  self.container = node
end

--[[ Removes the last container from the linked list of containers and returns it]]
function BaseBinder.__index:pop_container()
  self.container = self.container.last_symbol_container
  return self.container
end

return BaseBinder