local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local IfStatement = setmetatable({}, { __index = SyntaxNode })
IfStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function IfStatement.new(expr, block)
  return IfStatement.constructor(setmetatable({}, IfStatement), expr, block)
end
function IfStatement.constructor(self, expr, block)
  super(self, SyntaxKind.if_statement)
  self.expr = expr
  self.block = block
  self.elseif_branches = {}
  self.else_branch = nil
  return self
end
function IfStatement.__index:push_elseif(if_statement)
  table.insert(self.elseif_branches, if_statement)
  return self
end
function IfStatement.__index:set_else(if_statement)
  self.else_branch = if_statement
  return self
end
return IfStatement
