local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local MemberExpression = require "lunar.ast.exprs.member_expression"
local FunctionCallExpression = require "lunar.ast.exprs.function_call_expression"
local TableLiteralExpression = require "lunar.ast.exprs.table_literal_expression"
local VariableStatement = require "lunar.ast.stats.variable_statement"
local ExpressionStatement = require "lunar.ast.stats.expression_statement"
local AssignmentStatement = require "lunar.ast.stats.assignment_statement"
local SelfAssignmentOpKind = require "lunar.ast.stats.self_assignment_op_kind"
local ConstructorDeclaration = require "lunar.ast.decls.constructor_declaration"

local ClassStatement = {}
ClassStatement.__index = ClassStatement

function ClassStatement.new(name, base_name, members)
  local super = SyntaxNode.new(SyntaxKind.class_statement)
  local self = setmetatable(super, ClassStatement)
  self.name = name
  self.base_name = base_name
  self.members = members

  return self
end

function ClassStatement:lower()
  local statics, instances, constructor = {}, {}

  -- categorize static vs instance members for transpilation purposes
  for _, member in pairs(self.members) do
    -- since ConstructorDeclaration cannot be static but everything else can be, we'll exclude this
    if member.syntax_kind ~= SyntaxKind.constructor_declaration then
      table.insert(member.is_static and statics or instances, member)
    else
      -- prefer the first constructor declared, the rest should be semantically invalid
      constructor = constructor or member
    end
  end

  local class_name = MemberExpression.new(self.name)
  local empty_table = TableLiteralExpression.new({})

  -- declares the class that'll hold the static members
  local class = VariableStatement.new({ self.name }, { empty_table })
  local class_statics = {}
  for _, member in pairs(statics) do
    table.insert(class_statics, member:lower(class_name))
  end

  -- if there is no user-defined constructor, place a default one
  constructor = constructor or ConstructorDeclaration.new({}, {})
  table.insert(class_statics, constructor:lower(class_name, self.base_name))

  -- declares __index on the class that'll hold the instance members
  local index_member = MemberExpression.new(class_name, "__index")
  local class_index = AssignmentStatement.new({ index_member }, SelfAssignmentOpKind.equal_op, { empty_table })
  local class_instances = {}
  for _, member in pairs(instances) do
    table.insert(class_instances, member:lower(index_member))
  end

  local class_inherit_super
  if self.base_name then
    local setmt_member_expr = MemberExpression.new("setmetatable")
    local args = { index_member, MemberExpression.new(self.base_name) }
    class_inherit_super = ExpressionStatement.new(FunctionCallExpression.new(setmt_member_expr, args))
  end

  return {
    static_def = class,
    static_members = class_statics,
    instance_def = class_index,
    class_inherit_super = class_inherit_super,
    instance_members = class_instances
  }
end

return ClassStatement
