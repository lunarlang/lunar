return {
  DoStatement = require "lunar.ast.stats.do_statement",
  WhileStatement = require "lunar.ast.stats.while_statement",
  RepeatUntilStatement = require "lunar.ast.stats.repeat_until_statement",
  IfStatement = require "lunar.ast.stats.if_statement",
  RangeForStatement = require "lunar.ast.stats.range_for_statement",
  GenericForStatement = require "lunar.ast.stats.generic_for_statement",
  FunctionStatement = require "lunar.ast.stats.function_statement",
  VariableStatement = require "lunar.ast.stats.variable_statement",
  ExpressionStatement = require "lunar.ast.stats.expression_statement",
  AssignmentStatement = require "lunar.ast.stats.assignment_statement",
  BreakStatement = require "lunar.ast.stats.break_statement",
  ReturnStatement = require "lunar.ast.stats.return_statement",
  BinaryOpExpression = require "lunar.ast.exprs.binary_op_expression",
  BinaryOpKind = require "lunar.ast.exprs.binary_op_kind",
  UnaryOpExpression = require "lunar.ast.exprs.unary_op_expression",
  UnaryOpKind = require "lunar.ast.exprs.unary_op_kind",
  NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression",
  BooleanLiteralExpression = require "lunar.ast.exprs.boolean_literal_expression",
  NumberLiteralExpression = require "lunar.ast.exprs.number_literal_expression",
  StringLiteralExpression = require "lunar.ast.exprs.string_literal_expression",
  TableLiteralExpression = require "lunar.ast.exprs.table_literal_expression",
  VariableArgumentExpression = require "lunar.ast.exprs.variable_argument_expression",
  FunctionExpression = require "lunar.ast.exprs.function_expression",
  MemberExpression = require "lunar.ast.exprs.member_expression",
  FunctionCallExpression = require "lunar.ast.exprs.function_call_expression",
  ArgumentExpression = require "lunar.ast.exprs.argument_expression",
  LambdaExpression = require "lunar.ast.exprs.lambda_expression",
  FieldDeclaration = require "lunar.ast.decls.field_declaration",
  ParameterDeclaration = require "lunar.ast.decls.parameter_declaration",
}
