local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local BreakStatement = setmetatable({}, SyntaxNode)
BreakStatement.__index = BreakStatement

function BreakStatement.new()
  local super = SyntaxNode.new(SyntaxKind.break_statement)
  local self = setmetatable(super, BreakStatement)

  return self
end

return BreakStatement
