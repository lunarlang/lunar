local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local MemberExpression = require "lunar.ast.exprs.member_expression"
local TableLiteralExpression = require "lunar.ast.exprs.table_literal_expression"
local FunctionCallExpression = require "lunar.ast.exprs.function_call_expression"
local FunctionStatement = require "lunar.ast.stats.function_statement"
local VariableStatement = require "lunar.ast.stats.variable_statement"
local ReturnStatement = require "lunar.ast.stats.return_statement"

local ConstructorDeclaration = setmetatable({}, SyntaxNode)
ConstructorDeclaration.__index = ConstructorDeclaration

function ConstructorDeclaration.new(params, block)
  local super = SyntaxNode.new(SyntaxKind.constructor_declaration)
  local self = setmetatable(super, ConstructorDeclaration)
  self.params = params
  self.block = block

  return self
end

function ConstructorDeclaration:lower(class, class_base_name)
  -- looking for the statement that calls "super" if we have a base class
  -- and replace with a rewritten local super variable
  if class_base_name ~= nil then
    for index, stat in pairs(self.block) do
      if stat.syntax_kind == SyntaxKind.expression_statement
        and stat.expr.syntax_kind == SyntaxKind.function_call_expression
        and stat.expr.member_expressions.name == "super"
      then
        local super = stat.expr

        -- rewrite super_stat to a variable named super that calls new on the super class
        local super_member_expr = MemberExpression.new(MemberExpression.new(class_base_name), "new")
        local super_call_expr = FunctionCallExpression.new(super_member_expr, super.arguments)
        local super_variable = VariableStatement.new({ "super" }, { super_call_expr })
        self.block[index] = super_variable

        break
      end
    end
  end

  local constructor_block = self.block
  local new_self_instance = FunctionCallExpression.new(
    MemberExpression.new("setmetatable"), { TableLiteralExpression.new({}), class }
  )
  table.insert(self.block, 1, VariableStatement.new({ "self" }, { new_self_instance }))
  table.insert(self.block, ReturnStatement.new({ MemberExpression.new("self") }))

  return FunctionStatement.new(MemberExpression.new(class, "new"), self.params, self.block)
end

return ConstructorDeclaration
