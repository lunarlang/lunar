local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DeclareGlobalStatement = setmetatable({}, {
  __index = SyntaxNode,
})
DeclareGlobalStatement.__index = setmetatable({}, SyntaxNode)
function DeclareGlobalStatement.new(start_pos, end_pos, identifier, is_type_declaration)
  return DeclareGlobalStatement.constructor(setmetatable({}, DeclareGlobalStatement), start_pos, end_pos, identifier, is_type_declaration)
end
function DeclareGlobalStatement.constructor(self, start_pos, end_pos, identifier, is_type_declaration)
  SyntaxNode.constructor(self, SyntaxKind.declare_global_statement, start_pos, end_pos)
  self.identifier = identifier
  self.is_type_declaration = is_type_declaration
  return self
end
return DeclareGlobalStatement
