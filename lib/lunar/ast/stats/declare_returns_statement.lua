local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DeclareReturnsStatement = setmetatable({}, {
  __index = SyntaxNode,
})
DeclareReturnsStatement.__index = setmetatable({}, SyntaxNode)
function DeclareReturnsStatement.new(start_pos, end_pos, type_expr)
  return DeclareReturnsStatement.constructor(setmetatable({}, DeclareReturnsStatement), start_pos, end_pos, type_expr)
end
function DeclareReturnsStatement.constructor(self, start_pos, end_pos, type_expr)
  SyntaxNode.constructor(self, SyntaxKind.declare_returns_statement, start_pos, end_pos)
  self.type_expr = type_expr
  return self
end
return DeclareReturnsStatement
