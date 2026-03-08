--
-- Property tests for Package Configuration Round-Trip
-- Feature: functional-refactoring
-- Task 8.4: Write property tests for package configuration round-trip
--

describe("Package Configuration Round-Trip", function()
  local property = require('spec.property')
  local package_config

  setup(function()
    package_config = require('spec.package_config')
  end)

  describe("Property 10: Package Configuration Round-Trip", function()
    it("should restore package.preload to original state after apply and restore", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed - testing the round-trip property
        function()
          -- Capture initial package.preload state
          local initial_preload = {}
          local initial_keys = {}

          for k, v in pairs(package.preload) do
            initial_preload[k] = v
            table.insert(initial_keys, k)
          end

          -- Create and apply configuration
          local config = package_config.create_package_config()
          local backup = package_config.apply_package_config(config)

          -- Verify state changed (sanity check)
          local changed = false
          for alias, _ in pairs(config.aliases) do
            if package.preload[alias] ~= initial_preload[alias] then
              changed = true
              break
            end
          end
          assert.is_true(changed, "package.preload should be modified after apply")

          -- Restore configuration
          package_config.restore_package_config(backup)

          -- Verify all original keys have their original values
          for k, v in pairs(initial_preload) do
            assert.equals(v, package.preload[k],
              string.format("package.preload['%s'] should be restored to original value", k))
          end

          -- Verify no extra keys were added
          local current_keys = {}
          for k, _ in pairs(package.preload) do
            table.insert(current_keys, k)
          end

          table.sort(initial_keys)
          table.sort(current_keys)

          assert.equals(#initial_keys, #current_keys,
            "package.preload should have same number of keys after restore")

          for i = 1, #initial_keys do
            assert.equals(initial_keys[i], current_keys[i],
              "package.preload keys should be identical after restore")
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should handle nil entries correctly in round-trip", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Create a test alias that doesn't exist
          local test_alias = 'test.roundtrip.nil.alias.' .. math.random(1000000)
          package.preload[test_alias] = nil

          -- Verify it's nil
          assert.is_nil(package.preload[test_alias], "test alias should start as nil")

          -- Create config with this alias
          local config = {
            aliases = { [test_alias] = 'Actionable' },
            preload = {},
            loaded = {}
          }

          -- Apply configuration
          local backup = package_config.apply_package_config(config)

          -- Verify alias is now a function
          assert.is_function(package.preload[test_alias],
            "test alias should be a function after apply")

          -- Restore configuration
          package_config.restore_package_config(backup)

          -- Verify alias is nil again
          assert.is_nil(package.preload[test_alias],
            "test alias should be nil after restore")
        end,
        { iterations = 100 }
      )
    end)

    it("should handle existing entries correctly in round-trip", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Create a test alias with an original loader
          local test_alias = 'test.roundtrip.existing.alias.' .. math.random(1000000)
          local original_loader = function() return 'original_value_' .. math.random(1000) end
          package.preload[test_alias] = original_loader

          -- Create config with this alias
          local config = {
            aliases = { [test_alias] = 'Actionable' },
            preload = {},
            loaded = {}
          }

          -- Apply configuration
          local backup = package_config.apply_package_config(config)

          -- Verify alias is now a different function
          assert.is_function(package.preload[test_alias],
            "test alias should be a function after apply")
          assert.is_not.equals(original_loader, package.preload[test_alias],
            "test alias should be a different function after apply")

          -- Restore configuration
          package_config.restore_package_config(backup)

          -- Verify original loader is restored
          assert.equals(original_loader, package.preload[test_alias],
            "original loader should be restored")

          -- Cleanup
          package.preload[test_alias] = nil
        end,
        { iterations = 100 }
      )
    end)

    it("should handle multiple aliases correctly in round-trip", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Create multiple test aliases with different states
          local test_aliases = {}
          local original_loaders = {}

          for i = 1, 5 do
            local alias = 'test.roundtrip.multi.' .. i .. '.' .. math.random(1000000)
            test_aliases[i] = alias

            if i % 2 == 0 then
              -- Even indices: existing loaders
              original_loaders[alias] = function() return 'original_' .. i end
              package.preload[alias] = original_loaders[alias]
            else
              -- Odd indices: nil entries
              original_loaders[alias] = nil
              package.preload[alias] = nil
            end
          end

          -- Create config with all test aliases
          local config = {
            aliases = {},
            preload = {},
            loaded = {}
          }

          for i, alias in ipairs(test_aliases) do
            config.aliases[alias] = 'Actionable'
          end

          -- Apply configuration
          local backup = package_config.apply_package_config(config)

          -- Verify all aliases are now functions
          for _, alias in ipairs(test_aliases) do
            assert.is_function(package.preload[alias],
              string.format("alias '%s' should be a function after apply", alias))
          end

          -- Restore configuration
          package_config.restore_package_config(backup)

          -- Verify all original states are restored
          for alias, original_loader in pairs(original_loaders) do
            if original_loader == nil then
              assert.is_nil(package.preload[alias],
                string.format("alias '%s' should be nil after restore", alias))
            else
              assert.equals(original_loader, package.preload[alias],
                string.format("alias '%s' should have original loader after restore", alias))
            end
          end

          -- Cleanup
          for _, alias in ipairs(test_aliases) do
            package.preload[alias] = nil
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should be idempotent - multiple apply/restore cycles work correctly", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Capture initial state
          local initial_preload = {}
          for k, v in pairs(package.preload) do
            initial_preload[k] = v
          end

          -- Perform multiple apply/restore cycles
          for cycle = 1, 3 do
            local config = package_config.create_package_config()
            local backup = package_config.apply_package_config(config)
            package_config.restore_package_config(backup)

            -- Verify state is restored after each cycle
            for k, v in pairs(initial_preload) do
              assert.equals(v, package.preload[k],
                string.format("package.preload['%s'] should be restored after cycle %d", k, cycle))
            end
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should not affect package.loaded during round-trip", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Capture initial package.loaded state
          local initial_loaded = {}
          local initial_loaded_keys = {}

          for k, v in pairs(package.loaded) do
            initial_loaded[k] = v
            table.insert(initial_loaded_keys, k)
          end

          -- Apply and restore configuration
          local config = package_config.create_package_config()
          local backup = package_config.apply_package_config(config)
          package_config.restore_package_config(backup)

          -- Verify package.loaded is unchanged
          for k, v in pairs(initial_loaded) do
            assert.equals(v, package.loaded[k],
              string.format("package.loaded['%s'] should not be affected by round-trip", k))
          end

          -- Verify no new entries in package.loaded
          local current_loaded_keys = {}
          for k, _ in pairs(package.loaded) do
            table.insert(current_loaded_keys, k)
          end

          table.sort(initial_loaded_keys)
          table.sort(current_loaded_keys)

          assert.equals(#initial_loaded_keys, #current_loaded_keys,
            "package.loaded should have same number of keys after round-trip")
        end,
        { iterations = 100 }
      )
    end)

    it("should handle nested apply/restore operations correctly", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Capture initial state
          local initial_preload = {}
          for k, v in pairs(package.preload) do
            initial_preload[k] = v
          end

          -- Apply first configuration
          local config1 = package_config.create_package_config()
          local backup1 = package_config.apply_package_config(config1)

          -- Apply second configuration (nested)
          local test_alias = 'test.nested.alias.' .. math.random(1000000)
          local config2 = {
            aliases = { [test_alias] = 'Actionable' },
            preload = {},
            loaded = {}
          }
          local backup2 = package_config.apply_package_config(config2)

          -- Restore second configuration
          package_config.restore_package_config(backup2)

          -- Restore first configuration
          package_config.restore_package_config(backup1)

          -- Verify original state is restored
          for k, v in pairs(initial_preload) do
            assert.equals(v, package.preload[k],
              string.format("package.preload['%s'] should be restored after nested operations", k))
          end

          -- Cleanup
          package.preload[test_alias] = nil
        end,
        { iterations = 100 }
      )
    end)

    it("should preserve function identity for unchanged entries", function()
      -- **Validates: Requirements 4.3**

      property.forall(
        {},  -- No generators needed
        function()
          -- Find an existing entry in package.preload that won't be modified
          local unmodified_key = nil
          local unmodified_value = nil

          for k, v in pairs(package.preload) do
            -- Find a key that's not in the config aliases
            local config = package_config.create_package_config()
            local is_modified = false
            for alias, _ in pairs(config.aliases) do
              if alias == k then
                is_modified = true
                break
              end
            end

            if not is_modified then
              unmodified_key = k
              unmodified_value = v
              break
            end
          end

          if unmodified_key then
            -- Apply and restore configuration
            local config = package_config.create_package_config()
            local backup = package_config.apply_package_config(config)
            package_config.restore_package_config(backup)

            -- Verify unmodified entry has exact same value (identity preserved)
            assert.equals(unmodified_value, package.preload[unmodified_key],
              string.format("unmodified entry '%s' should preserve identity", unmodified_key))
          end
        end,
        { iterations = 100 }
      )
    end)
  end)
end)
