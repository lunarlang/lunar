local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local WhileStatement = setmetatable({}, {
  __index = SyntaxNode,
})
WhileStatement.__index = setmetatable({}, SyntaxNode)
function WhileStatement.new(expr, block)
  return WhileStatement.constructor(setmetatable({}, WhileStatement), expr, block)
end
function WhileStatement.constructor(self, expr, block)
  local super = SyntaxNode.new(SyntaxKind.while_statement)
  local self = setmetatable(super, WhileStatement)
  self.expr = expr
  self.block = block
  return self
end
return WhileStatement
