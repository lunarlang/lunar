local BaseLexer = require "lunar.compiler.lexical.base_lexer"
local StringUtils = require "lunar.utils.string_utils"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

local Lexer = setmetatable({}, BaseLexer)
Lexer.__index = Lexer

function Lexer.new(source, file_name)
  if file_name == nil then file_name = "src" end

  local function pair(type, value)
    return { type = type, value = value }
  end

  local super = BaseLexer.new(source, file_name)
  local self = setmetatable(super, Lexer)

  -- we need to guarantee the order (pitfalls of lua hashmaps, yay...)
  -- so we don't end up falsly match \r in \r\n
  -- thanks a lot, old macOS, DOS, and linux: not helping the case of https://xkcd.com/927/
  self.trivias = {
    pair(TokenType.end_of_line_trivia, "\r\n"), -- CRLF
    pair(TokenType.end_of_line_trivia, "\n"), -- LF
    pair(TokenType.end_of_line_trivia, "\r"), -- CR
    -- now that we have support for spaces AND tabs, we're feeding into the classic spaces vs tabs flame wars.
    pair(TokenType.whitespace_trivia, " "),
    pair(TokenType.whitespace_trivia, "\t")
  }

  self.keywords = {
    pair(TokenType.and_keyword, "and"),
    pair(TokenType.break_keyword, "break"),
    pair(TokenType.do_keyword, "do"),
    -- elseif before else and if, otherwise same issue with \r and \r\n
    pair(TokenType.elseif_keyword, "elseif"),
    pair(TokenType.else_keyword, "else"),
    pair(TokenType.end_keyword, "end"),
    pair(TokenType.false_keyword, "false"),
    pair(TokenType.for_keyword, "for"),
    pair(TokenType.function_keyword, "function"),
    pair(TokenType.if_keyword, "if"),
    pair(TokenType.in_keyword, "in"),
    pair(TokenType.local_keyword, "local"),
    pair(TokenType.nil_keyword, "nil"),
    pair(TokenType.not_keyword, "not"),
    pair(TokenType.or_keyword, "or"),
    pair(TokenType.repeat_keyword, "repeat"),
    pair(TokenType.return_keyword, "return"),
    pair(TokenType.then_keyword, "then"),
    pair(TokenType.true_keyword, "true"),
    pair(TokenType.until_keyword, "until"),
    pair(TokenType.while_keyword, "while")
  }

  self.operators = {
    pair(TokenType.triple_dot, "..."),

    pair(TokenType.double_equal, "=="),
    pair(TokenType.tilde_equal, "~="),
    pair(TokenType.left_angle_equal, "<="),
    pair(TokenType.right_angle_equal, ">="),
    pair(TokenType.double_dot, ".."),

    pair(TokenType.left_paren, "("),
    pair(TokenType.right_paren, ")"),
    pair(TokenType.left_brace, "{"),
    pair(TokenType.right_brace, "}"),
    pair(TokenType.left_bracket, "["),
    pair(TokenType.right_bracket, "]"),
    pair(TokenType.plus, "+"),
    pair(TokenType.minus, "-"),
    pair(TokenType.asterisk, "*"),
    pair(TokenType.slash, "/"),
    pair(TokenType.percent, "%"),
    pair(TokenType.caret, "^"),
    pair(TokenType.pound, "#"),
    pair(TokenType.left_angle, "<"),
    pair(TokenType.right_angle, ">"),
    pair(TokenType.equal, "="),
    pair(TokenType.semi_colon, ";"),
    pair(TokenType.colon, ":"),
    pair(TokenType.comma, ","),
    pair(TokenType.dot, ".")
  }

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
  local token = self:next_of(self.trivias)
    or self:next_string()
    or self:next_of(self.keywords)
    or self:next_of(self.operators)
    or self:next_identifier()

  return token ~= nil, token
end

function Lexer:next_of(list)
  for _, pair in pairs(list) do
    if self:match(pair.value) then
      return TokenInfo.new(pair.type, pair.value, self.position)
    end
  end
end

function Lexer:next_string()
  local block = self:next_multiline_block()

  if block then
    return TokenInfo.new(TokenType.string, block.value, self.position)
  elseif self:match("\"") or self:match("\'") then
    local old_pos = self.position
    local delimit = self:consume()
    local buffer = ""
    local escaping

    repeat
      local trivia_token = self:next_of(self.trivias)

      if self:peek() == nil then
        error("unfinished string near <eof>")
      elseif trivia_token and trivia_token.token_type == TokenType.end_of_line_trivia then
        error(("unfinished string near '%s'"):format(delimit .. buffer))
      end

      escaping = self:peek() == "\\"
      buffer = buffer .. self:consume()
    until not escaping and self:match(delimit)

    self.position = old_pos
    return TokenInfo.new(TokenType.string, delimit .. buffer .. delimit, self.position)
  end
end

function Lexer:next_identifier()
  local c = self:peek()

  if StringUtils.is_letter(c) or c == "_" then
    local start_pos = self.position -- to reset to when we finish scanning series of valid characters
    local buffer = ""
    local lookahead

    repeat
      buffer = buffer .. self:consume()
      lookahead = self:peek()
    until not (StringUtils.is_letter(lookahead) or lookahead == "_" or StringUtils.is_digit(lookahead))

    self.position = start_pos
    return TokenInfo.new(TokenType.identifier, buffer, self.position)
  end
end

function Lexer:next_multiline_block()
  if self:peek() == "[" then
    local old_pos = self.position
    local level = self:count("=", 1)

    if self:peek(level + 1) ~= "[" then
      return nil
    end

    self:move(level + 2)
    local buffer = "[" .. ("="):rep(level) .. "["

    repeat
      if self:peek() == nil then
        error("unfinished string near <eof>")
      end

      buffer = buffer .. self:consume()
    until self:match("]" .. ("="):rep(level) .. "]")

    self.position = old_pos
    buffer = buffer .. "]" .. ("="):rep(level) .. "]"
    return TokenInfo.new(TokenType.block, buffer, self.position)
  end
end

return Lexer
