local BaseTranspiler = {}
BaseTranspiler.__index = BaseTranspiler

function BaseTranspiler.new()
  local self = setmetatable({}, BaseTranspiler)
  self.indent_string = "  "
  self.indent_count = 0
  self.source = ""

  return self
end

function BaseTranspiler:write(segment)
  self.source = self.source .. segment
end

function BaseTranspiler:get_indent()
  if self.indent_count <= 0 then
    return ""
  end

  return self.indent_string:rep(self.indent_count)
end

function BaseTranspiler:indent()
  self.indent_count = self.indent_count + 1
  return "" -- messy workaround for all the concatenated indent calls
end

function BaseTranspiler:dedent()
  self.indent_count = self.indent_count - 1
  return self:get_indent()
end

return BaseTranspiler
