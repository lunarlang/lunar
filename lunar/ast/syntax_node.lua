local SyntaxNode = {}
SyntaxNode.__index = SyntaxNode

function SyntaxNode.new(syntax_kind)
  local self = setmetatable({}, SyntaxNode)
  self.syntax_kind = syntax_kind

  return self
end

return SyntaxNode
