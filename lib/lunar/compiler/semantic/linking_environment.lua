local SymbolTable = require("lunar.compiler.semantic.symbol_table")
local Symbol = require("lunar.compiler.semantic.symbol")
local SourceFileSymbol = require("lunar.compiler.semantic.source_file_symbol")
local CoreGlobals = require("lunar.compiler.semantic.core_globals")
local LinkingEnvironment = {}
LinkingEnvironment.__index = {}
function LinkingEnvironment.new()
  return LinkingEnvironment.constructor(setmetatable({}, LinkingEnvironment))
end
function LinkingEnvironment.constructor(self)
  self.source_file_symbol_map = {}
  self.visited_sources_map = {}
  self.existing_sources_map = {}
  self.env_globals = SymbolTable.new()
  self.linked = false
  self:inject_globals(CoreGlobals)
  return self
end
function LinkingEnvironment.__index:declare_visited_source(source_path_dot, exists)
  if self.visited_sources_map[source_path_dot] then
    error("Multiple declared modules found at the same path: '" .. source_path_dot .. "'")
  end
  self.visited_sources_map[source_path_dot] = true
  self.existing_sources_map[source_path_dot] = exists
  local existing_symbol = self.source_file_symbol_map[source_path_dot]
  if (not existing_symbol) then
    self.source_file_symbol_map[source_path_dot] = SourceFileSymbol.new(source_path_dot)
  end
end
function LinkingEnvironment.__index:link_external_references()
  if self.linked then
    error("Project environment has already been linked")
  end
  self.linked = true
  for source_path_dot, source_file_symbol in pairs(self.source_file_symbol_map) do
    local infile_globals = source_file_symbol.globals
    for i = 1, (#source_file_symbol.imports) do
      local import_statement = source_file_symbol.imports[i]
      local referenced_source_file_symbol = self.source_file_symbol_map[import_statement.path]
      if (not referenced_source_file_symbol) then
        if next(import_statement.values) then
          if self.existing_sources_map[import_statement.path] then
            error("Module '" .. import_statement.path .. "' has no exports")
          else
            error("Cannot find module '" .. import_statement.path .. "'")
          end
        end
      end
      for j = 1, (#import_statement.values) do
        local value_decl = import_statement.values[j]
        local import_name = value_decl.identifier.name
        local alias_ident = value_decl.alias_identifier or value_decl.identifier
        if import_name == "*" then
          referenced_source_file_symbol:bind_reference(value_decl.identifier)
          local alias_symbol = Symbol.new(alias_ident.name)
          alias_symbol:bind_assignment_reference(alias_ident)
          alias_symbol:bind_declaration_reference(alias_ident, import_statement)
          local existing_symbol = infile_globals:get_value(alias_ident.name)
          if existing_symbol then
            if existing_symbol:is_declared() then
              error("Import declaration conflicts with local declaration of '" .. alias_ident.name .. "'")
            end
            existing_symbol:merge_into(alias_symbol)
            infile_globals.values[alias_ident.name] = alias_symbol
          end
        else
          if value_decl.is_type then
            local referenced_type_export = referenced_source_file_symbol.exports:get_type(import_name)
            if referenced_type_export then
              referenced_type_export:bind_reference(value_decl.identifier)
              local alias_symbol = Symbol.new(alias_ident.name)
              alias_symbol:bind_assignment_reference(alias_ident)
              alias_symbol:bind_declaration_reference(alias_ident, import_statement)
              local existing_symbol = infile_globals:get_type(alias_ident.name)
              if existing_symbol then
                if existing_symbol:is_declared() then
                  error("Import declaration conflicts with local declaration of '" .. alias_ident.name .. "'")
                end
                existing_symbol:merge_into(alias_symbol)
                infile_globals.types[alias_ident.name] = alias_symbol
              end
            else
              error("Module '" .. import_statement.path .. "' has no exported type '" .. import_name .. "'")
            end
          else
            local referenced_type_export = referenced_source_file_symbol.exports:get_type(import_name)
            if referenced_type_export then
              referenced_type_export:bind_reference(value_decl.identifier)
              local alias_symbol = Symbol.new(alias_ident.name)
              alias_symbol:bind_assignment_reference(alias_ident)
              alias_symbol:bind_declaration_reference(alias_ident, import_statement)
              local existing_symbol = infile_globals:get_type(alias_ident.name)
              if existing_symbol then
                if existing_symbol:is_declared() then
                  error("Import declaration conflicts with local declaration of '" .. alias_ident.name .. "'")
                end
                existing_symbol:merge_into(alias_symbol)
                infile_globals.types[alias_ident.name] = alias_symbol
              end
            end
            local referenced_value_export = referenced_source_file_symbol.exports:get_value(import_name)
            if referenced_value_export then
              referenced_value_export:bind_reference(value_decl.identifier)
              local alias_symbol = Symbol.new(alias_ident.name)
              alias_symbol:bind_assignment_reference(alias_ident)
              alias_symbol:bind_declaration_reference(alias_ident, import_statement)
              local existing_symbol = infile_globals:get_value(alias_ident.name)
              if existing_symbol then
                if existing_symbol:is_declared() then
                  error("Import declaration conflicts with local declaration of '" .. alias_ident.name .. "'")
                end
                existing_symbol:merge_into(alias_symbol)
                infile_globals.values[alias_ident.name] = alias_symbol
              end
            else
              error("Module '" .. import_statement.path .. "' has no exported value '" .. import_name .. "'")
            end
          end
        end
      end
    end
    for name, symbol in pairs(self.env_globals.types) do
      local existing_symbol = infile_globals:get_type(name)
      if existing_symbol then
        if (not existing_symbol:is_declared()) then
          existing_symbol:merge_into(symbol)
          infile_globals.types[name] = symbol
        end
      end
    end
    for name, symbol in pairs(self.env_globals.values) do
      local existing_symbol = infile_globals:get_value(name)
      if existing_symbol then
        if existing_symbol:is_declared() then
          error("Attempt to re-declare global value '" .. name .. "'")
        else
          existing_symbol:merge_into(symbol)
          infile_globals.values[name] = symbol
        end
      end
    end
  end
end
function LinkingEnvironment.__index:get_unvisited_sources()
  local unvisited_sources = {}
  for path, was_visited in pairs(self.visited_sources_map) do
    if (not was_visited) then
      table.insert(unvisited_sources, path)
    end
  end
  return unvisited_sources
end
function LinkingEnvironment.__index:inject_globals(globals)
  for name, symbol in pairs(globals.values) do
    self.env_globals.values[name] = symbol
  end
  for name, symbol in pairs(globals.types) do
    self.env_globals.types[name] = symbol
  end
end
function LinkingEnvironment.__index:create_source_file_symbol(source_path_dot)
  local existing = self.source_file_symbol_map[source_path_dot]
  if existing then
    error("Cannot re-declare source files")
  else
    local source_file_symbol = SourceFileSymbol.new(source_path_dot)
    self.source_file_symbol_map[source_path_dot] = source_file_symbol
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end
    return source_file_symbol
  end
end
function LinkingEnvironment.__index:get_source_file_symbol(source_path_dot)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot]
end
function LinkingEnvironment.__index:get_exports_value(source_path_dot, value_name)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot].exports:get_value(value_name)
end
function LinkingEnvironment.__index:get_exports_type(source_path_dot, type_name)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot].exports:get_type(type_name)
end
function LinkingEnvironment.__index:has_global_value(source_path_dot, value_name)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot].globals:has_value(value_name)
end
function LinkingEnvironment.__index:has_global_type(source_path_dot, type_name)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot].globals:has_type(type_name)
end
function LinkingEnvironment.__index:get_global_value(source_path_dot, value_name)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot].globals:get_value(value_name)
end
function LinkingEnvironment.__index:get_global_type(source_path_dot, type_name)
  return self.source_file_symbol_map[source_path_dot] and self.source_file_symbol_map[source_path_dot].globals:get_type(type_name)
end
function LinkingEnvironment.__index:add_global_value(source_path_dot, value_name)
  return self.source_file_symbol_map[source_path_dot].globals:add_value(value_name)
end
function LinkingEnvironment.__index:add_global_type(source_path_dot, type_name)
  return self.source_file_symbol_map[source_path_dot].globals:add_type(type_name)
end
function LinkingEnvironment.__index:declare_import(source_path_dot, ast)
  return table.insert(self.source_file_symbol_map[source_path_dot].imports, ast)
end
return LinkingEnvironment
