return function()
  local spec_env = getfenv(2)

  spec_env.setup(function()
    spec_env.AST = require "lunar.ast"
    spec_env.Lexer = require "lunar.compiler.lexical.lexer"
    spec_env.TokenInfo = require "lunar.compiler.lexical.token_info"
    spec_env.TokenType = require "lunar.compiler.lexical.token_type"
    spec_env.Symbol = require "lunar.compiler.semantic.symbol"
    spec_env.SymbolTable = require "lunar.compiler.semantic.symbol_table"
    spec_env.Parser = require "lunar.compiler.syntax.parser"
    spec_env.Transpiler = require "lunar.compiler.codegen.transpiler"
    spec_env.Binder = require "lunar.compiler.semantic.binder"
    spec_env.Program = require "spec.helpers.program"
  end)

  spec_env.teardown(function()
    spec_env.AST = nil
    spec_env.Lexer = nil
    spec_env.TokenInfo = nil
    spec_env.TokenType = nil
    spec_env.Symbol = nil
    spec_env.SymbolTable = nil
    spec_env.Parser = nil
    spec_env.Transpiler = nil
    spec_env.Binder = nil
    spec_env.Program = nil
  end)
end
