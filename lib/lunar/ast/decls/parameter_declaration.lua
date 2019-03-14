local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ParameterDeclaration = setmetatable({}, { __index = SyntaxNode })
ParameterDeclaration.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function ParameterDeclaration.new(identifier)
  return ParameterDeclaration.constructor(setmetatable({}, ParameterDeclaration), identifier)
end
function ParameterDeclaration.constructor(self, identifier)
  super(self, SyntaxKind.parameter_declaration)
  self.identifier = identifier
  return self
end
return ParameterDeclaration
