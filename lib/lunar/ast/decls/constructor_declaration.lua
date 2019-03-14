local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberExpression = require("lunar.ast.exprs.member_expression")
local ArgumentExpression = require("lunar.ast.exprs.argument_expression")
local TableLiteralExpression = require("lunar.ast.exprs.table_literal_expression")
local FunctionCallExpression = require("lunar.ast.exprs.function_call_expression")
local Identifier = require("lunar.ast.exprs.identifier")
local ExpressionStatement = require("lunar.ast.stats.expression_statement")
local FunctionStatement = require("lunar.ast.stats.function_statement")
local ReturnStatement = require("lunar.ast.stats.return_statement")
local ParameterDeclaration = require("lunar.ast.decls.parameter_declaration")
local ConstructorDeclaration = setmetatable({}, { __index = SyntaxNode })
ConstructorDeclaration.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function ConstructorDeclaration.new(params, block)
  return ConstructorDeclaration.constructor(setmetatable({}, ConstructorDeclaration), params, block)
end
function ConstructorDeclaration.constructor(self, params, block)
  super(self, SyntaxKind.constructor_declaration)
  self.params = params
  self.block = block
  return self
end
function ConstructorDeclaration.__index:lower(class_identifier, class_base_identifier)
  if class_base_identifier ~= nil then
    for index, stat in pairs(self.block) do
      if stat.syntax_kind == SyntaxKind.expression_statement and stat.expr.syntax_kind == SyntaxKind.function_call_expression and stat.expr.base.syntax_kind == SyntaxKind.identifier and stat.expr.base.name == "super" then
        local super = stat.expr
        local super_member_expr = MemberExpression.new(class_base_identifier, Identifier.new("constructor"))
        local super_call_expr = FunctionCallExpression.new(super_member_expr, {
          ArgumentExpression.new(Identifier.new("self")),
          unpack(super.arguments),
        })
        table.remove(self.block, index)
        table.insert(self.block, 1, ExpressionStatement.new(super_call_expr))
        break
      end
    end
  end
  local new_block = {
    ReturnStatement.new({
      FunctionCallExpression.new(MemberExpression.new(class_identifier, Identifier.new("constructor")), {
        FunctionCallExpression.new(Identifier.new("setmetatable"), {
          TableLiteralExpression.new({}),
          class_identifier,
        }),
        unpack(self.params),
      }),
    }),
  }
  table.insert(self.block, ReturnStatement.new({
    Identifier.new("self"),
  }))
  return {
    new = FunctionStatement.new(MemberExpression.new(class_identifier, Identifier.new("new")), self.params, new_block, nil),
    constructor = FunctionStatement.new(MemberExpression.new(class_identifier, Identifier.new("constructor")), {
      ParameterDeclaration.new(Identifier.new("self")),
      unpack(self.params),
    }, self.block, nil),
  }
end
return ConstructorDeclaration
