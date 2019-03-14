local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local IndexExpression = setmetatable({}, { __index = SyntaxNode })
IndexExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function IndexExpression.new(base, index)
  return IndexExpression.constructor(setmetatable({}, IndexExpression), base, index)
end
function IndexExpression.constructor(self, base, index)
  super(self, SyntaxKind.index_expression)
  self.base = base
  self.index = index
  return self
end
return IndexExpression
