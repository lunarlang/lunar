local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberExpression = require("lunar.ast.exprs.member_expression")
local FunctionCallExpression = require("lunar.ast.exprs.function_call_expression")
local TableLiteralExpression = require("lunar.ast.exprs.table_literal_expression")
local Identifier = require("lunar.ast.exprs.identifier")
local VariableStatement = require("lunar.ast.stats.variable_statement")
local AssignmentStatement = require("lunar.ast.stats.assignment_statement")
local SelfAssignmentOpKind = require("lunar.ast.stats.self_assignment_op_kind")
local ConstructorDeclaration = require("lunar.ast.decls.constructor_declaration")
local MemberFieldDeclaration = require("lunar.ast.decls.member_field_declaration")
local ClassStatement = setmetatable({}, { __index = SyntaxNode })
ClassStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function ClassStatement.new(identifier, super_identifier, members)
  return ClassStatement.constructor(setmetatable({}, ClassStatement), identifier, super_identifier, members)
end
function ClassStatement.constructor(self, identifier, super_identifier, members)
  super(self, SyntaxKind.class_statement)
  self.identifier = identifier
  self.super_identifier = super_identifier
  self.members = members
  return self
end
function ClassStatement.__index:lower()
  local empty_table = TableLiteralExpression.new({})
  local class_def = VariableStatement.new({
    self.identifier,
  }, {}, {})
  local setmt_base = Identifier.new("setmetatable")
  if self.super_identifier ~= nil then
    table.insert(class_def.exprlist, FunctionCallExpression.new(setmt_base, {
      empty_table,
      TableLiteralExpression.new({
        MemberFieldDeclaration.new(Identifier.new("__index"), self.super_identifier),
      }),
    }))
  else
    table.insert(class_def.exprlist, empty_table)
  end
  local class_index = MemberExpression.new(self.identifier, Identifier.new("__index"))
  local class_index_def = AssignmentStatement.new({
    class_index,
  }, SelfAssignmentOpKind.equal_op, {})
  if self.super_identifier ~= nil then
    table.insert(class_index_def.exprs, FunctionCallExpression.new(setmt_base, {
      empty_table,
      self.super_identifier,
    }))
  else
    table.insert(class_index_def.exprs, empty_table)
  end
  local statics, instances, instance_fields, ctor_decl = {}, {}, {}
  for _, member in pairs(self.members) do
    if member.syntax_kind == SyntaxKind.constructor_declaration then
      ctor_decl = ctor_decl or member
    elseif member.syntax_kind == SyntaxKind.class_field_declaration then
      table.insert(member.is_static and statics or instance_fields, member)
    else
      table.insert(member.is_static and statics or instances, member)
    end
  end
  ctor_decl = ctor_decl or ConstructorDeclaration.new({}, {})
  ctor_decl = ctor_decl:lower(self.identifier, self.super_identifier)
  local index = 0
  for _, member in pairs(instance_fields) do
    local field = member:lower(self.identifier)
    if field then
      index = index + 1
      table.insert(ctor_decl.constructor.block, index + (self.super_identifier and 1 or 0), field)
    end
  end
  local nodes = {
    class_def,
    class_index_def,
    ctor_decl.new,
    ctor_decl.constructor,
  }
  for index, member in pairs(statics) do
    table.insert(nodes, member:lower(self.identifier))
  end
  for index, member in pairs(instances) do
    table.insert(nodes, member:lower(class_index))
  end
  return nodes
end
return ClassStatement
