local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local IfStatement = setmetatable({}, SyntaxNode)
IfStatement.__index = IfStatement

function IfStatement.new(expr, block)
  local super = SyntaxNode.new(SyntaxKind.if_statement)
  local self = setmetatable(super, IfStatement)
  self.expr = expr -- unless else branch
  self.block = block
  self.elseif_branches = {}
  self.else_branch = nil

  return self
end

function IfStatement:push_elseif(if_statement)
  table.insert(self.elseif_branches, if_statement)
  return self
end

function IfStatement:set_else(if_statement)
  self.else_branch = if_statement
  return self
end

return IfStatement
