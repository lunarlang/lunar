-- Stolen from https://github.com/mpeterv/luacheck/blob/master/src/luacheck/fs.lua

local PathUtils = {}

local lfs = require "lfs"
local StringUtils = require "lunar.utils.string_utils"

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

local function ensure_dir_sep(path)
   if path:sub(-1) ~= dir_sep then
	  return path .. dir_sep
   end

   return path
end

function PathUtils.split_base(path)
   if is_windows then
	  if path:match("^%a:\\") then
		 return path:sub(1, 3), path:sub(4)
	  else
		 -- Disregard UNC paths and relative paths with drive letter.
		 return "", path
	  end
   else
	  if path:match("^/") then
		 if path:match("^//") then
			return "//", path:sub(3)
		 else
			return "/", path:sub(2)
		 end
	  else
		 return "", path
	  end
   end
end

function PathUtils.is_absolute(path)
   return PathUtils.split_base(path) ~= ""
end

function PathUtils.normalize(path)
   if is_windows then
	  path = path:lower()
   end
   local base, rest = PathUtils.split_base(path)
   rest = rest:gsub("[/\\]", dir_sep)

   local parts = {}

   for part in rest:gmatch("[^"..dir_sep.."]+") do
	  if part ~= "." then
		 if part == ".." and #parts > 0 and parts[#parts] ~= ".." then
			parts[#parts] = nil
		 else
			parts[#parts + 1] = part
		 end
	  end
   end

   if base == "" and #parts == 0 then
	  return "."
   else
	  return base..table.concat(parts, dir_sep)
   end
end

local function join_two_paths(base, path)
   if base == "" or PathUtils.is_absolute(path) then
	  return path
   else
	  return ensure_dir_sep(base) .. path
   end
end

function PathUtils.join(base, ...)
   local res = base

   for i = 1, select("#", ...) do
	  res = join_two_paths(res, select(i, ...))
   end

   return res
end

function PathUtils.is_subpath(path, subpath)
   local base1, rest1 = PathUtils.split_base(path)
   local base2, rest2 = PathUtils.split_base(subpath)

   if base1 ~= base2 then
	  return false
   end

   if rest2:sub(1, #rest1) ~= rest1 then
	  return false
   end

   return rest1 == rest2 or rest2:sub(#rest1 + 1, #rest1 + 1) == dir_sep
end

function PathUtils.is_dir(path)
   return lfs.attributes(path, "mode") == "directory"
end

function PathUtils.is_file(path)
   return lfs.attributes(path, "mode") == "file"
end

-- Searches for file starting from path, going up until the file
-- is found or root directory is reached.
-- Path must be absolute.
-- Returns absolute and relative paths to directory containing file or nil.
function PathUtils.find_file(path, file)
   if PathUtils.is_absolute(file) then
	  return PathUtils.is_file(file) and file, ""
   end

   path = PathUtils.normalize(path)
   local base, rest = PathUtils.split_base(path)
   local rel_path = ""

   while true do
	  if PathUtils.is_file(PathUtils.join(base..rest, file)) then
		 return base..rest, rel_path
	  elseif rest == "" then
		 return
	  end

	  rest = rest:match("^(.*)"..dir_sep..".*$") or ""
	  rel_path = rel_path..".."..dir_sep
   end
end

-- Returns iterator over directory items or nil, error message.
function PathUtils.dir_iter(dir_path)
   local ok, iter, state, var = pcall(lfs.dir, dir_path)

   if not ok then
	  local err = StringUtils.unprefix(iter, "cannot open " .. dir_path .. ": ")
	  return nil, "couldn't list directory: " .. err
   end

   return iter, state, var
end

-- Returns list of all files in directory matching pattern.
-- Additionally returns a mapping from directory paths that couldn't be expanded
-- to error messages.
function PathUtils.extract_files(dir_path, pattern)
   local res = {}
   local err_map = {}

   local function scan(dir)
	  local iter, state, var = PathUtils.dir_iter(dir)

	  if not iter then
		 err_map[dir] = state
		 table.insert(res, dir)
		 return
	  end

	  for path in iter, state, var do
		 if path ~= "." and path ~= ".." then
			local full_path = PathUtils.join(dir, path)

			if PathUtils.is_dir(full_path) then
			   scan(full_path)
			elseif path:match(pattern) and PathUtils.is_file(full_path) then
			   table.insert(res, full_path)
			end
		 end
	  end
   end

   scan(dir_path)
   table.sort(res)
   return res, err_map
end

local function make_absolute_dirs(dir_path)
   if PathUtils.is_dir(dir_path) then
	  return true
   end

   local upper_dir = PathUtils.normalize(PathUtils.join(dir_path, ".."))

   if upper_dir == dir_path then
	  return nil, ("Filesystem root %s is not a directory"):format(upper_dir)
   end

   local upper_ok, upper_err = make_absolute_dirs(upper_dir)

   if not upper_ok then
	  return nil, upper_err
   end

   local make_ok, make_error = lfs.mkdir(dir_path)

   if not make_ok then
	  return nil, ("Couldn't make directory %s: %s"):format(dir_path, make_error)
   end

   return true
end

-- Ensures that a given path is a directory, creating intermediate directories if necessary.
-- Returns true on success, nil and an error message on failure.
function PathUtils.make_dirs(dir_path)
   return make_absolute_dirs(PathUtils.normalize(PathUtils.join(PathUtils.get_current_dir(), dir_path)))
end

-- Returns modification time for a file.
function PathUtils.get_mtime(path)
   return lfs.attributes(path, "modification")
end

-- Returns absolute path to current working directory, with trailing directory separator.
function PathUtils.get_current_dir()
   return ensure_dir_sep(assert(lfs.currentdir()))
end

function PathUtils.get_extensionless_name(path)
   local base_end = #path
   for i = #path, 1, -1 do
	  local char = path:sub(i, i)
	  if char == dir_sep then
		 break
	  elseif char == "." then
		 base_end = i - 1
	  end
   end

   if base_end > 1 then
	  return path:sub(1, base_end)
   else
	  return ""
   end
end

function PathUtils.to_dot_form(path)
   path = PathUtils.get_extensionless_name(path)
   while path:sub(1, dir_sep:len() + 1) == "." .. dir_sep do
	  path = path:sub(dir_sep:len() + 2)
   end
   if path:find("%.", nil, true) then
	  return nil
   end

   return table.concat(StringUtils.split(path, dir_sep), ".")
end

-- Cache LUA_PATH and LUA_CPATH, and map lunar/d.lunar files in the same path
function PathUtils.cache_lua_paths()
  local paths = StringUtils.split(package.path, ";")
  local cpaths = StringUtils.split(package.cpath, ";")

  PathUtils.lua_paths = {}
  for _, path in pairs(paths) do
    table.insert(PathUtils.lua_paths, path)
  end
  for _, cpath in pairs(cpaths) do
    table.insert(PathUtils.lua_paths, cpath)
  end

  PathUtils.source_paths = {}
  for _, path in pairs(paths) do
    table.insert(PathUtils.source_paths, PathUtils.get_extensionless_name(path) .. ".lunar")
    table.insert(PathUtils.source_paths, PathUtils.get_extensionless_name(path) .. ".d.lunar")
  end
  for _, cpath in pairs(cpaths) do
    table.insert(PathUtils.source_paths, PathUtils.get_extensionless_name(cpath) .. ".lunar")
    table.insert(PathUtils.source_paths, PathUtils.get_extensionless_name(cpath) .. ".d.lunar")
  end
end

function PathUtils.dot_path_to_absolute(source_path_dot)
  local slashed_path = source_path_dot:gsub("%.", "/")

  -- Lazy-load cached paths
  if not PathUtils.lua_paths then
    PathUtils.cache_lua_paths()
  end

  -- Check .lua paths to mask with an ad-hoc .d.lunar declaration
  for _, path in pairs(PathUtils.lua_paths) do
    local tentative_location = path:gsub("%?", slashed_path)
    local abs_path = PathUtils.find_file(".", tentative_location)

    if abs_path then
      return PathUtils.get_extensionless_name(abs_path) .. ".d.lunar"
    end
  end

  -- Check existing source paths
  for _, path in pairs(PathUtils.source_paths) do
    local tentative_location = path:gsub("%?", slashed_path)
    local abs_path = PathUtils.find_file(".", tentative_location)

    if abs_path then
      return abs_path
    end
  end

  return nil
end

return PathUtils