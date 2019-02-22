return function()
  local spec_env = getfenv(2)

  spec_env.setup(function()
    spec_env.AST = require "lunar.ast"
    spec_env.Lexer = require "lunar.compiler.lexical.lexer"
    spec_env.TokenInfo = require "lunar.compiler.lexical.token_info"
    spec_env.TokenType = require "lunar.compiler.lexical.token_type"
    spec_env.Parser = require "lunar.compiler.syntax.parser"
    spec_env.Transpiler = require "lunar.compiler.codegen.transpiler"
    spec_env.Environment = require "spec.helpers.environment"
  end)

  spec_env.teardown(function()
    spec_env.AST = nil
    spec_env.Lexer = nil
    spec_env.TokenInfo = nil
    spec_env.TokenType = nil
    spec_env.Parser = nil
    spec_env.Transpiler = nil
    spec_env.Environment = nil
  end)
end
