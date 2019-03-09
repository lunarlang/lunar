local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DeclarePackageStatement = setmetatable({}, SyntaxNode)
DeclarePackageStatement.__index = DeclarePackageStatement
function DeclarePackageStatement.new(path, type_expr)
  local super = SyntaxNode.new(SyntaxKind.declare_package_statement)
  local self = setmetatable(super, DeclarePackageStatement)
  self.path = path
  self.type_expr = type_expr
  return self
end
return DeclarePackageStatement
