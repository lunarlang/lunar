local TokenInfo = {}
TokenInfo.__index = TokenInfo
function TokenInfo.new(token_type, value, line, column)
  local self = setmetatable({}, TokenInfo)
  self.token_type = token_type
  self.value = value
  self.line = line
  self.column = column
  return self
end
function TokenInfo:__tostring()
  return ("%d %s"):format(self.token_type, self.value)
end
return TokenInfo
