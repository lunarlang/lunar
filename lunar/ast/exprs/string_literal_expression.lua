local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local StringLiteralExpression = setmetatable({}, SyntaxNode)
StringLiteralExpression.__index = StringLiteralExpression

function StringLiteralExpression.new(value)
  local super = SyntaxNode.new(SyntaxKind.string_literal_expression)
  local self = setmetatable(super, StringLiteralExpression)
  self.value = value

  return self
end

return StringLiteralExpression
