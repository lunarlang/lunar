local BaseTranspiler = {}
BaseTranspiler.__index = {}
function BaseTranspiler.new()
  return BaseTranspiler.constructor(setmetatable({}, BaseTranspiler))
end
function BaseTranspiler.constructor(self)
  self.indent_string = "  "
  self.indent_count = 0
  self.source = ""
  return self
end
function BaseTranspiler.__index:write(segment)
  if segment == nil then
    segment = ""
  end
  self.source = self.source .. segment
end
function BaseTranspiler.__index:writeln(segment)
  if segment == nil then
    segment = ""
  end
  self:write(segment .. "\n")
end
function BaseTranspiler.__index:iwrite(segment)
  if segment == nil then
    segment = ""
  end
  self:write(self:get_indent() .. segment)
end
function BaseTranspiler.__index:iwriteln(segment)
  if segment == nil then
    segment = ""
  end
  self:writeln(self:get_indent() .. segment)
end
function BaseTranspiler.__index:get_indent()
  if self.indent_count <= 0 then
    return ""
  end
  return self.indent_string:rep(self.indent_count)
end
function BaseTranspiler.__index:indent()
  self.indent_count = self.indent_count + 1
end
function BaseTranspiler.__index:dedent()
  self.indent_count = self.indent_count - 1
end
return BaseTranspiler
