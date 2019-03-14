local AST = require("lunar.ast")
local SyntaxKind = require("lunar.ast.syntax_kind")
local BaseTranspiler = require("lunar.compiler.codegen.base_transpiler")
local Transpiler = setmetatable({}, { __index = BaseTranspiler })
Transpiler.__index = setmetatable({}, BaseTranspiler)
local super = BaseTranspiler.constructor
function Transpiler.new(ast)
  return Transpiler.constructor(setmetatable({}, Transpiler), ast)
end
function Transpiler.constructor(self, ast)
  super(self)
  self.footer_exports = nil
  self.visitors = {
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
    [AST.BinaryOpKind.not_equal_op] = "~=",
    [AST.BinaryOpKind.equal_op] = "==",
    [AST.BinaryOpKind.less_than_op] = "<",
    [AST.BinaryOpKind.less_or_equal_op] = "<=",
    [AST.BinaryOpKind.greater_than_op] = ">",
    [AST.BinaryOpKind.greater_or_equal_op] = ">=",
    [AST.BinaryOpKind.and_op] = "and",
    [AST.BinaryOpKind.or_op] = "or",
  }
  self.unary_op_map = {
    [AST.UnaryOpKind.negative_op] = "-",
    [AST.UnaryOpKind.not_op] = "not ",
    [AST.UnaryOpKind.length_op] = "#",
  }
  self.ast = ast
  return self
end
function Transpiler.__index:transpile()
  self:visit_block(self.ast)
  self:visit_footer_exports()
  return self.source
end
function Transpiler.__index:visit_node(node)
  local visitor = self.visitors[node.syntax_kind]
  if visitor then
    return visitor(self, node)
  end
  error(("No visitor found for SyntaxKind %d"):format(node.syntax_kind))
end
function Transpiler.__index:visit_block(block)
  for _, stat in pairs(block) do
    self:visit_node(stat)
  end
end
function Transpiler.__index:visit_varlist(varlist)
  for i, var in pairs(varlist) do
    self:visit_node(var)
    if i ~= (#varlist) then
      self:write(", ")
    end
  end
end
function Transpiler.__index:visit_identlist(identlist)
  for i = 1, (#identlist) do
    if i > 1 then
      self:write(", ")
    end
    self:write(identlist[i].name)
  end
end
function Transpiler.__index:visit_fields(fields)
  if (#fields) == 0 then
    return ""
  end
  self:indent()
  for _, field in pairs(fields) do
    self:writeln()
    self:iwrite()
    self:visit_field_declaration(field)
    self:write(",")
  end
  self:dedent()
end
function Transpiler.__index:visit_params(params)
  for i, param in pairs(params) do
    self:visit_node(param)
    if i ~= (#params) then
      self:write(", ")
    end
  end
end
function Transpiler.__index:visit_args(args)
  for i, expr in pairs(args) do
    self:visit_node(expr)
    if i ~= (#args) then
      self:write(", ")
    end
  end
end
function Transpiler.__index:visit_exprlist(exprlist)
  for i, expr in pairs(exprlist) do
    self:visit_node(expr)
    if i ~= (#exprlist) then
      self:write(", ")
    end
  end
end
function Transpiler.__index:visit_class_function_declaration_list(methods, class_decl)
  for _, method in pairs(methods) do
    self:visit_class_function_declaration(method, class_decl)
  end
end
function Transpiler.__index:visit_constructor_declaration(ctor, fields, class_decl)
  if fields == nil then
    fields = {}
  end
  self:iwrite("function ")
  self:visit_identifier(class_decl.identifier)
  self:write(".new(")
  if ctor and ctor.params and (#ctor.params) > 0 then
    self:visit_params(ctor.params)
  end
  self:writeln(")")
  self:indent()
  self:iwrite("return ")
  self:visit_identifier(class_decl.identifier)
  self:write(".constructor(setmetatable({}, ")
  self:visit_identifier(class_decl.identifier)
  self:write(")")
  if ctor and ctor.params and (#ctor.params) > 0 then
    self:write(", ")
    self:visit_params(ctor.params)
  end
  self:writeln(")")
  self:dedent()
  self:iwriteln("end")
  self:iwrite("function ")
  self:visit_identifier(class_decl.identifier)
  self:write(".constructor(self")
  if ctor and ctor.params and (#ctor.params) > 0 then
    self:write(", ")
    self:visit_params(ctor.params)
  end
  self:writeln(")")
  self:indent()
  if class_decl.super_identifier then
    self:iwrite("super(self")
    for index, stat in pairs(ctor and ctor.block or {}) do
      if stat.syntax_kind == SyntaxKind.expression_statement and stat.expr.syntax_kind == SyntaxKind.function_call_expression and stat.expr.base.syntax_kind == SyntaxKind.identifier and stat.expr.base.name == "super" then
        local super_stat = stat
        table.remove(ctor.block, index)
        if super_stat.expr and super_stat.expr.arguments and (#super_stat.expr.arguments) > 0 then
          self:write(", ")
          self:visit_args(super_stat.expr.arguments)
        end
        break
      end
    end
    self:writeln(")")
  end
  for _, field in pairs(fields) do
    self:iwrite("self.")
    self:visit_identifier(field.identifier)
    self:write(" = ")
    self:visit_node(field.value)
    self:writeln()
  end
  self:visit_block(ctor and ctor.block or {})
  self:iwriteln("return self")
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_class_function_declaration(method, class_decl)
  self:iwrite("function ")
  self:visit_identifier(class_decl.identifier)
  self:write(".")
  if (not method.is_static) then
    self:write("__index:")
  end
  self:visit_identifier(method.identifier)
  self:write("(")
  self:visit_params(method.params)
  self:writeln(")")
  self:indent()
  self:visit_block(method.block)
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_do_statement(stat)
  self:iwriteln("do")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_if_statement(stat)
  self:iwrite("if ")
  self:visit_node(stat.expr)
  self:writeln(" then")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  for _, elseif_branch in pairs(stat.elseif_branches) do
    self:iwrite("elseif ")
    self:visit_node(elseif_branch.expr)
    self:writeln(" then")
    self:indent()
    self:visit_block(elseif_branch.block)
    self:dedent()
  end
  if stat.else_branch then
    self:iwriteln("else")
    self:indent()
    self:visit_block(stat.else_branch.block)
    self:dedent()
  end
  self:iwriteln("end")
end
function Transpiler.__index:visit_class_statement(stat)
  self:iwrite("local ")
  self:visit_identifier(stat.identifier)
  self:write(" = ")
  if stat.super_identifier ~= nil then
    self:write("setmetatable({}, { __index = ")
    self:visit_identifier(stat.super_identifier)
    self:writeln(" })")
  else
    self:writeln("{}")
  end
  self:visit_identifier(stat.identifier)
  self:write(".__index = ")
  if stat.super_identifier ~= nil then
    self:write("setmetatable({}, ")
    self:visit_identifier(stat.super_identifier)
    self:writeln(")")
  else
    self:writeln("{}")
  end
  if stat.super_identifier then
    self:iwrite("local super = ")
    self:visit_identifier(stat.super_identifier)
    self:writeln(".constructor")
  end
  local instance_fields, static_fields = {}, {}
  local instance_methods, static_methods = {}, {}
  local ctor = nil
  for _, member in pairs(stat.members) do
    if member.syntax_kind == SyntaxKind.class_field_declaration then
      local list = member.is_static and static_fields or instance_fields
      table.insert(list, member)
    elseif member.syntax_kind == SyntaxKind.class_function_declaration then
      local list = member.is_static and static_methods or instance_methods
      table.insert(list, member)
    elseif member.syntax_kind == SyntaxKind.constructor_declaration then
      ctor = member
    end
  end
  for _, field in pairs(static_fields) do
    self:visit_identifier(stat.identifier)
    self:write(".")
    self:visit_identifier(field.identifier)
    self:write(" = ")
    self:visit_node(field.value)
    self:writeln()
  end
  self:visit_constructor_declaration(ctor, instance_fields, stat)
  self:visit_class_function_declaration_list(static_methods, stat)
  self:visit_class_function_declaration_list(instance_methods, stat)
end
function Transpiler.__index:visit_while_statement(stat)
  self:iwrite("while ")
  self:visit_node(stat.expr)
  self:writeln(" do")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_break_statement(stat)
  self:iwriteln("break")
end
function Transpiler.__index:visit_return_statement(stat)
  self:iwrite("return")
  if stat.exprlist then
    self:write(" ")
    self:visit_exprlist(stat.exprlist)
  end
  self:write("\n")
end
function Transpiler.__index:visit_function_statement(stat)
  if stat.is_local then
    self:iwrite("local ")
  end
  self:write("function ")
  self:visit_node(stat.base)
  self:write("(")
  self:visit_params(stat.parameters)
  self:writeln(")")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_variable_statement(stat)
  self:iwrite("local ")
  self:visit_identlist(stat.identlist)
  if stat.exprlist then
    self:write(" = ")
    self:visit_exprlist(stat.exprlist)
  end
  self:writeln()
end
function Transpiler.__index:visit_identifier(node)
  self:write(node.name)
end
function Transpiler.__index:visit_range_for_statement(stat)
  self:iwrite("for ")
  self:visit_identifier(stat.identifier)
  self:write(" = ")
  self:visit_node(stat.start_expr)
  self:write(", ")
  self:visit_node(stat.end_expr)
  if stat.incremental_expr then
    self:write(", ")
    self:visit_node(stat.incremental_expr)
  end
  self:writeln(" do")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_expression_statement(stat)
  self:iwrite()
  self:visit_node(stat.expr)
  self:writeln()
end
function Transpiler.__index:visit_assignment_statement(stat)
  local lowered = stat:lower()
  self:iwrite()
  self:visit_varlist(lowered.variables)
  self:write(" = ")
  self:visit_exprlist(lowered.exprs)
  self:writeln()
end
function Transpiler.__index:visit_generic_for_statement(stat)
  self:iwrite("for ")
  self:visit_identlist(stat.identifiers)
  self:write(" in ")
  self:visit_exprlist(stat.exprlist)
  self:writeln(" do")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  self:iwriteln("end")
end
function Transpiler.__index:visit_repeat_until_statement(stat)
  self:iwriteln("repeat")
  self:indent()
  self:visit_block(stat.block)
  self:dedent()
  self:iwrite("until ")
  self:visit_node(stat.expr)
  self:writeln()
end
function Transpiler.__index:visit_declare_global_statement(stat)
end
function Transpiler.__index:visit_declare_package_statement(stat)
end
function Transpiler.__index:visit_declare_returns_statement(stat)
end
function Transpiler.__index:visit_import_statement(stat)
  self:visit_block(stat:lower())
end
function Transpiler.__index:visit_export_statement(stat)
  local assignment, identifier = stat:lower()
  if (not self.footer_exports) then
    self.footer_exports = {}
  end
  table.insert(self.footer_exports, identifier)
  self:visit_node(assignment)
end
function Transpiler.__index:visit_footer_exports(stat)
  if self.footer_exports then
    self:iwriteln("return {")
    self:indent()
    for i = 1, (#self.footer_exports) do
      self:iwrite()
      self:visit_identifier(self.footer_exports[i])
      self:writeln(",")
    end
    self:dedent()
    self:iwriteln("}")
  end
end
function Transpiler.__index:visit_prefix_expression(expr)
  self:write("(")
  self:visit_node(expr.expr)
  self:write(")")
end
function Transpiler.__index:visit_lambda_expression(expr)
  self:visit_function_expression(expr:lower())
end
function Transpiler.__index:visit_member_expression(member)
  self:visit_node(member.base)
  self:write(member.has_colon and ":" or ".")
  self:write(member.member_identifier.name)
end
function Transpiler.__index:visit_index_expression(expr)
  self:visit_node(expr.base)
  self:write("[")
  self:visit_node(expr.index)
  self:write("]")
end
function Transpiler.__index:visit_argument_expression(arg)
  self:visit_node(arg.value)
end
function Transpiler.__index:visit_function_expression(expr)
  self:write("function(")
  self:visit_params(expr.parameters)
  self:writeln(")")
  self:indent()
  self:visit_block(expr.block)
  self:dedent()
  self:iwrite("end")
end
function Transpiler.__index:visit_nil_literal_expression(expr)
  self:write("nil")
end
function Transpiler.__index:visit_function_call_expression(expr)
  self:visit_node(expr.base)
  self:write("(")
  self:visit_args(expr.arguments)
  self:write(")")
end
function Transpiler.__index:visit_unary_op_expression(expr)
  self:write("(")
  self:write(self.unary_op_map[expr.operator])
  self:visit_node(expr.right_operand)
  self:write(")")
end
function Transpiler.__index:visit_binary_op_expression(expr)
  self:visit_node(expr.left_operand)
  self:write(" ")
  self:write(self.binary_op_map[expr.operator])
  self:write(" ")
  self:visit_node(expr.right_operand)
end
function Transpiler.__index:visit_table_literal_expression(expr)
  self:write("{")
  self:visit_fields(expr.fields)
  if (#expr.fields) > 0 then
    self:writeln()
    self:iwrite("}")
  else
    self:write("}")
  end
end
function Transpiler.__index:visit_number_literal_expression(expr)
  self:write(tostring(expr.value))
end
function Transpiler.__index:visit_string_literal_expression(expr)
  self:write(expr.value)
end
function Transpiler.__index:visit_boolean_literal_expression(expr)
  self:write(tostring(expr.value))
end
function Transpiler.__index:visit_variable_argument_expression(expr)
  self:write("...")
end
function Transpiler.__index:visit_type_assertion_expression(expr)
  self:visit_node(expr.base)
end
function Transpiler.__index:visit_field_declaration(field)
  if field.syntax_kind == SyntaxKind.sequential_field_declaration then
    self:visit_sequential_field_declaration(field)
  elseif field.syntax_kind == SyntaxKind.member_field_declaration then
    self:visit_member_field_declaration(field)
  else
    self:visit_index_field_declaration(field)
  end
end
function Transpiler.__index:visit_sequential_field_declaration(field)
  self:visit_node(field.value)
end
function Transpiler.__index:visit_member_field_declaration(field)
  self:write(field.member_identifier.name)
  self:write(" = ")
  self:visit_node(field.value)
end
function Transpiler.__index:visit_index_field_declaration(field)
  self:write("[")
  self:visit_node(field.key)
  self:write("] = ")
  self:visit_node(field.value)
end
function Transpiler.__index:visit_parameter_declaration(param)
  self:visit_identifier(param.identifier)
end
return Transpiler
