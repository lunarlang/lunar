local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DoStatement = setmetatable({}, {
  __index = SyntaxNode,
})
DoStatement.__index = setmetatable({}, SyntaxNode)
function DoStatement.new(start_pos, end_pos, block)
  return DoStatement.constructor(setmetatable({}, DoStatement), start_pos, end_pos, block)
end
function DoStatement.constructor(self, start_pos, end_pos, block)
  SyntaxNode.constructor(self, SyntaxKind.do_statement, start_pos, end_pos)
  self.block = block
  return self
end
return DoStatement
