--
-- Tests for botcreate HTTP client injection (Task 4.3)
--
-- Validates Requirements 5.1, 5.2, 5.3, 7.3
--

local function setup_package_manager_stub()
  if package.preload['mq.PackageMan'] or package.loaded['mq.PackageMan'] then
    return
  end

  package.preload['mq.PackageMan'] = function()
    return {
      Require = function(_, _, module)
        local ok, mod = pcall(require, module)
        if ok then
          return mod
        end
        error(('Package "%s" is not available.'):format(module), 2)
      end,
    }
  end
end

local function setup_cjson_stub()
  -- Mock cjson for testing
  package.preload['cjson'] = function()
    return {
      decode = function(json_str)
        -- Simple JSON parser for test responses
        -- Handles {"names":["Name1","Name2"]} format
        local names = {}
        for name in json_str:gmatch('"([^"]+)"') do
          if name ~= "names" then
            table.insert(names, name)
          end
        end
        return { names = names }
      end,
      encode = function(tbl)
        return "{}"
      end
    }
  end
end

setup_package_manager_stub()
setup_cjson_stub()

local LuaBots = require('init')
local HTTPClient = require('LuaBots.HTTPClient')
local Class = require('enums.Class')
local Race = require('enums.Race')
local Gender = require('enums.Gender')
local test_helpers = require('spec.test_helpers')
local capture = test_helpers.capture

describe('LuaBots:botcreate HTTP injection', function()
  
  teardown(function()
    package.loaded['LuaBots.init'] = nil
    package.loaded['LuaBots.HTTPClient'] = nil
    package.loaded['LuaBots.NameGenerator'] = nil
    package.loaded['LuaBots.CommandBuilder'] = nil
    package.loaded['LuaBots.CommandExecutor'] = nil
  end)
  
  describe('Requirement 5.1: Accept optional HTTP client parameter', function()
    it('should accept http_client as 5th parameter', function()
      local mock_client = HTTPClient.create_mock_http_client({})
      
      -- Should not error when http_client is provided
      local output = capture(function()
        LuaBots:botcreate('TestBot', Class.WARRIOR, Race.HUMAN, Gender.MALE, mock_client)
      end)
      
      assert.is_string(output)
      assert.is_true(output:match('/say %^botcreate TestBot') ~= nil)
    end)
    
    it('should work without http_client parameter (backward compatibility)', function()
      -- Should not error when http_client is omitted
      local output = capture(function()
        LuaBots:botcreate('TestBot', Class.WARRIOR, Race.HUMAN, Gender.MALE)
      end)
      
      assert.is_string(output)
      assert.is_true(output:match('/say %^botcreate TestBot') ~= nil)
    end)
  end)
  
  describe('Requirement 5.2: Use custom HTTP client for name generation', function()
    it('should use custom HTTP client when name is AUTO', function()
      local custom_name = "CustomGeneratedName"
      local mock_responses = {
        ["https://names.ironarachne.com/race/human/male/1"] = {
          body = string.format('{"names":["%s"]}', custom_name),
          code = 200
        }
      }
      local mock_client = HTTPClient.create_mock_http_client(mock_responses)
      
      local result
      local output = capture(function()
        result = LuaBots:botcreate('AUTO', Class.WARRIOR, Race.HUMAN, Gender.MALE, mock_client)
      end)
      
      -- Verify the custom name was used
      assert.is_not_nil(result)
      assert.equals(custom_name, result.Name)
      assert.is_true(output:match('/say %^botcreate ' .. custom_name) ~= nil)
    end)
    
    it('should handle HTTP client errors gracefully', function()
      local mock_responses = {
        ["https://names.ironarachne.com/race/human/male/1"] = {
          body = "",
          code = 500
        }
      }
      local mock_client = HTTPClient.create_mock_http_client(mock_responses)
      
      local result
      -- Suppress print output for this test
      local orig_print = print
      print = function() end
      
      result = LuaBots:botcreate('AUTO', Class.WARRIOR, Race.HUMAN, Gender.MALE, mock_client)
      
      print = orig_print
      
      -- Should return nil on failure (this is the key requirement)
      assert.is_nil(result)
    end)
  end)
  
  describe('Requirement 5.3: Use default HTTP client when not provided', function()
    it('should not use HTTP client when name is not AUTO', function()
      -- When name is not AUTO, http_client should not be used at all
      local output = capture(function()
        LuaBots:botcreate('SpecificName', Class.WARRIOR, Race.HUMAN, Gender.MALE)
      end)
      
      assert.is_true(output:match('/say %^botcreate SpecificName') ~= nil)
    end)
  end)
  
  describe('Requirement 7.3: Backward compatibility', function()
    it('should work identically to original when called without http_client', function()
      local args = {'Testbot', Class.WARRIOR, Race.HUMAN, Gender.MALE}
      local result
      local output = capture(function()
        result = LuaBots:botcreate(table.unpack(args))
      end)
      
      -- Should produce correct command
      assert.equals('/say ^botcreate Testbot 1 1 0\n', output)
      
      -- Should return correct metadata
      assert.are.same({
        Name = 'Testbot',
        Class = Class.WARRIOR,
        Race = Race.HUMAN,
        Gender = Gender.MALE,
      }, result)
    end)
  end)
  
  describe('Integration: CommandBuilder and CommandExecutor', function()
    it('should use CommandBuilder.build_botcreate() and CommandExecutor.execute()', function()
      local CommandBuilder = require('LuaBots.CommandBuilder')
      
      -- Verify the command format matches what CommandBuilder produces
      local expected_cmd = CommandBuilder.build_botcreate('TestBot', Class.WARRIOR, Race.HUMAN, Gender.MALE)
      
      local output = capture(function()
        LuaBots:botcreate('TestBot', Class.WARRIOR, Race.HUMAN, Gender.MALE)
      end)
      
      -- The output should match the command builder's format
      assert.equals(expected_cmd .. '\n', output)
    end)
  end)
end)
