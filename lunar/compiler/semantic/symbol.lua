local Symbol = {}
Symbol.__index = {}

function Symbol.constructor(self)
    
end

function Symbol.new()
    local self = setmetatable({}, Symbol)
    Symbol.constructor(self)
    return self
end