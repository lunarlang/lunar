local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local RepeatUntilStatement = setmetatable({}, {
  __index = SyntaxNode,
})
RepeatUntilStatement.__index = setmetatable({}, SyntaxNode)
function RepeatUntilStatement.new(start_pos, end_pos, block, expr)
  return RepeatUntilStatement.constructor(setmetatable({}, RepeatUntilStatement), start_pos, end_pos, block, expr)
end
function RepeatUntilStatement.constructor(self, start_pos, end_pos, block, expr)
  SyntaxNode.constructor(self, SyntaxKind.repeat_until_statement, start_pos, end_post)
  self.block = block
  self.expr = expr
  return self
end
return RepeatUntilStatement
