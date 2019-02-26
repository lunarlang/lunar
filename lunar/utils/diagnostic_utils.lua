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

function DiagnosticUtils.inspectAST(tab, maxDepth, _indentation)
  _indentation = _indentation or 0
  maxDepth = maxDepth or 10
  local tabs = string.rep("  ", _indentation)

  local function inspectKV(k, v)
    local keyStr = tostring(k)
    local valueStr
    local comments
    if type(k) == "number" then
      keyStr = '[' .. keyStr .. ']'
    elseif type(k) == "string" then
      if k == "syntax_kind" and type(v) == "number" then
        valueStr = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(SyntaxKind, v)) .. ""
      elseif k == "operator" and type(v) == "number" and tab.syntax_kind == SyntaxKind.binary_op_expression then
        valueStr = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(BinaryOpKind, v)) .. ""
      elseif k == "operator" and type(v) == "number" and tab.syntax_kind == SyntaxKind.unary_op_expression then
        valueStr = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(UnaryOpKind, v)) .. ""
      elseif k == "token_type" and type(v) == "number" then
        valueStr = tostring(v)
        comments = " " .. tostring(DiagnosticUtils.index_of(TokenType, v)) .. ""
      end
    end

    if not valueStr then
      if type(v) == "string" then
        valueStr = "'" .. tostring(v) .. "'"
      else
        valueStr = tostring(v)
      end
    end

    if comments then
      comments = " --" .. comments
    end
    
    if type(v) == "table" then
      print(tabs .. tostring(keyStr) .. " = {")
      DiagnosticUtils.inspectAST(v, maxDepth, _indentation + 1)
      print(tabs .. "}," .. (comments or ""))
    else
      print(tabs .. tostring(keyStr) .. " = " .. valueStr .. "," .. (comments or ""))
    end
  end

  -- Inspect certain keys first if they exist
  local wasInspected = {}
  for _, k in pairs(INSPECT_FIRST) do
    if tab[k] ~= nil then
      inspectKV(k, tab[k])
      wasInspected[k] = true
    end
  end
  for k, v in pairs(tab) do
    if not wasInspected[k] then
      inspectKV(k, v)
    end
  end
end

return DiagnosticUtils