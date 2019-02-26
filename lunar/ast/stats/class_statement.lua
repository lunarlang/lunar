local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local MemberExpression = require "lunar.ast.exprs.member_expression"
local FunctionCallExpression = require "lunar.ast.exprs.function_call_expression"
local TableLiteralExpression = require "lunar.ast.exprs.table_literal_expression"
local Identifier = require "lunar.ast.exprs.identifier"
local VariableStatement = require "lunar.ast.stats.variable_statement"
local AssignmentStatement = require "lunar.ast.stats.assignment_statement"
local SelfAssignmentOpKind = require "lunar.ast.stats.self_assignment_op_kind"
local ConstructorDeclaration = require "lunar.ast.decls.constructor_declaration"

local ClassStatement = {}
ClassStatement.__index = ClassStatement

function ClassStatement.new(identifier, super_identifier, members)
  local super = SyntaxNode.new(SyntaxKind.class_statement)
  local self = setmetatable(super, ClassStatement)
  self.identifier = identifier
  self.super_identifier = super_identifier
  self.members = members

  return self
end

function ClassStatement:lower()
  local empty_table = TableLiteralExpression.new({})
  local class_def = VariableStatement.new({ self.identifier }, {}, {})

  if self.super_identifier ~= nil then
    local setmt_base = Identifier.new("setmetatable")
    table.insert(class_def.exprlist, FunctionCallExpression.new(setmt_base, {
      empty_table, self.super_identifier
    }))
  else
    table.insert(class_def.exprlist, empty_table)
  end

  local class_index = MemberExpression.new(self.identifier, Identifier.new("__index"))
  local class_index_def = AssignmentStatement.new({ class_index }, SelfAssignmentOpKind.equal_op, { empty_table })

  local statics, instances, ctor_decl = {}, {}
  for _, member in pairs(self.members) do
    -- since ConstructorDeclaration cannot be static but everything else can be, we'll exclude this
    if member.syntax_kind ~= SyntaxKind.constructor_declaration then
      table.insert(member.is_static and statics or instances, member)
    else
      ctor_decl = ctor_decl or member
    end
  end

  ctor_decl = ctor_decl or ConstructorDeclaration.new({}, {})
  ctor_decl = ctor_decl:lower(self.identifier, self.super_identifier)

  for index, member in pairs(statics) do
    statics[index] = member:lower(self.identifier)
  end

  for index, member in pairs(instances) do
    instances[index] = member:lower(class_index)
  end

  return {
    class_def,
    class_index_def,
    unpack(statics),
    unpack(instances),
    ctor_decl.new,
    ctor_decl.constructor,
  }
end

return ClassStatement
