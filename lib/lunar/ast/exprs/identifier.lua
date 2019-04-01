local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local Identifier = setmetatable({}, {
  __index = SyntaxNode,
})
Identifier.__index = setmetatable({}, SyntaxNode)
function Identifier.new(start_pos, end_pos, name, type_annotation)
  return Identifier.constructor(setmetatable({}, Identifier), start_pos, end_pos, name, type_annotation)
end
function Identifier.constructor(self, start_pos, end_pos, name, type_annotation)
  SyntaxNode.constructor(self, SyntaxKind.identifier, start_pos, end_pos)
  self.name = name
  self.type_annotation = type_annotation
  return self
end
return Identifier
