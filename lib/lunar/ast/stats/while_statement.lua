local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local WhileStatement = setmetatable({}, {
  __index = SyntaxNode,
})
WhileStatement.__index = setmetatable({}, SyntaxNode)
function WhileStatement.new(start_pos, end_pos, expr, block)
  return WhileStatement.constructor(setmetatable({}, WhileStatement), start_pos, end_pos, expr, block)
end
function WhileStatement.constructor(self, start_pos, end_pos, expr, block)
  SyntaxNode.constructor(self, SyntaxKind.while_statement, start_pos, end_pos)
  self.expr = expr
  self.block = block
  return self
end
return WhileStatement
