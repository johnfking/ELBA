--
-- Property tests for Package Setup Purity
-- Feature: functional-refactoring
-- Task 8.3: Write property tests for package setup purity
--

describe("Package Setup Purity", function()
  local property = require('spec.property')
  local package_config
  
  setup(function()
    package_config = require('spec.package_config')
  end)
  
  describe("Property 11: Package Setup Purity", function()
    it("should not modify package.preload when creating config", function()
      -- **Validates: Requirements 4.4**
      
      property.forall(
        {},  -- No generators needed - we're testing the function itself
        function()
          -- Capture initial package.preload state
          local initial_preload = {}
          local initial_keys = {}
          
          for k, v in pairs(package.preload) do
            initial_preload[k] = v
            table.insert(initial_keys, k)
          end
          
          -- Call create_package_config
          local config = package_config.create_package_config()
          
          -- Verify package.preload is unchanged
          -- Check all original keys still have same values
          for k, v in pairs(initial_preload) do
            assert.equals(v, package.preload[k], 
              string.format("package.preload['%s'] should not be modified", k))
          end
          
          -- Check no new keys were added
          local current_keys = {}
          for k, _ in pairs(package.preload) do
            table.insert(current_keys, k)
          end
          
          table.sort(initial_keys)
          table.sort(current_keys)
          
          assert.equals(#initial_keys, #current_keys, 
            "package.preload should not have new entries added")
          
          for i = 1, #initial_keys do
            assert.equals(initial_keys[i], current_keys[i],
              "package.preload keys should remain the same")
          end
          
          -- Verify config contains data (not empty)
          assert.is_table(config.aliases, "config.aliases should be a table")
          assert.is_true(next(config.aliases) ~= nil, 
            "config.aliases should not be empty")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should not modify package.loaded when creating config", function()
      -- **Validates: Requirements 4.4**
      
      property.forall(
        {},  -- No generators needed
        function()
          -- Capture initial package.loaded state
          local initial_loaded = {}
          local initial_keys = {}
          
          for k, v in pairs(package.loaded) do
            initial_loaded[k] = v
            table.insert(initial_keys, k)
          end
          
          -- Call create_package_config
          local config = package_config.create_package_config()
          
          -- Verify package.loaded is unchanged
          -- Check all original keys still have same values
          for k, v in pairs(initial_loaded) do
            assert.equals(v, package.loaded[k],
              string.format("package.loaded['%s'] should not be modified", k))
          end
          
          -- Check no new keys were added
          local current_keys = {}
          for k, _ in pairs(package.loaded) do
            table.insert(current_keys, k)
          end
          
          table.sort(initial_keys)
          table.sort(current_keys)
          
          assert.equals(#initial_keys, #current_keys,
            "package.loaded should not have new entries added")
          
          for i = 1, #initial_keys do
            assert.equals(initial_keys[i], current_keys[i],
              "package.loaded keys should remain the same")
          end
          
          -- Verify config contains data
          assert.is_table(config.preload, "config.preload should be a table")
          assert.is_table(config.loaded, "config.loaded should be a table")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should return configuration data without side effects", function()
      -- **Validates: Requirements 4.4**
      
      property.forall(
        {},  -- No generators needed
        function()
          -- Track all global state that could be modified
          local initial_state = {
            preload_keys = {},
            loaded_keys = {},
            global_keys = {}
          }
          
          -- Capture package.preload keys
          for k, _ in pairs(package.preload) do
            table.insert(initial_state.preload_keys, k)
          end
          
          -- Capture package.loaded keys
          for k, _ in pairs(package.loaded) do
            table.insert(initial_state.loaded_keys, k)
          end
          
          -- Capture global keys (sample, not all)
          for k, _ in pairs(_G) do
            if type(k) == 'string' and k:match('^package') then
              table.insert(initial_state.global_keys, k)
            end
          end
          
          -- Call create_package_config multiple times
          local config1 = package_config.create_package_config()
          local config2 = package_config.create_package_config()
          local config3 = package_config.create_package_config()
          
          -- Verify all configs are valid
          assert.is_table(config1.aliases)
          assert.is_table(config2.aliases)
          assert.is_table(config3.aliases)
          
          -- Verify package.preload unchanged
          local current_preload_keys = {}
          for k, _ in pairs(package.preload) do
            table.insert(current_preload_keys, k)
          end
          table.sort(initial_state.preload_keys)
          table.sort(current_preload_keys)
          assert.same(initial_state.preload_keys, current_preload_keys,
            "package.preload keys should not change")
          
          -- Verify package.loaded unchanged
          local current_loaded_keys = {}
          for k, _ in pairs(package.loaded) do
            table.insert(current_loaded_keys, k)
          end
          table.sort(initial_state.loaded_keys)
          table.sort(current_loaded_keys)
          assert.same(initial_state.loaded_keys, current_loaded_keys,
            "package.loaded keys should not change")
          
          -- Verify global package-related keys unchanged
          local current_global_keys = {}
          for k, _ in pairs(_G) do
            if type(k) == 'string' and k:match('^package') then
              table.insert(current_global_keys, k)
            end
          end
          table.sort(initial_state.global_keys)
          table.sort(current_global_keys)
          assert.same(initial_state.global_keys, current_global_keys,
            "global package keys should not change")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should be idempotent - multiple calls produce equivalent configs", function()
      -- **Validates: Requirements 4.4**
      
      property.forall(
        {},  -- No generators needed
        function()
          -- Call create_package_config multiple times
          local config1 = package_config.create_package_config()
          local config2 = package_config.create_package_config()
          
          -- Verify configs have same structure
          assert.is_table(config1.aliases)
          assert.is_table(config2.aliases)
          
          -- Verify aliases are equivalent (same keys and values)
          local keys1 = {}
          for k, _ in pairs(config1.aliases) do
            table.insert(keys1, k)
          end
          
          local keys2 = {}
          for k, _ in pairs(config2.aliases) do
            table.insert(keys2, k)
          end
          
          table.sort(keys1)
          table.sort(keys2)
          
          assert.same(keys1, keys2, "configs should have same alias keys")
          
          -- Verify values match
          for k, v in pairs(config1.aliases) do
            assert.equals(v, config2.aliases[k],
              string.format("alias '%s' should have same value in both configs", k))
          end
          
          -- Verify preload and loaded are empty in both
          local count1 = 0
          for _ in pairs(config1.preload) do count1 = count1 + 1 end
          assert.equals(0, count1, "config1.preload should be empty")
          
          local count2 = 0
          for _ in pairs(config2.preload) do count2 = count2 + 1 end
          assert.equals(0, count2, "config2.preload should be empty")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should not perform I/O operations", function()
      -- **Validates: Requirements 4.4**
      
      property.forall(
        {},  -- No generators needed
        function()
          -- Track I/O operations
          local io_operations = {}
          
          -- Mock io functions
          local original_io = {
            write = io.write,
            read = io.read,
            open = io.open,
            close = io.close
          }
          
          io.write = function(...) table.insert(io_operations, {'write', ...}) end
          io.read = function(...) table.insert(io_operations, {'read', ...}) end
          io.open = function(...) table.insert(io_operations, {'open', ...}) end
          io.close = function(...) table.insert(io_operations, {'close', ...}) end
          
          -- Call create_package_config
          local config = package_config.create_package_config()
          
          -- Restore io functions
          io.write = original_io.write
          io.read = original_io.read
          io.open = original_io.open
          io.close = original_io.close
          
          -- Verify no I/O operations occurred
          assert.equals(0, #io_operations,
            string.format("create_package_config should not perform I/O operations, but performed: %s",
              table.concat(io_operations, ', ')))
          
          -- Verify config is valid
          assert.is_table(config.aliases)
        end,
        { iterations = 100 }
      )
    end)
    
    it("should not call require() during config creation", function()
      -- **Validates: Requirements 4.4**
      
      property.forall(
        {},  -- No generators needed
        function()
          -- Track require calls
          local require_calls = {}
          local original_require = require
          
          -- Mock require to track calls
          _G.require = function(module_name)
            -- Allow loading of package_config itself and property framework
            if module_name == 'spec.package_config' or 
               module_name == 'spec.property' then
              return original_require(module_name)
            end
            
            -- Track other require calls
            table.insert(require_calls, module_name)
            return original_require(module_name)
          end
          
          -- Call create_package_config
          local config = package_config.create_package_config()
          
          -- Restore require
          _G.require = original_require
          
          -- Verify no unexpected require calls
          assert.equals(0, #require_calls,
            string.format("create_package_config should not call require(), but called: %s",
              table.concat(require_calls, ', ')))
          
          -- Verify config is valid
          assert.is_table(config.aliases)
          assert.is_true(next(config.aliases) ~= nil)
        end,
        { iterations = 100 }
      )
    end)
  end)
end)
