local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ReturnStatement = setmetatable({}, {
  __index = SyntaxNode,
})
ReturnStatement.__index = setmetatable({}, SyntaxNode)
function ReturnStatement.new(exprlist)
  return ReturnStatement.constructor(setmetatable({}, ReturnStatement), exprlist)
end
function ReturnStatement.constructor(self, exprlist)
  SyntaxNode.constructor(self, SyntaxKind.return_statement)
  self.exprlist = exprlist
  return self
end
return ReturnStatement
