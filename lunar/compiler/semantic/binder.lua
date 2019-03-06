local BaseBinder = require "lunar.compiler.semantic.base_binder"
local SyntaxKind = require "lunar.ast.syntax_kind"
local DiagnosticUtils = require "lunar.utils.diagnostic_utils"
local Symbol = require "lunar.compiler.semantic.symbol"
local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local Binder = {}
Binder.__index = setmetatable({}, BaseBinder)

function Binder.constructor(self, ast, environment, file_path_dot)
  BaseBinder.constructor(self, environment, file_path_dot)
  self.ast = ast
  self.contextual_varargs = nil
  self.is_function_scope = nil

  self.binding_visitors = {
    -- Statements
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
    
    -- Expressions
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

    -- Declarations
    [SyntaxKind.parameter_declaration] = self.bind_parameter_declaration,
  }
end

function Binder.__index:bind()
  self.environment:declare_visited_source(self.file_path)

  self.root_scope = self:push_scope(true)
  self:bind_node_list(self.ast)
  self:pop_level_scopes()

  -- Move undeclared type references into globals
  for name, symbol in pairs(self.root_scope.symbol_table.types) do
    if symbol.declaration == nil then
      self.root_scope.symbol_table.types[name] = nil
      self.environment.globals:add_type(symbol)
    end
  end
  -- NOTE: The checker should be responsible for guarding against re-declared global types

  -- Todo: collate return symbols and return them as a second parameter
  return self.environment
end

function Binder.__index:bind_node(node)
  local binder = self.binding_visitors[node.syntax_kind]
  if binder then
    binder(self, node)
  else
    error("No binding visitor found for syntax kind '"
      .. tostring(DiagnosticUtils.index_of(SyntaxKind, node.syntax_kind))
      .. "'"
    )
  end
end

function Binder.__index:bind_node_list(stats)
  for i = 1, #stats do
    self:bind_node(stats[i])
  end
end

function Binder.__index:bind_identifier(identifier)
  self:bind_value_reference(identifier)
end

function Binder.__index:bind_value_reference(identifier)
  if self.scope:has_value(identifier.name) then
    local symbol = self:bind_local_value_symbol(identifier, identifier.name)
    symbol.is_referenced = true
  else
    local symbol = self:bind_global_value_symbol(identifier, identifier.name)
    symbol.is_referenced = true
  end
end

function Binder.__index:bind_value_assignment(identifier, declaring_node)
  local symbol
  if self.scope:has_value(identifier.name) then
    symbol = self:bind_local_value_symbol(identifier, identifier.name)
  else
    -- We have re-assigned a global; should error in strict mode
    symbol = self:bind_global_value_symbol(identifier, identifier.name)
  end
  symbol.is_assigned = true
end

function Binder.__index:bind_value_assignment_declaration(identifier, declaring_node)
  -- In a non-strict mode, we should push the scope for re-declared variable
  if self.scope:has_level_value(identifier.name) then
    self:push_scope(false)
  end

  local symbol = Symbol.new(identifier.name)
  identifier.symbol = symbol
  symbol.is_assigned = true
  symbol.declaration = declaring_node
  self.scope:add_value(symbol)

  -- Allow types to be annotated in declarations
  if identifier.type_annotation then
    self:bind_type_expression(identifier.type_annotation)
  end
end

function Binder.__index:bind_global_value_declaration(identifier, declaring_node)
  local symbol = self.environment.globals:get_value(identifier.name)
  if symbol then
    if symbol.declaration then
      error("Attempt to re-declare global value '" .. identifier.name .. "'")
    end
  else
    symbol = Symbol.new(identifier.name)
    self.environment.globals:add_value(symbol)
  end

  identifier.symbol = symbol
  symbol.declaration = declaring_node

  -- Allow types to be annotated in declarations
  if identifier.type_annotation then
    self:bind_type_expression(identifier.type_annotation)
  end
end

function Binder.__index:bind_value_declaration(identifier, declaring_node)
  -- In a non-strict mode, we should push the scope for re-declared variable
  if self.scope:has_level_value(identifier.name) then
    self:push_scope(false)
  end

  local symbol = Symbol.new(identifier.name)
  identifier.symbol = symbol
  symbol.declaration = declaring_node
  self.scope:add_value(symbol)

  -- Allow types to be annotated in declarations
  if identifier.type_annotation then
    self:bind_type_expression(identifier.type_annotation)
  end
end

function Binder.__index:bind_type_reference(identifier)
  if self.environment.globals:has_type(identifier) then
    local symbol = self:bind_global_type_symbol(identifier, identifier.name)
    symbol.is_referenced = true
  else
    local symbol = self:bind_local_type_symbol(identifier, identifier.name)
    symbol.is_referenced = true
  end
end

function Binder.__index:bind_type_expression(expr)
  if expr.syntax_kind == SyntaxKind.identifier then
    self:bind_type_reference(expr)
  else
    error("Unbound type expression of syntax kind '"
      .. tostring(DiagnosticUtils.index_of(SyntaxKind, expr.syntax_kind))
      .. "'"
    )
  end
end

function Binder.__index:bind_variable_statement(stat)

  local identifiers = stat.identlist
  local assignments = stat.exprlist

  -- Bind in child expressions first (these variables should not be included in their scope)
  if assignments then
      self:bind_node_list(assignments)
  end

  -- Add symbols
  for i = 1, #identifiers do
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
  -- Condition
  if stat.expr then
    self:bind_node(stat.expr)
  end

  -- Block
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()

  -- Elseif clauses
  self:bind_node_list(stat.elseif_branches)

  -- Else clause
  if stat.else_branch then
    self:bind_node(stat.else_branch)
  end
end

function Binder.__index:bind_class_statement(stat)
  local identifier = stat.identifier
  -- Determine if the statics or type were declared
  -- In a non-strict mode, we should push the scope for re-declared variable
  if self.scope:has_level_value(identifier.name) or self.scope:has_type(identifier.name) then
    self:push_scope(false)
  end

  -- Add value symbol
  self:bind_value_assignment_declaration(identifier, stat)
  local value_symbol = identifier.symbol
  value_symbol.members = SymbolTable.new()
  value_symbol.exports = SymbolTable.new()

  -- Declare and assign type symbol
  local type_symbol = self.root_scope:get_type(identifier.name)
  if type_symbol then
    if type_symbol.declaration then
      error("Attempt to re-declare type '" .. identifier.name .. "'")
    end
  else
    type_symbol = Symbol.new(identifier.name)
    self.root_scope:add_type(type_symbol)
  end
  type_symbol.is_assigned = true
  type_symbol.declaration = stat

  self:push_scope(true)

  -- Bind contextual self and super symbols
  local contextual_self = Symbol.new("self")
  self.scope:add_value(contextual_self)
  contextual_self.is_assigned = true
  contextual_self.declaration = stat
  local contextual_super = Symbol.new("super")
  self.scope:add_value(contextual_super)
  contextual_super.is_assigned = stat.super_identifier ~= nil
  contextual_super.declaration = stat.super_identifier ~= nil and stat or nil

  -- Bind superclass identifier and contextual super
  if stat.super_identifier then
    self:bind_value_reference(stat.super_identifier)
  end

  -- Bind class member declarations in a new SymbolTable
  type_symbol.members = SymbolTable.new()
  for i = 1, #stat.members do
    local member = stat.members[i]
    if member.syntax_kind == SyntaxKind.class_function_declaration then
      self:bind_class_function_declaration(member, value_symbol)
    elseif member.syntax_kind == SyntaxKind.class_field_declaration then
      self:bind_class_field_declaration(member, value_symbol)
    elseif member.syntax_kind == SyntaxKind.constructor_declaration then
      self:bind_class_constructor_declaration(member, value_symbol)
    else
      error("Unbound class declaration of syntax kind '"
        .. tostring(DiagnosticUtils.index_of(SyntaxKind, member.syntax_kind))
        .. "'"
      )
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
  decl.identifier.symbol = member_symbol
  member_symbol.is_assigned = true
  member_symbol.declaration = decl.identifier

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
  decl.identifier.symbol = member_symbol
  member_symbol.is_assigned = true
  member_symbol.declaration = decl.identifier

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
  decl.symbol = member_symbol
  member_symbol.is_assigned = true
  member_symbol.declaration = decl.identifier

  class_symbol.exports:add_value(member_symbol)

  self:bind_function_like_expression(decl.params, decl.block, decl.return_type_annotation)
end

function Binder.__index:bind_while_statement(stat)
  -- Condition
  self:bind_node(stat.expr)

  -- Block
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end

function Binder.__index:bind_break_statement(stat)
  -- Todo: check reachability and breakability of ancestor scope
end

function Binder.__index:bind_return_statement(stat)
  if stat.exprlist then
    self:bind_node_list(stat.exprlist)
  end
  
  if not self.is_function_scope then
    if self.scope.level ~= self.root_scope.level then
      error("Conditional returns are not allowed in source files")
    end

    -- Declare source file return expression
    local source_returns = self.environment:get_returns_symbol(self.file_path)
    if source_returns then
      error("Cannot re-declare source returns")
    else
      source_returns = self.environment:create_returns_symbol(self.file_path)
    end

    -- Check if we have exported static values
    if next(source_returns.exports.values) then
      error("Cannot export and return values in the same scope")
    else
      source_returns.declaration = stat
    end
  end
end

function Binder.__index:bind_import_statement(stat)
  local importing_source_returns = self.environment:get_returns_symbol(stat.path)
  if not importing_source_returns then
    importing_source_returns = self.environment:create_returns_symbol(stat.path)
  end

  importing_source_returns.is_referenced = true
  for i = 1, #stat.values do
    self:bind_import_value_declaration(stat.values[i], stat)
  end
end

function Binder.__index:bind_import_value_declaration(decl, declaring_node)
  local local_name = decl.identifier.name
  if decl.alias_identifier then
    local_name = decl.alias_identifier.name
  end

  -- In a non-strict mode, we should push the scope for re-declared variable
  if self.scope:has_level_value(local_name) then
    self:push_scope(false)
  end

  if decl.is_type then
    if self.root_scope:has_type(local_name) then
      error("type '" .. local_name .. "' was already declared in this scope")
    else
      local alias_symbol = Symbol.new(local_name)
      alias_symbol.is_assigned = true
      alias_symbol.declaration = declaring_node
      self.root_scope:add_type(alias_symbol)

      local referenced_symbol = self.environment:get_exports_type(declaring_node.path, decl.identifier.name)
      referenced_symbol.is_referenced = true
    end
  else
    local alias_symbol = Symbol.new(local_name)
    alias_symbol.is_assigned = true
    alias_symbol.declaration = declaring_node
    self.scope:add_value(alias_symbol)

    if decl.identifier.name == "*" then
      local referenced_symbol = self.environment:get_returns_symbol(declaring_node.path)
      referenced_symbol.is_referenced = true
    else
      local referenced_symbol = self.environment:get_exports_value(declaring_node.path, decl.identifier.name)
      referenced_symbol.is_referenced = true
    end
  end
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

  -- In a non-strict mode, we should push the scope if the name was previously declared
  if self.scope:has_level_value(identifier.name) then
    self:push_scope(false)
  end

  -- Bind the statement as a normal local statement
  local type_symbol = nil
  if inner_stat.syntax_kind == SyntaxKind.variable_statement then
    self:bind_variable_statement(inner_stat)
  elseif inner_stat.syntax_kind == SyntaxKind.function_statement then
    self:bind_function_statement(inner_stat)
  elseif inner_stat.syntax_kind == SyntaxKind.class_statement then
    self:bind_class_statement(inner_stat)
    type_symbol = self.root_scope:get_type(identifier.name)
  end

  -- Add the value symbol to the source file's exports
  local value_symbol = identifier.symbol
  self.environment:add_exports_value(self.file_path, value_symbol)

  -- Add the type symbol to the source file's exports if it exists
  if type_symbol then
    self.environment:add_exports_type(self.file_path, type_symbol)
  end
  
end

function Binder.__index:bind_function_statement(stat)
  -- stat.base should be an identifier in local statements; the identifier should be included in the
  -- function's block scope
  if stat.is_local then
    self:bind_value_assignment_declaration(stat.base, stat)
  else
    if stat.base.syntax_kind == SyntaxKind.member_expression then
      -- Bind member expression and see if it resolved to a bindable symbol
      self:bind_member_expression(stat.base)
    else
      -- base should be an identifier
      self:bind_value_assignment(stat.base, stat)
    end
  end

  self:bind_function_like_expression(stat.parameters, stat.block, stat.return_type_annotation)
end

function Binder.__index:bind_range_for_statement(stat)
  -- Bind range outside of loop of scope
  self:bind_node(stat.start_expr)
  self:bind_node(stat.end_expr)
  if stat.incremental_expr then
    self:bind_node(stat.incremental_expr)
  end

  -- Bind parameter inside of loop scope
  self:push_scope(true)
  self:bind_value_assignment_declaration(stat.identifier, stat)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end

function Binder.__index:bind_expression_statement(stat)
  self:bind_node(stat.expr)
end

function Binder.__index:bind_assignment_statement(stat)
  -- Bind expression first
  self:bind_node_list(stat.exprs)

  -- Bind variables
  for i = 1, #stat.variables do
    local variable = stat.variables[i]
    if variable.syntax_kind == SyntaxKind.identifier then
      self:bind_value_assignment(variable, stat)
    else
      -- Should be a member expression or index expression
      self:bind_node(variable)
    end
  end
end

function Binder.__index:bind_generic_for_statement(stat)
  -- Bind iterator outside of loop of scope
  self:bind_node_list(stat.exprlist)

  -- Bind parameters inside of loop scope
  self:push_scope(true)
  for i = 1, #stat.identifiers do
    self:bind_value_assignment_declaration(stat.identifiers[i], stat)
  end
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end

function Binder.__index:bind_repeat_until_statement(stat)
  -- Block
  self:push_scope(true)
  self:bind_node_list(stat.block)
  
  -- Condition should include locals defined in the block scope
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

-- Should return the symbol of the rightmost member if it is a member of an identifier on the left
function Binder.__index:bind_member_expression(expr)
  -- Bind left symbol
  local left_base = expr.base
  while left_base.syntax_kind == SyntaxKind.prefix_expression do
    left_base = left_base.expr
  end
  if left_base.syntax_kind == SyntaxKind.identifier then
    self:bind_value_reference(left_base)
  elseif left_base.syntax_kind == SyntaxKind.member_expression then
    self:bind_member_expression(left_base)
  end

  -- Do not bind right identifier
end

function Binder.__index:bind_index_expression(expr)
  -- Bind left expression
  self:bind_node(expr.base)
  -- Bind right expression
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
  -- Pass
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

  -- In the future, members of table literals could be bound.
end

function Binder.__index:bind_sequential_field_declaration(expr)
  self:bind_node(expr.value)
end

function Binder.__index:bind_number_literal_expression(expr)
  -- Pass
end

function Binder.__index:bind_string_literal_expression(expr)
  -- Pass
end

function Binder.__index:bind_boolean_literal_expression(expr)
  -- Pass
end

function Binder.__index:bind_variable_argument_expression(expr)
  local symbol = self.contextual_varargs
  if symbol then
    expr.symbol = symbol
    symbol.is_referenced = true
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
    -- Special case: varargs
    local varargs_symbol = Symbol.new("...")
    expr.identifier.symbol = varargs_symbol
    varargs_symbol.declaration = expr
    varargs_symbol.is_assigned = true
    self.contextual_varargs = varargs_symbol
  else

    if self.scope:has_value(expr.identifier.name) then
      -- Todo: show diagnostics for shadowing definitions

      -- Todo: in strict mode, we should guard against repeated parameters
      if self.scope:has_level_value(expr.identifier.name) then
        self:push_scope(false)
      end
    end

    self:bind_value_assignment_declaration(expr.identifier, expr)
  end
end

function Binder.__index:bind_declare_global_statement(stat)
  if not stat.is_type_declaration then
    self:bind_global_value_declaration(stat.identifier, stat)
  else
    error("Global type declarations are not yet supported")
  end
end

function Binder.__index:bind_declare_package_statement(stat)
  self:bind_type_expression(stat.type_expr)

  -- Declare source file return expression
  local source_returns = self.environment:get_returns_symbol(stat.path)
  if source_returns then
    error("Attempt to re-declare package returns")
  else
    source_returns = self.environment:create_returns_symbol(stat.path)
  end

  -- Check if we have exported static values
  if next(source_returns.exports.values) then
    error("Cannot export and return values in the same scope")
  else
    source_returns.declaration = stat
  end
end

function Binder.__index:bind_declare_returns_statement(stat)
  self:bind_type_expression(stat.type_expr)

  -- Declare source file return expression
  local source_returns = self.environment:get_returns_symbol(self.file_path)
  if source_returns then
    error("Attempt to re-declare source file returns")
  else
    source_returns = self.environment:create_returns_symbol(self.file_path)
  end

  -- Check if we have exported static values
  if next(source_returns.exports.values) then
    error("Cannot export and return values in the same scope")
  else
    source_returns.declaration = stat
  end
end

function Binder.new(...)
  local self = setmetatable({}, Binder)
  Binder.constructor(self, ...)
  return self
end

return Binder
