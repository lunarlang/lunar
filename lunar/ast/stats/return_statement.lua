local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local ReturnStatement = setmetatable({}, SyntaxNode)
ReturnStatement.__index = ReturnStatement

function ReturnStatement.new(explist)
  local super = SyntaxNode.new(SyntaxKind.return_statement)
  local self = setmetatable(super, ReturnStatement)
  self.explist = explist

  return self
end

return ReturnStatement
