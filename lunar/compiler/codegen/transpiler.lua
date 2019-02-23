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
    [SyntaxKind.while_statement] = self.visit_while_statement,
    [SyntaxKind.break_statement] = self.visit_break_statement,
    [SyntaxKind.return_statement] = self.visit_return_statement,
    [SyntaxKind.function_statement] = self.visit_function_statement,
    [SyntaxKind.variable_statement] = self.visit_variable_statement,
    [SyntaxKind.expression_statement] = self.visit_expression_statement,
    [SyntaxKind.assignment_statement] = self.visit_assignment_statement,
    [SyntaxKind.repeat_until_statement] = self.visit_repeat_until_statement,

    -- exprs
    [SyntaxKind.number_literal_expression] = self.visit_number_literal_expression,
    [SyntaxKind.boolean_literal_expression] = self.visit_boolean_literal_expression,
    [SyntaxKind.string_literal_expression] = self.visit_string_literal_expression,
    [SyntaxKind.function_call_expression] = self.visit_function_call_expression,
    [SyntaxKind.member_expression] = self.visit_member_expression,
    [SyntaxKind.argument_expression] = self.visit_argument_expression,

    -- decls
    [SyntaxKind.parameter_declaration] = self.visit_parameter_declaration,
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

function Transpiler:visit_expression_statement(stat)
  return self:visit_node(stat.expr)
end

function Transpiler:visit_assignment_statement(stat)
  return self:visit_varlist(stat.members) .. " = " .. self:visit_exprlist(stat.exprs)
end

function Transpiler:visit_repeat_until_statement(stat)
  return "repeat\n" ..
    self:indent() .. self:visit_block(stat.block) .. self:dedent() ..
    "until " .. self:visit_node(stat.expr)
end

function Transpiler:visit_number_literal_expression(expr)
  return tostring(expr.value)
end

function Transpiler:visit_boolean_literal_expression(expr)
  return tostring(expr.value)
end

function Transpiler:visit_string_literal_expression(expr)
  return expr.value -- already a string
end

function Transpiler:visit_function_call_expression(expr)
  return self:visit_node(expr.member_expression) .. "(" .. self:visit_args(expr.arguments) .. ")"
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
    end

    current = current.left_member
  until current.right_member == nil -- innermost, therefore last

  return out
end

function Transpiler:visit_argument_expression(arg)
  return self:visit_node(arg.value)
end

function Transpiler:visit_parameter_declaration(param)
  return param.name
end

return Transpiler
