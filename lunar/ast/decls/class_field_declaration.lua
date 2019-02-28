local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local Identifier = require "lunar.ast.exprs.identifier"
local MemberExpression = require "lunar.ast.exprs.member_expression"
local AssignmentStatement = require "lunar.ast.stats.assignment_statement"
local SelfAssignmentOpKind = require "lunar.ast.stats.self_assignment_op_kind"

local ClassFieldDeclaration = setmetatable({}, SyntaxNode)
ClassFieldDeclaration.__index = ClassFieldDeclaration

function ClassFieldDeclaration.new(is_static, identifier, type_annotation, value)
  local super = SyntaxNode.new(SyntaxKind.class_field_declaration)
  local self = setmetatable(super, ClassFieldDeclaration)
  self.is_static = is_static
  self.identifier = identifier
  self.type_annotation = type_annotation
  self.value = value

  return self
end

function ClassFieldDeclaration:lower(class_member_expr)
  -- we don't transpile field members with no default value
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
  return AssignmentStatement.new({ member_expr }, SelfAssignmentOpKind.equal_op, { self.value })
end

return ClassFieldDeclaration
