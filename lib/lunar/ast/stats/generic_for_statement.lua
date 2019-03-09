local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local GenericForStatement = setmetatable({}, {
  __index = SyntaxNode,
})
GenericForStatement.__index = setmetatable({}, SyntaxNode)
function GenericForStatement.new(identifiers, exprlist, block)
  return GenericForStatement.constructor(setmetatable({}, GenericForStatement), identifiers, exprlist, block)
end
function GenericForStatement.constructor(self, identifiers, exprlist, block)
  SyntaxNode.constructor(self, SyntaxKind.generic_for_statement)
  self.identifiers = identifiers
  self.exprlist = exprlist
  self.block = block
  return self
end
return GenericForStatement
