local BaseLexer = {}
BaseLexer.__index = {}
function BaseLexer.new(source)
  return BaseLexer.constructor(setmetatable({}, BaseLexer), source)
end
function BaseLexer.constructor(self, source)
  self.line = 1
  self.line_begins = 0
  self.position = 1
  self.source = source
  return self
end
function BaseLexer.__index:consume()
  local c = self:peek()
  self:move(1)
  return c
end
function BaseLexer.__index:error(reason)
  error(string.format("%d:%d: %s", self.line, self:get_column(), reason), 0)
end
function BaseLexer.__index:get_column()
  return self.position - self.line_begins
end
function BaseLexer.__index:count(c, offset)
  if offset == nil then
    offset = 0
  end
  local n = 0
  while self:peek(offset + n) == c do
    n = n + 1
  end
  return n
end
function BaseLexer.__index:is_finished()
  return self.position > (#self.source)
end
function BaseLexer.__index:peek(offset)
  if offset == nil then
    offset = 0
  end
  if (not self:is_finished()) then
    return self.source:sub(self.position + offset, self.position + offset)
  end
end
function BaseLexer.__index:move(by)
  if by == nil then
    by = 0
  end
  self.position = self.position + by
end
function BaseLexer.__index:match(str)
  if self:is_finished() then
    return false
  end
  return self.source:sub(self.position, self.position + (#str) - 1) == str
end
function BaseLexer.__index:move_if_match(str)
  local ok = self:match(str)
  if ok then
    self:move((#str))
  end
  return ok
end
return BaseLexer
