local AST = require "lunar.ast"
local SyntaxKind = require "lunar.ast.syntax_kind"
local BaseTranspiler = require "lunar.compiler.codegen.base_transpiler"

local Transpiler = setmetatable({}, BaseTranspiler)
Transpiler.__index = Transpiler

function Transpiler.new(ast)
  local super = BaseTranspiler.new()
  local self = setmetatable(super, Transpiler)
  self.ast = ast
  self.visitors = {
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

    -- decls
    [SyntaxKind.field_declaration] = self.visit_field_declaration,
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
  self:write(self:visit_block(self.ast))
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

function Transpiler:visit_varlist(varlist)
  local out = {}

  for _, var in pairs(varlist) do
    table.insert(out, self:visit_member_expression(var))
  end

  return table.concat(out, ", ")
end

function Transpiler:visit_fields(fields)
  local out = {}

  for _, field in pairs(fields) do
    table.insert(out, self:visit_field_declaration(field))
  end

  return table.concat(out, ", ")
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
  return "do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_if_statement(stat)
  local out = "if " .. self:visit_node(stat.expr) .. " then\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent()

  for _, elseif_branch in pairs(stat.elseif_branches) do
    out = out .. "elseif " .. self:visit_node(elseif_branch.expr) .. " then\n" ..
      self:indent() .. self:visit_block(elseif_branch.block) .. self:dedent()
  end

  if stat.else_branch then
    out = out .. "else\n" ..
      self:indent() .. self:visit_block(stat.else_branch.block) .. self:dedent()
  end

  out = out .. "end"
  return out
end

function Transpiler:visit_class_statement(stat)
  local lowered = stat:lower()

  local out = self:visit_node(lowered.static_def) .. "\n" ..
    self:visit_block(lowered.static_members) ..
    self:visit_node(lowered.instance_def) .. "\n"

  if lowered.class_inherit_super then
    out = out .. self:visit_node(lowered.class_inherit_super) .. "\n"
  end

  out = out .. self:visit_block(lowered.instance_members)
  return out
end

function Transpiler:visit_while_statement(stat)
  return "while " .. self:visit_node(stat.expr) .. " do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_break_statement(stat)
  return "break"
end

function Transpiler:visit_return_statement(stat)
  if stat.exprlist then
    return "return " .. self:visit_exprlist(stat.exprlist)
  end

  return "return"
end

function Transpiler:visit_function_statement(stat)
  local out = ""

  if stat.is_local then
    out = "local function " .. stat.name
  else
    out = "function " .. self:visit_node(stat.name)
  end

  out = out .. "(" .. self:visit_params(stat.parameters) .. ")\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"

  return out
end

function Transpiler:visit_variable_statement(stat)
  return "local " .. table.concat(stat.namelist, ", ") .. " = " .. self:visit_exprlist(stat.exprlist)
end

function Transpiler:visit_range_for_statement(stat)
  local out = "for " .. stat.identifier .. " = " ..
    self:visit_node(stat.start_expr) .. ", " .. self:visit_node(stat.end_expr)

  if stat.incremental_expr then
    out = out .. ", " .. self:visit_node(stat.incremental_expr)
  end

  out = out .. " do" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"

  return out
end

function Transpiler:visit_expression_statement(stat)
  return self:visit_node(stat.expr)
end

function Transpiler:visit_assignment_statement(stat)
  local lowered = stat:lower()
  return self:visit_varlist(lowered.members) .. " = " .. self:visit_exprlist(lowered.exprs)
end

function Transpiler:visit_generic_for_statement(stat)
  return "for " .. table.concat(stat.identifiers, ", ") .. " in " .. self:visit_exprlist(stat.exprlist) .. "do\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "end"
end

function Transpiler:visit_repeat_until_statement(stat)
  return "repeat\n" ..
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
  local out = ""
  local current = member

  repeat
    if type(current.right_member) == "string" then
      -- right_member is a string, so possibly has ':' or '.'
      out = (current.has_colon and ":" or ".") .. current.right_member .. out
    elseif current.right_member ~= nil then
      -- right_member wasn't a string but should not be nil
      -- therefore right_member should be any expression
      out = "[" .. self:visit_node(current.right_member) .. "]" .. out
    end

    if type(current.left_member) == "string" then
      -- left_member was a string which means we're at the innermost MemberExpression
      out = current.left_member .. out
      break
    else
      -- otherwise we'll visit left, recursively
      out = self:visit_node(current.left_member) .. out
      break
    end

    current = current.left_member
  until current.right_member == nil -- innermost, therefore last

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
  return self:visit_node(expr.member_expression) .. "(" .. self:visit_args(expr.arguments) .. ")"
end

function Transpiler:visit_unary_op_expression(expr)
  -- wrapping around parenthesis because if we have "- -1" as the input, we would get out "--1"
  return "(" .. self.unary_op_map[expr.operator] .. self:visit_node(expr.right_operand) .. ")"
end

function Transpiler:visit_binary_op_expression(expr)
  local out = ""

  -- while left_operand is of BinaryOpExpression, visit left
  repeat
    local current = expr

    out = self:visit_node(current.left_operand) ..
      " " .. self.binary_op_map[expr.operator] .. " " ..
      self:visit_node(current.right_operand) .. out

    current = current.left_operand
  until current.left_operand == nil or current.left_operand.syntax_kind ~= SyntaxKind.binary_op_expression

  return out
end

function Transpiler:visit_table_literal_expression(expr)
  return "{" .. self:visit_fields(expr.fields) .. "}"
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

function Transpiler:visit_field_declaration(field)
  if field.key == nil then
    return self:visit_node(field.value)
  elseif type(field.key) == "string" then
    return field.key .. " = " .. self:visit_node(field.value)
  else
    return "[" .. self:visit_node(field.key) .. "] = " .. self:visit_node(field.value)
  end
end

function Transpiler:visit_parameter_declaration(param)
  return param.name
end

return Transpiler
