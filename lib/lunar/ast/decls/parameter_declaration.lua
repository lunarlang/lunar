local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ParameterDeclaration = setmetatable({}, {
  __index = SyntaxNode,
})
ParameterDeclaration.__index = setmetatable({}, SyntaxNode)
function ParameterDeclaration.new(start_pos, end_pos, identifier)
  return ParameterDeclaration.constructor(setmetatable({}, ParameterDeclaration), start_pos, end_pos, identifier)
end
function ParameterDeclaration.constructor(self, start_pos, end_pos, identifier)
  SyntaxNode.constructor(self, SyntaxKind.parameter_declaration, start_pos, end_pos)
  self.identifier = identifier
  return self
end
return ParameterDeclaration
