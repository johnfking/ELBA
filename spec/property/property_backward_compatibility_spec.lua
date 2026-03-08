--
-- Property tests for Backward Compatibility
-- Feature: functional-refactoring
-- Task 4.6: Write property tests for backward compatibility
--

-- Mock mq.PackageMan
package.preload['mq.PackageMan'] = function()
  return {
    Require = function(package_name)
      -- Mock package manager - just return success
      return true
    end
  }
end

-- Setup cjson stub for testing
package.preload['cjson'] = function()
  return {
    decode = function(json_str)
      -- Simple JSON parser for test responses
      if json_str == '' then
        error('Expected value but found invalid token')
      end
      
      if not json_str:match('^%s*{') then
        error('Expected object but found invalid token')
      end
      
      if not json_str:match('}%s*$') then
        error('Expected closing brace')
      end
      
      -- Extract names array
      local names = {}
      for name in json_str:gmatch('"([^"]+)"') do
        if name ~= "names" then
          table.insert(names, name)
        end
      end
      
      if json_str:match('"names"%s*:%s*%[') then
        return { names = names }
      else
        return {}
      end
    end
  }
end

describe("Backward Compatibility", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local LuaBots = require('init')
  local mq = require('LuaBots.mq')
  
  describe("Property 13: Optional Parameter Backward Compatibility", function()
    before_each(function()
      -- Clear captured commands before each test
      mq.enable_capture()
      mq.clear_captured_commands()
    end)
    
    after_each(function()
      -- Disable capture after each test
      mq.disable_capture()
    end)
    
    it("should work without optional http_client parameter for explicit names", function()
      -- **Validates: Requirements 7.3**
      
      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          -- Skip AUTO names for this test
          if name == "AUTO" then
            return
          end
          
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call botcreate WITHOUT optional http_client parameter
          -- This tests backward compatibility - existing code doesn't pass http_client
          local result = LuaBots:botcreate(name, class, race, gender)
          
          -- Verify result is returned
          assert.is_not_nil(result, "botcreate should return a result")
          assert.equals(name, result.Name, "Result should contain the provided name")
          assert.equals(class, result.Class, "Result should contain the provided class")
          assert.equals(race, result.Race, "Result should contain the provided race")
          assert.equals(gender, result.Gender, "Result should contain the provided gender")
          
          -- Verify command was executed
          local commands = mq.get_captured_commands()
          assert.equals(1, #commands, "Should execute exactly one command")
          
          -- Verify command format matches expected
          local expected_cmd = string.format("/say ^botcreate %s %d %d %d",
            name, class, race, gender)
          assert.equals(expected_cmd, commands[1],
            "Command should match expected format")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should work identically with all standard command functions", function()
      -- **Validates: Requirements 7.3**
      
      -- Test that all standard command functions work without optional parameters
      -- These functions don't have optional parameters yet, but we verify they
      -- continue to work with their standard signatures
      
      property.forall(
        {
          generators.stance_value(),
          generators.any_actionable()
        },
        function(value, act)
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call stance with standard parameters (no optional params)
          LuaBots:stance(value, act)
          
          -- Verify command was executed
          local commands = mq.get_captured_commands()
          assert.equals(1, #commands, "Should execute exactly one command")
          assert.is_string(commands[1], "Command should be a string")
          assert.is_not_nil(commands[1]:match("^/say %^stance"),
            "Command should start with '/say ^stance'")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should work identically for attack command", function()
      -- **Validates: Requirements 7.3**
      
      property.forall(
        {
          property.oneof({'on', 'off', nil}),
          generators.any_actionable()
        },
        function(value, act)
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call attack with standard parameters
          LuaBots:attack(value, act)
          
          -- Verify command was executed
          local commands = mq.get_captured_commands()
          assert.equals(1, #commands, "Should execute exactly one command")
          assert.is_string(commands[1], "Command should be a string")
          assert.is_not_nil(commands[1]:match("^/say %^attack"),
            "Command should start with '/say ^attack'")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should work identically for guard command", function()
      -- **Validates: Requirements 7.3**
      
      property.forall(
        {
          property.oneof({'on', 'off', nil}),
          generators.any_actionable()
        },
        function(value, act)
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call guard with standard parameters
          LuaBots:guard(value, act)
          
          -- Verify command was executed
          local commands = mq.get_captured_commands()
          assert.equals(1, #commands, "Should execute exactly one command")
          assert.is_string(commands[1], "Command should be a string")
          assert.is_not_nil(commands[1]:match("^/say %^guard"),
            "Command should start with '/say ^guard'")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should work identically for follow command", function()
      -- **Validates: Requirements 7.3**
      
      property.forall(
        {
          property.oneof({'on', 'off', nil}),
          generators.any_actionable()
        },
        function(value, act)
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call follow with standard parameters
          LuaBots:follow(value, act)
          
          -- Verify command was executed
          local commands = mq.get_captured_commands()
          assert.equals(1, #commands, "Should execute exactly one command")
          assert.is_string(commands[1], "Command should be a string")
          assert.is_not_nil(commands[1]:match("^/say %^follow"),
            "Command should start with '/say ^follow'")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should maintain function signature compatibility", function()
      -- **Validates: Requirements 7.3**
      
      -- Verify that calling functions with their original signatures works
      -- This ensures backward compatibility for existing code
      
      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          -- Skip AUTO names
          if name == "AUTO" then
            return
          end
          
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call with exactly 4 parameters (original signature)
          -- No optional parameters provided
          local success, result = pcall(function()
            return LuaBots:botcreate(name, class, race, gender)
          end)
          
          -- Verify call succeeded
          assert.is_true(success, "Function call should succeed with original signature")
          assert.is_not_nil(result, "Function should return a result")
          
          -- Verify behavior is correct
          local commands = mq.get_captured_commands()
          assert.equals(1, #commands, "Should execute exactly one command")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should handle nil optional parameters same as omitted parameters", function()
      -- **Validates: Requirements 7.3**
      
      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          -- Skip AUTO names
          if name == "AUTO" then
            return
          end
          
          -- Clear captured commands
          mq.clear_captured_commands()
          
          -- Call with explicit nil for optional parameter
          local result_with_nil = LuaBots:botcreate(name, class, race, gender, nil)
          local commands_with_nil = {}
          for i, cmd in ipairs(mq.get_captured_commands()) do
            commands_with_nil[i] = cmd
          end
          
          -- Clear and call without optional parameter
          mq.clear_captured_commands()
          local result_without = LuaBots:botcreate(name, class, race, gender)
          local commands_without = mq.get_captured_commands()
          
          -- Verify both produce identical results
          assert.equals(result_without.Name, result_with_nil.Name,
            "Results should be identical with nil vs omitted parameter")
          
          assert.equals(#commands_without, #commands_with_nil,
            "Should execute same number of commands")
          
          if #commands_without > 0 and #commands_with_nil > 0 then
            assert.equals(commands_without[1], commands_with_nil[1],
              "Commands should be identical")
          end
        end,
        { iterations = 100 }
      )
    end)
  end)
end)
