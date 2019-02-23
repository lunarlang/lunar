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
    ["and"] = TokenType.and_keyword,
    ["break"] = TokenType.break_keyword,
    ["do"] = TokenType.do_keyword,
    ["else"] = TokenType.else_keyword,
    ["elseif"] = TokenType.elseif_keyword,
    ["end"] = TokenType.end_keyword,
    ["false"] = TokenType.false_keyword,
    ["for"] = TokenType.for_keyword,
    ["function"] = TokenType.function_keyword,
    ["if"] = TokenType.if_keyword,
    ["in"] = TokenType.in_keyword,
    ["local"] = TokenType.local_keyword,
    ["nil"] = TokenType.nil_keyword,
    ["not"] = TokenType.not_keyword,
    ["or"] = TokenType.or_keyword,
    ["repeat"] = TokenType.repeat_keyword,
    ["return"] = TokenType.return_keyword,
    ["then"] = TokenType.then_keyword,
    ["true"] = TokenType.true_keyword,
    ["until"] = TokenType.until_keyword,
    ["while"] = TokenType.while_keyword
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
    pair(TokenType.dot, "."),
    pair(TokenType.bar, "|"),
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
  if not self:is_finished() then
    error(("lexical analysis failed at %d %s"):format(self.position, self:peek()))
  end

  return tokens
end

function Lexer:next_token()
  local token = self:next_of(self.trivias)
    or self:next_comment()
    or self:next_string()
    or self:next_number()
    or self:next_keyword()
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

function Lexer:next_comment()
  local old_pos = self.position

  if self:move_if_match("--") then
    local buffer = "--"
    local block = self:next_multiline_block()

    if block then
      self.position = old_pos
      return TokenInfo.new(TokenType.comment, buffer .. block.value, self.position)
    end

    while not self:is_finished() do
      local trivia_token = self:next_of(self.trivias)

      if trivia_token and trivia_token.token_type == TokenType.end_of_line_trivia then
        break
      end

      buffer = buffer .. self:consume()
    end

    self.position = old_pos
    return TokenInfo.new(TokenType.comment, buffer, self.position)
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

    -- immediately return in cases of empty strings
    if self:match(delimit) then
      self.position = old_pos
      return TokenInfo.new(TokenType.string, delimit .. delimit, self.position)
    end

    repeat
      local trivia_token = self:next_of(self.trivias)

      if self:is_finished() then
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

-- not quite a fan of this... but it works
-- TODO: refactor to use finite state automata at some point
function Lexer:next_number()
  local c = self:peek()

  if StringUtils.is_digit(c) or (c == "." and StringUtils.is_digit(self:peek(1))) then
    local old_pos = self.position
    local buffer = ""

    repeat
      buffer = buffer .. self:consume()
    until not (StringUtils.is_digit(self:peek()) or self:match("."))

    if self:match("e") or self:match("E") then
      buffer = buffer .. self:consume()

      if self:match("+") or self:match("-") then
        buffer = buffer .. self:consume()
      end
    end

    while not self:is_finished() and (StringUtils.is_digit(self:peek()) or StringUtils.is_letter(self:peek()) or self:match("_")) do
      buffer = buffer .. self:consume()
    end

    if tonumber(buffer) then
      self.position = old_pos
      return TokenInfo.new(TokenType.number, buffer, self.position)
    else
      error(("malformed number near '%s'"):format(buffer))
    end
  end
end

function Lexer:next_keyword()
  local id = self:next_identifier()

  if id and self.keywords[id.value] then
    return TokenInfo.new(self.keywords[id.value], id.value, self.position)
  end
end

function Lexer:next_identifier()
  local c = self:peek()

  if StringUtils.is_letter(c) or c == "_" then
    local old_pos = self.position
    local buffer = ""
    local lookahead

    repeat
      buffer = buffer .. self:consume()
      lookahead = self:peek()
    until not (StringUtils.is_letter(lookahead) or lookahead == "_" or StringUtils.is_digit(lookahead))

    self.position = old_pos
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
      if self:is_finished() then
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
