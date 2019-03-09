local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local GenericForStatement = setmetatable({}, SyntaxNode)
GenericForStatement.__index = GenericForStatement

function GenericForStatement.new(identifiers, exprlist, block)
  local super = SyntaxNode.new(SyntaxKind.generic_for_statement)
  local self = setmetatable(super, GenericForStatement)
  self.identifiers = identifiers
  self.exprlist = exprlist
  self.block = block

  return self
end

return GenericForStatement
