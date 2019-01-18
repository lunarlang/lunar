local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local ReturnStatement = setmetatable({}, SyntaxNode)
ReturnStatement.__index = ReturnStatement

function ReturnStatement.new(...)
  local super = SyntaxNode.new(SyntaxKind.return_statement, ...)
  local self = setmetatable(super, ReturnStatement)

  return self
end

return ReturnStatement
