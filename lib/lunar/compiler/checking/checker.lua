local SyntaxKind = require('lunar.ast.syntax_kind')
local Checker = {}
Checker.__index = {}
function Checker.new(ast, linked_env, is_ambient_context)
  return Checker.constructor(setmetatable({}, Checker), ast, linked_env, is_ambient_context)
end
function Checker.constructor(self, ast, linked_env, is_ambient_context)
  self.in_header_context = true
  self.visitors = {
    [SyntaxKind.variable_statement] = self.visit_variable_statement,
    [SyntaxKind.do_statement] = self.visit_do_statement,
    [SyntaxKind.if_statement] = self.visit_if_statement,
    [SyntaxKind.class_statement] = self.visit_class_statement,
    [SyntaxKind.while_statement] = self.visit_while_statement,
    [SyntaxKind.break_statement] = self.visit_break_statement,
    [SyntaxKind.return_statement] = self.visit_return_statement,
    [SyntaxKind.function_statement] = self.visit_function_statement,
    [SyntaxKind.range_for_statement] = self.visit_range_for_statement,
    [SyntaxKind.expression_statement] = self.visit_expression_statement,
    [SyntaxKind.assignment_statement] = self.visit_assignment_statement,
    [SyntaxKind.generic_for_statement] = self.visit_generic_for_statement,
    [SyntaxKind.repeat_until_statement] = self.visit_repeat_until_statement,
    [SyntaxKind.declare_global_statement] = self.visit_declare_global_statement,
    [SyntaxKind.declare_package_statement] = self.visit_declare_package_statement,
    [SyntaxKind.declare_returns_statement] = self.visit_declare_returns_statement,
    [SyntaxKind.import_statement] = self.visit_import_statement,
    [SyntaxKind.export_statement] = self.visit_export_statement,
    [SyntaxKind.prefix_expression] = self.visit_prefix_expression,
    [SyntaxKind.lambda_expression] = self.visit_lambda_expression,
    [SyntaxKind.member_expression] = self.visit_member_expression,
    [SyntaxKind.argument_expression] = self.visit_argument_expression,
    [SyntaxKind.function_expression] = self.visit_function_expression,
    [SyntaxKind.unary_op_expression] = self.visit_unary_op_expression,
    [SyntaxKind.binary_op_expression] = self.visit_binary_op_expression,
    [SyntaxKind.nil_literal_expression] = self.visit_nil_literal_expression,
    [SyntaxKind.function_call_expression] = self.visit_function_call_expression,
    [SyntaxKind.table_literal_expression] = self.visit_table_literal_expression,
    [SyntaxKind.number_literal_expression] = self.visit_number_literal_expression,
    [SyntaxKind.string_literal_expression] = self.visit_string_literal_expression,
    [SyntaxKind.boolean_literal_expression] = self.visit_boolean_literal_expression,
    [SyntaxKind.variable_argument_expression] = self.visit_variable_argument_expression,
    [SyntaxKind.identifier] = self.visit_identifier,
    [SyntaxKind.index_expression] = self.visit_index_expression,
    [SyntaxKind.type_assertion_expression] = self.visit_type_assertion_expression,
    [SyntaxKind.parameter_declaration] = self.visit_parameter_declaration,
  }
  self.ast = ast
  self.env = linked_env
  self.is_ambient_context = is_ambient_context or false
  return self
end
function Checker.__index:check()
  if (not self.env.linked) then
    error("Cannot check in an unlinked environment")
  end
  self:visit_statements(self.ast)
end
function Checker.__index:visit_statements(stats)
  for i = 1, (#stats) do
    self:visit_statement(stats[i])
  end
end
function Checker.__index:visit_expression_list(exprs)
  for i = 1, (#exprs) do
    self:visit_node(exprs[i])
  end
end
function Checker.__index:visit_statement(stat)
  if stat.syntax_kind ~= SyntaxKind.import_statement and stat.syntax_kind ~= SyntaxKind.declare_global_statement and stat.syntax_kind ~= SyntaxKind.declare_package_statement and stat.syntax_kind ~= SyntaxKind.declare_returns_statement then
    self.is_header_context = false
  end
  self:visit_node(stat)
end
function Checker.__index:visit_node(node)
  local visitor = self.visitors[node.syntax_kind]
  if visitor then
    visitor(self, node)
  end
end
function Checker.__index:visit_import_statement(stat)
  if (not self.in_header_context) then
    error("Imports must be declared at the top of a file")
  end
end
function Checker.__index:visit_declare_returns_statement(stat)
  if (not self.is_ambient_context) then
    error("Declare statements can only be made in a declaration file context")
  end
  self:visit_type_expression(stat.type_expr)
end
function Checker.__index:visit_declare_global_statement(stat)
  if (not self.is_ambient_context) then
    error("Declare statements can only be made in a declaration file context")
  end
  if (not stat.is_type_declaration) then
    if stat.identifier.type_annotation then
      self:visit_type_expression(stat.identifier.type_annotation)
    end
  else
    error("Global type declarations are not yet supported")
  end
end
function Checker.__index:visit_declare_package_statement(stat)
  if (not self.is_ambient_context) then
    error("Declare statements can only be made in a declaration file context")
  end
  self:visit_type_expression(stat.type_expr)
end
function Checker.__index:visit_type_expression(expr)
end
function Checker.__index:visit_variable_statement(stat)
  local assignments = stat.exprlist
  if assignments then
    self:visit_expression_list(assignments)
  end
end
function Checker.__index:visit_do_statement(stat)
  self:visit_statements(stat.block)
end
function Checker.__index:visit_if_statement(stat)
  if stat.expr then
    self:visit_node(stat.expr)
  end
  self:visit_statements(stat.block)
  self:visit_expression_list(stat.elseif_branches)
  if stat.else_branch then
    self:visit_statements(stat.else_branch)
  end
end
function Checker.__index:visit_class_statement(stat)
  for i = 1, (#stat.members) do
    local member = stat.members[i]
    if member.syntax_kind == SyntaxKind.class_function_declaration then
      self:visit_class_function_declaration(member)
    elseif member.syntax_kind == SyntaxKind.class_field_declaration then
      self:visit_class_field_declaration(member)
    elseif member.syntax_kind == SyntaxKind.constructor_declaration then
      self:visit_class_constructor_declaration(member)
    end
  end
end
function Checker.__index:visit_class_field_declaration(decl)
  if decl.value then
    self:visit_node(decl.value)
  end
end
function Checker.__index:visit_class_function_declaration(decl)
  self:visit_function_like_expression(decl.params, decl.block, decl.return_type_annotation)
end
function Checker.__index:visit_class_constructor_declaration(decl)
  self:visit_function_like_expression(decl.params, decl.block, decl.return_type_annotation)
end
function Checker.__index:visit_while_statement(stat)
  self:visit_node(stat.expr)
  self:visit_statements(stat.block)
end
function Checker.__index:visit_break_statement(stat)
end
function Checker.__index:visit_return_statement(stat)
  if stat.exprlist then
    self:visit_expression_list(stat.exprlist)
  end
end
function Checker.__index:visit_export_statement(stat)
  local inner_stat = stat.body
  if inner_stat.syntax_kind == SyntaxKind.variable_statement then
    self:visit_variable_statement(inner_stat)
  elseif inner_stat.syntax_kind == SyntaxKind.function_statement then
    self:visit_function_statement(inner_stat)
  elseif inner_stat.syntax_kind == SyntaxKind.class_statement then
    self:visit_class_statement(inner_stat)
  end
end
function Checker.__index:visit_function_statement(stat)
  if (not stat.is_local) then
    if stat.base.syntax_kind == SyntaxKind.member_expression then
      self:visit_member_expression(stat.base)
    end
  end
  self:visit_function_like_expression(stat.parameters, stat.block, stat.return_type_annotation)
end
function Checker.__index:visit_range_for_statement(stat)
  self:visit_node(stat.start_expr)
  self:visit_node(stat.end_expr)
  if stat.incremental_expr then
    self:visit_node(stat.incremental_expr)
  end
  self:visit_statements(stat.block)
end
function Checker.__index:visit_expression_statement(stat)
  self:visit_node(stat.expr)
end
function Checker.__index:visit_assignment_statement(stat)
  self:visit_expression_list(stat.exprs)
  for i = 1, (#stat.variables) do
    local variable = stat.variables[i]
    self:visit_node(variable)
  end
end
function Checker.__index:visit_generic_for_statement(stat)
  self:visit_expression_list(stat.exprlist)
  self:visit_statements(stat.block)
end
function Checker.__index:visit_repeat_until_statement(stat)
  self:visit_statements(stat.block)
  self:visit_node(stat.expr)
end
function Checker.__index:visit_prefix_expression(stat)
  self:visit_node(stat.expr)
end
function Checker.__index:visit_lambda_expression(stat)
  if stat.expr then
    self:visit_node(stat.expr)
  end
  self:visit_expression_list(stat.parameters)
  if stat.implicit_return then
    self:visit_node(stat.body)
  else
    self:visit_statements(stat.body)
  end
end
function Checker.__index:visit_member_expression(expr)
  self:visit_node(expr.base)
end
function Checker.__index:visit_index_expression(expr)
  self:visit_node(expr.base)
  self:visit_node(expr.index)
end
function Checker.__index:visit_argument_expression(expr)
  self:visit_node(expr.value)
end
function Checker.__index:visit_function_like_expression(params, block, return_type_annotation)
  self:visit_expression_list(params)
  self:visit_statements(block)
  if return_type_annotation then
    self:visit_type_expression(return_type_annotation)
  end
end
function Checker.__index:visit_function_expression(expr)
  self:visit_function_like_expression(expr.parameters, expr.block, expr.return_type_annotation)
end
function Checker.__index:visit_unary_op_expression(expr)
  self:visit_node(expr.right_operand)
end
function Checker.__index:visit_binary_op_expression(expr)
  self:visit_node(expr.left_operand)
  self:visit_node(expr.right_operand)
end
function Checker.__index:visit_nil_literal_expression(expr)
end
function Checker.__index:visit_function_call_expression(expr)
  self:visit_node(expr.base)
  self:visit_expression_list(expr.arguments)
end
function Checker.__index:visit_table_literal_expression(expr)
  if expr.syntax_kind == SyntaxKind.index_field_declaration then
    self:visit_index_field_declaration(expr)
  elseif expr.syntax_kind == SyntaxKind.member_field_declaration then
    self:visit_member_field_declaration(expr)
  elseif expr.syntax_kind == SyntaxKind.sequential_field_declaration then
    self:visit_sequential_field_declaration(expr)
  end
end
function Checker.__index:visit_index_field_declaration(expr, table_literal_symbol)
  self:visit_node(expr.key)
  self:visit_node(expr.value)
end
function Checker.__index:visit_member_field_declaration(expr)
  self:visit_node(expr.value)
end
function Checker.__index:visit_sequential_field_declaration(expr)
  self:visit_node(expr.value)
end
function Checker.__index:visit_number_literal_expression(expr)
end
function Checker.__index:visit_string_literal_expression(expr)
end
function Checker.__index:visit_boolean_literal_expression(expr)
end
function Checker.__index:visit_variable_argument_expression(expr)
end
function Checker.__index:visit_type_assertion_expression(expr)
  self:visit_node(expr.base)
  self:visit_type_expression(expr.type)
end
function Checker.__index:visit_parameter_declaration(expr)
end
return Checker
