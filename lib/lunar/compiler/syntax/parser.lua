local AST = require("lunar.ast")
local BaseParser = require("lunar.compiler.syntax.base_parser")
local TokenType = require("lunar.compiler.lexical.token_type")
local SyntaxKind = require("lunar.ast.syntax_kind")
local unary_priority = 8
local priority = {
  {
    6,
    6,
  },
  {
    6,
    6,
  },
  {
    7,
    7,
  },
  {
    7,
    7,
  },
  {
    7,
    7,
  },
  {
    10,
    9,
  },
  {
    5,
    4,
  },
  {
    3,
    3,
  },
  {
    3,
    3,
  },
  {
    3,
    3,
  },
  {
    3,
    3,
  },
  {
    3,
    3,
  },
  {
    3,
    3,
  },
  {
    2,
    2,
  },
  {
    1,
    1,
  },
}
local Parser = setmetatable({}, {
  __index = BaseParser,
})
Parser.__index = setmetatable({}, BaseParser)
function Parser.new(tokens)
  return Parser.constructor(setmetatable({}, Parser), tokens)
end
function Parser.constructor(self, tokens)
  BaseParser.constructor(self, tokens)
  self.binary_op_map = {
    ["+"] = AST.BinaryOpKind.addition_op,
    ["-"] = AST.BinaryOpKind.subtraction_op,
    ["*"] = AST.BinaryOpKind.multiplication_op,
    ["/"] = AST.BinaryOpKind.division_op,
    ["%"] = AST.BinaryOpKind.modulus_op,
    ["^"] = AST.BinaryOpKind.power_op,
    [".."] = AST.BinaryOpKind.concatenation_op,
    ["~="] = AST.BinaryOpKind.not_equal_op,
    ["=="] = AST.BinaryOpKind.equal_op,
    ["<"] = AST.BinaryOpKind.less_than_op,
    ["<="] = AST.BinaryOpKind.less_or_equal_op,
    [">"] = AST.BinaryOpKind.greater_than_op,
    [">="] = AST.BinaryOpKind.greater_or_equal_op,
    ["and"] = AST.BinaryOpKind.and_op,
    ["or"] = AST.BinaryOpKind.or_op,
  }
  self.unary_op_map = {
    ["-"] = AST.UnaryOpKind.negative_op,
    ["not"] = AST.UnaryOpKind.not_op,
    ["#"] = AST.UnaryOpKind.length_op,
  }
  self.self_assignment_op_map = {
    ["="] = AST.SelfAssignmentOpKind.equal_op,
    ["..="] = AST.SelfAssignmentOpKind.concatenation_equal_op,
    ["+="] = AST.SelfAssignmentOpKind.addition_equal_op,
    ["-="] = AST.SelfAssignmentOpKind.subtraction_equal_op,
    ["*="] = AST.SelfAssignmentOpKind.multiplication_equal_op,
    ["/="] = AST.SelfAssignmentOpKind.division_equal_op,
    ["^="] = AST.SelfAssignmentOpKind.power_equal_op,
    ["%="] = AST.SelfAssignmentOpKind.remainder_equal_op,
  }
  return self
end
function Parser.__index:parse()
  self.position = self.position + self:count_trivias()
  local block = self:block()
  if (not self:is_finished()) then
    local weird_token = self:peek()
    error(("%d:%d: unexpected token '%s'"):format(weird_token.line, weird_token.column, weird_token.value))
  end
  return block
end
function Parser.__index:block()
  local stats = {}
  while (not self:is_finished()) do
    local stat = self:match_statement()
    if stat ~= nil then
      table.insert(stats, stat)
      self:match(TokenType.semi_colon)
    end
    local last = self:match_last_statement()
    if last ~= nil then
      table.insert(stats, last)
      self:match(TokenType.semi_colon)
      break
    end
    if (stat or last) == nil then
      break
    end
  end
  return stats
end
function Parser.__index:match_class_member()
  local start_pos = self:next_nontrivial_pos()
  if self:assert_seq("constructor") then
    self:move(1)
    self:expect(TokenType.left_paren, "Expected '(' after 'constructor'")
    local params = self:parameter_list()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'constructor'")
    local end_pos = self:last_nontrivial_pos()
    return AST.ConstructorDeclaration.new(start_pos, end_pos, params, block)
  end
  local old_position = self.position
  local is_static = self:assert_seq("static")
  if is_static then
    self:move(1)
  end
  if self:match(TokenType.function_keyword) then
    local name = self:expect(TokenType.identifier, "Expected identifier after 'function'").value
    local name_ident = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name)
    if name == "constructor" then
      error("Unexpected 'constructor' keyword near 'function'")
    end
    self:expect(TokenType.left_paren, "Expected '(' after " .. name)
    local params = self:parameter_list()
    self:expect(TokenType.right_paren, "Expected ')' to close '(' after 'function " .. name .. "'")
    local return_type_annotation = nil
    if self:match(TokenType.colon) then
      return_type_annotation = self:type_expression()
    end
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'function " .. name .. "'")
    local end_pos = self:last_nontrivial_pos()
    return AST.ClassFunctionDeclaration.new(start_pos, end_pos, is_static, name_ident, params, block, return_type_annotation)
  elseif self:assert(TokenType.identifier) then
    local name_value = self:consume().value
    local name = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name_value)
    local type_annotation = nil
    if self:match(TokenType.colon) then
      type_annotation = self:type_expression()
    end
    local value = nil
    if self:match(TokenType.equal) then
      value = self:expression()
    end
    local end_pos = self:last_nontrivial_pos()
    return AST.ClassFieldDeclaration.new(start_pos, end_pos, is_static, name, type_annotation, value)
  end
  self.position = old_position
end
function Parser.__index:match_statement()
  return self:class_statement() or self:import_statement() or self:export_statement() or self:do_statement() or self:while_statement() or self:repeat_until_statement() or self:if_statement() or self:for_statement() or self:function_statement() or self:variable_statement() or self:declare_statement() or self:expression_statement()
end
function Parser.__index:class_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:assert_seq("class", TokenType.identifier) then
    self:move(1)
    local name = self:expect(TokenType.identifier, "Expected identifier after 'class'").value
    local name_ident = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name)
    local super_identifier
    if self:match(TokenType.double_left_angle) then
      local super_name = self:expect(TokenType.identifier, "Expected an identifier after '<<'").value
      super_identifier = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), super_name)
    end
    local members = {}
    repeat
      local member = self:match_class_member()
      self:match(TokenType.semi_colon)
      if member ~= nil then
        table.insert(members, member)
      end
    until member == nil
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'class'")
    local end_pos = self:last_nontrivial_pos()
    return AST.ClassStatement.new(start_pos, end_pos, name_ident, super_identifier, members)
  end
end
function Parser.__index:import_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:assert_seq("from", TokenType.string, TokenType.import_keyword) then
    self:move(1)
    local path = self:parse_string_contents(self:consume())
    self:move(1)
    local values = {}
    repeat
      local is_type = self:assert_seq("type")
      if is_type then
        self:move(1)
      end
      local value, value_ident, value_decl_start_pos
      if self:assert(TokenType.identifier, TokenType.asterisk) then
        value = self:consume().value
        value_decl_start_pos = self:last_nontrivial_pos()
        value_ident = AST.Identifier.new(value_decl_start_pos, value_decl_start_pos, value)
        if value == '*' and is_type then
          error("Unexpected symbol '*' after 'type'")
        end
      else
        error(TokenType.identifier, "expected identifier after '" .. ((#values) == 0 and 'import' or ',') .. "'")
      end
      if value then
        local alias
        if self:match(TokenType.as_keyword) then
          local alias_name = self:expect(TokenType.identifier, "expected identifier after 'as'").value
          alias = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), alias_name)
        elseif value == '*' then
          error("expected 'as' after '*'")
        end
        local value_decl_end_pos = self:last_nontrivial_pos()
        table.insert(values, AST.ImportValueDeclaration.new(value_decl_start_pos, value_decl_end_pos, value_ident, is_type, alias))
      end
    until (not self:match(TokenType.comma))
    local end_pos = self:last_nontrivial_pos()
    return AST.ImportStatement.new(start_pos, end_pos, path, values)
  end
  if self:match(TokenType.import_keyword) then
    local path = self:parse_string_contents(self:expect(TokenType.string, "expected string after 'import'"))
    local end_pos = self:last_nontrivial_pos()
    return AST.ImportStatement.new(start_pos, end_pos, path, {}, true)
  end
end
function Parser.__index:export_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.export_keyword) then
    if self:match(TokenType.function_keyword) then
      local func_start_pos = self:last_nontrivial_pos()
      local first_name = self:expect(TokenType.identifier, "Expected identifier after 'function'").value
      local base = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), first_name)
      self:expect(TokenType.left_paren, "Expected '(' to start 'function'")
      local paramlist = self:parameter_list()
      self:expect(TokenType.right_paren, "Expected ')' to close '('")
      local return_type_annotation = nil
      if self:match(TokenType.colon) then
        return_type_annotation = self:type_expression()
      end
      local block = self:block()
      self:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")
      local func_end_pos = self:last_nontrivial_pos()
      local func_stat = AST.FunctionStatement.new(func_start_pos, func_end_pos, base, paramlist, block, return_type_annotation, true)
      return AST.ExportStatement.new(start_pos, end_pos, func_stat)
    end
    local stat = self:class_statement()
    if stat then
      return AST.ExportStatement.new(start_pos, self:last_nontrivial_pos(), stat)
    end
    if self:assert(TokenType.identifier) then
      local variable_start_pos = self:next_nontrivial_pos()
      local name = self:consume().value
      local type_annotation
      if self:match(TokenType.colon) then
        type_annotation = self:type_expression()
      end
      self:expect(TokenType.equal, "Declaration or statement expected")
      local expr = self:expression()
      local end_pos = self:last_nontrivial_pos()
      local ident = AST.Identifier.new(variable_start_pos, variable_start_pos, name, type_annotation)
      local var_stat = AST.VariableStatement.new(variable_start_pos, end_pos, {
        ident,
      }, {
        expr,
      })
      return AST.ExportStatement.new(start_pos, end_pos, var_stat)
    end
    error("Expected function, class, or variable statement to follow 'export'")
  end
end
function Parser.__index:expression_statement()
  local start_pos = self:next_nontrivial_pos()
  local primaryexpr = self:match_primary_expression()
  if primaryexpr ~= nil then
    if primaryexpr.syntax_kind == SyntaxKind.function_call_expression then
      local end_pos = self:last_nontrivial_pos()
      local test = AST.ExpressionStatement.new(start_pos, end_pos, primaryexpr)
      return test
    elseif primaryexpr.syntax_kind == SyntaxKind.member_expression or primaryexpr.syntax_kind == SyntaxKind.index_expression or primaryexpr.syntax_kind == SyntaxKind.identifier then
      local variables = {
        primaryexpr,
      }
      while self:match(TokenType.comma) do
        local expr = self:match_primary_expression()
        if expr and (expr.syntax_kind == SyntaxKind.member_expression or primaryexpr.syntax_kind == SyntaxKind.index_expression or primaryexpr.syntax_kind == SyntaxKind.identifier) then
          table.insert(variables, expr)
        else
          return nil
        end
      end
      local self_assignable_ops = {
        TokenType.equal,
        TokenType.double_dot_equal,
        TokenType.plus_equal,
        TokenType.minus_equal,
        TokenType.asterisk_equal,
        TokenType.slash_equal,
        TokenType.caret_equal,
        TokenType.percent_equal,
      }
      local op
      if (not self:assert(unpack(self_assignable_ops))) then
        self:expect(TokenType.equal, "Expected '=' to follow this variable")
      else
        op = self:consume(unpack(self_assignable_ops))
      end
      local exprs = self:expression_list()
      local end_pos = self:last_nontrivial_pos()
      return AST.AssignmentStatement.new(start_pos, end_pos, variables, self.self_assignment_op_map[op.value], exprs)
    else
      return nil
    end
  end
end
function Parser.__index:do_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.do_keyword) then
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")
    local end_pos = self:last_nontrivial_pos()
    return AST.DoStatement.new(start_pos, end_pos, block)
  end
end
function Parser.__index:while_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.while_keyword) then
    local expr = self:expression()
    self:expect(TokenType.do_keyword, "Expected 'do' to close 'while'")
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")
    local end_pos = self:last_nontrivial_pos()
    return AST.WhileStatement.new(start_pos, end_pos, expr, block)
  end
end
function Parser.__index:repeat_until_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.repeat_keyword) then
    local block = self:block()
    self:expect(TokenType.until_keyword, "Expected 'until' to close 'repeat'")
    local expr = self:expression()
    local end_pos = self:last_nontrivial_pos()
    return AST.RepeatUntilStatement.new(start_pos, end_pos, block, expr)
  end
end
function Parser.__index:if_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.if_keyword) then
    local expr = self:expression()
    self:expect(TokenType.then_keyword, "Expected 'then' to close 'if'")
    local block = self:block()
    local if_statement = AST.IfStatement.new(start_pos, start_pos, expr, block)
    while self:match(TokenType.elseif_keyword) do
      local elseif_start_pos = self:last_nontrivial_pos()
      local elseif_expr = self:expression()
      self:expect(TokenType.then_keyword, "Expected 'then' to close 'elseif'")
      local elseif_block = self:block()
      local elseif_end_pos = self:last_nontrivial_pos()
      if_statement:push_elseif(AST.IfStatement.new(elseif_start_pos, elseif_end_pos, elseif_expr, elseif_block))
    end
    if self:match(TokenType.else_keyword) then
      local else_start_pos = self:last_nontrivial_pos()
      local else_block = self:block()
      local else_end_pos = self:last_nontrivial_pos()
      if_statement:set_else(AST.IfStatement.new(else_start_pos, else_end_pos, nil, else_block))
    end
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'if'")
    local end_pos = self:last_nontrivial_pos()
    if_statement.end_pos = end_pos
    return if_statement
  end
end
function Parser.__index:for_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.for_keyword) and self:assert(TokenType.identifier) then
    local first_name = self:consume().value
    local first_ident_pos = self:last_nontrivial_pos()
    local type_annotation = nil
    if self:match(TokenType.colon) then
      type_annotation = self:type_expression()
    end
    local first_identifier = AST.Identifier.new(first_ident_pos, first_ident_pos, first_name, type_annotation)
    if self:match(TokenType.equal) then
      local start_expr = self:expression()
      self:expect(TokenType.comma, "Expected ',' after first expression")
      local end_expr = self:expression()
      local incremental_expr
      if self:match(TokenType.comma) then
        incremental_expr = self:expression()
      end
      self:expect(TokenType.do_keyword, "Expected 'do' to close 'for'")
      local block = self:block()
      self:expect(TokenType.end_keyword, "Expected 'end' to close 'for'")
      local end_pos = self:last_nontrivial_pos()
      return AST.RangeForStatement.new(start_pos, end_pos, first_identifier, start_expr, end_expr, incremental_expr, block)
    end
    if self:assert(TokenType.comma, TokenType.in_keyword) then
      local identifiers = {
        first_identifier,
      }
      while self:match(TokenType.comma) do
        local value_name = self:expect(TokenType.identifier, "Expected identifier after ','").value
        local value_ident_pos = self:last_nontrivial_pos()
        local type_annotation = nil
        if self:match(TokenType.colon) then
          type_annotation = self:type_expression()
        end
        table.insert(identifiers, AST.Identifier.new(value_ident_pos, value_ident_pos, value_name, type_annotation))
      end
      self:expect(TokenType.in_keyword, "Expected 'in' after identifier list")
      local exprlist = self:expression_list()
      self:expect(TokenType.do_keyword, "Expected 'do' to close 'for'")
      local block = self:block()
      self:expect(TokenType.end_keyword, "Expected 'end' to close 'for'")
      local end_pos = self:last_nontrivial_pos()
      return AST.GenericForStatement.new(start_pos, end_pos, identifiers, exprlist, block)
    end
  end
end
function Parser.__index:function_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.function_keyword) then
    local first_name = self:expect(TokenType.identifier, "Expected identifier after 'function'").value
    local member_start_pos = self:last_nontrivial_pos()
    local first_identifier = AST.Identifier.new(member_start_pos, member_start_pos, first_name)
    local base = first_identifier
    while self:match(TokenType.dot) do
      local name = self:expect(TokenType.identifier, "Expected identifier after '.'").value
      local identifier = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name)
      base = AST.MemberExpression.new(member_start_pos, self:last_nontrivial_pos(), base, identifier)
    end
    if self:match(TokenType.colon) then
      local name = self:expect(TokenType.identifier, "Expected identifier after ':'").value
      local identifier = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name)
      base = AST.MemberExpression.new(member_start_pos, self:last_nontrivial_pos(), base, identifier, true)
    end
    self:expect(TokenType.left_paren, "Expected '(' to start 'function'")
    local paramlist = self:parameter_list()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    local return_type_annotation = nil
    if self:match(TokenType.colon) then
      return_type_annotation = self:type_expression()
    end
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")
    local end_pos = self:last_nontrivial_pos()
    return AST.FunctionStatement.new(start_pos, end_pos, base, paramlist, block, return_type_annotation)
  end
end
function Parser.__index:variable_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.local_keyword) then
    if self:match(TokenType.function_keyword) then
      local name = self:expect(TokenType.identifier, "Expected identifier after 'function'").value
      local name_ident = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name)
      self:expect(TokenType.left_paren, "Expected '(' to start 'function'")
      local paramlist = self:parameter_list()
      self:expect(TokenType.right_paren, "Expected ')' to close '('")
      local return_type_annotation = nil
      if self:match(TokenType.colon) then
        return_type_annotation = self:type_expression()
      end
      local block = self:block()
      self:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")
      local end_pos = self:last_nontrivial_pos()
      return AST.FunctionStatement.new(start_pos, end_pos, name_ident, paramlist, block, return_type_annotation, true)
    end
    if self:assert(TokenType.identifier) then
      local identlist = {}
      local exprlist
      local i = 0
      repeat
        i = i + 1
        local name = self:expect(TokenType.identifier, "Expected identifier after ','").value
        local ident_pos = self:last_nontrivial_pos()
        local type_annotation = nil
        if self:match(TokenType.colon) then
          type_annotation = self:type_expression()
        end
        table.insert(identlist, AST.Identifier.new(ident_pos, ident_pos, name, type_annotation))
      until (not self:match(TokenType.comma))
      if self:match(TokenType.equal) then
        exprlist = self:expression_list()
      end
      local end_pos = self:last_nontrivial_pos()
      return AST.VariableStatement.new(start_pos, end_pos, identlist, exprlist)
    end
  end
end
function Parser.__index:declare_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.declare_keyword) then
    local context = self:expect(TokenType.identifier, "Expected declaration context after 'declare'").value
    if context == "global" then
      local identifier
      if self:assert(TokenType.identifier) then
        local name = self:consume().value
        local name_pos = self:last_nontrivial_pos()
        local type_annotation
        if self:match(TokenType.colon) then
          type_annotation = self:type_expression()
        end
        identifier = AST.Identifier.new(name_pos, name_pos, name, type_annotation)
      else
        error("Expected identifier after 'declare " .. context .. "'")
      end
      local end_pos = self:last_nontrivial_pos()
      return AST.DeclareGlobalStatement.new(start_pos, end_pos, identifier, false)
    elseif context == "package" then
      local path = self:parse_string_contents(self:expect(TokenType.string, "Expected string after 'declare package'"))
      local type = self:type_expression()
      local end_pos = self:last_nontrivial_pos()
      return AST.DeclarePackageStatement.new(start_pos, end_pos, path, type)
    elseif context == "returns" then
      local type = self:type_expression()
      local end_pos = self:last_nontrivial_pos()
      return AST.DeclareReturnsStatement.new(start_pos, end_pos, type)
    else
      error("Expected 'global' 'package' or 'returns' after 'declare' keyword")
    end
  end
end
function Parser.__index:parse_string_contents(string_token)
  if string_token.value:sub(1, 1) == "'" or string_token.value:sub(1, 1) == '"' then
    return string_token.value:sub(2, (-2))
  else
    local length = (#string_token.value:match("%[=*%["))
    return string_token.value:sub(length + 1, (-length) - 1)
  end
end
function Parser.__index:match_last_statement()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.break_keyword) then
    local end_pos = self:last_nontrivial_pos()
    return AST.BreakStatement.new(start_pos, end_pos)
  end
  if self:match(TokenType.return_keyword) then
    local exprlist = self:expression_list()
    if (#exprlist) == 0 then
      local end_pos = self:last_nontrivial_pos()
      return AST.ReturnStatement.new(start_pos, end_pos, nil)
    end
    local end_pos = self:last_nontrivial_pos()
    return AST.ReturnStatement.new(start_pos, end_pos, exprlist)
  end
end
function Parser.__index:match_function_arg()
  local start_pos = self:next_nontrivial_pos()
  local expr = self:match_expression()
  if expr then
    local end_pos = self:last_nontrivial_pos()
    return AST.ArgumentExpression.new(start_pos, end_pos, expr)
  end
  return expr
end
function Parser.__index:function_arg_list()
  if self:match(TokenType.left_paren) then
    local args = {}
    repeat
      local arg = self:match_function_arg()
      if arg ~= nil then
        table.insert(args, arg)
      end
    until (not self:match(TokenType.comma))
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    return args
  end
  if self:assert(TokenType.string, TokenType.left_brace) then
    return {
      self:match_function_arg(),
    }
  end
end
function Parser.__index:match_prefix_expression()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.left_paren) then
    local inner_expr = self:expression()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    local end_pos = self:last_nontrivial_pos()
    return AST.PrefixExpression.new(start_pos, end_pos, inner_expr)
  end
  if self:assert(TokenType.identifier) then
    local name = self:consume().value
    local ident_pos = self:last_nontrivial_pos()
    return AST.Identifier.new(ident_pos, ident_pos, name)
  end
end
function Parser.__index:match_expression()
  return self:match_sub_expression(0)
end
function Parser.__index:expression()
  return self:sub_expression(0)
end
function Parser.__index:match_primary_expression()
  local start_pos = self:next_nontrivial_pos()
  local expr = self:match_prefix_expression()
  if (not expr) then
    return nil
  end
  while true do
    if self:match(TokenType.dot) then
      local name = self:expect(TokenType.identifier, "Expected identifier after '.'").value
      local ident = AST.Identifier.new(self:last_nontrivial_pos(), self:last_nontrivial_pos(), name)
      local end_pos = self:last_nontrivial_pos()
      expr = AST.MemberExpression.new(start_pos, end_pos, expr, ident)
    elseif self:match(TokenType.left_bracket) then
      local inner_expr = self:expression()
      self:expect(TokenType.right_bracket, "Expected ']' to close '['")
      local end_pos = self:last_nontrivial_pos()
      expr = AST.IndexExpression.new(start_pos, end_pos, expr, inner_expr)
    elseif self:match(TokenType.colon) then
      local name = self:expect(TokenType.identifier, "Expected identifier after ':'").value
      local member_end_pos = self:last_nontrivial_pos()
      local ident = AST.Identifier.new(member_end_pos, member_end_pos, name)
      local args = self:function_arg_list()
      local end_pos = self:last_nontrivial_pos()
      expr = AST.FunctionCallExpression.new(start_pos, end_pos, AST.MemberExpression.new(start_pos, member_end_pos, expr, ident, true), args)
    elseif self:assert(TokenType.left_paren, TokenType.string, TokenType.left_brace) then
      local args = self:function_arg_list()
      local end_pos = self:last_nontrivial_pos()
      expr = AST.FunctionCallExpression.new(start_pos, end_pos, expr, args)
    else
      return expr
    end
  end
end
function Parser.__index:match_simple_expression()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.nil_keyword) then
    local end_pos = self:last_nontrivial_pos()
    return AST.NilLiteralExpression.new(start_pos, end_pos)
  end
  if self:assert(TokenType.true_keyword, TokenType.false_keyword) then
    local boolean_token = self:consume()
    local end_pos = self:last_nontrivial_pos()
    return AST.BooleanLiteralExpression.new(start_pos, end_pos, boolean_token.token_type == TokenType.true_keyword)
  end
  if self:assert(TokenType.number) then
    local number_token = self:consume()
    local end_pos = self:last_nontrivial_pos()
    return AST.NumberLiteralExpression.new(start_pos, end_pos, tonumber(number_token.value))
  end
  if self:assert(TokenType.string) then
    local string_token = self:consume()
    local end_pos = self:last_nontrivial_pos()
    return AST.StringLiteralExpression.new(start_pos, end_pos, string_token.value)
  end
  if self:match(TokenType.left_brace) then
    local fieldlist = self:field_list()
    self:expect(TokenType.right_brace, "Expected '}' to close '{'")
    local end_pos = self:last_nontrivial_pos()
    return AST.TableLiteralExpression.new(start_pos, end_pos, fieldlist)
  end
  if self:match(TokenType.triple_dot) then
    local end_pos = self:last_nontrivial_pos()
    return AST.VariableArgumentExpression.new(start_pos, end_pos)
  end
  if self:match(TokenType.function_keyword) then
    self:expect(TokenType.left_paren, "Expected '(' to start 'function'")
    local paramlist = self:parameter_list()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    local return_type_annotation = nil
    if self:match(TokenType.colon) then
      return_type_annotation = self:type_expression()
    end
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")
    local end_pos = self:last_nontrivial_pos()
    return AST.FunctionExpression.new(start_pos, end_pos, paramlist, block, return_type_annotation)
  end
  if self:match(TokenType.bar) then
    local params = self:parameter_list()
    self:expect(TokenType.bar, "Expected '|' to close '|'")
    local return_type_annotation = nil
    if self:match(TokenType.colon) then
      return_type_annotation = self:type_expression()
    end
    if self:match(TokenType.do_keyword) then
      local block = self:block()
      self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")
      local end_pos = self:last_nontrivial_pos()
      return AST.LambdaExpression.new(start_pos, end_pos, params, block, false, return_type_annotation)
    else
      local expr = self:expression()
      local end_pos = self:last_nontrivial_pos()
      return AST.LambdaExpression.new(start_pos, end_pos, params, expr, true, return_type_annotation)
    end
  elseif self:match(TokenType.do_keyword) then
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")
    local end_pos = self:last_nontrivial_pos()
    return AST.LambdaExpression.new(start_pos, end_pos, {}, block, false, nil)
  end
  return self:match_primary_expression()
end
function Parser.__index:type_expression()
  local start_pos = self:next_nontrivial_pos()
  if self:assert(TokenType.nil_keyword) or self:assert(TokenType.function_keyword) or self:assert(TokenType.true_keyword) or self:assert(TokenType.false_keyword) then
    local name = self:consume().value
    local end_pos = self:last_nontrivial_pos()
    return AST.Identifier.new(start_pos, end_pos, name)
  end
  if self:assert(TokenType.identifier) then
    local name = self:consume().value
    local end_pos = self:last_nontrivial_pos()
    return AST.Identifier.new(start_pos, end_pos, name)
  else
    error("Expected identifier in type expression")
  end
end
function Parser.__index:get_unary_op()
  local ops = {
    TokenType.minus,
    TokenType.not_keyword,
    TokenType.pound,
  }
  if self:assert(unpack(ops)) then
    local op = self:peek()
    return self.unary_op_map[op.value]
  end
end
function Parser.__index:get_binary_op()
  local ops = {
    TokenType.plus,
    TokenType.minus,
    TokenType.asterisk,
    TokenType.slash,
    TokenType.percent,
    TokenType.caret,
    TokenType.double_dot,
    TokenType.tilde_equal,
    TokenType.double_equal,
    TokenType.left_angle,
    TokenType.left_angle_equal,
    TokenType.right_angle,
    TokenType.right_angle_equal,
    TokenType.and_keyword,
    TokenType.or_keyword,
  }
  if self:assert(unpack(ops)) then
    local op = self:peek()
    return self.binary_op_map[op.value]
  end
end
function Parser.__index:sub_expression(limit)
  local expr = self:match_sub_expression(limit)
  if expr == nil then
    self:error_near_next_token("unexpected symbol")
  end
  return expr
end
function Parser.__index:match_sub_expression(limit)
  local start_pos = self:next_nontrivial_pos()
  local expr
  local unary_op = self:get_unary_op()
  if unary_op ~= nil then
    self:consume()
    local inner_expr = self:sub_expression(unary_priority)
    local end_pos = self:last_nontrivial_pos()
    expr = AST.UnaryOpExpression.new(start_pos, end_pos, unary_op, inner_expr)
  else
    expr = self:match_simple_expression()
  end
  local binary_op = self:get_binary_op()
  while binary_op ~= nil and priority[binary_op][1] > limit do
    self:consume()
    if expr == nil then
      self:error_near_next_token("unexpected symbol")
    end
    local next_expr = self:sub_expression(priority[binary_op][2])
    local end_pos = self:last_nontrivial_pos()
    expr = AST.BinaryOpExpression.new(start_pos, end_pos, expr, binary_op, next_expr)
    binary_op = self:get_binary_op()
  end
  while self:match(TokenType.as_keyword) do
    if expr == nil then
      error("unexpected symbol near 'as'")
    end
    local type_expr = self:type_expression()
    local end_pos = self:last_nontrivial_pos()
    expr = AST.TypeAssertionExpression.new(start_pos, end_pos, expr, type_expr)
  end
  return expr
end
function Parser.__index:expression_list()
  local exprlist = {}
  repeat
    local expr = self:match_expression()
    if expr ~= nil then
      table.insert(exprlist, expr)
    end
  until (not self:match(TokenType.comma))
  return exprlist
end
function Parser.__index:match_parameter_declaration()
  local start_pos = self:next_nontrivial_pos()
  if self:assert(TokenType.identifier, TokenType.triple_dot) then
    local param = self:consume().value
    local param_pos = self:last_nontrivial_pos()
    local type_annotation = nil
    if self:match(TokenType.colon) then
      type_annotation = self:type_expression()
    end
    local end_pos = self:last_nontrivial_pos()
    local param_ident = AST.Identifier.new(start_pos, param_pos, param, type_annotation)
    return AST.ParameterDeclaration.new(start_pos, end_pos, param_ident)
  end
end
function Parser.__index:parameter_list()
  local paramlist = {}
  local param
  repeat
    param = self:match_parameter_declaration()
    if param ~= nil then
      table.insert(paramlist, param)
    end
  until (not self:match(TokenType.comma)) or param.identifier.name == "..."
  return paramlist
end
function Parser.__index:match_field_declaration()
  local start_pos = self:next_nontrivial_pos()
  if self:match(TokenType.left_bracket) then
    local key = self:expression()
    self:expect(TokenType.right_bracket, "Expected ']' to close '['")
    self:expect(TokenType.equal, "Expected '=' near ']'")
    local value = self:expression()
    local end_pos = self:last_nontrivial_pos()
    return AST.IndexFieldDeclaration.new(start_pos, end_pos, key, value)
  end
  if self:assert_seq(TokenType.identifier, TokenType.equal) then
    local key = self:expect(TokenType.identifier, "Expected identifier to start this field").value
    local key_pos = self:last_nontrivial_pos()
    local type_annotation = nil
    if self:match(TokenType.colon) then
      type_annotation = self:type_expression()
    end
    local key_ident = AST.Identifier.new(key_pos, key_pos, key, type_annotation)
    self:consume()
    local value = self:expression()
    local end_pos = self:last_nontrivial_pos()
    return AST.MemberFieldDeclaration.new(start_pos, end_pos, key_ident, value)
  end
  local value = self:match_expression()
  if value ~= nil then
    local end_pos = self:last_nontrivial_pos()
    return AST.SequentialFieldDeclaration.new(start_pos, end_pos, value)
  end
end
function Parser.__index:field_list()
  local fieldlist = {}
  local lastfield
  repeat
    lastfield = self:match_field_declaration()
    if lastfield ~= nil then
      table.insert(fieldlist, lastfield)
      self:match(TokenType.comma, TokenType.semi_colon)
    end
  until lastfield == nil
  return fieldlist
end
return Parser
