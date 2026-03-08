--
-- Property tests for Command Builder Purity
-- Feature: functional-refactoring
-- Task 1.3: Write property tests for command builder purity
--

describe("Command Builder Purity", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local CommandBuilder = require('LuaBots.CommandBuilder')
  
  describe("Property 1: Command Builder Purity", function()
    it("should not call mq.cmd or mq.cmdf", function()
      -- **Validates: Requirements 1.1, 8.3, 8.4**
      
      -- Setup: Track if mq.cmd/cmdf are called
      local mq_cmd_called = false
      local mq_cmdf_called = false
      
      -- Mock mq module to detect calls
      local original_mq = package.loaded['mq']
      package.loaded['mq'] = {
        cmd = function() mq_cmd_called = true end,
        cmdf = function() mq_cmdf_called = true end
      }
      
      -- Test all builder functions with random inputs
      property.forall(
        {
          generators.string_parameter(),  -- value parameter
          generators.any_actionable()     -- actionable parameter
        },
        function(value, act)
          -- Reset flags for each iteration
          mq_cmd_called = false
          mq_cmdf_called = false
          
          -- Test a sample of builder functions
          local builders = {
            CommandBuilder.build_stance,
            CommandBuilder.build_attack,
            CommandBuilder.build_guard,
            CommandBuilder.build_follow,
            CommandBuilder.build_hold,
            CommandBuilder.build_cast,
            CommandBuilder.build_taunt
          }
          
          for _, builder in ipairs(builders) do
            local cmd = builder(value, act)
            
            -- Verify builder returned a string
            assert.is_string(cmd, "Builder should return a string")
            
            -- Verify no mq.cmd/cmdf calls
            assert.is_false(mq_cmd_called, "Builder should not call mq.cmd")
            assert.is_false(mq_cmdf_called, "Builder should not call mq.cmdf")
          end
        end,
        { iterations = 100 }
      )
      
      -- Restore original mq module
      package.loaded['mq'] = original_mq
    end)
    
    it("should not modify global state", function()
      -- **Validates: Requirements 8.4**
      
      -- Capture initial global state
      local initial_globals = {}
      for k, v in pairs(_G) do
        initial_globals[k] = v
      end
      
      -- Track io.write to detect I/O operations
      local io_write_called = false
      local original_io_write = io.write
      io.write = function(...)
        io_write_called = true
        return original_io_write(...)
      end
      
      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Reset I/O flag
          io_write_called = false
          
          -- Call various builders
          CommandBuilder.build_stance(value, act)
          CommandBuilder.build_attack(value, act)
          CommandBuilder.build_guard(value, act)
          
          -- Verify no I/O operations
          assert.is_false(io_write_called, "Builder should not perform I/O operations")
          
          -- Verify global state unchanged (check for new globals)
          for k, v in pairs(_G) do
            if initial_globals[k] == nil then
              -- New global was added
              assert.fail(string.format("Builder added new global: %s", k))
            end
          end
        end,
        { iterations = 100 }
      )
      
      -- Restore io.write
      io.write = original_io_write
    end)
    
    it("should not perform I/O operations", function()
      -- **Validates: Requirements 8.3**
      
      -- Track all I/O operations
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
      
      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Clear I/O tracking
          io_operations = {}
          
          -- Call all single-parameter builders
          CommandBuilder.build_stance(value, act)
          CommandBuilder.build_attack(value, act)
          CommandBuilder.build_guard(value, act)
          CommandBuilder.build_follow(value, act)
          CommandBuilder.build_hold(value, act)
          CommandBuilder.build_cast(value, act)
          CommandBuilder.build_taunt(value, act)
          CommandBuilder.build_defensive(value, act)
          CommandBuilder.build_discipline(value, act)
          
          -- Verify no I/O operations occurred
          assert.equals(0, #io_operations, 
            string.format("Builder should not perform I/O operations, but performed: %s", 
              table.concat(io_operations, ', ')))
        end,
        { iterations = 100 }
      )
      
      -- Restore io functions
      io.write = original_io.write
      io.read = original_io.read
      io.open = original_io.open
      io.close = original_io.close
    end)
    
    it("should not call mq.cmd/cmdf for botcreate builder", function()
      -- **Validates: Requirements 1.1, 8.3, 8.4**
      
      local mq_cmd_called = false
      local mq_cmdf_called = false
      
      -- Mock mq module
      local original_mq = package.loaded['mq']
      package.loaded['mq'] = {
        cmd = function() mq_cmd_called = true end,
        cmdf = function() mq_cmdf_called = true end
      }
      
      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          -- Reset flags
          mq_cmd_called = false
          mq_cmdf_called = false
          
          -- Call botcreate builder
          local cmd = CommandBuilder.build_botcreate(name, class, race, gender)
          
          -- Verify builder returned a string
          assert.is_string(cmd, "build_botcreate should return a string")
          
          -- Verify no mq.cmd/cmdf calls
          assert.is_false(mq_cmd_called, "build_botcreate should not call mq.cmd")
          assert.is_false(mq_cmdf_called, "build_botcreate should not call mq.cmdf")
        end,
        { iterations = 100 }
      )
      
      -- Restore original mq module
      package.loaded['mq'] = original_mq
    end)
    
    it("should not call mq.cmd/cmdf for multi-parameter builders", function()
      -- **Validates: Requirements 1.1, 8.3, 8.4**
      
      local mq_cmd_called = false
      local mq_cmdf_called = false
      
      -- Mock mq module
      local original_mq = package.loaded['mq']
      package.loaded['mq'] = {
        cmd = function() mq_cmd_called = true end,
        cmdf = function() mq_cmdf_called = true end
      }
      
      property.forall(
        {
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.any_actionable()
        },
        function(val1, val2, val3, act)
          -- Reset flags
          mq_cmd_called = false
          mq_cmdf_called = false
          
          -- Test multi-parameter builders
          local cmd1 = CommandBuilder.build_botdyearmor(val1, val2, val3, 100, act)
          local cmd2 = CommandBuilder.build_spelldelays(val1, val2, act)
          local cmd3 = CommandBuilder.build_spellholds(val1, val2, act)
          
          -- Verify builders returned strings
          assert.is_string(cmd1, "build_botdyearmor should return a string")
          assert.is_string(cmd2, "build_spelldelays should return a string")
          assert.is_string(cmd3, "build_spellholds should return a string")
          
          -- Verify no mq.cmd/cmdf calls
          assert.is_false(mq_cmd_called, "Builders should not call mq.cmd")
          assert.is_false(mq_cmdf_called, "Builders should not call mq.cmdf")
        end,
        { iterations = 100 }
      )
      
      -- Restore original mq module
      package.loaded['mq'] = original_mq
    end)
    
    it("should verify purity across all builder functions", function()
      -- **Validates: Requirements 1.1, 8.3, 8.4**
      
      -- Track side effects
      local mq_cmd_called = false
      local io_write_called = false
      
      -- Mock mq and io
      local original_mq = package.loaded['mq']
      local original_io_write = io.write
      
      package.loaded['mq'] = {
        cmd = function() mq_cmd_called = true end,
        cmdf = function() mq_cmd_called = true end
      }
      
      io.write = function(...) io_write_called = true end
      
      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Reset flags
          mq_cmd_called = false
          io_write_called = false
          
          -- Call a variety of builders
          local results = {
            CommandBuilder.build_stance(value, act),
            CommandBuilder.build_attack(value, act),
            CommandBuilder.build_guard(value, act),
            CommandBuilder.build_follow(value, act),
            CommandBuilder.build_hold(value, act),
            CommandBuilder.build_release(value, act),
            CommandBuilder.build_taunt(value, act),
            CommandBuilder.build_charm(value, act),
            CommandBuilder.build_cure(value, act),
            CommandBuilder.build_defensive(value, act)
          }
          
          -- Verify all returned strings
          for i, result in ipairs(results) do
            assert.is_string(result, string.format("Builder %d should return a string", i))
          end
          
          -- Verify no side effects
          assert.is_false(mq_cmd_called, "Builders should not call mq.cmd/cmdf")
          assert.is_false(io_write_called, "Builders should not perform I/O")
        end,
        { iterations = 100 }
      )
      
      -- Restore
      package.loaded['mq'] = original_mq
      io.write = original_io_write
    end)
  end)
end)
