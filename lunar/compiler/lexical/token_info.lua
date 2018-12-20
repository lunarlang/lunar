local TokenInfo = {}
TokenInfo.__index = TokenInfo

function TokenInfo.new(token_type, value, position)
  local self = setmetatable({}, TokenInfo)
  self.token_type = token_type
  self.value = value
  self.position = position

  return self
end

function TokenInfo:__tostring()
  return ("%d %s"):format(self.token_type, self.value)
end

return TokenInfo
