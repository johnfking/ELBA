-- Unit tests for NameGenerator module (Task 3.3)
-- These tests verify name generation with various HTTP client responses

package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

local function setup_package_aliases()
  local function alias(name, target)
    package.preload[name] = function() return require(target) end
  end

  alias('LuaBots.NameGenerator', 'LuaBots/NameGenerator')
  alias('LuaBots.HTTPClient', 'LuaBots/HTTPClient')
end

local function setup_cjson_stub()
  -- Mock cjson for testing
  package.preload['cjson'] = function()
    return {
      decode = function(json_str)
        -- Simple JSON parser for test responses
        -- Handles {"names":["Name1","Name2"]} format
        if json_str == '' then
          error('Expected value but found invalid token at character 1')
        end
        
        -- Check for basic JSON validity
        if not json_str:match('^%s*{') then
          error('Expected object but found invalid token')
        end
        
        -- Handle malformed JSON
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
        
        -- Check if names field exists
        if json_str:match('"names"%s*:%s*null') then
          return { names = nil }
        elseif json_str:match('"names"%s*:%s*"[^"]*"') then
          -- names is a string, not an array
          return { names = "not an array" }
        elseif json_str:match('"names"%s*:') then
          return { names = names }
        else
          -- No names field
          return {}
        end
      end,
      encode = function(tbl)
        return "{}"
      end
    }
  end
end

setup_package_aliases()
setup_cjson_stub()

local NameGenerator = require('LuaBots.NameGenerator')
local HTTPClient = require('LuaBots.HTTPClient')

describe('NameGenerator Module - Task 3.3 Verification', function()

  describe('successful name generation with mock HTTP client', function()
    it('returns first name from API response for human male', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["Aldric","Bran","Cedric"]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(err)
      assert.are.equal('Aldric', name)
    end)

    it('returns first name from API response for elf female', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/elf/female/1'] = {
          body = '{"names":["Arwen","Galadriel","Luthien"]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(4, 1, mock_client)

      assert.is_nil(err)
      assert.are.equal('Arwen', name)
    end)

    it('returns first name from API response for dwarf male', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/dwarf/male/1'] = {
          body = '{"names":["Thorin","Gimli","Balin"]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(8, 0, mock_client)

      assert.is_nil(err)
      assert.are.equal('Thorin', name)
    end)

    it('handles single name in response', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["SingleName"]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(err)
      assert.are.equal('SingleName', name)
    end)

    it('maps unknown race ID to human', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["DefaultName"]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(999, 0, mock_client)

      assert.is_nil(err)
      assert.are.equal('DefaultName', name)
    end)

    it('maps unknown gender ID to male', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["DefaultName"]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 999, mock_client)

      assert.is_nil(err)
      assert.are.equal('DefaultName', name)
    end)
  end)

  describe('HTTP failure handling', function()
    it('returns nil and error message for 404 response', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = 'Not Found',
          code = 404
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('HTTP request failed with code 404', err)
    end)

    it('returns nil and error message for 500 response', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = 'Internal Server Error',
          code = 500
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('HTTP request failed with code 500', err)
    end)

    it('returns nil and error message for 403 response', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/elf/female/1'] = {
          body = 'Forbidden',
          code = 403
        }
      })

      local name, err = NameGenerator.generate_name(4, 1, mock_client)

      assert.is_nil(name)
      assert.are.equal('HTTP request failed with code 403', err)
    end)

    it('handles nil HTTP code', function()
      local mock_client = {
        request = function(opts)
          return 'Some body', nil
        end
      }

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('HTTP request failed with code 0', err)
    end)
  end)

  describe('JSON parse failure handling', function()
    it('returns nil and error message for invalid JSON', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = 'This is not valid JSON',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('Failed to parse API response', err)
    end)

    it('returns nil and error message for malformed JSON', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["incomplete"',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('Failed to parse API response', err)
    end)

    it('returns nil and error message for empty string', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('Failed to parse API response', err)
    end)
  end)

  describe('empty response handling', function()
    it('returns nil and error message for missing names field', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"other_field":"value"}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('No valid names in API response', err)
    end)

    it('returns nil and error message for empty names array', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":[]}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('No valid names in API response', err)
    end)

    it('returns nil and error message for null names field', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":null}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('No valid names in API response', err)
    end)

    it('returns nil and error message for non-array names field', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":"not an array"}',
          code = 200
        }
      })

      local name, err = NameGenerator.generate_name(1, 0, mock_client)

      assert.is_nil(name)
      assert.are.equal('No valid names in API response', err)
    end)
  end)

  describe('race and gender mapping', function()
    it('correctly maps all human race IDs', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["HumanName"]}',
          code = 200
        }
      })

      -- Race IDs 1, 2, 3 should all map to "human"
      for _, race_id in ipairs({1, 2, 3}) do
        local name, err = NameGenerator.generate_name(race_id, 0, mock_client)
        assert.is_nil(err)
        assert.are.equal('HumanName', name)
      end
    end)

    it('correctly maps all elf race IDs', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/elf/male/1'] = {
          body = '{"names":["ElfName"]}',
          code = 200
        }
      })

      -- Race IDs 4, 5, 6 should all map to "elf"
      for _, race_id in ipairs({4, 5, 6}) do
        local name, err = NameGenerator.generate_name(race_id, 0, mock_client)
        assert.is_nil(err)
        assert.are.equal('ElfName', name)
      end
    end)

    it('correctly maps special race IDs', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/dragonborn/male/1'] = {
          body = '{"names":["DragonName"]}',
          code = 200
        }
      })

      -- Race IDs 128 and 522 should both map to "dragonborn"
      for _, race_id in ipairs({128, 522}) do
        local name, err = NameGenerator.generate_name(race_id, 0, mock_client)
        assert.is_nil(err)
        assert.are.equal('DragonName', name)
      end
    end)
  end)
end)
