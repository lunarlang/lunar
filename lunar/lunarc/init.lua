local function fail(reason, exit_code, include_traceback)
  if include_traceback == nil then include_traceback = true end

  io.stderr:write("lunarc: " .. reason .. "\n")
  if include_traceback then
    io.stderr:write(debug.traceback() .. "\n")
  end
  os.exit(exit_code or 1)
end

local lfs_ok, lfs = pcall(require, "lfs")
if not lfs_ok then
  fail("required dependency 'LuaFileSystem' was not found, install with 'luarocks install luafilesystem'.", false)
end

local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local Binder = require "lunar.compiler.semantic.binder"
local Checker = require "lunar.compiler.checking.checker"
local Transpiler = require "lunar.compiler.codegen.transpiler"
local ProjectEnvironment = require "lunar.compiler.semantic.project_environment"
local PathUtils = require "lunar.utils.path_utils"

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
local include = config.include or fail("'include' was not defined in '.lunarconfig'")
local out_dir = config.out_dir or fail("'out_dir' was not defined in '.lunarconfig'")

local function assert_file_ext(name, ext)
  return name:sub(-#ext) == ext
end

local project_env = ProjectEnvironment.new()
local parsed_sources = {}
local error_infos = {}

local function parse_and_bind_source(source, in_path, in_path_dot, out_path)
  local success, err = pcall(function()
    local tokens = Lexer.new(source):tokenize()
    local ast = Parser.new(tokens):parse()
    Binder.new(ast, project_env, in_path_dot):bind()
    table.insert(parsed_sources, {
      ast = ast,
      in_path = in_path,
      out_path = out_path,
    })
  end)

  if not success then
    table.insert(error_infos, {
      in_path = in_path,
      error = err
    })
  end
end

local function transpile_source(ast)
  local lua_out = Transpiler.new(ast):transpile()
  return lua_out
end

local used_paths = {}
local function parse_subpath(path, dot_path, name)
  if path == out_dir or path == PathUtils.join(".", out_dir) then return end

  local file_path = join(path, name)
  local file_path_dot = dot_path .. (dot_path == "" and "" or ".") .. name:match("[^%.]*")
  local attrs = lfs.attributes(file_path) -- nilable

  -- Guard against output files with the same name in dot form
  if assert_file_ext(name, ".lunar") or assert_file_ext(name, ".lua") then
    if used_paths[file_path_dot] then
      if (assert_file_ext(used_paths[file_path_dot], ".lua") and assert_file_ext(name, ".d.lunar"))
        or (assert_file_ext(used_paths[file_path_dot], ".d.lunar") and assert_file_ext(name, ".lua")) then
        -- A declaration can mask a lua file; this case is fine.
      else
        error("Multiple files found at the same path: '" .. file_path_dot .. "'")
      end
    else
      used_paths[file_path_dot] = name
    end
  end

  if attrs and attrs.mode == "directory" then
    lfs.mkdir(join(out_dir, path, name))
    for sub_name in lfs.dir(file_path) do
      if name ~= "." and name ~= ".." then
        parse_subpath(file_path, file_path_dot, sub_name)
      end
    end
  elseif attrs and attrs.mode == "file" and (assert_file_ext(name, ".lunar") or assert_file_ext(name, ".d.lunar")) then
    local out_path = join(out_dir, path, name:sub(1, -7) .. ".lua")
    parse_and_bind_source(
      io.open(file_path):read("*a"),
      file_path,
      file_path_dot,
      (not assert_file_ext(name, ".d.lunar")) and out_path or nil
    )
  elseif attrs and attrs.mode == "file" then
    -- Copy other files normally

    local contents = io.open(file_path):read("*a")
    local out_file, err = io.open(join(out_dir, path, name), "w")

    if err then
      if out_file then out_file:close() end -- close the file if it exists
      fail(err)
    end

    out_file:write(contents)
    out_file:flush()
  end
end

lfs.mkdir(out_dir)

-- Parse and bind included files
for _, include_path in pairs(include) do
  local include_path_dot = PathUtils.to_dot_form(include_path)
  if not include_path_dot then
    error("Invalid include path '" .. include_path .. "': include paths must be in the root directory")
  end
  local root_path_end
  for i = #include_path_dot, 1, -1 do
    if include_path_dot:sub(i, i) == "." then
      root_path_end = i - 1
      break
    end
  end

  if root_path_end and root_path_end >= 1 then
    local root_path_dot = include_path_dot:sub(1, root_path_end)
    local accumulated_dirs = out_dir
    for root_subpath in root_path_dot:gmatch("([^%.]+)%.?") do
      accumulated_dirs = PathUtils.join(accumulated_dirs, root_subpath)
      lfs.mkdir(accumulated_dirs)
    end

    parse_subpath(PathUtils.normalize(join(include_path, "..")), root_path_dot, include_path_dot:sub(root_path_end + 2))
  else
    parse_subpath('.', '', include_path)
  end
end

-- Parse and bind referenced files that were not included
repeat
  local unvisited_sources = project_env:get_unvisited_sources()
  for i = 1, #unvisited_sources do
    local source_path_dot = unvisited_sources[i]

    local absolute_path = PathUtils.dot_path_to_absolute(source_path_dot)
    local attrs = absolute_path and lfs.attributes(absolute_path, "mode")
    if absolute_path and attrs and attrs == "file" then
      parse_and_bind_source(
        io.open(absolute_path):read("*a"),
        absolute_path,
        source_path_dot,
        nil
      )
    else
      project_env:declare_visited_source(source_path_dot, false)
      -- Mark as visited (with return types ultimately undeclared, unless declared elsewhere)
    end
  end
until #unvisited_sources == 0

-- Link symbols among files
project_env:link_external_references()

-- Run the checker on all sources
for i = 1, #parsed_sources do
  local source_info = parsed_sources[i]
  Checker.new(source_info.ast, project_env, assert_file_ext(source_info.in_path, ".d.lunar")):check()
end


-- Transpile sources
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

if #error_infos > 0 then
  for _, error_info in pairs(error_infos) do
    io.stderr:write(error_info.in_path .. ":" .. error_info.error .. "\n")
  end

  os.exit(1)
end
