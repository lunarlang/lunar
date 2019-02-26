local BaseBinder = require "lunar.compiler.semantic.base_binder"
local PrimitiveType = require "lunar.compiler.semantic.primitive_type"
local SyntaxKind = require "lunar.ast.syntax_kind"
local Symbol = require "lunar.compiler.semantic.symbol"
local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local Binder = {}
Binder.__index = setmetatable({}, BaseBinder)

function Binder.constructor(self, chunk)
	BaseBinder.constructor(self)

  self.container = nil
  self.chunk = chunk

	self.primitive_type_symbols = {
		[PrimitiveType.any_type] = Symbol.new("any"),
		[PrimitiveType.nil_type] = Symbol.new("nil"),
		[PrimitiveType.string_type] = Symbol.new("string"),
		[PrimitiveType.boolean_type] = Symbol.new("boolean"),
		[PrimitiveType.function_type] = Symbol.new("function"),
		[PrimitiveType.userdata_type] = Symbol.new("userdata"),
		[PrimitiveType.thread_type] = Symbol.new("thread"),
		[PrimitiveType.table_type] = Symbol.new("table"),
	}

	self.binders = {
		[SyntaxKind.chunk] = self.bind_chunk,
  }
end

function Binder.__index:bind()
    self:bind_chunk(self.chunk)
end

function Binder.__index:bind_node(node)
  local binder = self.binders[node.syntax_kind]
  if binder then
    binder(self, node)
  end
end

function Binder.__index:bind_chunk(node)
  self:push_container(node)
end

function Binder.new(chunk)
	local self = setmetatable({}, Binder)
	Binder.constructor(self, chunk)
	return self
end

return Binder