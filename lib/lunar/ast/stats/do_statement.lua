local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DoStatement = setmetatable({}, { __index = SyntaxNode })
DoStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function DoStatement.new(block)
  return DoStatement.constructor(setmetatable({}, DoStatement), block)
end
function DoStatement.constructor(self, block)
  super(self, SyntaxKind.do_statement)
  self.block = block
  return self
end
return DoStatement
