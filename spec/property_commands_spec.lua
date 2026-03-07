---@diagnostic disable: undefined-global
package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

-- Set up package aliases for testing
local function setup_package_aliases()
  local function alias(name, target)
    package.preload[name] = function() return require(target) end
  end

  alias('LuaBots.init', 'init')
  alias('LuaBots.Actionable', 'Actionable')
  alias('LuaBots.enums.Slot', 'enums.Slot')
  alias('LuaBots.enums.Class', 'enums.Class')
  alias('LuaBots.enums.Gender', 'enums.Gender')
  alias('LuaBots.enums.Race', 'enums.Race')
  alias('LuaBots.enums.SpellType', 'enums.SpellType')
  alias('LuaBots.enums.SpellDelayCategory', 'enums.SpellDelayCategory')
  alias('LuaBots.enums.SpellHoldCategory', 'enums.SpellHoldCategory')
  alias('LuaBots.enums.Stance', 'enums.Stance')
  alias('LuaBots.enums.MaterialSlot', 'enums.MaterialSlot')
  alias('LuaBots.enums.PetType', 'enums.PetType')
end

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

setup_package_aliases()
setup_package_manager_stub()

local property = require('spec.property')
local generators = require('spec.generators')
local LuaBots = require('LuaBots.init')
local Actionable = require('Actionable')

local function capture(fn)
  local output = {}
  local orig = io.write
  ---@diagnostic disable-next-line: duplicate-set-field
  io.write = function(str) table.insert(output, str) end
  fn()
  io.write = orig
  return table.concat(output)
end

describe('Command formatting properties', function()
  -- Property tests will be added here
end)

  it('Property 5: all commands start with "/say ^"', function()
    -- Feature: comprehensive-property-based-testing, Property 5
    property.forall(
      { generators.stance_value() },
      function(stance_value)
        local output = capture(function()
          LuaBots:stance(stance_value)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
      end,
      { iterations = 50 }
    )
  end)

  it('Property 6: command parameters are space-separated', function()
    -- Feature: comprehensive-property-based-testing, Property 6
    property.forall(
      { generators.numeric_parameter(), generators.numeric_parameter() },
      function(val1, val2)
        local output = capture(function()
          LuaBots:botdyearmor(1, val1, val2, 100)
        end)
        -- Check that parameters are separated by single spaces
        assert.is_true(output:find('%d+ %d+ %d+') ~= nil)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 7: Actionables appear at command end', function()
    -- Feature: comprehensive-property-based-testing, Property 7
    property.forall(
      { generators.any_actionable() },
      function(actionable)
        local output = capture(function()
          LuaBots:attack(1, actionable)
        end)
        local actionable_str = tostring(actionable)
        assert.is_true(output:sub(-#actionable_str - 1, -2) == actionable_str)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 8: command output is deterministic', function()
    -- Feature: comprehensive-property-based-testing, Property 8
    property.forall(
      { generators.stance_value(), generators.any_actionable() },
      function(stance_value, actionable)
        local output1 = capture(function()
          LuaBots:stance(stance_value, actionable)
        end)
        local output2 = capture(function()
          LuaBots:stance(stance_value, actionable)
        end)
        assert.equals(output1, output2)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 9: nil parameters are omitted', function()
    -- Feature: comprehensive-property-based-testing, Property 9
    local output = capture(function()
      LuaBots:attack(nil)
    end)
    -- Should just be "/say ^attack\n" without any nil
    assert.equals('/say ^attack\n', output)
  end)

  it('Property 10: parameters are converted to strings', function()
    -- Feature: comprehensive-property-based-testing, Property 10
    property.forall(
      { property.integer(1, 100), property.boolean() },
      function(num, bool)
        local output = capture(function()
          LuaBots:attack(num)
        end)
        assert.is_true(output:find(tostring(num)) ~= nil)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 20: optional parameters can be omitted', function()
    -- Feature: comprehensive-property-based-testing, Property 20
    -- Test command without optional Actionable
    local output1 = capture(function()
      LuaBots:attack(1)
    end)
    assert.is_true(output1:sub(1, 6) == '/say ^')
    
    -- Test command without optional value
    local output2 = capture(function()
      LuaBots:botcamp()
    end)
    assert.is_true(output2:sub(1, 6) == '/say ^')
  end)

  it('Property 21: multi-parameter commands preserve order', function()
    -- Feature: comprehensive-property-based-testing, Property 21
    property.forall(
      { property.integer(0, 255), property.integer(0, 255), property.integer(0, 255) },
      function(r, g, b)
        local output = capture(function()
          LuaBots:botdyearmor(1, r, g, b)
        end)
        -- Parameters should appear in order: slot, r, g, b
        local pattern = string.format('1 %d %d %d', r, g, b)
        assert.is_true(output:find(pattern, 1, true) ~= nil)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 22: maximum parameter values are handled', function()
    -- Feature: comprehensive-property-based-testing, Property 22
    local output = capture(function()
      LuaBots:botdyearmor(1, 255, 255, 255)
    end)
    assert.is_true(output:find('255') ~= nil)
    
    local output2 = capture(function()
      LuaBots:sithppercent(100)
    end)
    assert.is_true(output2:find('100') ~= nil)
  end)

  it('Property 25: commands with Actionables are longer', function()
    -- Feature: comprehensive-property-based-testing, Property 25
    property.forall(
      { generators.any_actionable() },
      function(actionable)
        local output_without = capture(function()
          LuaBots:attack(1)
        end)
        local output_with = capture(function()
          LuaBots:attack(1, actionable)
        end)
        assert.is_true(#output_with > #output_without)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 26: commands with parameters are longer or equal', function()
    -- Feature: comprehensive-property-based-testing, Property 26
    property.forall(
      { property.integer(1, 100) },
      function(value)
        local output_without = capture(function()
          LuaBots:attack()
        end)
        local output_with = capture(function()
          LuaBots:attack(value)
        end)
        assert.is_true(#output_with >= #output_without)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 24: botcreate produces valid commands for all combinations', function()
    -- Feature: comprehensive-property-based-testing, Property 24
    property.forall(
      { generators.bot_name(), generators.class_value(), generators.race_value(), generators.gender_value() },
      function(name, class, race, gender)
        local result
        local output = capture(function()
          result = LuaBots:botcreate(name, class, race, gender)
        end)
        
        -- Should start with /say ^botcreate (16 chars including trailing space)
        assert.is_true(output:sub(1, 16) == '/say ^botcreate ')
        
        -- Result should be a table with correct fields
        assert.is_table(result)
        assert.equals(name, result.Name)
        assert.equals(class, result.Class)
        assert.equals(race, result.Race)
        assert.equals(gender, result.Gender)
      end,
      { iterations = 50 }
    )
  end)
