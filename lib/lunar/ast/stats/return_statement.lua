local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ReturnStatement = setmetatable({}, {
  __index = SyntaxNode,
})
ReturnStatement.__index = setmetatable({}, SyntaxNode)
function ReturnStatement.new(start_pos, end_pos, exprlist)
  return ReturnStatement.constructor(setmetatable({}, ReturnStatement), start_pos, end_pos, exprlist)
end
function ReturnStatement.constructor(self, start_pos, end_pos, exprlist)
  SyntaxNode.constructor(self, SyntaxKind.return_statement, start_pos, end_pos)
  self.exprlist = exprlist
  return self
end
return ReturnStatement
