local SyntaxNode = {}
SyntaxNode.__index = {}
function SyntaxNode.new(syntax_kind)
  return SyntaxNode.constructor(setmetatable({}, SyntaxNode), syntax_kind)
end
function SyntaxNode.constructor(self, syntax_kind)
  self.syntax_kind = syntax_kind
  return self
end
function SyntaxNode.__index:lower()
  return nil
end
return SyntaxNode
