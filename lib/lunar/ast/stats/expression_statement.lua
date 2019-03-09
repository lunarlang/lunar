local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local ExpressionStatement = setmetatable({}, SyntaxNode)
ExpressionStatement.__index = ExpressionStatement

function ExpressionStatement.new(expr)
  local super = SyntaxNode.new(SyntaxKind.expression_statement)
  local self = setmetatable(super, ExpressionStatement)
  self.expr = expr

  return self
end

return ExpressionStatement
