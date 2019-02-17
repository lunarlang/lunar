local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local AssignmentStatement = setmetatable({}, SyntaxNode)
AssignmentStatement.__index = AssignmentStatement

function AssignmentStatement.new(members, exprs)
  local super = SyntaxNode.new(SyntaxKind.assignment_statement)
  local self = setmetatable(super, AssignmentStatement)
  self.members = members
  self.exprs = exprs

  return self
end

return AssignmentStatement
