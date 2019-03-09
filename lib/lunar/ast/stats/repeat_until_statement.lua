local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local RepeatUntilStatement = setmetatable({}, SyntaxNode)
RepeatUntilStatement.__index = RepeatUntilStatement
function RepeatUntilStatement.new(block, expr)
  local super = SyntaxNode.new(SyntaxKind.repeat_until_statement)
  local self = setmetatable(super, RepeatUntilStatement)
  self.block = block
  self.expr = expr
  return self
end
return RepeatUntilStatement
