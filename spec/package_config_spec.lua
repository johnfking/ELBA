---
--- Unit tests for package_config module (Task 8.1)
---
--- Validates Requirements 4.1
---

describe('package_config module', function()
  local package_config
  
  setup(function()
    package_config = require('spec.package_config')
  end)
  
  describe('create_package_config', function()
    it('returns a PackageConfig structure', function()
      local config = package_config.create_package_config()
      
      assert.is_table(config, 'config should be a table')
      assert.is_table(config.aliases, 'config.aliases should be a table')
      assert.is_table(config.preload, 'config.preload should be a table')
      assert.is_table(config.loaded, 'config.loaded should be a table')
    end)
    
    it('contains core LuaBots module aliases', function()
      local config = package_config.create_package_config()
      
      assert.equals('init', config.aliases['LuaBots.init'])
      assert.equals('LuaBots/Actionable', config.aliases['LuaBots.Actionable'])
    end)
    
    it('contains command building module aliases', function()
      local config = package_config.create_package_config()
      
      assert.equals('LuaBots/CommandBuilder', config.aliases['LuaBots.CommandBuilder'])
      assert.equals('LuaBots/CommandExecutor', config.aliases['LuaBots.CommandExecutor'])
      assert.equals('LuaBots/HTTPClient', config.aliases['LuaBots.HTTPClient'])
      assert.equals('LuaBots/NameGenerator', config.aliases['LuaBots.NameGenerator'])
    end)
    
    it('contains enum module aliases', function()
      local config = package_config.create_package_config()
      
      assert.equals('enums.Slot', config.aliases['LuaBots.enums.Slot'])
      assert.equals('enums.Class', config.aliases['LuaBots.enums.Class'])
      assert.equals('enums.Gender', config.aliases['LuaBots.enums.Gender'])
      assert.equals('enums.Race', config.aliases['LuaBots.enums.Race'])
      assert.equals('enums.SpellType', config.aliases['LuaBots.enums.SpellType'])
      assert.equals('enums.SpellDelayCategory', config.aliases['LuaBots.enums.SpellDelayCategory'])
      assert.equals('enums.SpellHoldCategory', config.aliases['LuaBots.enums.SpellHoldCategory'])
      assert.equals('enums.Stance', config.aliases['LuaBots.enums.Stance'])
      assert.equals('enums.MaterialSlot', config.aliases['LuaBots.enums.MaterialSlot'])
      assert.equals('enums.PetType', config.aliases['LuaBots.enums.PetType'])
    end)
    
    it('contains test stub aliases', function()
      local config = package_config.create_package_config()
      
      assert.equals('mq_stub', config.aliases['mq'])
    end)
    
    it('initializes preload and loaded as empty tables', function()
      local config = package_config.create_package_config()
      
      -- Count entries in preload and loaded
      local preload_count = 0
      for _ in pairs(config.preload) do
        preload_count = preload_count + 1
      end
      
      local loaded_count = 0
      for _ in pairs(config.loaded) do
        loaded_count = loaded_count + 1
      end
      
      assert.equals(0, preload_count, 'preload should be empty')
      assert.equals(0, loaded_count, 'loaded should be empty')
    end)
    
    it('does not modify global package.preload', function()
      -- Capture initial state
      local initial_preload = {}
      for k, v in pairs(package.preload) do
        initial_preload[k] = v
      end
      
      -- Call create_package_config
      local config = package_config.create_package_config()
      
      -- Verify package.preload unchanged
      for k, v in pairs(package.preload) do
        assert.equals(initial_preload[k], v, 'package.preload["' .. k .. '"] should not change')
      end
      
      -- Verify no new entries added
      for k, v in pairs(initial_preload) do
        assert.equals(v, package.preload[k], 'package.preload should not have entries removed')
      end
    end)
    
    it('does not modify global package.loaded', function()
      -- Capture initial state
      local initial_loaded = {}
      for k, v in pairs(package.loaded) do
        initial_loaded[k] = v
      end
      
      -- Call create_package_config
      local config = package_config.create_package_config()
      
      -- Verify package.loaded unchanged
      for k, v in pairs(package.loaded) do
        assert.equals(initial_loaded[k], v, 'package.loaded["' .. k .. '"] should not change')
      end
      
      -- Verify no new entries added
      for k, v in pairs(initial_loaded) do
        assert.equals(v, package.loaded[k], 'package.loaded should not have entries removed')
      end
    end)
    
    it('returns a new table on each call (not cached)', function()
      local config1 = package_config.create_package_config()
      local config2 = package_config.create_package_config()

      -- Tables should be different instances
      assert.is_not.equals(config1, config2, 'should return new table instances')
      assert.is_not.equals(config1.aliases, config2.aliases, 'aliases should be new instances')
      assert.is_not.equals(config1.preload, config2.preload, 'preload should be new instances')
      assert.is_not.equals(config1.loaded, config2.loaded, 'loaded should be new instances')
    end)
  end)

  describe('apply_package_config', function()
    it('applies aliases to package.preload', function()
      local config = package_config.create_package_config()

      -- Apply configuration
      local backup = package_config.apply_package_config(config)

      -- Verify aliases are applied
      for alias, _ in pairs(config.aliases) do
        assert.is_function(package.preload[alias], 'package.preload["' .. alias .. '"] should be a function')
      end

      -- Cleanup
      package_config.restore_package_config(backup)
    end)

    it('returns backup of original package.preload state', function()
      -- Set up a test alias
      local test_alias = 'test.alias.for.backup'
      local original_loader = function() return 'original' end
      package.preload[test_alias] = original_loader

      -- Create config with this alias
      local config = {
        aliases = { [test_alias] = 'some.path' },
        preload = {},
        loaded = {}
      }

      -- Apply configuration
      local backup = package_config.apply_package_config(config)

      -- Verify backup contains original loader
      assert.equals(original_loader, backup.preload[test_alias], 'backup should contain original loader')

      -- Cleanup
      package_config.restore_package_config(backup)
    end)

    it('handles nil entries in package.preload', function()
      local test_alias = 'test.new.alias'

      -- Ensure alias doesn't exist
      package.preload[test_alias] = nil

      local config = {
        aliases = { [test_alias] = 'some.path' },
        preload = {},
        loaded = {}
      }

      -- Apply configuration
      local backup = package_config.apply_package_config(config)

      -- Verify new alias is applied
      assert.is_function(package.preload[test_alias], 'new alias should be applied')

      -- Verify backup contains nil
      assert.is_nil(backup.preload[test_alias], 'backup should contain nil for new entries')

      -- Cleanup
      package_config.restore_package_config(backup)
    end)

    it('creates loader functions that call require with correct path', function()
      local config = {
        aliases = { ['test.alias'] = 'LuaBots/Actionable' },
        preload = {},
        loaded = {}
      }

      local backup = package_config.apply_package_config(config)

      -- Get the loader function
      local loader = package.preload['test.alias']
      assert.is_function(loader, 'loader should be a function')

      -- Call the loader and verify it loads the correct module
      local result = loader()
      assert.is_not_nil(result, 'loader should return a module')

      -- Cleanup
      package_config.restore_package_config(backup)
    end)
  end)

  describe('restore_package_config', function()
    it('restores package.preload to original state', function()
      local test_alias = 'test.restore.alias'
      local original_loader = function() return 'original' end
      package.preload[test_alias] = original_loader

      local config = {
        aliases = { [test_alias] = 'some.path' },
        preload = {},
        loaded = {}
      }

      -- Apply and then restore
      local backup = package_config.apply_package_config(config)
      package_config.restore_package_config(backup)

      -- Verify original loader is restored
      assert.equals(original_loader, package.preload[test_alias], 'original loader should be restored')
    end)

    it('restores nil entries correctly', function()
      local test_alias = 'test.restore.nil.alias'
      package.preload[test_alias] = nil

      local config = {
        aliases = { [test_alias] = 'some.path' },
        preload = {},
        loaded = {}
      }

      -- Apply and then restore
      local backup = package_config.apply_package_config(config)
      assert.is_function(package.preload[test_alias], 'alias should be applied')

      package_config.restore_package_config(backup)

      -- Verify nil is restored
      assert.is_nil(package.preload[test_alias], 'nil should be restored')
    end)

    it('handles multiple aliases correctly', function()
      local aliases = {
        'test.multi.alias1',
        'test.multi.alias2',
        'test.multi.alias3'
      }

      -- Set up original loaders
      local original_loaders = {}
      for i, alias in ipairs(aliases) do
        original_loaders[i] = function() return 'original' .. i end
        package.preload[alias] = original_loaders[i]
      end

      local config = {
        aliases = {
          [aliases[1]] = 'path1',
          [aliases[2]] = 'path2',
          [aliases[3]] = 'path3'
        },
        preload = {},
        loaded = {}
      }

      -- Apply and restore
      local backup = package_config.apply_package_config(config)
      package_config.restore_package_config(backup)

      -- Verify all original loaders are restored
      for i, alias in ipairs(aliases) do
        assert.equals(original_loaders[i], package.preload[alias],
          'original loader ' .. i .. ' should be restored')
      end
    end)
  end)

  describe('apply and restore round-trip', function()
    it('returns package.preload to original state after apply and restore', function()
      -- Capture initial state
      local initial_state = {}
      for k, v in pairs(package.preload) do
        initial_state[k] = v
      end

      -- Apply configuration
      local config = package_config.create_package_config()
      local backup = package_config.apply_package_config(config)

      -- Verify state changed
      local changed = false
      for alias, _ in pairs(config.aliases) do
        if package.preload[alias] ~= initial_state[alias] then
          changed = true
          break
        end
      end
      assert.is_true(changed, 'package.preload should be modified after apply')

      -- Restore configuration
      package_config.restore_package_config(backup)

      -- Verify state is restored
      for k, v in pairs(initial_state) do
        assert.equals(v, package.preload[k], 'package.preload["' .. k .. '"] should be restored')
      end

      -- Verify no extra entries
      for k, v in pairs(package.preload) do
        if initial_state[k] == nil then
          -- This is a new entry added during the test, should be nil after restore
          assert.equals(initial_state[k], v, 'new entry should be removed or set to nil')
        end
      end
    end)
  end)
end)
