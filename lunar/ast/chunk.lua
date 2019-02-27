local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local Chunk = setmetatable({}, SyntaxNode)
Chunk.__index = Chunk

function Chunk.new(block)
  local super = SyntaxNode.new(SyntaxKind.chunk)
  local self = setmetatable(super, Chunk)
  self.block = block

  return self
end

return Chunk