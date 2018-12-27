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

--- Returns the character at the current position and moves forward
-- @treturn string A single letter string from the previous position
function BaseLexer:consume()
  local c = self:peek()
  self:move(1)
  return c
end

--- Returns the character at the current position plus the offset
-- @tparam[opt=0] number offset Number of characters to skip ahead (or behind, if negative) to peek at
-- @treturn string The single character string at that position
function BaseLexer:peek(offset)
  if offset == nil then offset = 0 end

  -- string.sub outside the boundary of self.source will return empty string
  -- but we want it to return nil so it can evaluate to false
  if #self.source >= self.position then
    return self.source:sub(self.position + offset, self.position + offset)
  end
end

--- Moves the position of this lexer instance by an amount
-- @tparam[opt=0] number by Number of characters to move from the position
function BaseLexer:move(by)
  if by == nil then by = 0 end

  self.position = self.position + by
end

--- Asserts whether the following string matches the given string
-- @tparam string str The string to match with the following string
-- @treturn boolean true if the following string matches the given string, otherwise false
function BaseLexer:match(str)
  return self.source:sub(self.position, self.position + #str - 1) == str
end

return BaseLexer
