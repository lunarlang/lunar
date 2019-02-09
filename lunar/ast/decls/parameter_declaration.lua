local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local ParameterDeclaration = setmetatable({}, SyntaxNode)
ParameterDeclaration.__index = ParameterDeclaration

function ParameterDeclaration.new(name)
  local super = SyntaxNode.new(SyntaxKind.parameter_declaration)
  local self = setmetatable(super, ParameterDeclaration)
  self.name = name

  return self
end

return ParameterDeclaration
