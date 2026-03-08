---
--- Package Configuration Module
---
--- This module provides functions to create, apply, and restore package configurations
--- for LuaBots testing. It separates configuration data from side effects, allowing
--- tests to explicitly manage package aliases without modifying global state directly.
---
--- Validates Requirements 4.1
---

---@class PackageConfig
---@field aliases table<string, string> package alias mappings (alias name -> target path)
---@field preload table<string, function> package preload functions
---@field loaded table<string, any> loaded package cache

local M = {}

--- Create package configuration for LuaBots testing
---
--- Returns a PackageConfig structure containing all LuaBots package aliases
--- without modifying global package.preload or package.loaded tables.
---
--- This is a pure function that constructs configuration data.
---
---@return PackageConfig configuration with LuaBots aliases
function M.create_package_config()
  return {
    aliases = {
      -- Core LuaBots modules
      ['LuaBots.init'] = 'init',
      ['LuaBots.Actionable'] = 'LuaBots/Actionable',

      -- Command building modules
      ['LuaBots.CommandBuilder'] = 'LuaBots/CommandBuilder',
      ['LuaBots.CommandExecutor'] = 'LuaBots/CommandExecutor',
      ['LuaBots.HTTPClient'] = 'LuaBots/HTTPClient',
      ['LuaBots.NameGenerator'] = 'LuaBots/NameGenerator',

      -- Enum modules
      ['LuaBots.enums.Slot'] = 'enums.Slot',
      ['LuaBots.enums.Class'] = 'enums.Class',
      ['LuaBots.enums.Gender'] = 'enums.Gender',
      ['LuaBots.enums.Race'] = 'enums.Race',
      ['LuaBots.enums.SpellType'] = 'enums.SpellType',
      ['LuaBots.enums.SpellDelayCategory'] = 'enums.SpellDelayCategory',
      ['LuaBots.enums.SpellHoldCategory'] = 'enums.SpellHoldCategory',
      ['LuaBots.enums.Stance'] = 'enums.Stance',
      ['LuaBots.enums.MaterialSlot'] = 'enums.MaterialSlot',
      ['LuaBots.enums.PetType'] = 'enums.PetType',

      -- Test stubs
      ['mq'] = 'mq_stub',
    },
    preload = {},
    loaded = {}
  }
end

--- Apply package configuration to global package tables
---
--- Takes a PackageConfig and applies its aliases to package.preload by creating
--- loader functions that redirect to the target paths. Returns a backup of the
--- original package.preload state so it can be restored later.
---
--- This function has side effects: it modifies global package.preload.
---
--- Validates Requirements 4.2
---
---@param config PackageConfig configuration to apply
---@return PackageConfig backup of original package.preload state
function M.apply_package_config(config)
  local backup = {
    aliases = {},
    preload = {},
    loaded = {},
    _keys = {}  -- Track all keys for restoration, including nil values
  }

  -- Backup and apply aliases
  for alias, path in pairs(config.aliases) do
    backup.preload[alias] = package.preload[alias]
    table.insert(backup._keys, alias)
    package.preload[alias] = function()
      return require(path)
    end
  end

  return backup
end

--- Restore package configuration from backup
---
--- Takes a backup PackageConfig (returned by apply_package_config) and restores
--- package.preload to its original state.
---
--- This function has side effects: it modifies global package.preload.
---
--- Validates Requirements 4.3
---
---@param backup PackageConfig backup configuration to restore
function M.restore_package_config(backup)
  -- Use _keys to restore all entries, including those that were nil
  if backup._keys then
    for _, alias in ipairs(backup._keys) do
      package.preload[alias] = backup.preload[alias]
    end
  else
    -- Fallback for backups without _keys (shouldn't happen with new code)
    for alias, loader in pairs(backup.preload) do
      package.preload[alias] = loader
    end
  end
end

return M
