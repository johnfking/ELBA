--- Unit tests for test_helpers module (Task 7.2)
--- These tests verify that the capture() function uses OutputSink correctly

package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

local test_helpers = require('spec.test_helpers')
local output_sink = require('spec.output_sink')

describe('test_helpers.capture - Task 7.2 Verification', function()
  
  describe('Basic functionality', function()
    it('captures output from io.write', function()
      local output = test_helpers.capture(function()
        io.write('Hello, World!')
      end)
      
      assert.equals('Hello, World!', output)
    end)
    
    it('captures multiple io.write calls', function()
      local output = test_helpers.capture(function()
        io.write('Line 1\n')
        io.write('Line 2\n')
        io.write('Line 3')
      end)
      
      assert.equals('Line 1\nLine 2\nLine 3', output)
    end)
    
    it('returns empty string when no output is produced', function()
      local output = test_helpers.capture(function()
        -- No output
      end)
      
      assert.equals('', output)
    end)
  end)
  
  describe('Requirement 3.2: Redirect output to provided sink', function()
    it('uses custom sink when provided', function()
      local custom_sink = output_sink.create_buffer_sink()
      
      local output = test_helpers.capture(function()
        io.write('Custom sink test')
      end, custom_sink)
      
      assert.equals('Custom sink test', output)
      assert.equals('Custom sink test', custom_sink:get_output())
    end)
    
    it('creates buffer sink when not provided', function()
      -- Should work without providing a sink
      local output = test_helpers.capture(function()
        io.write('Default sink')
      end)
      
      assert.equals('Default sink', output)
    end)
  end)
  
  describe('Requirement 3.3: Restore original io.write without side effects', function()
    it('restores io.write after successful execution', function()
      local original_write = io.write
      
      test_helpers.capture(function()
        io.write('Test')
      end)
      
      -- io.write should be restored to original
      assert.equals(original_write, io.write)
    end)
    
    it('restores io.write even when function errors', function()
      local original_write = io.write
      
      -- Capture should propagate the error but still restore io.write
      assert.has_error(function()
        test_helpers.capture(function()
          io.write('Before error')
          error('Test error')
        end)
      end)
      
      -- io.write should still be restored despite the error
      assert.equals(original_write, io.write)
    end)
    
    it('does not affect io.write outside of capture', function()
      -- Write something outside capture
      local external_output = {}
      local original_write = io.write
      io.write = function(text) table.insert(external_output, text) end
      
      -- Use capture (should temporarily replace io.write)
      test_helpers.capture(function()
        io.write('Inside capture')
      end)
      
      -- io.write should be restored to our custom function
      io.write('After capture')
      
      -- Verify our custom function still works
      assert.equals('After capture', external_output[1])
      
      -- Restore original
      io.write = original_write
    end)
  end)
  
  describe('Error handling', function()
    it('propagates errors from captured function', function()
      local error_message = 'Expected error'
      
      assert.has_error(function()
        test_helpers.capture(function()
          error(error_message)
        end)
      end)
    end)
    
    it('captures output before error occurs', function()
      local success, err = pcall(function()
        test_helpers.capture(function()
          io.write('Before error\n')
          error('Test error')
        end)
      end)
      
      -- Should have failed
      assert.is_false(success)
      assert.is_not_nil(err)
    end)
  end)
  
  describe('Integration with existing tests', function()
    it('works with mq_stub commands', function()
      local mq = require('mq')
      
      local output = test_helpers.capture(function()
        mq.cmd('/say ^test')
      end)
      
      assert.equals('/say ^test\n', output)
    end)
  end)
end)
