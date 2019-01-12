local BaseLexer = {}
BaseLexer.__index = BaseLexer

function BaseLexer.new(source, file_name)
  if file_name == nil then file_name = "src" end

  local self = setmetatable({}, BaseLexer)
  self.source = source
  self.file_name = file_name
  self.position = 1

  return self
end

function BaseLexer:consume()
  local c = self:peek()
  self:move(1)
  return c
end

function BaseLexer:count(c, offset)
  if offset == nil then offset = 0 end

  local n = 0

  while self:peek(offset + n) == c do
    n = n + 1
  end

  return n
end

function BaseLexer:is_finished()
  return self.position > #self.source
end

function BaseLexer:peek(offset)
  if offset == nil then offset = 0 end

  -- string.sub outside the boundary of self.source will return empty string
  -- but we want it to return nil so it can evaluate to false
  if not self:is_finished() then
    return self.source:sub(self.position + offset, self.position + offset)
  end
end

function BaseLexer:move(by)
  if by == nil then by = 0 end

  self.position = self.position + by
end

function BaseLexer:match(str)
  if self:is_finished() then
    return false
  end

  return self.source:sub(self.position, self.position + #str - 1) == str
end

function BaseLexer:move_if_match(str)
  local ok = self:match(str)

  if ok then
    self:move(#str)
  end

  return ok
end

return BaseLexer
