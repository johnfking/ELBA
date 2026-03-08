--
-- Property tests for Command String Format
-- Feature: functional-refactoring
-- Task 1.5: Write property tests for command string format
--

describe("Command String Format", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local CommandBuilder = require('LuaBots.CommandBuilder')

  describe("Property 3: Command String Format", function()
    it("should match /say ^<command> [params] format for single-parameter builders", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.string_parameter(),  -- value parameter
          generators.any_actionable()     -- actionable parameter
        },
        function(value, act)
          -- Test single-parameter builders
          local builders = {
            { fn = CommandBuilder.build_stance, cmd = 'stance' },
            { fn = CommandBuilder.build_attack, cmd = 'attack' },
            { fn = CommandBuilder.build_guard, cmd = 'guard' },
            { fn = CommandBuilder.build_follow, cmd = 'follow' },
            { fn = CommandBuilder.build_hold, cmd = 'hold' },
            { fn = CommandBuilder.build_cast, cmd = 'cast' },
            { fn = CommandBuilder.build_taunt, cmd = 'taunt' },
            { fn = CommandBuilder.build_defensive, cmd = 'defensive' },
            { fn = CommandBuilder.build_discipline, cmd = 'discipline' },
            { fn = CommandBuilder.build_charm, cmd = 'charm' },
            { fn = CommandBuilder.build_cure, cmd = 'cure' }
          }

          for _, builder_info in ipairs(builders) do
            local result = builder_info.fn(value, act)

            -- Verify result is a string
            assert.is_string(result, "Builder should return a string")

            -- Verify format starts with /say ^<command>
            local expected_prefix = '/say ^' .. builder_info.cmd
            assert.is_true(result:sub(1, #expected_prefix) == expected_prefix,
              string.format("Command should start with '%s', got: %s", expected_prefix, result))

            -- Verify parameters are properly formatted
            -- Format should be: /say ^<command> [value] [actionable]
            local parts = {}
            for part in result:gmatch("%S+") do
              table.insert(parts, part)
            end

            -- First two parts should be "/say" and "^<command>"
            assert.equals('/say', parts[1], "First part should be '/say'")
            assert.equals('^' .. builder_info.cmd, parts[2],
              string.format("Second part should be '^%s'", builder_info.cmd))

            -- Remaining parts should be value and/or actionable (if provided)
            -- We don't check exact content since value and actionable can vary
            -- but we verify the structure is correct
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should match /say ^botcreate <name> <class> <race> <gender> format", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          local result = CommandBuilder.build_botcreate(name, class, race, gender)

          -- Verify result is a string
          assert.is_string(result, "build_botcreate should return a string")

          -- Verify format starts with /say ^botcreate
          assert.is_true(result:find('^/say %^botcreate ') ~= nil,
            string.format("Command should start with '/say ^botcreate ', got: %s", result))

          -- Verify all parameters are present
          local expected = string.format("/say ^botcreate %s %d %d %d", name, class, race, gender)
          assert.equals(expected, result,
            "botcreate command should match expected format")
        end,
        { iterations = 100 }
      )
    end)

    it("should match format for multi-parameter builders", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.any_actionable()
        },
        function(val1, val2, val3, act)
          -- Test botdyearmor builder (4 numeric params + actionable)
          local result1 = CommandBuilder.build_botdyearmor(val1, val2, val3, 100, act)

          assert.is_string(result1, "build_botdyearmor should return a string")
          assert.is_true(result1:find('^/say %^botdyearmor') ~= nil,
            string.format("Command should start with '/say ^botdyearmor', got: %s", result1))

          -- Test spelldelays builder (2 params + actionable)
          local result2 = CommandBuilder.build_spelldelays(val1, val2, act)

          assert.is_string(result2, "build_spelldelays should return a string")
          assert.is_true(result2:find('^/say %^spelldelays') ~= nil,
            string.format("Command should start with '/say ^spelldelays', got: %s", result2))

          -- Test spellholds builder (2 params + actionable)
          local result3 = CommandBuilder.build_spellholds(val1, val2, act)

          assert.is_string(result3, "build_spellholds should return a string")
          assert.is_true(result3:find('^/say %^spellholds') ~= nil,
            string.format("Command should start with '/say ^spellholds', got: %s", result3))
        end,
        { iterations = 100 }
      )
    end)

    it("should handle nil parameters correctly in format", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.any_actionable()
        },
        function(act)
          -- Test with nil value parameter
          local result1 = CommandBuilder.build_stance(nil, act)

          assert.is_string(result1, "Builder should return a string with nil value")
          assert.is_true(result1:sub(1, 12) == '/say ^stance',
            "Command should start with '/say ^stance'")

          -- Test with nil actionable
          local result2 = CommandBuilder.build_attack('on', nil)

          assert.is_string(result2, "Builder should return a string with nil actionable")
          assert.is_true(result2:sub(1, 12) == '/say ^attack',
            "Command should start with '/say ^attack'")

          -- Test with both nil
          local result3 = CommandBuilder.build_guard(nil, nil)

          assert.is_string(result3, "Builder should return a string with both nil")
          assert.equals('/say ^guard', result3,
            "Command with both nil should be just '/say ^guard'")
        end,
        { iterations = 100 }
      )
    end)

    it("should verify format consistency across all single-parameter builders", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Comprehensive list of single-parameter builders
          local builders = {
            { fn = CommandBuilder.build_stance, cmd = 'stance' },
            { fn = CommandBuilder.build_attack, cmd = 'attack' },
            { fn = CommandBuilder.build_guard, cmd = 'guard' },
            { fn = CommandBuilder.build_follow, cmd = 'follow' },
            { fn = CommandBuilder.build_hold, cmd = 'hold' },
            { fn = CommandBuilder.build_release, cmd = 'release' },
            { fn = CommandBuilder.build_taunt, cmd = 'taunt' },
            { fn = CommandBuilder.build_charm, cmd = 'charm' },
            { fn = CommandBuilder.build_cure, cmd = 'cure' },
            { fn = CommandBuilder.build_defensive, cmd = 'defensive' },
            { fn = CommandBuilder.build_discipline, cmd = 'discipline' },
            { fn = CommandBuilder.build_cast, cmd = 'cast' },
            { fn = CommandBuilder.build_pull, cmd = 'pull' },
            { fn = CommandBuilder.build_behindmob, cmd = 'behindmob' },
            { fn = CommandBuilder.build_circle, cmd = 'circle' },
            { fn = CommandBuilder.build_depart, cmd = 'depart' },
            { fn = CommandBuilder.build_escape, cmd = 'escape' }
          }

          for _, builder_info in ipairs(builders) do
            local result = builder_info.fn(value, act)

            -- Verify string type
            assert.is_string(result, string.format("%s should return a string", builder_info.cmd))

            -- Verify /say ^<command> prefix
            local expected_prefix = '/say ^' .. builder_info.cmd
            local actual_prefix = result:sub(1, #expected_prefix)
            assert.equals(expected_prefix, actual_prefix,
              string.format("Command should start with '%s'", expected_prefix))

            -- Verify no extra whitespace or malformed structure at the command level
            -- Note: Actionable selectors may contain spaces (including trailing ones from user input)
            -- We only check that the command structure itself is correct
            assert.is_nil(result:match('^ '), "Command should not start with space")
            assert.is_nil(result:match('^/say  '), "Should not have double space after /say")
            -- We don't check for trailing spaces since selectors may legitimately have them
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should verify command name is properly formatted with caret prefix", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          local builders = {
            { fn = CommandBuilder.build_applypoison, cmd = 'applypoison' },
            { fn = CommandBuilder.build_bindaffinity, cmd = 'bindaffinity' },
            { fn = CommandBuilder.build_botcamp, cmd = 'botcamp' },
            { fn = CommandBuilder.build_botdelete, cmd = 'botdelete' },
            { fn = CommandBuilder.build_botspawn, cmd = 'botspawn' },
            { fn = CommandBuilder.build_help, cmd = 'help' },
            { fn = CommandBuilder.build_invisibility, cmd = 'invisibility' },
            { fn = CommandBuilder.build_levitation, cmd = 'levitation' },
            { fn = CommandBuilder.build_mesmerize, cmd = 'mesmerize' },
            { fn = CommandBuilder.build_portal, cmd = 'portal' }
          }

          for _, builder_info in ipairs(builders) do
            local result = builder_info.fn(value, act)

            -- Extract the command part (second token)
            local parts = {}
            for part in result:gmatch("%S+") do
              table.insert(parts, part)
            end

            -- Verify second part has caret prefix
            assert.is_true(#parts >= 2, "Command should have at least 2 parts")
            assert.equals('^' .. builder_info.cmd, parts[2],
              string.format("Command name should be '^%s'", builder_info.cmd))
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should verify parameters are space-separated and properly ordered", function()
      -- **Validates: Requirements 1.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          local result = CommandBuilder.build_stance(value, act)

          -- Split by spaces
          local parts = {}
          for part in result:gmatch("%S+") do
            table.insert(parts, part)
          end

          -- Verify structure: /say ^stance [value] [actionable]
          assert.equals('/say', parts[1], "First part should be '/say'")
          assert.equals('^stance', parts[2], "Second part should be '^stance'")

          -- If value is provided, it should be the third part
          if value ~= nil then
            assert.equals(tostring(value), parts[3],
              "Third part should be the value parameter")
          end

          -- If actionable is provided, it should be after value (or third if no value)
          if act ~= nil then
            local act_str = tostring(act)
            local found = false
            for i = 3, #parts do
              if parts[i] == act_str or result:find(act_str, 1, true) then
                found = true
                break
              end
            end
            assert.is_true(found, "Actionable should be present in command")
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should verify all builders produce valid command strings", function()
      -- **Validates: Requirements 1.2**

      -- Test a comprehensive set of builders with various parameter combinations
      local test_cases = {
        { fn = CommandBuilder.build_stance, args = {'Passive', nil}, cmd = 'stance' },
        { fn = CommandBuilder.build_attack, args = {'on', nil}, cmd = 'attack' },
        { fn = CommandBuilder.build_botcreate, args = {'TestBot', 1, 1, 0}, cmd = 'botcreate' },
        { fn = CommandBuilder.build_guard, args = {nil, nil}, cmd = 'guard' },
        { fn = CommandBuilder.build_follow, args = {'me', nil}, cmd = 'follow' },
        { fn = CommandBuilder.build_hold, args = {'on', nil}, cmd = 'hold' },
        { fn = CommandBuilder.build_cast, args = {'heal', nil}, cmd = 'cast' },
        { fn = CommandBuilder.build_taunt, args = {'on', nil}, cmd = 'taunt' }
      }

      for _, test_case in ipairs(test_cases) do
        local result = test_case.fn(table.unpack(test_case.args))

        -- Verify basic format
        assert.is_string(result, string.format("%s should return a string", test_case.cmd))
        assert.is_true(result:sub(1, 5) == '/say ', "Command should start with '/say '")
        assert.is_true(result:find('^' .. test_case.cmd, 1, true) ~= nil,
          string.format("Command should contain '^%s'", test_case.cmd))

        -- Verify no malformed structure
        assert.is_nil(result:match('^/say  '), "Should not have double space after /say")
        assert.is_nil(result:match('  '), "Should not contain double spaces")
      end
    end)
  end)
end)
