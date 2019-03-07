local SyntaxNode = {}
SyntaxNode.__index = SyntaxNode

function SyntaxNode.new(syntax_kind)
  local self = setmetatable({}, SyntaxNode)
  self.syntax_kind = syntax_kind

  return self
end

function SyntaxNode:lower()
  -- returns whether this node can be lowered, if true returns the lowered node(s)
  return nil
end

return SyntaxNode
