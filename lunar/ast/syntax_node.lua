local SyntaxNode = {}
SyntaxNode.__index = SyntaxNode

function SyntaxNode.new(syntax_kind)
  local self = setmetatable({}, SyntaxNode)
  self.syntax_kind = syntax_kind

  -- Binding-initialized fields (should be of optional type)
  self.symbol = nil -- Symbol | nil

  return self
end

function SyntaxNode:lower()
  -- returns whether this node can be lowered, if true returns the lowered node(s)
  return nil
end

return SyntaxNode
