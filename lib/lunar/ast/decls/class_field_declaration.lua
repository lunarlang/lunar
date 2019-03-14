local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local Identifier = require("lunar.ast.exprs.identifier")
local MemberExpression = require("lunar.ast.exprs.member_expression")
local AssignmentStatement = require("lunar.ast.stats.assignment_statement")
local SelfAssignmentOpKind = require("lunar.ast.stats.self_assignment_op_kind")
local ClassFieldDeclaration = setmetatable({}, { __index = SyntaxNode })
ClassFieldDeclaration.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function ClassFieldDeclaration.new(is_static, identifier, type_annotation, value)
  return ClassFieldDeclaration.constructor(setmetatable({}, ClassFieldDeclaration), is_static, identifier, type_annotation, value)
end
function ClassFieldDeclaration.constructor(self, is_static, identifier, type_annotation, value)
  super(self, SyntaxKind.class_field_declaration)
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
    lhs = Identifier.new("self")
  end
  local member_expr = MemberExpression.new(lhs, self.identifier)
  return AssignmentStatement.new({
    member_expr,
  }, SelfAssignmentOpKind.equal_op, {
    self.value,
  })
end
return ClassFieldDeclaration
