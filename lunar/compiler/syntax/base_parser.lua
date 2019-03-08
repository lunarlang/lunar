local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

local BaseParser = {}
BaseParser.__index = BaseParser

function BaseParser.new(tokens)
  local self = setmetatable({}, BaseParser)
  self.position = 1
  self.tokens = tokens

  return self
end

function BaseParser:count_trivias(offset)
  if offset == nil then offset = 0 end

  local n = 0

  for i = self.position + offset, #self.tokens do
    local token = self.tokens[i]

    if token.token_type == TokenType.whitespace_trivia
      or token.token_type == TokenType.end_of_line_trivia
      or token.token_type == TokenType.comment then
      n = n + 1
    else
      return n
    end
  end

  return 0
end

function BaseParser:is_finished()
  return self.position > #self.tokens
end

function BaseParser:move(by)
  if by == nil then by = 1 end

  if not self:is_finished() then
    self.position = self.position + self:count_trivias(by) + by
  end
end

-- Peeks at the current token where the parser is currently at
function BaseParser:peek(offset)
  if offset == nil then offset = 0 end

  return self.tokens[self.position + self:count_trivias(offset) + offset]
end

-- Asserts whether the current token equals to one of the given TokenTypes
function BaseParser:assert(...)
  if self:is_finished() then
    return false
  end

  local token_types = { ... }

  for _, token_type in pairs(token_types) do
    if self:peek().token_type == token_type then
      return true
    end
  end
end

function BaseParser:assert_seq(...)
  if self:is_finished() then
    return false
  end

  -- we need to keep track number of non-trivial tokens to skip ahead
  -- because when we skip trivial tokens, we don't end up carrying over non-trivial tokens
  local non_trivial_count = 0
  for offset, expected in pairs({ ... }) do
    local current_token = self:peek(offset - 1 + non_trivial_count)

    local same = (type(expected) == "string" and current_token.value == expected)
              or (type(expected) == "number" and current_token.token_type == expected)

    if not same then
      return false
    end

    non_trivial_count = non_trivial_count + 1
  end

  return true
end

-- Expects the current token to be the same as the given token_type, otherwise throws reason
function BaseParser:expect(token_type, reason)
  if self:is_finished() then
    return false
  end

  local token = self:peek()

  if self:assert(token_type) then
    self:move(1)
    return token
  end

  error(("%d:%d %s; got %s"):format(token.line, token.column, reason, token.value), 0)
end

-- Consumes the current token irrespective of the token_type (not to be used without asserting the type beforehand!)
function BaseParser:consume()
  local token = self:peek()
  self:move(1)
  return token
end

-- If current token is one of these expected TokenType, moves the position by one
function BaseParser:match(...)
  if self:is_finished() then
    return false
  end

  if self:assert(...) then
    self:move(1)
    return true
  end
end

return BaseParser
