local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local FieldDeclaration = setmetatable({}, SyntaxNode)
FieldDeclaration.__index = FieldDeclaration

function FieldDeclaration.new(key, value)
  local super = SyntaxNode.new(SyntaxKind.field_declaration)
  local self = setmetatable(super, FieldDeclaration)
  self.key = key
  self.value = value

  return self
end

function FieldDeclaration.try_parse(parser)
  return FieldDeclaration.try_parse_key_value_field(parser)
      or FieldDeclaration.try_parse_list_value_field(parser)
end

function FieldDeclaration.try_parse_key_value_field(parser)
  if parser:match(TokenType.left_bracket) then
    local key = parser:parse_expression()
    parser:expect(TokenType.right_bracket, "Expected ']' to close '['")
    parser:expect(TokenType.equal, "Expected '=' near ']'")
    local value = parser:parse_expression()

    return FieldDeclaration.new(key, value)
  elseif parser:peek(1) and parser:peek(1).token_type == TokenType.equal then
    local key = parser:expect(TokenType.identifier, "Expected identifier to start this field")
    parser:consume() -- consumes the equal token, because we asserted it earlier
    local value = parser:parse_expression()

    return FieldDeclaration.new(key, value)
  end
end

function FieldDeclaration.try_parse_list_value_field(parser)
  local value = parser:parse_expression()

  if value ~= nil then
    return FieldDeclaration.new(nil, value)
  end
end

return FieldDeclaration
