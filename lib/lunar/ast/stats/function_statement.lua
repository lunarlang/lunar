local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionStatement = setmetatable({}, {
  __index = SyntaxNode,
})
FunctionStatement.__index = setmetatable({}, SyntaxNode)
function FunctionStatement.new(start_pos, end_pos, base, parameters, block, return_type_annotation, is_local)
  return FunctionStatement.constructor(setmetatable({}, FunctionStatement), start_pos, end_pos, base, parameters, block, return_type_annotation, is_local)
end
function FunctionStatement.constructor(self, start_pos, end_pos, base, parameters, block, return_type_annotation, is_local)
  SyntaxNode.constructor(self, SyntaxKind.function_statement, start_pos, end_pos)
  if is_local == nil then
    is_local = false
  end
  self.base = base
  self.parameters = parameters
  self.block = block
  self.is_local = is_local
  self.return_type_annotation = return_type_annotation
  return self
end
return FunctionStatement
