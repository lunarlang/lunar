local SymbolTable = require "lunar.compiler.semantic.symbol_table"
local Symbol = require "lunar.compiler.semantic.symbol"
local CoreGlobals = require "lunar.compiler.semantic.core_globals"

local ProjectEnvironment = {}
ProjectEnvironment.__index = {}
--[[
typealias ReturnsMap = Map<string, {
  symbol?: Symbol -- The symbol for all of the module's returns
    & exports: {
      values?: Map<string, Symbol> -- A map of exported symbols for the module's returns
      types: Map<string, Symbol>
    }
}>
]]

function ProjectEnvironment.constructor(self)
  self.returns_map = {} -- public returns_map: ReturnsMap
  self.visited_sources_map = {} -- Map<string, boolean>
    -- A map determining whether or not a source file in the project environment was bound
  self.existing_sources_map = {} -- Map<string, boolean>
    -- A map determining whether or not a source file in the project environment exists
  self.globals_map = {} -- Map of global symbols before linking
  self.imports_map = {} -- Map of imported value declarations
  self.env_globals = SymbolTable.new() -- Environment globals pos-linking
  self:inject_globals(CoreGlobals)
  self.linked = false
end

function ProjectEnvironment.new(...)
  local self = setmetatable({}, ProjectEnvironment)
  ProjectEnvironment.constructor(self, ...)
  return self
end

function ProjectEnvironment.__index:declare_visited_source(source_path_dot, exists)
  if self.visited_sources_map[source_path_dot] then
    error("Multiple declared modules found at the same path: '" .. source_path_dot .. "'")
  end
  self.visited_sources_map[source_path_dot] = true
  self.existing_sources_map[source_path_dot] = exists
  self.globals_map[source_path_dot] = SymbolTable.new()
  self.imports_map[source_path_dot] = {}
end

function ProjectEnvironment.__index:link_external_references()
  if self.linked then
    error("Project environment has already been linked")
  end
  self.linked = true
  for source_path_dot, infile_globals in pairs(self.globals_map) do
    -- Compare with imports
    for i = 1, #self.imports_map[source_path_dot] do
      local import_statement = self.imports_map[source_path_dot][i]
      local referenced_returns = self.returns_map[import_statement.path]
      if not referenced_returns then
        if next(import_statement.values) then
          if self.existing_sources_map[import_statement.path] then
            error("Module '" .. import_statement.path .. "' has no exports")
          else
            error("Cannot find module '" .. import_statement.path .. "'")
          end
        end
      end

      -- Search exports now that we know they have been declared
      for j = 1, #import_statement.values do
        local value_decl = import_statement.values[j]
        local import_name = value_decl.identifier.name
        local alias_ident = value_decl.alias_identifier or value_decl.identifier

        if import_name == "*" then
          -- Bind * identifier as reference
          referenced_returns:bind_reference(value_decl.identifier)

          -- link all gobal references to this returns symbol using an alias
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
            local referenced_type_export = referenced_returns.exports:get_type(import_name)
            if referenced_type_export then
              referenced_type_export:bind_reference(value_decl.identifier)

              -- link all gobal references to this type symbol using an alias
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
            -- Also import type export under the same name if it exists
            local referenced_type_export = referenced_returns.exports:get_type(import_name)
            if referenced_type_export then
              referenced_type_export:bind_reference(value_decl.identifier)

              -- link all gobal references to this type symbol using an alias
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
  
            local referenced_value_export = referenced_returns.exports:get_value(import_name)
            if referenced_value_export then
              referenced_value_export:bind_reference(value_decl.identifier)
              -- link all gobal references to this value symbol using an alias
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
              error("Module '" .. import_statement.path .. "' has no exported value '" .. import_name.. "'")
            end
          end
        end
      end
    end

    -- Merge remaining undeclared globals into the environment globals
    for name, symbol in pairs(self.env_globals.types) do
      local existing_symbol = infile_globals:get_type(name)
      if existing_symbol then
        if not existing_symbol:is_declared() then
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

function ProjectEnvironment.__index:get_unvisited_sources()
  local unvisited_sources = {}
  for path, was_visited in pairs(self.visited_sources_map) do
    if not was_visited then
      table.insert(unvisited_sources, path)
    end
  end

  return unvisited_sources
end

function ProjectEnvironment.__index:inject_globals(globals)
  for name, symbol in pairs(globals.values) do
    self.env_globals.values[name] = symbol
  end
  for name, symbol in pairs(globals.types) do
    self.env_globals.types[name] = symbol
  end
end

function ProjectEnvironment.__index:add_exports_value(source_path_dot, symbol)
  local existing = self.returns_map[source_path_dot]
  if existing then
    if existing:is_declared() then
      error("Cannot export and return values at the same time")
    end
    existing.exports:add_value(symbol)
  else
    local returns = Symbol.new()
    returns.exports = SymbolTable.new()
    returns.exports:add_value(symbol)
    self.returns_map[source_path_dot] = returns
    
    -- Mark as unbound reference
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end
  end
end

function ProjectEnvironment.__index:add_exports_type(source_path_dot, symbol)
  local existing = self.returns_map[source_path_dot]
  if existing then
    existing.exports:add_type(symbol)
  else
    local returns = Symbol.new()
    returns.exports = SymbolTable.new()
    returns.exports:add_type(symbol)
    self.returns_map[source_path_dot] = returns
    
    -- Mark as unbound reference
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end
  end
end

function ProjectEnvironment.__index:create_returns_symbol(source_path_dot)
  local existing = self.returns_map[source_path_dot]
  if existing then
    error("Cannot re-declare source file returns")
  else
    local returns = Symbol.new()
    returns.exports = SymbolTable.new()
    self.returns_map[source_path_dot] = returns
    
    -- Mark as unbound reference
    if self.visited_sources_map[source_path_dot] == nil then
      self.visited_sources_map[source_path_dot] = false
    end

    return returns
  end
end

function ProjectEnvironment.__index:get_returns_symbol(source_path_dot)
  return self.returns_map[source_path_dot] and self.returns_map[source_path_dot]
end

function ProjectEnvironment.__index:get_exports_value(source_path_dot, value_name)
  return self.returns_map[source_path_dot] and self.returns_map[source_path_dot].exports:get_value(value_name)
end

function ProjectEnvironment.__index:get_exports_type(source_path_dot, type_name)
  return self.returns_map[source_path_dot] and self.returns_map[source_path_dot].exports:get_type(type_name)
end

function ProjectEnvironment.__index:has_global_value(source_path_dot, value_name)
  return self.globals_map[source_path_dot]
    and self.globals_map[source_path_dot]:has_value(value_name)
end

function ProjectEnvironment.__index:has_global_type(source_path_dot, type_name)
  return self.globals_map[source_path_dot]
    and self.globals_map[source_path_dot]:has_type(type_name)
end

function ProjectEnvironment.__index:get_global_value(source_path_dot, value_name)
  return self.globals_map[source_path_dot]
    and self.globals_map[source_path_dot]:get_value(value_name)
end

function ProjectEnvironment.__index:get_global_type(source_path_dot, type_name)
  return self.globals_map[source_path_dot]
    and self.globals_map[source_path_dot]:get_type(type_name)
end

function ProjectEnvironment.__index:add_global_value(source_path_dot, value_name)
  return self.globals_map[source_path_dot]:add_value(value_name)
end

function ProjectEnvironment.__index:add_global_type(source_path_dot, type_name)
  return self.globals_map[source_path_dot]:add_type(type_name)
end

function ProjectEnvironment.__index:declare_import(source_path_dot, ast)
  return table.insert(self.imports_map[source_path_dot], ast)
end

return ProjectEnvironment