local require_dev = require "spec.helpers.require_dev"
-- setup handler is called too late, so we need to require this early
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer:next_keyword", function()
  require_dev()

  local function keyword_equals(keyword, token_type)
    return function()
      local tokens = Lexer.new(keyword):tokenize()

      assert.same({
        TokenInfo.new(token_type, keyword, 1)
      }, tokens)
    end
  end

  it("should return one and_keyword token", keyword_equals("and", TokenType.and_keyword))
  it("should return one break_keyword token", keyword_equals("break", TokenType.break_keyword))
  it("should return one do_keyword token", keyword_equals("do", TokenType.do_keyword))
  it("should return one else_keyword token", keyword_equals("else", TokenType.else_keyword))
  it("should return one elseif_keyword token", keyword_equals("elseif", TokenType.elseif_keyword))
  it("should return one end_keyword token", keyword_equals("end", TokenType.end_keyword))
  it("should return one false_keyword token", keyword_equals("false", TokenType.false_keyword))
  it("should return one for_keyword token", keyword_equals("for", TokenType.for_keyword))
  it("should return one function_keyword token", keyword_equals("function", TokenType.function_keyword))
  it("should return one if_keyword token", keyword_equals("if", TokenType.if_keyword))
  it("should return one in_keyword token", keyword_equals("in", TokenType.in_keyword))
  it("should return one local_keyword token", keyword_equals("local", TokenType.local_keyword))
  it("should return one nil_keyword token", keyword_equals("nil", TokenType.nil_keyword))
  it("should return one not_keyword token", keyword_equals("not", TokenType.not_keyword))
  it("should return one or_keyword token", keyword_equals("or", TokenType.or_keyword))
  it("should return one repeat_keyword token", keyword_equals("repeat", TokenType.repeat_keyword))
  it("should return one return_keyword token", keyword_equals("return", TokenType.return_keyword))
  it("should return one then_keyword token", keyword_equals("then", TokenType.then_keyword))
  it("should return one true_keyword token", keyword_equals("true", TokenType.true_keyword))
  it("should return one until_keyword token", keyword_equals("until", TokenType.until_keyword))
  it("should return one while_keyword token", keyword_equals("while", TokenType.while_keyword))
end)
