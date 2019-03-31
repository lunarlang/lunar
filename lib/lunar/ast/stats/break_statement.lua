local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BreakStatement = setmetatable({}, {
  __index = SyntaxNode,
})
BreakStatement.__index = setmetatable({}, SyntaxNode)
function BreakStatement.new(start_pos, end_pos)
  return BreakStatement.constructor(setmetatable({}, BreakStatement), start_pos, end_pos)
end
function BreakStatement.constructor(self, start_pos, end_pos)
  SyntaxNode.constructor(self, SyntaxKind.break_statement, start_pos, end_pos)
  return self
end
return BreakStatement
