local BaseLexer = require("lunar.compiler.lexical.base_lexer")
local StringUtils = require("lunar.utils.string_utils")
local TokenInfo = require("lunar.compiler.lexical.token_info")
local TokenType = require("lunar.compiler.lexical.token_type")
local function pair(type, value)
  return {
    type = type,
    value = value,
  }
end
local Lexer = setmetatable({}, { __index = BaseLexer })
Lexer.__index = setmetatable({}, BaseLexer)
local super = BaseLexer.constructor
function Lexer.new(source)
  return Lexer.constructor(setmetatable({}, Lexer), source)
end
function Lexer.constructor(self, source)
  super(self, source)
  self.trivias = {
    pair(TokenType.end_of_line_trivia, "\r\n"),
    pair(TokenType.end_of_line_trivia, "\n"),
    pair(TokenType.end_of_line_trivia, "\r"),
    pair(TokenType.whitespace_trivia, " "),
    pair(TokenType.whitespace_trivia, "\t"),
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
    ["while"] = TokenType.while_keyword,
    ["as"] = TokenType.as_keyword,
    ["declare"] = TokenType.declare_keyword,
    ["import"] = TokenType.import_keyword,
    ["export"] = TokenType.export_keyword,
  }
  self.operators = {
    pair(TokenType.triple_dot, "..."),
    pair(TokenType.double_dot_equal, "..="),
    pair(TokenType.double_equal, "=="),
    pair(TokenType.tilde_equal, "~="),
    pair(TokenType.left_angle_equal, "<="),
    pair(TokenType.right_angle_equal, ">="),
    pair(TokenType.double_dot, ".."),
    pair(TokenType.plus_equal, "+="),
    pair(TokenType.minus_equal, "-="),
    pair(TokenType.asterisk_equal, "*="),
    pair(TokenType.slash_equal, "/="),
    pair(TokenType.caret_equal, "^="),
    pair(TokenType.percent_equal, "%="),
    pair(TokenType.double_left_angle, "<<"),
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
function Lexer.__index:tokenize()
  local tokens = {}
  local ok, token
  repeat
    ok, token = self:next_token()
    if ok then
      self:move((#token.value))
      table.insert(tokens, token)
    end
  until (not ok)
  if (not self:is_finished()) then
    self:error(("lexical analysis failed '%s'"):format(self:peek()))
  end
  return tokens
end
function Lexer.__index:next_token()
  local token = self:next_trivia() or self:next_comment() or self:next_string() or self:next_number() or self:next_keyword() or self:next_of(self.operators) or self:next_identifier()
  return token ~= nil, token
end
function Lexer.__index:next_of(list)
  for _, pair in pairs(list) do
    if self:match(pair.value) then
      return TokenInfo.new(pair.type, pair.value, self.line, self:get_column())
    end
  end
end
function Lexer.__index:next_trivia()
  for _, pair in pairs(self.trivias) do
    if self:match(pair.value) then
      if pair.type == TokenType.end_of_line_trivia then
        local lineToken = TokenInfo.new(pair.type, pair.value, self.line, self:get_column())
        self.line = self.line + 1
        self.line_begins = self.position + (#pair.value) - 1
        return lineToken
      end
      return TokenInfo.new(pair.type, pair.value, self.line, self:get_column())
    end
  end
end
function Lexer.__index:next_comment()
  local old_pos = self.position
  if self:move_if_match("--") then
    local buffer = "--"
    local block = self:next_multiline_block()
    if block then
      self.position = old_pos
      return TokenInfo.new(TokenType.comment, buffer .. block.value, self.line, self:get_column())
    end
    while (not self:is_finished()) do
      local trivia_token = self:next_of(self.trivias)
      if trivia_token and trivia_token.token_type == TokenType.end_of_line_trivia then
        break
      end
      buffer = buffer .. self:consume()
    end
    self.position = old_pos
    return TokenInfo.new(TokenType.comment, buffer, self.line, self:get_column())
  end
end
function Lexer.__index:next_string()
  local block = self:next_multiline_block()
  if block then
    return TokenInfo.new(TokenType.string, block.value, self.line, self:get_column())
  elseif self:match("\"") or self:match("\'") then
    local old_pos = self.position
    local delimit = self:consume()
    local buffer = ""
    local escaping
    if self:match(delimit) then
      self.position = old_pos
      return TokenInfo.new(TokenType.string, delimit .. delimit, self.line, self:get_column())
    end
    repeat
      local trivia_token = self:next_of(self.trivias)
      if self:is_finished() then
        self:error("unfinished string near <eof>")
      elseif trivia_token and trivia_token.token_type == TokenType.end_of_line_trivia then
        self:error(("unfinished string near '%s'"):format(delimit .. buffer))
      end
      escaping = (not escaping) and self:peek() == "\\" or false
      buffer = buffer .. self:consume()
    until (not escaping) and self:match(delimit)
    self.position = old_pos
    return TokenInfo.new(TokenType.string, delimit .. buffer .. delimit, self.line, self:get_column())
  end
end
function Lexer.__index:next_number()
  local c = self:peek()
  if StringUtils.is_digit(c) or (c == "." and StringUtils.is_digit(self:peek(1))) then
    local old_pos = self.position
    local buffer = ""
    repeat
      buffer = buffer .. self:consume()
    until (not (StringUtils.is_digit(self:peek()) or self:match(".")))
    if self:match("e") or self:match("E") then
      buffer = buffer .. self:consume()
      if self:match("+") or self:match("-") then
        buffer = buffer .. self:consume()
      end
    end
    while (not self:is_finished()) and (StringUtils.is_digit(self:peek()) or StringUtils.is_letter(self:peek()) or self:match("_")) do
      buffer = buffer .. self:consume()
    end
    if tonumber(buffer) then
      self.position = old_pos
      return TokenInfo.new(TokenType.number, buffer, self.line, self:get_column())
    else
      self:error(("malformed number near '%s'"):format(buffer))
    end
  end
end
function Lexer.__index:next_keyword()
  local id = self:next_identifier()
  if id and self.keywords[id.value] then
    return TokenInfo.new(self.keywords[id.value], id.value, self.line, self:get_column())
  end
end
function Lexer.__index:next_identifier()
  local c = self:peek()
  if StringUtils.is_letter(c) or c == "_" then
    local old_pos = self.position
    local buffer = ""
    local lookahead
    repeat
      buffer = buffer .. self:consume()
      lookahead = self:peek()
    until (not (StringUtils.is_letter(lookahead) or lookahead == "_" or StringUtils.is_digit(lookahead)))
    self.position = old_pos
    return TokenInfo.new(TokenType.identifier, buffer, self.line, self:get_column())
  end
end
function Lexer.__index:next_multiline_block()
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
        self:error("unfinished string near <eof>")
      end
      buffer = buffer .. self:consume()
    until self:match("]" .. ("="):rep(level) .. "]")
    self.position = old_pos
    buffer = buffer .. "]" .. ("="):rep(level) .. "]"
    return TokenInfo.new(TokenType.block, buffer, self.line, self:get_column())
  end
end
return Lexer
