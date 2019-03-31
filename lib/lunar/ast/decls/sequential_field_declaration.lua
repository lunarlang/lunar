local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local SequentialFieldDeclaration = setmetatable({}, {
  __index = SyntaxNode,
})
SequentialFieldDeclaration.__index = setmetatable({}, SyntaxNode)
function SequentialFieldDeclaration.new(start_pos, end_pos, value)
  return SequentialFieldDeclaration.constructor(setmetatable({}, SequentialFieldDeclaration), start_pos, end_pos, value)
end
function SequentialFieldDeclaration.constructor(self, start_pos, end_pos, value)
  SyntaxNode.constructor(self, SyntaxKind.sequential_field_declaration, start_pos, end_pos)
  self.value = value
  return self
end
return SequentialFieldDeclaration
