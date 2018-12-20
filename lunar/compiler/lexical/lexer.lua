local BaseLexer = require "lunar.compiler.lexical.base_lexer"

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

function Lexer:next_token() -- luacheck: ignore 212 will use self when we add tokenization methods
  local token = nil

  return token ~= nil, token
end

return Lexer
