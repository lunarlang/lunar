local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local RepeatUntilStatement = setmetatable({}, { __index = SyntaxNode })
RepeatUntilStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function RepeatUntilStatement.new(block, expr)
  return RepeatUntilStatement.constructor(setmetatable({}, RepeatUntilStatement), block, expr)
end
function RepeatUntilStatement.constructor(self, block, expr)
  super(self, SyntaxKind.repeat_until_statement)
  self.block = block
  self.expr = expr
  return self
end
return RepeatUntilStatement
