local BaseBinder = require "lunar.compiler.syntax.base_binder"

local Binder = {}
Binder.__index = setmetatable({}, BaseBinder)

function Binder.constructor(self)
    BaseBinder.constructor(self)

    
end

function Binder.new()
    local self = setmetatable({}, Binder)
    Binder.constructor(self)
    return self
end