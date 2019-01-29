local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local DoStatement = setmetatable({}, SyntaxNode)
DoStatement.__index = DoStatement

function DoStatement.new(...)
  local block = { ... }

  local super = SyntaxNode.new(SyntaxKind.do_statement)
  local self = setmetatable(super, DoStatement)
  self.block = block

  return self
end

function DoStatement.try_parse(parser)
  if parser:match(TokenType.do_keyword) then
    local block = parser:parse_block()
    parser:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")

    if #block == 0 then
      return DoStatement.new(nil)
    end

    return DoStatement.new(unpack(block))
  end
end

return DoStatement
