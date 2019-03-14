local VariableStatement = require("lunar.ast.stats.variable_statement")
local ExpressionStatement = require("lunar.ast.stats.expression_statement")
local FunctionCallExpression = require("lunar.ast.exprs.function_call_expression")
local StringLiteralExpression = require("lunar.ast.exprs.string_literal_expression")
local ArgumentExpression = require("lunar.ast.exprs.argument_expression")
local MemberExpression = require("lunar.ast.exprs.member_expression")
local Identifier = require("lunar.ast.exprs.identifier")
local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ImportStatement = setmetatable({}, { __index = SyntaxNode })
ImportStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function ImportStatement.new(path, values, side_effects)
  return ImportStatement.constructor(setmetatable({}, ImportStatement), path, values, side_effects)
end
function ImportStatement.constructor(self, path, values, side_effects)
  super(self, SyntaxKind.import_statement)
  self.path = path
  self.values = values
  self.side_effects = side_effects
  return self
end
function ImportStatement.__index:get_base_path_name()
  local base_index = 1
  repeat
    local s, e = self.path:sub(base_index):find("[./]")
    if e then
      base_index = base_index + e
    end
  until (not s)
  local base_name = ""
  local prefix = ""
  for word in self.path:sub(base_index):gmatch("[a-zA-Z_]+") do
    base_name = base_name .. prefix .. word
    prefix = "_"
  end
  return base_name
end
function ImportStatement.__index:lower()
  local has_value = false
  local value_map = {}
  local source_alias = "__" .. self:get_base_path_name()
  for i = 1, (#self.values) do
    local val = self.values[i]
    if (not val.is_type) then
      has_value = true
      if val.identifier.name == "*" then
        source_alias = val.alias_identifier.name
      else
        value_map[val.identifier] = val.alias_identifier or val.identifier
      end
    end
  end
  if has_value then
    local source_id = Identifier.new(source_alias)
    local stats = {
      VariableStatement.new({
        source_id,
      }, {
        FunctionCallExpression.new(Identifier.new("require"), {
          ArgumentExpression.new(StringLiteralExpression.new("'" .. self.path .. "'")),
        }),
      }),
    }
    for value_id, alias_id in pairs(value_map) do
      table.insert(stats, VariableStatement.new({
        alias_id,
      }, {
        MemberExpression.new(source_id, value_id),
      }))
    end
    return stats
  elseif self.side_effects then
    return {
      ExpressionStatement.new(FunctionCallExpression.new(Identifier.new("require"), {
        ArgumentExpression.new(StringLiteralExpression.new("'" .. self.path .. "'")),
      })),
    }
  else
    return {}
  end
end
return ImportStatement
