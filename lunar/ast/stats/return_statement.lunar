local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local ReturnStatement = setmetatable({}, SyntaxNode)
ReturnStatement.__index = ReturnStatement

function ReturnStatement.new(exprlist)
  local super = SyntaxNode.new(SyntaxKind.return_statement)
  local self = setmetatable(super, ReturnStatement)
  self.exprlist = exprlist

  return self
end

return ReturnStatement
