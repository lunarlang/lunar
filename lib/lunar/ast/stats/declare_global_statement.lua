local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DeclareGlobalStatement = setmetatable({}, { __index = SyntaxNode })
DeclareGlobalStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function DeclareGlobalStatement.new(identifier, is_type_declaration)
  return DeclareGlobalStatement.constructor(setmetatable({}, DeclareGlobalStatement), identifier, is_type_declaration)
end
function DeclareGlobalStatement.constructor(self, identifier, is_type_declaration)
  super(self, SyntaxKind.declare_global_statement)
  self.identifier = identifier
  self.is_type_declaration = is_type_declaration
  return self
end
return DeclareGlobalStatement
