--
-- Domain-specific test data generators for LuaBots
-- Builds on the property framework to create bot-specific test data
--

package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

local property = require('spec.property')
local Actionable = require('Actionable')

local generators = {}

--- Generate actionable types that require selectors
function generators.actionable_type_requiring_selector()
  local types_requiring_selector = {}
  for actionable_type, requires in pairs(Actionable.RequiresSelector) do
    if requires then
      table.insert(types_requiring_selector, actionable_type)
    end
  end
  return property.oneof(types_requiring_selector)
end

--- Generate actionable types that do not require selectors
function generators.actionable_type_not_requiring_selector()
  local types_not_requiring_selector = {}
  for actionable_type, _ in pairs(Actionable.ActionableType) do
    if not Actionable.RequiresSelector[actionable_type] then
      table.insert(types_not_requiring_selector, actionable_type)
    end
  end
  return property.oneof(types_not_requiring_selector)
end

--- Generate selector strings with various lengths and characters
function generators.selector_string()
  return {
    generate = function()
      local choice = math.random(1, 5)
      if choice == 1 then
        -- Short alphanumeric
        return property.string(1, 10).generate()
      elseif choice == 2 then
        -- Long string
        return property.string(50, 200).generate()
      elseif choice == 3 then
        -- String with spaces
        return property.string(5, 15, 'abcdefghij ').generate()
      elseif choice == 4 then
        -- String with special characters
        return property.string(5, 15, 'abc123!@#$%^&*()_+-=[]{}|;:,.<>?').generate()
      else
        -- Empty string (edge case)
        return ''
      end
    end
  }
end

--- Generate Actionable instances with selectors
function generators.actionable_with_selector()
  return {
    generate = function()
      local actionable_type = generators.actionable_type_requiring_selector().generate()
      local selector = generators.selector_string().generate()
      -- Ensure selector is not empty for types requiring it
      if selector == '' then
        selector = 'default'
      end
      return Actionable.new(actionable_type, selector)
    end
  }
end

--- Generate Actionable instances without selectors
function generators.actionable_without_selector()
  return {
    generate = function()
      local actionable_type = generators.actionable_type_not_requiring_selector().generate()
      return Actionable.new(actionable_type)
    end
  }
end

--- Generate any valid Actionable instance
function generators.any_actionable()
  return {
    generate = function()
      if math.random() < 0.5 then
        return generators.actionable_with_selector().generate()
      else
        return generators.actionable_without_selector().generate()
      end
    end
  }
end

-- Load enum modules
local Class = require('enums.Class')
local Race = require('enums.Race')
local Gender = require('enums.Gender')
local SpellType = require('enums.SpellType')
local Stance = require('enums.Stance')
local MaterialSlot = require('enums.MaterialSlot')
local PetType = require('enums.PetType')
local Slot = require('enums.Slot')

--- Helper to get all values from an enum table
local function enum_values(enum_table)
  local values = {}
  for _, value in pairs(enum_table) do
    table.insert(values, value)
  end
  return values
end

--- Generate Class enum values
function generators.class_value()
  return property.oneof(enum_values(Class))
end

--- Generate Race enum values
function generators.race_value()
  return property.oneof(enum_values(Race))
end

--- Generate Gender enum values
function generators.gender_value()
  return property.oneof(enum_values(Gender))
end

--- Generate SpellType enum values
function generators.spell_type_value()
  return property.oneof(enum_values(SpellType))
end

--- Generate Stance enum values
function generators.stance_value()
  return property.oneof(enum_values(Stance))
end

--- Generate MaterialSlot enum values
function generators.material_slot_value()
  return property.oneof(enum_values(MaterialSlot))
end

--- Generate PetType enum values
function generators.pet_type_value()
  return property.oneof(enum_values(PetType))
end

--- Generate Slot enum values
function generators.slot_value()
  return property.oneof(enum_values(Slot))
end

--- Generate any enum value from any enum type
function generators.any_enum_value()
  return {
    generate = function()
      local enum_gen = property.oneof({
        generators.class_value(),
        generators.race_value(),
        generators.gender_value(),
        generators.spell_type_value(),
        generators.stance_value(),
        generators.material_slot_value(),
        generators.pet_type_value(),
        generators.slot_value()
      }).generate()
      return enum_gen.generate()
    end
  }
end

--- Generate bot names
function generators.bot_name()
  return property.string(3, 15)
end

--- Generate numeric parameters for commands
function generators.numeric_parameter()
  return property.integer(0, 255)
end

--- Generate string parameters
function generators.string_parameter()
  return property.string(1, 20)
end

--- Generate command names from LuaBots
function generators.command_name()
  local commands = {
    'stance', 'attack', 'behindmob', 'cast', 'follow', 'guard',
    'hold', 'taunt', 'assist', 'camp', 'spawn', 'delete'
  }
  return property.oneof(commands)
end

return generators
