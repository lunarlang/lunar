local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local SequentialFieldDeclaration = setmetatable({}, { __index = SyntaxNode })
SequentialFieldDeclaration.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function SequentialFieldDeclaration.new(value)
  return SequentialFieldDeclaration.constructor(setmetatable({}, SequentialFieldDeclaration), value)
end
function SequentialFieldDeclaration.constructor(self, value)
  super(self, SyntaxKind.sequential_field_declaration)
  self.value = value
  return self
end
return SequentialFieldDeclaration
