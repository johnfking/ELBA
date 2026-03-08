-- Unit tests for CommandExecutor module (Task 2.2)
-- These tests verify that the CommandExecutor correctly calls mq.cmd() and mq.cmdf()

local CommandExecutor = require('LuaBots.CommandExecutor')
local test_helpers = require('spec.test_helpers')
local capture = test_helpers.capture

describe('CommandExecutor Module - Task 2.2 Verification', function()

  describe('execute', function()
    it('calls mq.cmd with the correct command string', function()
      local cmd_string = '/say ^stance Passive'
      
      local output = capture(function()
        CommandExecutor.execute(cmd_string)
      end)
      
      -- Verify mq.cmd was called with the command (mq_stub writes to stdout)
      assert.are.equal(cmd_string .. '\n', output)
    end)

    it('handles simple commands without parameters', function()
      local cmd_string = '/say ^attack'
      
      local output = capture(function()
        CommandExecutor.execute(cmd_string)
      end)
      
      assert.are.equal(cmd_string .. '\n', output)
    end)

    it('handles commands with multiple parameters', function()
      local cmd_string = '/say ^stance Passive byname BotName'
      
      local output = capture(function()
        CommandExecutor.execute(cmd_string)
      end)
      
      assert.are.equal(cmd_string .. '\n', output)
    end)

    it('handles commands with special characters', function()
      local cmd_string = '/say ^botcreate TestBot123 1 2 0'
      
      local output = capture(function()
        CommandExecutor.execute(cmd_string)
      end)
      
      assert.are.equal(cmd_string .. '\n', output)
    end)
  end)

  describe('executef', function()
    it('formats and calls mq.cmdf correctly', function()
      local format_str = '/say ^botcreate %s %d %d %d'
      local name = 'TestBot'
      local class = 1
      local race = 2
      local gender = 0
      
      local output = capture(function()
        CommandExecutor.executef(format_str, name, class, race, gender)
      end)
      
      local expected = string.format(format_str, name, class, race, gender) .. '\n'
      assert.are.equal(expected, output)
    end)

    it('handles format strings with no arguments', function()
      local cmd_string = '/say ^attack'
      
      local output = capture(function()
        CommandExecutor.executef(cmd_string)
      end)
      
      assert.are.equal(cmd_string .. '\n', output)
    end)

    it('handles format strings with string parameters', function()
      local format_str = '/say ^stance %s'
      local value = 'Passive'
      
      local output = capture(function()
        CommandExecutor.executef(format_str, value)
      end)
      
      local expected = string.format(format_str, value) .. '\n'
      assert.are.equal(expected, output)
    end)

    it('handles format strings with numeric parameters', function()
      local format_str = '/say ^guard %d'
      local value = 1
      
      local output = capture(function()
        CommandExecutor.executef(format_str, value)
      end)
      
      local expected = string.format(format_str, value) .. '\n'
      assert.are.equal(expected, output)
    end)

    it('handles format strings with mixed parameters', function()
      local format_str = '/say ^command %s %d %s'
      local str1 = 'test'
      local num = 42
      local str2 = 'value'
      
      local output = capture(function()
        CommandExecutor.executef(format_str, str1, num, str2)
      end)
      
      local expected = string.format(format_str, str1, num, str2) .. '\n'
      assert.are.equal(expected, output)
    end)
  end)

  describe('Side effects verification', function()
    it('execute performs I/O operations', function()
      -- This test verifies that execute actually performs side effects
      -- by checking that output is produced
      local cmd_string = '/say ^test'
      
      local output = capture(function()
        CommandExecutor.execute(cmd_string)
      end)
      
      -- Verify output was produced (side effect occurred)
      assert.is_not_nil(output)
      assert.is_true(#output > 0, 'execute should produce output')
    end)

    it('executef performs I/O operations', function()
      -- This test verifies that executef actually performs side effects
      local format_str = '/say ^test %s'
      local value = 'value'
      
      local output = capture(function()
        CommandExecutor.executef(format_str, value)
      end)
      
      -- Verify output was produced (side effect occurred)
      assert.is_not_nil(output)
      assert.is_true(#output > 0, 'executef should produce output')
    end)
  end)

  describe('Integration with mq module', function()
    it('execute requires and uses mq module', function()
      -- Verify that execute actually requires the mq module
      -- by checking that it works with the mq_stub
      local cmd_string = '/say ^integration_test'
      
      -- This should not error if mq module is properly required
      assert.has_no_errors(function()
        CommandExecutor.execute(cmd_string)
      end)
    end)

    it('executef requires and uses mq module', function()
      -- Verify that executef actually requires the mq module
      local format_str = '/say ^integration_test %s'
      
      -- This should not error if mq module is properly required
      assert.has_no_errors(function()
        CommandExecutor.executef(format_str, 'test')
      end)
    end)
  end)
end)
