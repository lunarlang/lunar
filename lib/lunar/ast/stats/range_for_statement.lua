local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local RangeForStatement = setmetatable({}, {
  __index = SyntaxNode,
})
RangeForStatement.__index = setmetatable({}, SyntaxNode)
function RangeForStatement.new(identifier, start_expr, end_expr, incremental_expr, block)
  return RangeForStatement.constructor(setmetatable({}, RangeForStatement), identifier, start_expr, end_expr, incremental_expr, block)
end
function RangeForStatement.constructor(self, identifier, start_expr, end_expr, incremental_expr, block)
  SyntaxNode.constructor(self, SyntaxKind.range_for_statement)
  self.identifier = identifier
  self.start_expr = start_expr
  self.end_expr = end_expr
  self.incremental_expr = incremental_expr
  self.block = block
  return self
end
return RangeForStatement
