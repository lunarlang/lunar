local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local DoStatement = setmetatable({}, SyntaxNode)
DoStatement.__index = DoStatement

function DoStatement.new(block)
  local super = SyntaxNode.new(SyntaxKind.do_statement)
  local self = setmetatable(super, DoStatement)
  self.block = block

  return self
end

return DoStatement
