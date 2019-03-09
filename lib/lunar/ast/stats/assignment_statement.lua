local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BinaryOpKind = require("lunar.ast.exprs.binary_op_kind")
local BinaryOpExpression = require("lunar.ast.exprs.binary_op_expression")
local NilLiteralExpression = require("lunar.ast.exprs.nil_literal_expression")
local SelfAssignmentOpKind = require("lunar.ast.stats.self_assignment_op_kind")
local AssignmentStatement = setmetatable({}, SyntaxNode)
AssignmentStatement.__index = AssignmentStatement
function AssignmentStatement.new(variables, operator, exprs)
  local super = SyntaxNode.new(SyntaxKind.assignment_statement)
  local self = setmetatable(super, AssignmentStatement)
  self.variables = variables
  self.operator = operator
  self.exprs = exprs
  self.binary_op_map = {
    [SelfAssignmentOpKind.concatenation_equal_op] = BinaryOpKind.concatenation_op,
    [SelfAssignmentOpKind.addition_equal_op] = BinaryOpKind.addition_op,
    [SelfAssignmentOpKind.subtraction_equal_op] = BinaryOpKind.subtraction_op,
    [SelfAssignmentOpKind.multiplication_equal_op] = BinaryOpKind.multiplication_op,
    [SelfAssignmentOpKind.division_equal_op] = BinaryOpKind.division_op,
    [SelfAssignmentOpKind.power_equal_op] = BinaryOpKind.power_op,
  }
  return self
end
function AssignmentStatement:lower()
  if self.operator == SelfAssignmentOpKind.equal_op then
    return self
  end
  local variables = {}
  local exprs = {}
  for index, expr in pairs(self.exprs) do
    local variable = self.variables[index]
    if variable ~= nil then
      table.insert(variables, variable)
      local op = self.binary_op_map[self.operator]
      table.insert(exprs, BinaryOpExpression.new(variable, op, expr))
    else
      table.insert(exprs, expr)
    end
  end
  if (#self.variables) > (#variables) then
    for index = (#variables), (#self.variables) do
      local variable = self.variables[index]
      table.insert(variables, variable)
      local op = self.binary_op_map[self.operator]
      table.insert(exprs, BinaryOpExpression.new(variable, op, NilLiteralExpression.new()))
    end
  end
  return AssignmentStatement.new(variables, SelfAssignmentOpKind.equal_op, exprs)
end
return AssignmentStatement
