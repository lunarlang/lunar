local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BreakStatement = setmetatable({}, { __index = SyntaxNode })
BreakStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function BreakStatement.new()
  return BreakStatement.constructor(setmetatable({}, BreakStatement))
end
function BreakStatement.constructor(self)
  super(self, SyntaxKind.break_statement)
  return self
end
return BreakStatement
