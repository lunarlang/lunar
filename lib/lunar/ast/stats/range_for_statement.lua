local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local RangeForStatement = setmetatable({}, SyntaxNode)
RangeForStatement.__index = RangeForStatement
function RangeForStatement.new(identifier, start_expr, end_expr, incremental_expr, block)
  local super = SyntaxNode.new(SyntaxKind.range_for_statement)
  local self = setmetatable(super, RangeForStatement)
  self.identifier = identifier
  self.start_expr = start_expr
  self.end_expr = end_expr
  self.incremental_expr = incremental_expr
  self.block = block
  return self
end
return RangeForStatement
