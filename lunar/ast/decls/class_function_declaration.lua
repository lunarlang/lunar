local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local MemberExpression = require "lunar.ast.exprs.member_expression"
local FunctionStatement = require "lunar.ast.stats.function_statement"

local ClassFunctionDeclaration = setmetatable({}, SyntaxNode)
ClassFunctionDeclaration.__index = ClassFunctionDeclaration

function ClassFunctionDeclaration.new(is_static, identifier, params, block)
  local super = SyntaxNode.new(SyntaxKind.class_function_declaration)
  local self = setmetatable(super, ClassFunctionDeclaration)
  self.is_static = is_static
  self.identifier = identifier
  self.params = params
  self.block = block

  return self
end

function ClassFunctionDeclaration:lower(class_member_expr)
  local new_class_member_expr = MemberExpression.new(class_member_expr, self.identifier, not self.is_static)
  return FunctionStatement.new(new_class_member_expr, self.params, self.block, nil)
end

return ClassFunctionDeclaration
