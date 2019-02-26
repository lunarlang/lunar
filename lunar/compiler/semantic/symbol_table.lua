local SymbolTable = {}
SymbolTable.__index = {}

function SymbolTable.constructor(self)
    
end

function SymbolTable.new()
    local self = setmetatable({}, SymbolTable)
    SymbolTable.constructor(self)
    return self
end