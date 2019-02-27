local SourceFileReturns = {}
SourceFileReturns.__index = {}

function SourceFileReturns.constructor(self)
  self.ast = nil
  self.values = nil
  self.types = {}
end

function SourceFileReturns.new(...)
  local self = setmetatable({}, SourceFileReturns)
  SourceFileReturns.constructor(self, ...)
  return self
end

return SourceFileReturns