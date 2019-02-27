local Symbol = require "lunar.compiler.semantic.symbol"
local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local CoreGlobals = SymbolTable.new()

CoreGlobals:add_type(Symbol.new("any"))
CoreGlobals:add_type(Symbol.new("unknown"))
CoreGlobals:add_type(Symbol.new("never"))
CoreGlobals:add_type(Symbol.new("nil"))
CoreGlobals:add_type(Symbol.new("string"))
CoreGlobals:add_type(Symbol.new("boolean"))
CoreGlobals:add_type(Symbol.new("function"))
CoreGlobals:add_type(Symbol.new("userdata"))
CoreGlobals:add_type(Symbol.new("thread"))
CoreGlobals:add_type(Symbol.new("table"))

return CoreGlobals