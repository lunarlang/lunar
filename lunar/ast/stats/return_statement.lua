local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local ReturnStatement = setmetatable({}, SyntaxNode)
ReturnStatement.__index = ReturnStatement

function ReturnStatement.new(explist)
  local super = SyntaxNode.new(SyntaxKind.return_statement)
  local self = setmetatable(super, ReturnStatement)
  self.explist = explist

  return self
end

function ReturnStatement.try_parse(parser)
  if parser:match(TokenType.return_keyword) then
    local explist = parser:parse_expression_list()

    -- prefer nil if explist returned empty
    if #explist.expressions == 0 then
      return ReturnStatement.new(nil)
    end

    return ReturnStatement.new(explist)
  end
end

return ReturnStatement
