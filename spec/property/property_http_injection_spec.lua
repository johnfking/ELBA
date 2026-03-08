--
-- Property tests for HTTP Client Injection
-- Feature: functional-refactoring
-- Task 3.4: Write property tests for HTTP client injection
--

package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

-- Setup mq stub BEFORE requiring init.lua
local captured_commands = {}

package.loaded['mq'] = {
  cmd = function(cmd)
    table.insert(captured_commands, cmd)
  end,
  cmdf = function(fmt, ...)
    local cmd = string.format(fmt, ...)
    table.insert(captured_commands, cmd)
  end,
  get_captured = function()
    return captured_commands
  end,
  clear_captured = function()
    captured_commands = {}
  end
}

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

-- Setup package aliases for LuaBots modules
local function setup_package_aliases()
  local function alias(name, target)
    package.preload[name] = function() return require(target) end
  end

  alias('LuaBots.NameGenerator', 'LuaBots/NameGenerator')
  alias('LuaBots.HTTPClient', 'LuaBots/HTTPClient')
  alias('LuaBots.CommandBuilder', 'LuaBots/CommandBuilder')
  alias('LuaBots.CommandExecutor', 'LuaBots/CommandExecutor')
  alias('LuaBots.Actionable', 'Actionable')
  alias('LuaBots.enums.Class', 'enums/Class')
  alias('LuaBots.enums.Race', 'enums/Race')
  alias('LuaBots.enums.Gender', 'enums/Gender')
  alias('LuaBots.enums.Slot', 'enums/Slot')
  alias('LuaBots.enums.SpellType', 'enums/SpellType')
  alias('LuaBots.enums.SpellDelayCategory', 'enums/SpellDelayCategory')
  alias('LuaBots.enums.SpellHoldCategory', 'enums/SpellHoldCategory')
  alias('LuaBots.enums.Stance', 'enums/Stance')
  alias('LuaBots.enums.MaterialSlot', 'enums/MaterialSlot')
  alias('LuaBots.enums.PetType', 'enums/PetType')
end

setup_package_aliases()

describe("HTTP Client Injection", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local HTTPClient = require('LuaBots.HTTPClient')
  local LuaBots = require('init')
  
  describe("Property 12: HTTP Client Injection", function()
    before_each(function()
      -- Clear captured commands before each test
      package.loaded['mq'].clear_captured()
    end)
    
    it("should use custom HTTP client when provided", function()
      -- **Validates: Requirements 5.2**
      
      property.forall(
        {
          generators.race_value(),
          generators.gender_value(),
          generators.class_value(),
          generators.bot_name()
        },
        function(race, gender, class, expected_name)
          -- Create a mock HTTP client that tracks if it was called
          local http_client_called = false
          local request_url = nil
          
          local mock_client = {
            request = function(opts)
              http_client_called = true
              request_url = opts.url
              -- Return a valid JSON response with the expected name
              return string.format('{"names":["%s"]}', expected_name), 200
            end
          }
          
          -- Clear captured commands
          package.loaded['mq'].clear_captured()
          
          -- Call botcreate with AUTO name and custom HTTP client
          local result = LuaBots:botcreate("AUTO", class, race, gender, mock_client)
          
          -- Verify custom HTTP client was called
          assert.is_true(http_client_called, 
            "Custom HTTP client should be called when provided")
          
          -- Verify the request URL was constructed correctly
          assert.is_not_nil(request_url, "HTTP client should receive a URL")
          assert.is_string(request_url, "Request URL should be a string")
          
          -- Verify result contains the name from HTTP client response
          assert.is_not_nil(result, "botcreate should return a result")
          assert.equals(expected_name, result.Name, 
            "Returned name should match HTTP client response")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should return name matching HTTP client response", function()
      -- **Validates: Requirements 5.2**
      
      property.forall(
        {
          generators.race_value(),
          generators.gender_value(),
          generators.class_value(),
          property.string(3, 20)  -- Generate random bot names
        },
        function(race, gender, class, generated_name)
          -- Create mock HTTP client with specific response
          local mock_responses = {}
          
          local mock_client = {
            request = function(opts)
              -- Return the generated name in the response
              return string.format('{"names":["%s","OtherName","ThirdName"]}', 
                generated_name), 200
            end
          }
          
          -- Clear captured commands
          package.loaded['mq'].clear_captured()
          
          -- Call botcreate with AUTO name
          local result = LuaBots:botcreate("AUTO", class, race, gender, mock_client)
          
          -- Verify result is not nil
          assert.is_not_nil(result, "botcreate should return a result")
          
          -- Verify the returned name matches the first name from HTTP response
          assert.equals(generated_name, result.Name,
            string.format("Expected name '%s' but got '%s'", 
              generated_name, result.Name))
          
          -- Verify the command was executed with the correct name
          local commands = package.loaded['mq'].get_captured()
          assert.equals(1, #commands, "Should execute exactly one command")
          
          local expected_cmd = string.format("/say ^botcreate %s %d %d %d",
            generated_name, class, race, gender)
          assert.equals(expected_cmd, commands[1],
            "Command should use the name from HTTP client response")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should handle HTTP client errors gracefully", function()
      -- **Validates: Requirements 5.2**
      
      property.forall(
        {
          generators.race_value(),
          generators.gender_value(),
          generators.class_value(),
          property.integer(400, 599)  -- HTTP error codes
        },
        function(race, gender, class, error_code)
          -- Create mock HTTP client that returns an error
          local mock_client = {
            request = function(opts)
              return "Error response", error_code
            end
          }
          
          -- Clear captured commands
          package.loaded['mq'].clear_captured()
          
          -- Call botcreate with AUTO name and failing HTTP client
          local result = LuaBots:botcreate("AUTO", class, race, gender, mock_client)
          
          -- Verify botcreate returns nil on HTTP failure
          assert.is_nil(result, 
            "botcreate should return nil when HTTP client fails")
          
          -- Verify no command was executed
          local commands = package.loaded['mq'].get_captured()
          assert.equals(0, #commands, 
            "No command should be executed when name generation fails")
        end,
        { iterations = 50 }
      )
    end)
    
    it("should not call HTTP client when name is not AUTO", function()
      -- **Validates: Requirements 5.2**
      
      property.forall(
        {
          generators.bot_name(),
          generators.race_value(),
          generators.gender_value(),
          generators.class_value()
        },
        function(bot_name, race, gender, class)
          -- Skip if name happens to be "AUTO"
          if bot_name == "AUTO" then
            return
          end
          
          -- Create mock HTTP client that tracks calls
          local http_client_called = false
          
          local mock_client = {
            request = function(opts)
              http_client_called = true
              return '{"names":["ShouldNotBeUsed"]}', 200
            end
          }
          
          -- Clear captured commands
          package.loaded['mq'].clear_captured()
          
          -- Call botcreate with explicit name
          local result = LuaBots:botcreate(bot_name, class, race, gender, mock_client)
          
          -- Verify HTTP client was NOT called
          assert.is_false(http_client_called,
            "HTTP client should not be called when name is not AUTO")
          
          -- Verify result uses the provided name
          assert.is_not_nil(result, "botcreate should return a result")
          assert.equals(bot_name, result.Name,
            "Returned name should match the provided name")
        end,
        { iterations = 100 }
      )
    end)
    
    it("should verify HTTP client receives correct URL parameters", function()
      -- **Validates: Requirements 5.2**
      
      -- Race mapping for verification
      local race_map = {
        [1] = "human", [2] = "human", [3] = "human",
        [4] = "elf", [5] = "elf", [6] = "elf",
        [7] = "half-elf", [8] = "dwarf", [9] = "troll",
        [10] = "orc", [11] = "halfling", [12] = "gnome",
        [128] = "dragonborn", [130] = "tiefling",
        [330] = "goblin", [522] = "dragonborn"
      }
      
      local gender_map = { [0] = "male", [1] = "female" }
      
      property.forall(
        {
          generators.race_value(),
          generators.gender_value(),
          generators.class_value()
        },
        function(race, gender, class)
          -- Track the URL received by HTTP client
          local received_url = nil
          
          local mock_client = {
            request = function(opts)
              received_url = opts.url
              return '{"names":["TestName"]}', 200
            end
          }
          
          -- Clear captured commands
          package.loaded['mq'].clear_captured()
          
          -- Call botcreate with AUTO name
          local result = LuaBots:botcreate("AUTO", class, race, gender, mock_client)
          
          -- Verify URL was received
          assert.is_not_nil(received_url, "HTTP client should receive a URL")
          
          -- Verify URL contains correct race and gender
          local expected_race = race_map[race] or "human"
          local expected_gender = gender_map[gender] or "male"
          
          -- Use string.find instead of match to avoid pattern issues with special chars
          assert.is_true(received_url:find(expected_race, 1, true) ~= nil,
            string.format("URL should contain race '%s', got: %s", 
              expected_race, received_url))
          
          assert.is_true(received_url:find(expected_gender, 1, true) ~= nil,
            string.format("URL should contain gender '%s', got: %s",
              expected_gender, received_url))
        end,
        { iterations = 100 }
      )
    end)
  end)
end)

