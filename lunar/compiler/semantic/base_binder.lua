local BaseBinder = {}
BaseBinder.__index = {}

function BaseBinder.constructor(self)
    
end

function BaseBinder.new()
    local self = setmetatable({}, BaseBinder)
    BaseBinder.constructor(self)
    return self
end