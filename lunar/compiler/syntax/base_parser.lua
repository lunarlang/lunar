local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

local BaseParser = {}
BaseParser.__index = BaseParser

function BaseParser.new(tokens)
  local self = setmetatable({}, BaseParser)
  self.tokens = tokens
  self.position = 1

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

function BaseParser:previous()
  return self:peek(-1)
end

function BaseParser:next()
  return self:peek(1)
end

function BaseParser:skip_tokens()
  repeat
    local token = self:peek()
    local trivial_token = token.token_type == TokenType.whitespace_trivia
      or token.token_type == TokenType.end_of_line_trivia
      or token.token_type == TokenType.comment

    -- we're done skipping trivial tokens, so break
    if not trivial_token then
      break
    end

    self:move(1)
  until self:is_finished()
end

-- Asserts whether the current token equals to one of the given TokenTypes
function BaseParser:assert(...)
  local token_types = { ... }

  if not self:is_finished() then
    for _, token_type in pairs(token_types) do
      self:skip_tokens()

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
    self:skip_tokens()

    if self:assert(token_type) then
      local token = self:peek()
      self:move(1)
      return token
    end

    error(reason)
  end
end

-- If current token is one of these expected TokenType, moves the position by one
function BaseParser:match_any(...)
  if not self:is_finished() then
    self:skip_tokens()

    if self:assert(...) then
      self:move(1)
      return true
    end
  end

  return false
end

return BaseParser
