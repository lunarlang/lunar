local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local Identifier = require("lunar.ast.exprs.identifier")
local MemberExpression = require("lunar.ast.exprs.member_expression")
local AssignmentStatement = require("lunar.ast.stats.assignment_statement")
local SelfAssignmentOpKind = require("lunar.ast.stats.self_assignment_op_kind")
local ClassFieldDeclaration = setmetatable({}, {
  __index = SyntaxNode,
})
ClassFieldDeclaration.__index = setmetatable({}, SyntaxNode)
function ClassFieldDeclaration.new(start_pos, end_pos, is_static, identifier, type_annotation, value)
  return ClassFieldDeclaration.constructor(setmetatable({}, ClassFieldDeclaration), start_pos, end_pos, is_static, identifier, type_annotation, value)
end
function ClassFieldDeclaration.constructor(self, start_pos, end_pos, is_static, identifier, type_annotation, value)
  SyntaxNode.constructor(self, SyntaxKind.class_field_declaration, start_pos, end_pos)
  self.is_static = is_static
  self.identifier = identifier
  self.type_annotation = type_annotation
  self.value = value
  return self
end
function ClassFieldDeclaration.__index:lower(class_member_expr)
  if self.value == nil then
    return nil
  end
  local lhs
  if self.is_static then
    lhs = class_member_expr
  else
    lhs = Identifier.new(nil, nil, "self")
  end
  local member_expr = MemberExpression.new(nil, nil, lhs, self.identifier)
  return AssignmentStatement.new(nil, nil, {
    member_expr,
  }, SelfAssignmentOpKind.equal_op, {
    self.value,
  })
end
return ClassFieldDeclaration
