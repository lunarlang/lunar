local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local DeclarePackageStatement = setmetatable({}, {
  __index = SyntaxNode,
})
DeclarePackageStatement.__index = setmetatable({}, SyntaxNode)
function DeclarePackageStatement.new(path, type_expr)
  return DeclarePackageStatement.constructor(setmetatable({}, DeclarePackageStatement), path, type_expr)
end
function DeclarePackageStatement.constructor(self, path, type_expr)
  SyntaxNode.constructor(self, SyntaxKind.declare_package_statement)
  self.path = path
  self.type_expr = type_expr
  return self
end
return DeclarePackageStatement
