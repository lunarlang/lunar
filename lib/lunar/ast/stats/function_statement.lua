local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionStatement = setmetatable({}, SyntaxNode)
FunctionStatement.__index = FunctionStatement
function FunctionStatement.new(base, parameters, block, return_type_annotation, is_local)
  if is_local == nil then
    is_local = false
  end
  local super = SyntaxNode.new(SyntaxKind.function_statement)
  local self = setmetatable(super, FunctionStatement)
  self.base = base
  self.parameters = parameters
  self.block = block
  self.is_local = is_local
  self.return_type_annotation = return_type_annotation
  return self
end
return FunctionStatement
