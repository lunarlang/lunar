local SyntaxNode = {}
SyntaxNode.__index = SyntaxNode

function SyntaxNode.new(syntax_kind, ...)
  local children = { ... }

  local self = setmetatable({}, SyntaxNode)
  self.syntax_kind = syntax_kind
  -- enforces terminals by convention based on the given SyntaxKind
  self.children = syntax_kind >= 500 and children or nil

  return self
end

return SyntaxNode
