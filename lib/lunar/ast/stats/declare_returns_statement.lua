local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DeclareReturnsStatement = setmetatable({}, {
  __index = SyntaxNode,
})
DeclareReturnsStatement.__index = setmetatable({}, SyntaxNode)
function DeclareReturnsStatement.new(type_expr)
  return DeclareReturnsStatement.constructor(setmetatable({}, DeclareReturnsStatement), type_expr)
end
function DeclareReturnsStatement.constructor(self, type_expr)
  SyntaxNode.constructor(self, SyntaxKind.declare_returns_statement)
  self.type_expr = type_expr
  return self
end
return DeclareReturnsStatement
