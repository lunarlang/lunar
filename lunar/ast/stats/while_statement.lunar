local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local WhileStatement = setmetatable({}, SyntaxNode)
WhileStatement.__index = WhileStatement

function WhileStatement.new(expr, block)
  local super = SyntaxNode.new(SyntaxKind.while_statement)
  local self = setmetatable(super, WhileStatement)
  self.expr = expr
  self.block = block

  return self
end

return WhileStatement
