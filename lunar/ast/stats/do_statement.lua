local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local DoStatement = setmetatable({}, SyntaxNode)
DoStatement.__index = DoStatement

function DoStatement.new(...)
  local block = { ... }

  local super = SyntaxNode.new(SyntaxKind.do_statement)
  local self = setmetatable(super, DoStatement)
  self.block = block

  return self
end

return DoStatement
