local TokenInfo = {}
TokenInfo.__index = {}
function TokenInfo.new(token_type, value, line, column)
  return TokenInfo.constructor(setmetatable({}, TokenInfo), token_type, value, line, column)
end
function TokenInfo.constructor(self, token_type, value, line, column)
  self.token_type = token_type
  self.value = value
  self.line = line
  self.column = column
  return self
end
function TokenInfo.__index:__tostring()
  return ("%d %s"):format(self.token_type, self.value)
end
return TokenInfo
