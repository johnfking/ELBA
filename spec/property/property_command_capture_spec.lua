--
-- Property tests for Command Capture Accumulation
-- Feature: functional-refactoring
-- Task 9.2: Write property tests for command capture accumulation
--

describe("Command Capture Accumulation", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local mq

  before_each(function()
    -- Reload mq_stub to get fresh state
    package.loaded['mq_stub'] = nil
    mq = require('LuaBots.mq_stub')
  end)

  describe("Property 14: Command Capture Accumulation", function()
    it("should capture all commands in order", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          property.integer(1, 20)  -- number of commands to generate
        },
        function(num_commands)
          -- Enable capture mode
          mq.enable_capture()

          -- Generate and send commands
          local expected_commands = {}
          for i = 1, num_commands do
            local cmd = string.format("test_command_%d", i)
            table.insert(expected_commands, cmd)
            mq.cmd(cmd)
          end

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify all commands were captured
          assert.equals(num_commands, #captured,
            string.format("Should capture %d commands, got %d", num_commands, #captured))

          -- Verify commands are in correct order
          for i = 1, num_commands do
            assert.equals(expected_commands[i], captured[i],
              string.format("Command %d should be '%s', got '%s'",
                i, expected_commands[i], captured[i]))
          end

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should accumulate commands with various content", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.string_parameter(),
          generators.string_parameter()
        },
        function(cmd1, cmd2, cmd3)
          -- Enable capture mode
          mq.enable_capture()

          -- Send commands with different content
          mq.cmd(cmd1)
          mq.cmd(cmd2)
          mq.cmd(cmd3)

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify all commands captured
          assert.equals(3, #captured, "Should capture 3 commands")

          -- Verify order and content
          assert.equals(cmd1, captured[1], "First command should match")
          assert.equals(cmd2, captured[2], "Second command should match")
          assert.equals(cmd3, captured[3], "Third command should match")

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should accumulate formatted commands via cmdf", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          generators.string_parameter(),
          property.integer(1, 100),
          generators.string_parameter()
        },
        function(str1, num, str2)
          -- Enable capture mode
          mq.enable_capture()

          -- Send formatted commands
          mq.cmdf("command %s", str1)
          mq.cmdf("value %d", num)
          mq.cmdf("text %s %d", str2, num)

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify all commands captured
          assert.equals(3, #captured, "Should capture 3 formatted commands")

          -- Verify formatted content
          assert.equals(string.format("command %s", str1), captured[1],
            "First formatted command should match")
          assert.equals(string.format("value %d", num), captured[2],
            "Second formatted command should match")
          assert.equals(string.format("text %s %d", str2, num), captured[3],
            "Third formatted command should match")

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should accumulate mixed cmd and cmdf calls", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          generators.string_parameter(),
          property.integer(1, 100),
          generators.string_parameter()
        },
        function(str1, num, str2)
          -- Enable capture mode
          mq.enable_capture()

          -- Mix cmd and cmdf calls
          mq.cmd(str1)
          mq.cmdf("formatted %d", num)
          mq.cmd(str2)
          mq.cmdf("another %s %d", str1, num)

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify all commands captured in order
          assert.equals(4, #captured, "Should capture 4 commands")
          assert.equals(str1, captured[1], "First command should be plain string")
          assert.equals(string.format("formatted %d", num), captured[2],
            "Second command should be formatted")
          assert.equals(str2, captured[3], "Third command should be plain string")
          assert.equals(string.format("another %s %d", str1, num), captured[4],
            "Fourth command should be formatted")

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain order across multiple capture sessions", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          property.integer(1, 10),
          property.integer(1, 10)
        },
        function(session1_count, session2_count)
          -- First capture session
          mq.enable_capture()
          local session1_commands = {}
          for i = 1, session1_count do
            local cmd = string.format("session1_cmd_%d", i)
            session1_commands[i] = cmd
            mq.cmd(cmd)
          end

          local captured1 = mq.get_captured_commands()
          assert.equals(session1_count, #captured1,
            "First session should capture correct number of commands")

          -- Verify first session order
          for i = 1, session1_count do
            assert.equals(session1_commands[i], captured1[i],
              string.format("Session 1 command %d should match", i))
          end

          -- Clear and start second session
          mq.clear_captured_commands()
          local session2_commands = {}
          for i = 1, session2_count do
            local cmd = string.format("session2_cmd_%d", i)
            session2_commands[i] = cmd
            mq.cmd(cmd)
          end

          local captured2 = mq.get_captured_commands()
          assert.equals(session2_count, #captured2,
            "Second session should capture correct number of commands")

          -- Verify second session order
          for i = 1, session2_count do
            assert.equals(session2_commands[i], captured2[i],
              string.format("Session 2 command %d should match", i))
          end

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should preserve command content exactly", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          property.string(1, 50, 'abcdefghijklmnopqrstuvwxyz0123456789 !@#$%^&*()_+-=[]{}|;:,.<>?')
        },
        function(complex_cmd)
          -- Enable capture mode
          mq.enable_capture()

          -- Send command with special characters
          mq.cmd(complex_cmd)

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify exact content preservation
          assert.equals(1, #captured, "Should capture 1 command")
          assert.equals(complex_cmd, captured[1],
            "Command content should be preserved exactly")

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should handle empty command strings", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          property.integer(1, 5)
        },
        function(num_empty)
          -- Enable capture mode
          mq.enable_capture()

          -- Send empty commands
          for i = 1, num_empty do
            mq.cmd("")
          end

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify all empty commands captured
          assert.equals(num_empty, #captured,
            string.format("Should capture %d empty commands", num_empty))

          -- Verify all are empty strings
          for i = 1, num_empty do
            assert.equals("", captured[i],
              string.format("Command %d should be empty string", i))
          end

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 100 }
      )
    end)

    it("should accumulate commands without limit", function()
      -- **Validates: Requirements 10.2**

      property.forall(
        {
          property.integer(50, 200)  -- test with larger numbers
        },
        function(num_commands)
          -- Enable capture mode
          mq.enable_capture()

          -- Generate many commands
          for i = 1, num_commands do
            mq.cmd(string.format("cmd_%d", i))
          end

          -- Get captured commands
          local captured = mq.get_captured_commands()

          -- Verify all commands captured
          assert.equals(num_commands, #captured,
            string.format("Should capture all %d commands", num_commands))

          -- Verify order is maintained
          for i = 1, num_commands do
            assert.equals(string.format("cmd_%d", i), captured[i],
              string.format("Command %d should be in correct position", i))
          end

          -- Cleanup
          mq.disable_capture()
        end,
        { iterations = 50 }  -- fewer iterations for larger command counts
      )
    end)
  end)
end)
