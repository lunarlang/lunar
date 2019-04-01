local SyntaxNode = {}
SyntaxNode.__index = {}
function SyntaxNode.new(syntax_kind, start_pos, end_pos)
  return SyntaxNode.constructor(setmetatable({}, SyntaxNode), syntax_kind, start_pos, end_pos)
end
function SyntaxNode.constructor(self, syntax_kind, start_pos, end_pos)
  self.syntax_kind = syntax_kind
  self.start_pos = start_pos
  self.end_pos = end_pos
  return self
end
function SyntaxNode.__index:lower()
  return nil
end
return SyntaxNode
