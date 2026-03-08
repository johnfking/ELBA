--
-- Property tests for Build-Execute Equivalence
-- Feature: functional-refactoring
-- Task 4.5: Write property tests for build-execute equivalence
--

describe("Build-Execute Equivalence", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local CommandBuilder = require('LuaBots.CommandBuilder')
  local CommandExecutor = require('LuaBots.CommandExecutor')
  local mq = require('LuaBots.mq')

  describe("Property 4: Build-Execute Equivalence", function()
    it("should produce same mq.cmd call for single-parameter builders", function()
      -- **Validates: Requirements 1.4, 7.2**

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
            -- Clear captured commands
            mq.enable_capture()
            mq.clear_captured_commands()

            -- Execute using builder + executor (refactored approach)
            local cmd_string = builder_info.fn(value, act)
            CommandExecutor.execute(cmd_string)

            -- Get the captured command
            local captured = mq.get_captured_commands()
            assert.equals(1, #captured, "Should capture exactly one command")
            local refactored_cmd = captured[1]

            -- Clear for next test
            mq.clear_captured_commands()

            -- Execute using original implementation (direct construction)
            local parts = { '/say ^' .. builder_info.cmd }
            if value ~= nil then table.insert(parts, tostring(value)) end
            if act ~= nil then table.insert(parts, tostring(act)) end
            local original_cmd = table.concat(parts, ' ')
            mq.cmd(original_cmd)

            -- Get the captured command from original approach
            local captured_original = mq.get_captured_commands()
            assert.equals(1, #captured_original, "Should capture exactly one command from original")
            local original_result = captured_original[1]

            -- Verify both approaches produce identical mq.cmd calls
            assert.equals(original_result, refactored_cmd,
              string.format("Builder + executor should produce same command as original for %s", builder_info.cmd))

            mq.disable_capture()
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should produce same mq.cmd call for botcreate", function()
      -- **Validates: Requirements 1.4, 7.2**

      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          -- Enable capture mode
          mq.enable_capture()
          mq.clear_captured_commands()

          -- Execute using builder + executor (refactored approach)
          local cmd_string = CommandBuilder.build_botcreate(name, class, race, gender)
          CommandExecutor.execute(cmd_string)

          -- Get the captured command
          local captured = mq.get_captured_commands()
          assert.equals(1, #captured, "Should capture exactly one command")
          local refactored_cmd = captured[1]

          -- Clear for next test
          mq.clear_captured_commands()

          -- Execute using original implementation
          local original_cmd = string.format("/say ^botcreate %s %d %d %d", name, class, race, gender)
          mq.cmd(original_cmd)

          -- Get the captured command from original approach
          local captured_original = mq.get_captured_commands()
          assert.equals(1, #captured_original, "Should capture exactly one command from original")
          local original_result = captured_original[1]

          -- Verify both approaches produce identical mq.cmd calls
          assert.equals(original_result, refactored_cmd,
            "Builder + executor should produce same botcreate command as original")

          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should produce same mq.cmd call for multi-parameter builders", function()
      -- **Validates: Requirements 1.4, 7.2**

      property.forall(
        {
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.any_actionable()
        },
        function(val1, val2, val3, act)
          -- Enable capture mode
          mq.enable_capture()

          -- Test botdyearmor builder (4 numeric params + actionable)
          mq.clear_captured_commands()
          local cmd1 = CommandBuilder.build_botdyearmor(val1, val2, val3, 100, act)
          CommandExecutor.execute(cmd1)
          local captured1 = mq.get_captured_commands()
          assert.equals(1, #captured1, "Should capture exactly one command for botdyearmor")
          local refactored_cmd1 = captured1[1]

          -- Original implementation for botdyearmor
          mq.clear_captured_commands()
          local value = val1 .. ' ' .. val2 .. ' ' .. val3 .. ' ' .. 100
          local parts = { '/say ^botdyearmor', value }
          if act ~= nil then table.insert(parts, tostring(act)) end
          local original_cmd1 = table.concat(parts, ' ')
          mq.cmd(original_cmd1)
          local captured_original1 = mq.get_captured_commands()
          assert.equals(original_cmd1, refactored_cmd1,
            "Builder + executor should produce same botdyearmor command as original")

          -- Test spelldelays builder (2 params + actionable)
          mq.clear_captured_commands()
          local cmd2 = CommandBuilder.build_spelldelays(val1, val2, act)
          CommandExecutor.execute(cmd2)
          local captured2 = mq.get_captured_commands()
          assert.equals(1, #captured2, "Should capture exactly one command for spelldelays")
          local refactored_cmd2 = captured2[1]

          -- Original implementation for spelldelays
          mq.clear_captured_commands()
          local parts2 = { '/say ^spelldelays' }
          if val1 ~= nil then table.insert(parts2, tostring(val1)) end
          if val2 ~= nil then table.insert(parts2, tostring(val2)) end
          if act ~= nil then table.insert(parts2, tostring(act)) end
          local original_cmd2 = table.concat(parts2, ' ')
          mq.cmd(original_cmd2)
          local captured_original2 = mq.get_captured_commands()
          assert.equals(original_cmd2, refactored_cmd2,
            "Builder + executor should produce same spelldelays command as original")

          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should produce same mq.cmd call with nil parameters", function()
      -- **Validates: Requirements 1.4, 7.2**

      property.forall(
        {
          generators.any_actionable()
        },
        function(act)
          -- Enable capture mode
          mq.enable_capture()

          -- Test with nil value parameter
          mq.clear_captured_commands()
          local cmd1 = CommandBuilder.build_stance(nil, act)
          CommandExecutor.execute(cmd1)
          local captured1 = mq.get_captured_commands()
          assert.equals(1, #captured1, "Should capture exactly one command")
          local refactored_cmd1 = captured1[1]

          -- Original implementation with nil value
          mq.clear_captured_commands()
          local parts1 = { '/say ^stance' }
          if act ~= nil then table.insert(parts1, tostring(act)) end
          local original_cmd1 = table.concat(parts1, ' ')
          mq.cmd(original_cmd1)
          local captured_original1 = mq.get_captured_commands()
          assert.equals(original_cmd1, refactored_cmd1,
            "Builder + executor should produce same command with nil value")

          -- Test with nil actionable
          mq.clear_captured_commands()
          local cmd2 = CommandBuilder.build_attack('on', nil)
          CommandExecutor.execute(cmd2)
          local captured2 = mq.get_captured_commands()
          assert.equals(1, #captured2, "Should capture exactly one command")
          local refactored_cmd2 = captured2[1]

          -- Original implementation with nil actionable
          mq.clear_captured_commands()
          local original_cmd2 = '/say ^attack on'
          mq.cmd(original_cmd2)
          local captured_original2 = mq.get_captured_commands()
          assert.equals(original_cmd2, refactored_cmd2,
            "Builder + executor should produce same command with nil actionable")

          -- Test with both nil
          mq.clear_captured_commands()
          local cmd3 = CommandBuilder.build_guard(nil, nil)
          CommandExecutor.execute(cmd3)
          local captured3 = mq.get_captured_commands()
          assert.equals(1, #captured3, "Should capture exactly one command")
          local refactored_cmd3 = captured3[1]

          -- Original implementation with both nil
          mq.clear_captured_commands()
          local original_cmd3 = '/say ^guard'
          mq.cmd(original_cmd3)
          local captured_original3 = mq.get_captured_commands()
          assert.equals(original_cmd3, refactored_cmd3,
            "Builder + executor should produce same command with both nil")

          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should produce same mq.cmd call across all command types", function()
      -- **Validates: Requirements 1.4, 7.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Comprehensive list of builders to test
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
            { fn = CommandBuilder.build_escape, cmd = 'escape' },
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

          -- Enable capture mode
          mq.enable_capture()

          for _, builder_info in ipairs(builders) do
            -- Test refactored approach
            mq.clear_captured_commands()
            local cmd_string = builder_info.fn(value, act)
            CommandExecutor.execute(cmd_string)
            local captured = mq.get_captured_commands()
            assert.equals(1, #captured, string.format("Should capture exactly one command for %s", builder_info.cmd))
            local refactored_cmd = captured[1]

            -- Test original approach
            mq.clear_captured_commands()
            local parts = { '/say ^' .. builder_info.cmd }
            if value ~= nil then table.insert(parts, tostring(value)) end
            if act ~= nil then table.insert(parts, tostring(act)) end
            local original_cmd = table.concat(parts, ' ')
            mq.cmd(original_cmd)
            local captured_original = mq.get_captured_commands()
            assert.equals(1, #captured_original, string.format("Should capture exactly one command from original for %s", builder_info.cmd))
            local original_result = captured_original[1]

            -- Verify equivalence
            assert.equals(original_result, refactored_cmd,
              string.format("Builder + executor should produce same command as original for %s", builder_info.cmd))
          end

          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should verify round-trip property: build then execute equals direct execution", function()
      -- **Validates: Requirements 1.4, 7.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Enable capture mode
          mq.enable_capture()
          mq.clear_captured_commands()

          -- Approach 1: Build command string, then execute it
          local built_cmd = CommandBuilder.build_stance(value, act)
          CommandExecutor.execute(built_cmd)
          local captured_refactored = mq.get_captured_commands()

          -- Approach 2: Direct execution (what original code would do)
          mq.clear_captured_commands()
          local parts = { '/say ^stance' }
          if value ~= nil then table.insert(parts, tostring(value)) end
          if act ~= nil then table.insert(parts, tostring(act)) end
          mq.cmd(table.concat(parts, ' '))
          local captured_direct = mq.get_captured_commands()

          -- Verify round-trip: both approaches result in same mq.cmd call
          assert.equals(1, #captured_refactored, "Refactored approach should capture one command")
          assert.equals(1, #captured_direct, "Direct approach should capture one command")
          assert.equals(captured_direct[1], captured_refactored[1],
            "Round-trip property: build + execute should equal direct execution")

          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)
  end)
end)
