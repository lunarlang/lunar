--[[

	TODO NEXT:
Refactor rest vararg parameter
Store declarations within symbols
Migrate return in bind_member_expression to a separate util call that recurs after binding
Handle "self" and "super" identifiers as special cases
Handle statics of declared classes within member expressions

]]


local BaseBinder = require "lunar.compiler.semantic.base_binder"
local PrimitiveType = require "lunar.compiler.semantic.primitive_type"
local SyntaxKind = require "lunar.ast.syntax_kind"
local DiagnosticUtils = require "lunar.utils.diagnostic_utils"
local Symbol = require "lunar.compiler.semantic.symbol"
local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local Binder = {}
Binder.__index = setmetatable({}, BaseBinder)

function Binder.constructor(self, chunk)
	BaseBinder.constructor(self)

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
		
    -- Declarations
    [SyntaxKind.field_declaration] = self.bind_field_declaration,
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
	self:bind_identifier_reference(identifier)
end

function Binder.__index:bind_identifier_reference(identifier)
	if self.scope:has(identifier.name) then
		local symbol = self:bind_local_symbol(identifier, identifier.name)
		symbol.is_referenced = true
	else
		-- else it is unbound
		-- todo: add warning to diagnostic chain
	end
end

function Binder.__index:bind_identifier_assignment(identifier)
	local symbol
	if self.scope:has(identifier.name) then
		symbol = self:bind_local_symbol(identifier, identifier.name)
	else
		-- else it is a global assignment; todo: add warning to diagnostic chain
		symbol = self:bind_global_symbol(identifier, identifier.name)
	end
	symbol.is_assigned = true
end

function Binder.__index:bind_identifier_assignment_declaration(identifier)
	-- In a non-strict mode, we should push the scope for re-declared variable
	if self.scope:has(identifier) then
		self:push_scope(false)
	end

	-- Allow types to be annotated in declarations
	if identifier.type_annotation then
		self:bind_node(identifier.type_annotation)
	end

	self:bind_identifier_assignment(identifier)
end

function Binder.__index:bind_identifier_declaration(identifier)
	-- In a non-strict mode, we should push the scope for re-declared variable
	if self.scope:has(identifier) then
		self:push_scope(false)
	end

	-- Allow types to be annotated in declarations
	if identifier.type_annotation then
		self:bind_node(identifier.type_annotation)
	end

	self:bind_local_symbol(identifier, identifier.name)
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
			self:bind_identifier_assignment_declaration(identifier)
		else
			self:bind_identifier_declaration(identifier)
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
	-- Determine if a variable was re-declared
	-- In a non-strict mode, we should push the scope for re-declared variable
	if self.scope:has(identifier) then
		self:push_scope(false)
	end

	-- Add symbol
	local symbol = self:bind_local_symbol(identifier, identifier.name)

	-- Flag as assigned
	symbol.is_assigned = true

	-- Bind class member declarations in a new SymbolTable
	symbol.members = SymbolTable.new()
	for i = 1, #stat.members do
		local member = stat.members[i]
		if member.syntax_kind == SyntaxKind.class_function_declaration then
			
		else
			error("Unbound class declaration of syntax kind '"
				.. DiagnosticUtils.index_of(SyntaxKind, tostring(member.syntax_kind))
				.. "'"
			)
		end
	end

	-- Bind superclass identifier
	if self.super_identifier then
		self:bind_identifier(self.super_identifier)
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
		self:bind_identifier_assignment_declaration(stat.base)
	else
		if self.base.syntax_kind == SyntaxKind.member_expression then
			-- Bind member expression and see if it resolved to a bindable symbol
			local member_symbol = self:bind_member_expression(self.base)
			if member_symbol then
				-- Mark as assigned
				member_symbol.is_assigned = true
			end
		else
			-- base should be an identifier
			self:bind_identifier_assignment(stat.base)
		end
	end
	
	self:push_scope(true)
	self:bind_node_list(stat.parameters)
	self:bind_node_list(stat.block)
	self:pop_level_scopes()
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
	self:bind_identifier_assignment_declaration(stat.identifier)
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
		if variable.syntax_kind == SyntaxKind.member_expression then
			local member_symbol = self:bind_member_expression(self.base)
			if member_symbol then
				-- Mark as assigned
				member_symbol.is_assigned = true
			end
		else
			-- Should be an identifier
			self:bind_identifier_assignment(variable)
		end
	end
end

function Binder.__index:bind_generic_for_statement(stat)
	-- Bind iterator outside of loop of scope
	self:bind_node_list(stat.exprlist)

	-- Bind parameters inside of loop scope
	self:push_scope(true)
	for i = 1, #stat.identifiers do
		self:bind_identifier_assignment_declaration(stat.identifiers[i])
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
	self:bind_node(stat.expr)
	
	self:push_scope(true)
	self:bind_node_list(stat.parameters)
	if stat.implicit_return then
		self:bind_node(stat.body)
	else
		self:bind_node_list(stat.body)
	end
	self:pop_level_scopes()
end

-- Should return the symbol of the rightmost member if it is a member of an identifier on the left
function Binder.__index:bind_member_expression(stat)

end

--[[

function Binder.__index:(stat)
end

]]

function Binder.new(...)
	local self = setmetatable({}, Binder)
	Binder.constructor(self, ...)
	return self
end

return Binder