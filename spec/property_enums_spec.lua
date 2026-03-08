package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

-- Set up package aliases
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
  ---@diagnostic disable-next-line: duplicate-set-field
  package.preload['mq.PackageMan'] = function()
    return {
      Require = function(_, _, module)
        local ok, mod = pcall(require, module)
        if ok then return mod end
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

describe('Enum integration properties', function()
  it('Property 11: all enum values produce valid commands', function()
    -- Feature: comprehensive-property-based-testing, Property 11
    
    -- Test Class enum with byclass
    property.forall(
      { generators.class_value() },
      function(class_value)
        local actionable = Actionable.byclass(class_value)
        local output = capture(function()
          LuaBots:stance(2, actionable)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(class_value):len() > 0)
      end,
      { iterations = 20 }
    )
    
    -- Test Race enum with byrace
    property.forall(
      { generators.race_value() },
      function(race_value)
        local actionable = Actionable.byrace(race_value)
        local output = capture(function()
          LuaBots:stance(2, actionable)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(race_value):len() > 0)
      end,
      { iterations = 20 }
    )
    
    -- Test Gender enum with botcreate
    property.forall(
      { generators.gender_value() },
      function(gender_value)
        local output = capture(function()
          LuaBots:botcreate('TestBot', 1, 1, gender_value)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(gender_value):len() > 0)
      end,
      { iterations = 5 }
    )
    
    -- Test SpellType enum with cast
    property.forall(
      { generators.spell_type_value() },
      function(spell_type_value)
        local output = capture(function()
          LuaBots:cast(spell_type_value)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(spell_type_value):len() > 0)
      end,
      { iterations = 20 }
    )
    
    -- Test Stance enum with stance command
    property.forall(
      { generators.stance_value() },
      function(stance_value)
        local output = capture(function()
          LuaBots:stance(stance_value)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(stance_value):len() > 0)
      end,
      { iterations = 20 }
    )
    
    -- Test MaterialSlot enum with botdyearmor
    property.forall(
      { generators.material_slot_value() },
      function(material_slot_value)
        local output = capture(function()
          LuaBots:botdyearmor(material_slot_value, 100, 100, 100)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(material_slot_value):len() > 0)
      end,
      { iterations = 10 }
    )
    
    -- Test PetType enum with petsettype
    property.forall(
      { generators.pet_type_value() },
      function(pet_type_value)
        local output = capture(function()
          LuaBots:petsettype(pet_type_value)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(pet_type_value):len() > 0)
      end,
      { iterations = 10 }
    )
    
    -- Test Slot enum with clickitem
    property.forall(
      { generators.slot_value() },
      function(slot_value)
        local output = capture(function()
          LuaBots:clickitem(slot_value)
        end)
        assert.is_true(output:sub(1, 6) == '/say ^')
        assert.is_true(tostring(slot_value):len() > 0)
      end,
      { iterations = 20 }
    )
  end)
end)
