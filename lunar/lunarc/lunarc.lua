local lfs = require "lfs"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local Binder = require "lunar.compiler.semantic.binder"
local Transpiler = require "lunar.compiler.codegen.transpiler"
local ProjectEnvironment = require "lunar.compiler.semantic.project_environment"

local function fail(reason, exit_code)
  io.stderr:write("lunarc: " .. reason .. "\n")
  os.exit(exit_code or 1)
end

local function join(...)
  return table.concat({ ... }, "/")
end

-- settings to be overriden by the .lunarconfig file
local lunarconfig, _ = io.open("./.lunarconfig", "r")
if not lunarconfig then
  fail("Could not find '.lunarconfig' in '" .. lfs.currentdir() .. "'")
end

-- given that the lunarconfig file follows the convention, everything is swell
local config = {}
setfenv(loadstring(lunarconfig:read("*a")), config)()
local root_dirs = config.root_dirs or fail("'root_dirs' was not defined in '.lunarconfig'")
local out_dir = config.out_dir or fail("'out_dir' was not defined in '.lunarconfig'")

local function is_file_lunar(name)
  return name:sub(-6) == ".lunar"
end
local function is_file_lunar_declaration(name)
  return name:sub(-8) == ".d.lunar"
end

local project_env = ProjectEnvironment.new()
local parsed_sources = {}

local function parse_and_bind_source(source, in_path, out_path)
  local tokens = Lexer.new(source):tokenize()
  local ast = Parser.new(tokens):parse()
  Binder.new(ast, project_env, in_path):bind()
  table.insert(parsed_sources, {
    ast = ast,
    in_path = in_path,
    out_path = out_path,
  })
end

local function transpile_source(ast)
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
      elseif attrs and attrs.mode == "file" and (is_file_lunar_declaration(name) or is_file_lunar(name)) then
        local out_path = join(out_dir, path, name:sub(1, -7) .. ".lua")
        parse_and_bind_source(
          io.open(file_path):read("*a"),
          file_path,
          (not is_file_lunar_declaration(name)) and out_path or nil
        )
      elseif attrs and attrs.mode == "file" then
        -- Copy other files normally
        
        local contents = io.open(file_path):read("*a")
        local out_file, err = io.open(join(out_dir, path, name:sub(1, -5) .. ".lua"), "w")

        if err then
          if out_file then out_file:close() end -- close the file if it exists
          fail(err)
        end

        out_file:write(contents)
        out_file:flush()
      end
    end
  end
end

lfs.mkdir(out_dir)
for _, root_dir in pairs(root_dirs) do
  lfs.mkdir(join(out_dir, root_dir))
  parse_sources_in_directory(root_dir)

  for i = 1, #parsed_sources do
    local source_info = parsed_sources[i]
    if source_info.out_path then
      local out = transpile_source(source_info.ast)
      local out_file, err = io.open(source_info.out_path, "w")

      if err then
        if out_file then out_file:close() end -- close the file if it exists
        fail(err)
      end

      out_file:write(out)
      out_file:flush()
    end
  end
end
