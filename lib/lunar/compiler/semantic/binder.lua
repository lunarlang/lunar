local BaseBinder = require("lunar.compiler.semantic.base_binder")
local SyntaxKind = require("lunar.ast.syntax_kind")
local DiagnosticUtils = require("lunar.utils.diagnostic_utils")
local Symbol = require("lunar.compiler.semantic.symbol")
local SymbolTable = require("lunar.compiler.semantic.symbol_table")
local Binder = setmetatable({}, { __index = BaseBinder })
Binder.__index = setmetatable({}, BaseBinder)
local super = BaseBinder.constructor
function Binder.new(ast, environment, file_path_dot)
  return Binder.constructor(setmetatable({}, Binder), ast, environment, file_path_dot)
end
function Binder.constructor(self, ast, environment, file_path_dot)
  super(self, environment, file_path_dot)
  self.contextual_varargs = nil
  self.is_function_scope = nil
  self.binding_visitors = {
    [SyntaxKind.variable_statement] = self.bind_variable_statement,
    [SyntaxKind.do_statement] = self.bind_do_statement,
    [SyntaxKind.if_statement] = self.bind_if_statement,
    [SyntaxKind.class_statement] = self.bind_class_statement,
    [SyntaxKind.while_statement] = self.bind_while_statement,
    [SyntaxKind.break_statement] = self.bind_break_statement,
    [SyntaxKind.return_statement] = self.bind_return_statement,
    [SyntaxKind.function_statement] = self.bind_function_statement,
    [SyntaxKind.range_for_statement] = self.bind_range_for_statement,
    [SyntaxKind.expression_statement] = self.bind_expression_statement,
    [SyntaxKind.assignment_statement] = self.bind_assignment_statement,
    [SyntaxKind.generic_for_statement] = self.bind_generic_for_statement,
    [SyntaxKind.repeat_until_statement] = self.bind_repeat_until_statement,
    [SyntaxKind.declare_global_statement] = self.bind_declare_global_statement,
    [SyntaxKind.declare_package_statement] = self.bind_declare_package_statement,
    [SyntaxKind.declare_returns_statement] = self.bind_declare_returns_statement,
    [SyntaxKind.import_statement] = self.bind_import_statement,
    [SyntaxKind.export_statement] = self.bind_export_statement,
    [SyntaxKind.prefix_expression] = self.bind_prefix_expression,
    [SyntaxKind.lambda_expression] = self.bind_lambda_expression,
    [SyntaxKind.member_expression] = self.bind_member_expression,
    [SyntaxKind.argument_expression] = self.bind_argument_expression,
    [SyntaxKind.function_expression] = self.bind_function_expression,
    [SyntaxKind.unary_op_expression] = self.bind_unary_op_expression,
    [SyntaxKind.binary_op_expression] = self.bind_binary_op_expression,
    [SyntaxKind.nil_literal_expression] = self.bind_nil_literal_expression,
    [SyntaxKind.function_call_expression] = self.bind_function_call_expression,
    [SyntaxKind.table_literal_expression] = self.bind_table_literal_expression,
    [SyntaxKind.number_literal_expression] = self.bind_number_literal_expression,
    [SyntaxKind.string_literal_expression] = self.bind_string_literal_expression,
    [SyntaxKind.boolean_literal_expression] = self.bind_boolean_literal_expression,
    [SyntaxKind.variable_argument_expression] = self.bind_variable_argument_expression,
    [SyntaxKind.identifier] = self.bind_identifier,
    [SyntaxKind.index_expression] = self.bind_index_expression,
    [SyntaxKind.type_assertion_expression] = self.bind_type_assertion_expression,
    [SyntaxKind.parameter_declaration] = self.bind_parameter_declaration,
  }
  self.ast = ast
  return self
end
function Binder.__index:bind()
  self.environment:declare_visited_source(self.file_path, true)
  self.root_scope = self:push_scope(true)
  self:bind_node_list(self.ast)
  self:pop_level_scopes()
  return self.environment
end
function Binder.__index:bind_node(node)
  local binder = self.binding_visitors[node.syntax_kind]
  if binder then
    binder(self, node)
  else
    error("No binding visitor found for syntax kind '" .. tostring(DiagnosticUtils.index_of(SyntaxKind, node.syntax_kind)) .. "'")
  end
end
function Binder.__index:bind_node_list(stats)
  for i = 1, (#stats) do
    self:bind_node(stats[i])
  end
end
function Binder.__index:bind_identifier(identifier)
  self:bind_value_reference(identifier)
end
function Binder.__index:bind_value_reference(identifier)
  local symbol
  if self.scope:has_value(identifier.name) then
    symbol = self.scope:get_value(identifier.name)
    if (not symbol) then
      symbol = Symbol.new(identifier.name)
      self.scope:add_value(symbol)
    end
  else
    symbol = self.environment:get_global_value(self.file_path, identifier.name)
    if (not symbol) then
      symbol = Symbol.new(identifier.name)
      self.environment:add_global_value(self.file_path, symbol)
    end
  end
  symbol:bind_reference(identifier)
end
function Binder.__index:bind_value_assignment(identifier)
  local symbol
  if self.scope:has_value(identifier.name) then
    symbol = self.scope:get_value(identifier.name)
  else
    symbol = self.environment:get_global_value(self.file_path, identifier.name)
    if (not symbol) then
      symbol = Symbol.new(identifier.name)
      self.environment:add_global_value(self.file_path, symbol)
    end
  end
  symbol:bind_assignment_reference(identifier)
end
function Binder.__index:bind_value_assignment_declaration(identifier, declaring_node)
  if self.scope:has_level_value(identifier.name) then
    self:push_scope(false)
  end
  local symbol = Symbol.new(identifier.name)
  symbol:bind_assignment_reference(identifier)
  symbol:bind_declaration_reference(identifier, declaring_node)
  self.scope:add_value(symbol)
  if identifier.type_annotation then
    self:bind_type_expression(identifier.type_annotation)
  end
end
function Binder.__index:bind_value_declaration(identifier, declaring_node)
  if self.scope:has_level_value(identifier.name) then
    self:push_scope(false)
  end
  local symbol = Symbol.new(identifier.name)
  symbol:bind_declaration_reference(identifier, declaring_node)
  self.scope:add_value(symbol)
  if identifier.type_annotation then
    self:bind_type_expression(identifier.type_annotation)
  end
end
function Binder.__index:bind_type_reference(identifier)
  local symbol = self.environment:get_global_type(self.file_path, identifier.name)
  if (not symbol) then
    symbol = Symbol.new(identifier.name)
    self.environment:add_global_type(self.file_path, symbol)
  end
  symbol:bind_reference(identifier)
end
function Binder.__index:bind_type_expression(expr)
  if expr.syntax_kind == SyntaxKind.identifier then
    self:bind_type_reference(expr)
  else
    error("Unbound type expression of syntax kind '" .. tostring(DiagnosticUtils.index_of(SyntaxKind, expr.syntax_kind)) .. "'")
  end
end
function Binder.__index:bind_variable_statement(stat)
  local identifiers = stat.identlist
  local assignments = stat.exprlist
  if assignments then
    self:bind_node_list(assignments)
  end
  for i = 1, (#identifiers) do
    local identifier = identifiers[i]
    if assignments and assignments[i] then
      self:bind_value_assignment_declaration(identifier, stat)
    else
      self:bind_value_declaration(identifier, stat)
    end
  end
end
function Binder.__index:bind_do_statement(stat)
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end
function Binder.__index:bind_if_statement(stat)
  if stat.expr then
    self:bind_node(stat.expr)
  end
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
  self:bind_node_list(stat.elseif_branches)
  if stat.else_branch then
    self:bind_node(stat.else_branch)
  end
end
function Binder.__index:bind_class_statement(stat)
  local identifier = stat.identifier
  if self.scope:has_level_value(identifier.name) or self.scope:has_type(identifier.name) then
    self:push_scope(false)
  end
  local type_symbol = self.environment:get_global_type(self.file_path, identifier.name)
  if type_symbol then
    if type_symbol:is_declared() then
      error("Attempt to re-declare type '" .. identifier.name .. "'")
    end
  else
    type_symbol = Symbol.new(identifier.name)
    self.environment:add_global_type(self.file_path, type_symbol)
  end
  type_symbol:bind_assignment_reference(identifier)
  type_symbol:bind_declaration_reference(identifier, stat)
  self:bind_value_assignment_declaration(identifier, stat)
  local value_symbol = self.scope:get_value(identifier.name)
  value_symbol.members = SymbolTable.new()
  value_symbol.exports = SymbolTable.new()
  self:push_scope(true)
  local contextual_self = Symbol.new("self")
  self.scope:add_value(contextual_self)
  contextual_self:bind_declaration(stat)
  local contextual_super = Symbol.new("super")
  self.scope:add_value(contextual_super)
  if stat.super_identifier ~= nil then
    contextual_self:bind_declaration(stat)
  end
  if stat.super_identifier then
    self:bind_value_reference(stat.super_identifier)
  end
  for i = 1, (#stat.members) do
    local member = stat.members[i]
    if member.syntax_kind == SyntaxKind.class_function_declaration then
      self:bind_class_function_declaration(member, value_symbol)
    elseif member.syntax_kind == SyntaxKind.class_field_declaration then
      self:bind_class_field_declaration(member, value_symbol)
    elseif member.syntax_kind == SyntaxKind.constructor_declaration then
      self:bind_class_constructor_declaration(member, value_symbol)
    else
      error("Unbound class declaration of syntax kind '" .. tostring(DiagnosticUtils.index_of(SyntaxKind, member.syntax_kind)) .. "'")
    end
  end
  self:pop_level_scopes()
end
function Binder.__index:bind_class_field_declaration(decl, class_symbol)
  if decl.is_static then
    if class_symbol.exports:has_value(decl.identifier.name) then
      error("Attempt to re-declare static class field '" .. decl.identifier.name .. "'")
    end
  else
    if class_symbol.members:has_value(decl.identifier.name) then
      error("Attempt to re-declare class field '" .. decl.identifier.name .. "'")
    end
  end
  local member_symbol = Symbol.new(decl.identifier.name)
  member_symbol:bind_assignment_reference(decl.identifier)
  member_symbol:bind_declaration_reference(decl.identifier, decl)
  if decl.is_static then
    class_symbol.exports:add_value(member_symbol)
  else
    class_symbol.members:add_value(member_symbol)
  end
  if decl.value then
    self:bind_node(decl.value)
  end
end
function Binder.__index:bind_class_function_declaration(decl, class_symbol)
  if decl.is_static then
    if class_symbol.exports:has_value(decl.identifier.name) then
      error("Attempt to re-declare static class field '" .. decl.identifier.name .. "'")
    end
  else
    if class_symbol.members:has_value(decl.identifier.name) then
      error("Attempt to re-declare class field '" .. decl.identifier.name .. "'")
    end
  end
  local member_symbol = Symbol.new(decl.identifier.name)
  member_symbol:bind_assignment_reference(decl.identifier)
  member_symbol:bind_declaration_reference(decl.identifier, decl)
  if decl.is_static then
    class_symbol.exports:add_value(member_symbol)
  else
    class_symbol.members:add_value(member_symbol)
  end
  self:bind_function_like_expression(decl.params, decl.block, decl.return_type_annotation)
end
function Binder.__index:bind_class_constructor_declaration(decl, class_symbol)
  if class_symbol.exports:has_value('constructor') then
    error("Attempt to re-declare class constructor")
  end
  local member_symbol = Symbol.new('constructor')
  member_symbol:bind_declaration(decl)
  class_symbol.exports:add_value(member_symbol)
  self:bind_function_like_expression(decl.params, decl.block, decl.return_type_annotation)
end
function Binder.__index:bind_while_statement(stat)
  self:bind_node(stat.expr)
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end
function Binder.__index:bind_break_statement(stat)
end
function Binder.__index:bind_return_statement(stat)
  if stat.exprlist then
    self:bind_node_list(stat.exprlist)
  end
  if (not self.is_function_scope) then
    if self.scope.level ~= self.root_scope.level then
      error("Conditional returns are not allowed in source files")
    end
    local source_returns = self.environment:get_returns_symbol(self.file_path)
    if source_returns then
      error("Cannot re-declare source returns")
    else
      source_returns = self.environment:create_returns_symbol(self.file_path)
    end
    if next(source_returns.exports.values) then
      error("Cannot export and return values in the same scope")
    else
      source_returns:bind_declaration(stat)
    end
  end
end
function Binder.__index:bind_import_statement(stat)
  self.environment:declare_import(self.file_path, stat)
end
function Binder.__index:bind_export_statement(stat)
  local inner_stat = stat.body
  local identifier
  if inner_stat.syntax_kind == SyntaxKind.variable_statement then
    identifier = inner_stat.identlist[1]
  elseif inner_stat.syntax_kind == SyntaxKind.function_statement then
    identifier = inner_stat.base
  elseif inner_stat.syntax_kind == SyntaxKind.class_statement then
    identifier = inner_stat.identifier
  else
    error("Unbound export statement")
  end
  if self.scope:has_level_value(identifier.name) then
    self:push_scope(false)
  end
  local type_symbol = nil
  if inner_stat.syntax_kind == SyntaxKind.variable_statement then
    self:bind_variable_statement(inner_stat)
  elseif inner_stat.syntax_kind == SyntaxKind.function_statement then
    self:bind_function_statement(inner_stat)
  elseif inner_stat.syntax_kind == SyntaxKind.class_statement then
    self:bind_class_statement(inner_stat)
    type_symbol = self.environment:get_global_type(self.file_path, identifier.name)
  end
  local value_symbol = self.scope:get_value(identifier.name)
  self.environment:add_exports_value(self.file_path, value_symbol)
  if type_symbol then
    self.environment:add_exports_type(self.file_path, type_symbol)
  end
end
function Binder.__index:bind_function_statement(stat)
  if stat.is_local then
    self:bind_value_assignment_declaration(stat.base, stat)
  else
    if stat.base.syntax_kind == SyntaxKind.member_expression then
      self:bind_member_expression(stat.base)
    else
      self:bind_value_assignment(stat.base, stat)
    end
  end
  self:bind_function_like_expression(stat.parameters, stat.block, stat.return_type_annotation)
end
function Binder.__index:bind_range_for_statement(stat)
  self:bind_node(stat.start_expr)
  self:bind_node(stat.end_expr)
  if stat.incremental_expr then
    self:bind_node(stat.incremental_expr)
  end
  self:push_scope(true)
  self:bind_value_assignment_declaration(stat.identifier, stat)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end
function Binder.__index:bind_expression_statement(stat)
  self:bind_node(stat.expr)
end
function Binder.__index:bind_assignment_statement(stat)
  self:bind_node_list(stat.exprs)
  for i = 1, (#stat.variables) do
    local variable = stat.variables[i]
    if variable.syntax_kind == SyntaxKind.identifier then
      self:bind_value_assignment(variable, stat)
    else
      self:bind_node(variable)
    end
  end
end
function Binder.__index:bind_generic_for_statement(stat)
  self:bind_node_list(stat.exprlist)
  self:push_scope(true)
  for i = 1, (#stat.identifiers) do
    self:bind_value_assignment_declaration(stat.identifiers[i], stat)
  end
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end
function Binder.__index:bind_repeat_until_statement(stat)
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:bind_node(stat.expr)
  self:pop_level_scopes()
end
function Binder.__index:bind_prefix_expression(stat)
  self:bind_node(stat.expr)
end
function Binder.__index:bind_lambda_expression(stat)
  if stat.expr then
    self:bind_node(stat.expr)
  end
  self:push_scope(true)
  local save_contextual_varargs = self.contextual_varargs
  local save_is_function_scope = self.is_function_scope
  self.contextual_varargs = nil
  self.is_function_scope = true
  self:bind_node_list(stat.parameters)
  if stat.implicit_return then
    self:bind_node(stat.body)
  else
    self:bind_node_list(stat.body)
  end
  self:pop_level_scopes()
  self.is_function_scope = save_is_function_scope
  self.contextual_varargs = save_contextual_varargs
end
function Binder.__index:bind_member_expression(expr)
  local left_base = expr.base
  while left_base.syntax_kind == SyntaxKind.prefix_expression do
    left_base = left_base.expr
  end
  if left_base.syntax_kind == SyntaxKind.identifier then
    self:bind_value_reference(left_base)
  elseif left_base.syntax_kind == SyntaxKind.member_expression then
    self:bind_member_expression(left_base)
  end
end
function Binder.__index:bind_index_expression(expr)
  self:bind_node(expr.base)
  self:bind_node(expr.index)
end
function Binder.__index:bind_argument_expression(expr)
  self:bind_node(expr.value)
end
function Binder.__index:bind_function_like_expression(params, block, return_type_annotation)
  self:push_scope(true)
  local save_contextual_varargs = self.contextual_varargs
  local save_is_function_scope = self.is_function_scope
  self.contextual_varargs = nil
  self.is_function_scope = true
  self:bind_node_list(params)
  self:bind_node_list(block)
  self:pop_level_scopes()
  self.contextual_varargs = save_contextual_varargs
  self.is_function_scope = save_is_function_scope
  if return_type_annotation then
    self:bind_type_expression(return_type_annotation)
  end
end
function Binder.__index:bind_function_expression(expr)
  self:bind_function_like_expression(expr.parameters, expr.block, expr.return_type_annotation)
end
function Binder.__index:bind_unary_op_expression(expr)
  self:bind_node(expr.right_operand)
end
function Binder.__index:bind_binary_op_expression(expr)
  self:bind_node(expr.left_operand)
  self:bind_node(expr.right_operand)
end
function Binder.__index:bind_nil_literal_expression(expr)
end
function Binder.__index:bind_function_call_expression(expr)
  self:bind_node(expr.base)
  self:bind_node_list(expr.arguments)
end
function Binder.__index:bind_table_literal_expression(expr)
  if expr.syntax_kind == SyntaxKind.index_field_declaration then
    self:bind_index_field_declaration(expr)
  elseif expr.syntax_kind == SyntaxKind.member_field_declaration then
    self:bind_member_field_declaration(expr)
  elseif expr.syntax_kind == SyntaxKind.sequential_field_declaration then
    self:bind_sequential_field_declaration(expr)
  end
end
function Binder.__index:bind_index_field_declaration(expr, table_literal_symbol)
  self:bind_node(expr.key)
  self:bind_node(expr.value)
end
function Binder.__index:bind_member_field_declaration(expr)
  self:bind_node(expr.value)
end
function Binder.__index:bind_sequential_field_declaration(expr)
  self:bind_node(expr.value)
end
function Binder.__index:bind_number_literal_expression(expr)
end
function Binder.__index:bind_string_literal_expression(expr)
end
function Binder.__index:bind_boolean_literal_expression(expr)
end
function Binder.__index:bind_variable_argument_expression(expr)
  local symbol = self.contextual_varargs
  if symbol then
    symbol:bind_reference(expr)
  else
    error("Attempt to reference vararg expression '...' in a scope where it was not declared")
  end
end
function Binder.__index:bind_type_assertion_expression(expr)
  self:bind_node(expr.base)
  self:bind_type_expression(expr.type)
end
function Binder.__index:bind_parameter_declaration(expr)
  if expr.identifier.name == "..." then
    local varargs_symbol = Symbol.new("...")
    varargs_symbol:bind_assignment_reference(expr.identifier)
    varargs_symbol:bind_declaration_reference(expr.identifier, expr)
    self.contextual_varargs = varargs_symbol
  else
    if self.scope:has_value(expr.identifier.name) then
      if self.scope:has_level_value(expr.identifier.name) then
        self:push_scope(false)
      end
    end
    self:bind_value_assignment_declaration(expr.identifier, expr)
  end
end
function Binder.__index:bind_declare_global_statement(stat)
  if (not stat.is_type_declaration) then
    local symbol = self.environment.env_globals:get_value(stat.identifier.name)
    if symbol then
      if symbol:is_declared() then
        error("Attempt to re-declare global value '" .. stat.identifier.name .. "'")
      end
    else
      symbol = Symbol.new(stat.identifier.name)
      self.environment.env_globals:add_value(symbol)
    end
    symbol:bind_declaration_reference(stat.identifier, stat)
    if stat.identifier.type_annotation then
      self:bind_type_expression(stat.identifier.type_annotation)
    end
  else
    error("Global type declarations are not yet supported")
  end
end
function Binder.__index:bind_declare_package_statement(stat)
  self:bind_type_expression(stat.type_expr)
  local source_returns = self.environment:get_returns_symbol(stat.path)
  if source_returns then
    error("Attempt to re-declare package returns")
  else
    source_returns = self.environment:create_returns_symbol(stat.path)
    self.environment:declare_visited_source(stat.path, true)
  end
  if next(source_returns.exports.values) then
    error("Cannot export and return values in the same scope")
  else
    source_returns:bind_declaration(stat)
  end
end
function Binder.__index:bind_declare_returns_statement(stat)
  self:bind_type_expression(stat.type_expr)
  local source_returns = self.environment:get_returns_symbol(self.file_path)
  if source_returns then
    error("Attempt to re-declare source file returns")
  else
    source_returns = self.environment:create_returns_symbol(self.file_path)
  end
  if next(source_returns.exports.values) then
    error("Cannot export and return values in the same scope")
  else
    source_returns:bind_declaration(stat)
  end
end
return Binder
