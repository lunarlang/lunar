local AST = require "lunar.ast"
local SyntaxKind = require "lunar.ast.syntax_kind"
local BaseTranspiler = require "lunar.compiler.codegen.base_transpiler"
local Binder = require "lunar.compiler.semantic.binder"

local Transpiler = setmetatable({}, BaseTranspiler)
Transpiler.__index = Transpiler

function Transpiler.new(ast)
  local super = BaseTranspiler.new()
  local self = setmetatable(super, Transpiler)
  self.chunk = AST.Chunk.new(ast)
  self.binder = Binder.new(self.chunk)
  self.visitors = {
    [SyntaxKind.chunk] = self.visit_chunk,

    -- stats
    [SyntaxKind.do_statement] = self.visit_do_statement,
    [SyntaxKind.if_statement] = self.visit_if_statement,
    [SyntaxKind.class_statement] = self.visit_class_statement,
    [SyntaxKind.while_statement] = self.visit_while_statement,
    [SyntaxKind.break_statement] = self.visit_break_statement,
    [SyntaxKind.return_statement] = self.visit_return_statement,
    [SyntaxKind.function_statement] = self.visit_function_statement,
    [SyntaxKind.variable_statement] = self.visit_variable_statement,
    [SyntaxKind.range_for_statement] = self.visit_range_for_statement,
    [SyntaxKind.expression_statement] = self.visit_expression_statement,
    [SyntaxKind.assignment_statement] = self.visit_assignment_statement,
    [SyntaxKind.generic_for_statement] = self.visit_generic_for_statement,
    [SyntaxKind.repeat_until_statement] = self.visit_repeat_until_statement,

    -- exprs
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

    -- decls
    [SyntaxKind.index_field_declaration] = self.visit_index_field_declaration,
    [SyntaxKind.member_field_declaration] = self.visit_member_field_declaration,
    [SyntaxKind.sequential_field_declaration] = self.visit_sequential_field_declaration,
    [SyntaxKind.parameter_declaration] = self.visit_parameter_declaration,
  }

  self.binary_op_map = {
    [AST.BinaryOpKind.addition_op] = "+",
    [AST.BinaryOpKind.subtraction_op] = "-",
    [AST.BinaryOpKind.multiplication_op] = "*",
    [AST.BinaryOpKind.division_op] = "/",
    [AST.BinaryOpKind.modulus_op] = "%",
    [AST.BinaryOpKind.power_op] = "^",
    [AST.BinaryOpKind.concatenation_op] = "..",
    [AST.BinaryOpKind.not_equal_op] = "~=",    [AST.BinaryOpKind.equal_op] = "==",
    [AST.BinaryOpKind.less_than_op] = "<",
    [AST.BinaryOpKind.less_or_equal_op] = "<=",
    [AST.BinaryOpKind.greater_than_op] = ">",
    [AST.BinaryOpKind.greater_or_equal_op] = ">=",
    [AST.BinaryOpKind.and_op] = "and",
    [AST.BinaryOpKind.or_op] = "or",
  }

  self.unary_op_map = {
    [AST.UnaryOpKind.negative_op] = "-",
    [AST.UnaryOpKind.not_op] = "not ", -- space is intentional!
    [AST.UnaryOpKind.length_op] = "#",
  }

  return self
end

function Transpiler:transpile()
  self.binder:bind()

  self:write(self:visit_chunk(self.chunk))
  return self.source
end

function Transpiler:visit_node(node)
  local visitor = self.visitors[node.syntax_kind]
  if visitor then
    return visitor(self, node)
  end

  error(("No visitor found for SyntaxKind %d"):format(node.syntax_kind))
end

function Transpiler:visit_block(block)
  local out = ""

  for _, stat in pairs(block) do
    out = out .. self:visit_node(stat) .. "\n"
  end

  return out
end

function Transpiler:visit_chunk(chunk)
  return self:visit_block(chunk.block)
end

function Transpiler:visit_varlist(varlist)
  local out = {}

  for _, var in pairs(varlist) do
    table.insert(out, self:visit_node(var))
  end

  return table.concat(out, ", ")
end

function Transpiler:visit_fields(fields)
  if #fields == 0 then return "" end

  local out = "\n"

  self:indent()
  for _, field in pairs(fields) do
    out = out .. self:get_indent() .. self:visit_field_declaration(field) .. ",\n"
  end
  self:dedent()

  return out
end


function Transpiler:visit_params(params)
  local out = {}

  for _, param in pairs(params) do
    table.insert(out, self:visit_node(param))
  end

  return table.concat(out, ", ")
end

function Transpiler:visit_args(args)
  -- since this one has to not have leading comma, otherwise we emit invalid lua
  -- we use a list of string instead and then use table.concat for convenience
  local out = {}

  for _, expr in pairs(args) do
    table.insert(out, self:visit_node(expr))
  end

  return table.concat(out, ", ")
end

function Transpiler:visit_exprlist(exprlist)
  local out = {}

  for _, expr in pairs(exprlist) do
    table.insert(out, self:visit_node(expr))
  end

  return table.concat(out, ", ")
end

function Transpiler:visit_do_statement(stat)
  return self:get_indent() .. "do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_if_statement(stat)
  local out = self:get_indent() .. "if " .. self:visit_node(stat.expr) .. " then\n" ..
    self:indent() .. self:visit_block(stat.block)
  self:dedent()

  for _, elseif_branch in pairs(stat.elseif_branches) do
    out = out .. self:get_indent() .. "elseif " .. self:visit_node(elseif_branch.expr) .. " then\n" ..
      self:indent() .. self:visit_block(elseif_branch.block)
    self:dedent()
  end

  if stat.else_branch then
    out = out .. self:get_indent() .. "else\n" ..
      self:indent() .. self:visit_block(stat.else_branch.block)
    self:dedent()
  end

  out = out .. self:get_indent() .. "end"
  return out
end

function Transpiler:visit_class_statement(stat)
  return self:visit_block(stat:lower())
end

function Transpiler:visit_while_statement(stat)
  return self:get_indent() .. "while " .. self:visit_node(stat.expr) .. " do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_break_statement(stat)
  return self:get_indent() .. "break"
end

function Transpiler:visit_return_statement(stat)
  if stat.exprlist then
    return self:get_indent() .. "return " .. self:visit_exprlist(stat.exprlist)
  end

  return self:get_indent() .. "return"
end

function Transpiler:visit_function_statement(stat)
  local out = self:get_indent()

  if stat.is_local then
    out = out .. "local function " .. self:visit_node(stat.base)
  else
    out = out .. "function " .. self:visit_node(stat.base)
  end

  out = out .. "(" .. self:visit_params(stat.parameters) .. ")\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"

  return out
end

function Transpiler:visit_variable_statement(stat)
  local out = self:get_indent() .. "local "
  for i = 1, #stat.identlist do
    if i > 1 then
      out = out .. ", "
    end
    out = out .. stat.identlist[i].name
  end
  if stat.exprlist then
    return out .. " = " .. self:visit_exprlist(stat.exprlist)
  else
    return out
  end
end

function Transpiler:visit_identifier(node)
  return node.name
end

function Transpiler:visit_range_for_statement(stat)
  local out = self:get_indent() .. "for " .. stat.identifier.name .. " = " ..
    self:visit_node(stat.start_expr) .. ", " .. self:visit_node(stat.end_expr)

  if stat.incremental_expr then
    out = out .. ", " .. self:visit_node(stat.incremental_expr)
  end

  out = out .. " do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"

  return out
end

function Transpiler:visit_expression_statement(stat)
  return self:get_indent() .. self:visit_node(stat.expr)
end

function Transpiler:visit_assignment_statement(stat)
  local lowered = stat:lower()
  return self:get_indent() .. self:visit_varlist(lowered.variables) .. " = " .. self:visit_exprlist(lowered.exprs)
end

function Transpiler:visit_generic_for_statement(stat)
  local out = self:get_indent() .. "for "
  for i = 1, #stat.identifiers do
    if i > 1 then
      out = out .. ", "
    end
    out = out .. stat.identifiers[i].name
  end
  return out .. " in " .. self:visit_exprlist(stat.exprlist) .. "do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_repeat_until_statement(stat)
  return self:get_indent() .. "repeat\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "until " .. self:visit_node(stat.expr)
end

function Transpiler:visit_prefix_expression(expr)
  return "(" .. self:visit_node(expr.expr) .. ")"
end

function Transpiler:visit_lambda_expression(expr)
  return self:visit_function_expression(expr:lower())
end

function Transpiler:visit_member_expression(member)
  local out = (member.has_colon and ":" or ".") .. member.member_identifier.name

  -- we'll visit left, recursively
  out = self:visit_node(member.base) .. out

  return out
end

function Transpiler:visit_index_expression(expr)
  local out = "[" .. self:visit_node(expr.index) .. "]"

  -- we'll visit left, recursively
  out = self:visit_node(expr.base) .. out

  return out
end

function Transpiler:visit_argument_expression(arg)
  return self:visit_node(arg.value)
end

function Transpiler:visit_function_expression(expr)
  return "function(" .. self:visit_params(expr.parameters) .. ")\n" ..
    self:indent() .. self:visit_block(expr.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_nil_literal_expression(expr)
  return "nil"
end

function Transpiler:visit_function_call_expression(expr)
  return self:visit_node(expr.base) .. "(" .. self:visit_args(expr.arguments) .. ")"
end

function Transpiler:visit_unary_op_expression(expr)
  -- wrapping around parenthesis because if we have "- -1" as the input, we would get out "--1"
  return "(" .. self.unary_op_map[expr.operator] .. self:visit_node(expr.right_operand) .. ")"
end

function Transpiler:visit_binary_op_expression(expr)
  return self:visit_node(expr.left_operand) ..
    " " .. self.binary_op_map[expr.operator] .. " " ..
    self:visit_node(expr.right_operand)
end

function Transpiler:visit_table_literal_expression(expr)
  return "{" .. self:visit_fields(expr.fields) .. self:get_indent() .. "}"
end

function Transpiler:visit_number_literal_expression(expr)
  return tostring(expr.value)
end

function Transpiler:visit_string_literal_expression(expr)
  return expr.value -- already a string
end

function Transpiler:visit_boolean_literal_expression(expr)
  return tostring(expr.value)
end

function Transpiler:visit_variable_argument_expression(expr)
  return "..."
end

function Transpiler:visit_type_assertion_expression(expr)
  return self:visit_node(expr.base)
end

function Transpiler:visit_field_declaration(field)
  if field.syntax_kind == SyntaxKind.sequential_field_declaration then
    return self:visit_sequential_field_declaration(field)
  elseif field.syntax_kind == SyntaxKind.member_field_declaration then
    return self:visit_member_field_declaration(field)
  else
    return self:visit_index_field_declaration(field)
  end
end

function Transpiler:visit_sequential_field_declaration(field)
  return self:visit_node(field.value)
end

function Transpiler:visit_member_field_declaration(field)
  return field.member_identifier.name .. " = " .. self:visit_node(field.value)
end

function Transpiler:visit_index_field_declaration(field)
  return "[" .. self:visit_node(field.key) .. "] = " .. self:visit_node(field.value)
end

function Transpiler:visit_parameter_declaration(param)
  return self:visit_identifier(param.identifier)
end

return Transpiler
