--[[

  TODO NEXT:
Refactor builtins and add environment argument (always include primitive types)

]]


local BaseBinder = require "lunar.compiler.semantic.base_binder"
local PrimitiveType = require "lunar.compiler.semantic.primitive_type"
local SyntaxKind = require "lunar.ast.syntax_kind"
local DiagnosticUtils = require "lunar.utils.diagnostic_utils"
local Symbol = require "lunar.compiler.semantic.symbol"
local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local Binder = {}
Binder.__index = setmetatable({}, BaseBinder)

function Binder.constructor(self, chunk, environment)
  BaseBinder.constructor(self, environment)

  self.chunk = chunk

  self.primitive_type_symbols = {
    [PrimitiveType.any_type] = Symbol.new("any"),
    [PrimitiveType.nil_type] = Symbol.new("nil"),
    [PrimitiveType.string_type] = Symbol.new("string"),
    [PrimitiveType.boolean_type] = Symbol.new("boolean"),
    [PrimitiveType.function_type] = Symbol.new("function"),
    [PrimitiveType.userdata_type] = Symbol.new("userdata"),
    [PrimitiveType.thread_type] = Symbol.new("thread"),
    [PrimitiveType.table_type] = Symbol.new("table"),
  }

  self.binding_visitors = {
    [SyntaxKind.chunk] = self.bind_chunk,

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
    [SyntaxKind.index_field_declaration] = self.bind_index_field_declaration,
    [SyntaxKind.member_field_declaration] = self.bind_member_field_declaration,
    [SyntaxKind.sequential_field_declaration] = self.bind_sequential_field_declaration,
    [SyntaxKind.parameter_declaration] = self.bind_parameter_declaration,

  }
end

function Binder.__index:bind()
    self:bind_chunk(self.chunk)
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
    -- else it is unbound
    -- todo: add warning to diagnostic chain
  end
end

function Binder.__index:bind_value_assignment(identifier, declaring_node)
  local symbol
  if self.scope:has_value(identifier.name) then
    symbol = self:bind_local_value_symbol(identifier, identifier.name)
  else
    -- else it is a first global assignment; todo: add warning to diagnostic chain if in strict mode
    symbol = self:bind_global_value_symbol(identifier, identifier.name)
    symbol.declaration = declaring_node
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
  if self.scope:has_type(identifier.name) then
    local symbol = self:bind_local_type_symbol(identifier, identifier.name)
    symbol.is_referenced = true
  else
    -- else it is unbound
    -- todo: add warning to diagnostic chain
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

function Binder.__index:bind_chunk(node)
  self:push_scope(true)
  self:bind_node_list(node.block)
  self:pop_level_scopes()
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

  self:push_scope()

  -- Add static and type symbols
  self:bind_value_assignment_declaration(identifier, stat)
  local type_symbol = Symbol.new(identifier.name)
  self.scope:add_type(type_symbol)
  type_symbol.is_assigned = true
  type_symbol.declaration = stat

  -- Bind superclass identifier
  if stat.super_identifier then
    self:bind_type_reference(stat.super_identifier)
    self:bind_value_reference(stat.super_identifier)

    -- Pass declaration status of the "super" identifier from the extended class
    local super_symbol = Symbol.new("super")
    self.scope:add_value(super_symbol)
    super_symbol.is_assigned = stat.super_identifier.is_assigned
    super_symbol.declaration = stat.super_identifier.declaration
  end

  -- Bind "self" and "super" types for this scope
  local self_symbol = Symbol.new("self")
  self.scope:add_value(self_symbol)
  self_symbol.is_assigned = true
  self_symbol.declaration = stat

  -- Bind class member declarations in a new SymbolTable
  type_symbol.members = SymbolTable.new()
  for i = 1, #stat.members do
    local member = stat.members[i]
    if member.syntax_kind == SyntaxKind.class_function_declaration then
      local member_symbol = Symbol.new(member.identifier.name)
      member_symbol.is_assigned = true

      if not member.is_static then
        type_symbol.members:add_value(member_symbol)
      end

      self:bind_function_like_expression(member.params, member.block, member.return_type_annotation)
    elseif member.syntax_kind == SyntaxKind.constructor_declaration then
      self:bind_function_like_expression(member.params, member.block)
    else
      error("Unbound class declaration of syntax kind '"
        .. tostring(DiagnosticUtils.index_of(SyntaxKind, member.syntax_kind))
        .. "'"
      )
    end
  end
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
  -- Todo: check reachability and returnability of ancestor scope
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
  -- Condition
  self:bind_node(stat.expr)

  -- Block
  self:push_scope(true)
  self:bind_node_list(stat.block)
  self:pop_level_scopes()
end

function Binder.__index:bind_prefix_expression(stat)
  self:bind_node(stat.expr)
end

function Binder.__index:bind_lambda_expression(stat)
  if stat.expr then
    self:bind_node(stat.expr)
  end
  
  self:push_scope(true, true)
  self:bind_node_list(stat.parameters)
  if stat.implicit_return then
    self:bind_node(stat.body)
  else
    self:bind_node_list(stat.body)
  end
  self:pop_level_scopes()
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
  self:push_scope(true, true)
  self:bind_node_list(params)
  self:bind_node_list(block)
  self:pop_level_scopes()

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
  self:bind_node_list(expr.fields)
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
  local symbol = self:get_last_vararg_symbol()
  if symbol then
    expr.symbol = symbol
    symbol.is_referenced = true
  else
    error("Attempt to reference vararg expression '...' in a scope where it was not declared")
  end
end

function Binder.__index:bind_type_assertion_expression(expr)
end

function Binder.__index:bind_index_field_declaration(expr)
  self:bind_node(expr.key)
  self:bind_node(expr.value)
end

function Binder.__index:bind_member_field_declaration(expr)
  -- Do not bind identifier
  self:bind_node(expr.value)
end

function Binder.__index:bind_sequential_field_declaration(expr)
  self:bind_node(expr.value)
end

function Binder.__index:bind_parameter_declaration(expr)
  if expr.identifier.name == "..." then
    -- Special case: varargs
    local varargs_symbol = Symbol.new("...")
    self:declare_varargs(varargs_symbol, expr)
    self.scope:add_value(varargs_symbol)
  else

    if self.scope:has_value(expr.identifier.name) then
      -- Todo: show diagnostics for shadowing definitions
  
      -- Todo: in strict mode, we should guard against repeated parameters
      if self.scope:has_level_value(expr.identifier.name) then
        self:push_scope(true)
      end
    end
  
    self:bind_value_assignment_declaration(expr.identifier, expr)
  end
end

function Binder.new(...)
  local self = setmetatable({}, Binder)
  Binder.constructor(self, ...)
  return self
end

return Binder