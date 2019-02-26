local lfs = require "lfs"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local Transpiler = require "lunar.compiler.codegen.transpiler"

local function fail(reason, exit_code)
  io.stderr:write("lunarc: " .. reason .. "\n")
  os.exit(exit_code or 1)
end

local function join(...)
  return table.concat({ ... }, "/")
end

-- settings to be overriden by the .lunarconfig file
local lunarconfig, err = io.open("./.lunarconfig", "r")
if not lunarconfig then
  fail("Could not find '.lunarconfig' in '" .. lfs.currentdir() .. "'")
end

-- given that the lunarconfig file follows the convention, everything is swell
loadstring(lunarconfig:read("*a"))()
local root_dirs = root_dirs or fail("'root_dirs' was not defined in '.lunarconfig'")
local out_dir = out_dir or fail("'out_dir' was not defined in '.lunarconfig'")

local function is_file_lunar(name)
  return name:sub(-6) == ".lunar"
end

local function parse_and_emit(source, name)
  local tokens = Lexer.new(source, name):tokenize()
  local ast = Parser.new(tokens, name):parse()
  local lua_out = Transpiler.new(ast):transpile()

  return lua_out
end

local function parse_sources_in_directory(path)
  for name in lfs.dir(path) do
    if name ~= "." and name ~= ".." then
      local file_path = join(path, name)
      local attrs = lfs.attributes(file_path) -- nilable

      if attrs and attrs.mode == "directory" then
        lfs.mkdir(join(out_dir, path, name))
        parse_sources_in_directory(file_path)
      elseif attrs and attrs.mode == "file" and is_file_lunar(name) then
        local out = parse_and_emit(io.open(file_path):read("*a"), name)
        local out_file, err = io.open(join(out_dir, path, name:sub(1, -7) .. ".lua"), "w")

        if err then
          if out_file then out_file:close() end -- close the file if it exists
          fail(err)
        end

        out_file:write(out)
        out_file:flush()
      end
    end
  end
end

lfs.mkdir(out_dir)
for _, root_dir in pairs(root_dirs) do
  lfs.mkdir(join(out_dir, root_dir))
  parse_sources_in_directory(root_dir)
end
