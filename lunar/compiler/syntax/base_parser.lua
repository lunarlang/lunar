local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

local function should_skip_token(token)
  return token.token_type == TokenType.whitespace_trivia
      or token.token_type == TokenType.end_of_line_trivia
      or token.token_type == TokenType.comment
end

local BaseParser = {}
BaseParser.__index = BaseParser

function BaseParser.new(tokens)
  local self = setmetatable({}, BaseParser)
  self.position = 1

  local filtered_tokens = {}

  for index, token in pairs(tokens) do
    if not should_skip_token(token) then
      table.insert(filtered_tokens, token)
    end
  end

  self.tokens = filtered_tokens

  return self
end

function BaseParser:is_finished()
  return self.position > #self.tokens
end

function BaseParser:move(by)
  if by == nil then by = 1 end

  if not self:is_finished() then
    self.position = self.position + by
  end
end

-- Peeks at the current token where the parser is currently at
function BaseParser:peek(offset)
  if offset == nil then offset = 0 end

  return self.tokens[self.position + offset]
end

-- Asserts whether the current token equals to one of the given TokenTypes
function BaseParser:assert(...)
  local token_types = { ... }

  if not self:is_finished() then
    for _, token_type in pairs(token_types) do
      if self:peek().token_type == token_type then
        return true
      end
    end
  end

  return false
end

-- Expects the current token to be the same as the given token_type, otherwise throws reason
function BaseParser:expect(token_type, reason)
  if not self:is_finished() then
    if self:assert(token_type) then
      local token = self:peek()
      self:move(1)
      return token
    end

    error(reason)
  end
end

-- Consumes the current token irrespective of the token_type (not to be used without asserting the type beforehand!)
function BaseParser:consume()
  local token = self:peek()
  self:move(1)
  return token
end

-- If current token is one of these expected TokenType, moves the position by one
function BaseParser:match(...)
  if not self:is_finished() then
    if self:assert(...) then
      self:move(1)
      return true
    end
  end

  return false
end

return BaseParser
