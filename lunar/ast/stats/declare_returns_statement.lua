local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local DeclareReturnsStatement = setmetatable({}, SyntaxNode)
DeclareReturnsStatement.__index = DeclareReturnsStatement

function DeclareReturnsStatement.new(type_expr)
  local super = SyntaxNode.new(SyntaxKind.declare_returns_statement)
  local self = setmetatable(super, DeclareReturnsStatement)
  self.type_expr = type_expr

  return self
end

return DeclareReturnsStatement
