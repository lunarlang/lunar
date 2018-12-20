local BaseLexer = require "lunar.compiler.lexical.base_lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

local Lexer = {}
Lexer.__index = Lexer

function Lexer.new(source, file_name)
  if file_name == nil then file_name = "src" end

  local super = BaseLexer.new(source, file_name)
  local self = setmetatable(super, Lexer)

  return self
end

function Lexer:tokenize()
  local tokens = {}
  local ok, token

  repeat
    ok, token = self:next_token()

    if ok then
      self:move(#token.value)
      table.insert(tokens, token)
    end
  until not ok

  -- if position has not reached the end of source, then we failed to tokenize something
  if self.position < #self.source then
    error(("lexical analysis failed at %d %s"):format(self.position, self:peek()))
  end

  return tokens
end

function Lexer:next_token()
  local token = self:next_trivia()

  return token ~= nil, token
end

function Lexer:next_trivia()
  -- we need to guarantee the order (pitfalls of lua hashmaps, yay...)
  -- so we don't end up falsly match \r in \r\n
  -- thanks a lot, old macOS, DOS, and linux: not helping the case of https://xkcd.com/927/
  local trivias = {
    { value = "\r\n", type = TokenType.end_of_line_trivia }, -- CRLF
    { value = "\n", type = TokenType.end_of_line_trivia }, -- LF
    { value = "\r", type = TokenType.end_of_line_trivia }, -- CR
    -- now that we have support for spaces AND tabs, we're feeding into the classic spaces vs tabs flame wars.
    { value = " ", type = TokenType.whitespace_trivia },
    { value = "\t", type = TokenType.whitespace_trivia }
  }

  for _, trivia in pairs(trivias) do
    if self:match(trivia.value) then
      return TokenInfo.new(trivia.type, trivia.value, self.position)
    end
  end
end

return Lexer
