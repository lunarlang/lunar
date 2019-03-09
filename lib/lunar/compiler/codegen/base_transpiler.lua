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
  if segment == nil then
    segment = ""
  end
  self.source = self.source .. segment
end
function BaseTranspiler:writeln(segment)
  if segment == nil then
    segment = ""
  end
  self:write(segment .. "\n")
end
function BaseTranspiler:iwrite(segment)
  if segment == nil then
    segment = ""
  end
  self:write(self:get_indent() .. segment)
end
function BaseTranspiler:iwriteln(segment)
  if segment == nil then
    segment = ""
  end
  self:writeln(self:get_indent() .. segment)
end
function BaseTranspiler:get_indent()
  if self.indent_count <= 0 then
    return ""
  end
  return self.indent_string:rep(self.indent_count)
end
function BaseTranspiler:indent()
  self.indent_count = self.indent_count + 1
end
function BaseTranspiler:dedent()
  self.indent_count = self.indent_count - 1
end
return BaseTranspiler
