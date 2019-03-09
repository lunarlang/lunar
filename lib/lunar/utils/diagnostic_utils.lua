local SyntaxKind = require "lunar.ast.syntax_kind"
local BinaryOpKind = require "lunar.ast.exprs.binary_op_kind"
local UnaryOpKind = require "lunar.ast.exprs.unary_op_kind"
local TokenType = require "lunar.compiler.lexical.token_type"

local DiagnosticUtils = {}

function DiagnosticUtils.index_of(tab, val)
  for k, v in pairs(tab) do
    if val == v then
      return k
    end
  end
end

local INSPECT_FIRST = {
  "syntax_kind",
  "token_type",
  "operator",
  "has_colon",
}

function DiagnosticUtils.inspect_ast(tab, max_depth, _indentation)
  _indentation = _indentation or 0
  max_depth = max_depth or 10
  local tabs = string.rep("  ", _indentation)

  local function inspect_kv(k, v)
    local key_str = tostring(k)
    local value_str
    local comments
    if type(k) == "number" then
      key_str = '[' .. key_str .. ']'
    elseif type(k) == "string" then
      if k == "syntax_kind" and type(v) == "number" then
        value_str = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(SyntaxKind, v)) .. ""
      elseif k == "operator" and type(v) == "number" and tab.syntax_kind == SyntaxKind.binary_op_expression then
        value_str = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(BinaryOpKind, v)) .. ""
      elseif k == "operator" and type(v) == "number" and tab.syntax_kind == SyntaxKind.unary_op_expression then
        value_str = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(UnaryOpKind, v)) .. ""
      elseif k == "token_type" and type(v) == "number" then
        value_str = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(TokenType, v)) .. ""
      end
    end

    if not value_str then
      if type(v) == "string" then
        value_str = "'" .. tostring(v) .. "'"
      else
        value_str = tostring(v)
      end
    end

    if comments then
      comments = " --" .. comments
    end

    if type(v) == "table" then
      print(tabs .. tostring(key_str) .. " = {")
      DiagnosticUtils.inspect_ast(v, max_depth, _indentation + 1)
      print(tabs .. "}," .. (comments or ""))
    else
      print(tabs .. tostring(key_str) .. " = " .. value_str .. "," .. (comments or ""))
    end
  end

  -- Inspect certain keys first if they exist
  local was_inspected = {}
  for _, k in pairs(INSPECT_FIRST) do
    if tab[k] ~= nil then
      inspect_kv(k, tab[k])
      was_inspected[k] = true
    end
  end
  for k, v in pairs(tab) do
    if not was_inspected[k] then
      inspect_kv(k, v)
    end
  end
end

return DiagnosticUtils
