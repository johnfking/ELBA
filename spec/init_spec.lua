local function setup_package_manager_stub()
  if package.preload['mq.PackageMan'] or package.loaded['mq.PackageMan'] then
    return
  end

  ---@diagnostic disable-next-line: duplicate-set-field
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

setup_package_manager_stub()

local LuaBots = require('init')
local Actionable = require('LuaBots.Actionable')
local Class = require('enums.Class')
local Gender = require('enums.Gender')
local MaterialSlot = require('enums.MaterialSlot')
local PetType = require('enums.PetType')
local Race = require('enums.Race')
local Slot = require('enums.Slot')
local SpellDelayCategory = require('enums.SpellDelayCategory')
local SpellHoldCategory = require('enums.SpellHoldCategory')
local SpellType = require('enums.SpellType')
local Stance = require('enums.Stance')
local test_helpers = require('spec.test_helpers')
local capture = test_helpers.capture

local function read_init_source()
  local handle = assert(io.open('init.lua', 'r'))
  local text = handle:read('*a')
  handle:close()
  return text
end

local function parse_command_definitions()
  local defs = {}
  for name, params in read_init_source():gmatch('function%s+LuaBots:([%w_]+)%(([^)]*)%)') do
    local arguments = {}
    for param in params:gmatch('([%w_]+)') do
      table.insert(arguments, param)
    end
    table.insert(defs, {name = name, params = arguments})
  end
  return defs
end

local function has_act_parameter(params)
  for _, param in ipairs(params) do
    if param == 'act' then
      return true
    end
  end
  return false
end

local function clone(list)
  local copy = {}
  for index, value in ipairs(list) do
    copy[index] = value
  end
  return copy
end

local function expected_message(command, args, include_actionable, actionable)
  local parts = {'/say ^' .. command}
  for _, value in ipairs(args) do
    table.insert(parts, tostring(value))
  end
  if include_actionable then
    table.insert(parts, tostring(actionable))
  end
  return table.concat(parts, ' ') .. '\n'
end

local command_args_overrides = {
  stance = {Stance.PASSIVE},
  botdyearmor = {MaterialSlot.HEAD, 10, 20, 30},
  cast = {SpellType.NUKE},
  clickitem = {Slot.MAINHAND},
  distanceranged = {120},
  maxmeleerange = {50},
  petsettype = {PetType.AIR},
  spellholds = {SpellHoldCategory.NUKES, 1},
  spelldelays = {SpellDelayCategory.NUKES, 150},
  spellmaxthresholds = {SpellType.FAST_HEALS, 65},
  spellmaxhppct = {80},
  spellmaxmanapct = {70},
  spellminhppct = {40},
  spellminmanapct = {30},
  spelltargetcount = {5},
  healrotationadaptivetargeting = {1},
  healrotationadjustcritical = {10},
  healrotationadjustsafe = {15},
  healrotationcastingoverride = {1},
  healrotationchangeinterval = {12},
  botstopmeleelevel = {60},
  sithppercent = {40},
  sitmanapercent = {30},
  sitincombat = {1},
  owneroption = {'assist'},
  timer = {30},
  defaultsettings = {},
}

local function default_args(name, params, include_actionable)
  local override = command_args_overrides[name]
  if override then
    return override
  end
  local count = #params - (include_actionable and 1 or 0)
  if count <= 0 then
    return {}
  end
  local args = {}
  for index = 1, count do
    args[index] = 'foo'
  end
  return args
end

local command_definitions = parse_command_definitions()

local enum_tests = {
  {label = 'Class', module = Class, expected = {
    NONE         = 0,
    WARRIOR      = 1,
    CLERIC       = 2,
    PALADIN      = 3,
    RANGER       = 4,
    SHADOWKNIGHT = 5,
    DRUID        = 6,
    MONK         = 7,
    BARD         = 8,
    ROGUE        = 9,
    SHAMAN       = 10,
    NECROMANCER  = 11,
    WIZARD       = 12,
    MAGICIAN     = 13,
    ENCHANTER    = 14,
    BEASTLORD    = 15,
    BERSERKER    = 16,
  }},
  {label = 'Race', module = Race, expected = {
    HUMAN     = 1,
    BARBARIAN = 2,
    ERUDITE   = 3,
    WOOD_ELF  = 4,
    HIGH_ELF  = 5,
    DARK_ELF  = 6,
    HALF_ELF  = 7,
    DWARF     = 8,
    TROLL     = 9,
    OGRE      = 10,
    HALFLING  = 11,
    GNOME     = 12,
    IKSAR     = 128,
    VAH_SHIR  = 130,
    FROGLOK   = 330,
    DRAKKIN   = 522,
  }},
  {label = 'Gender', module = Gender, expected = {
    MALE   = 0,
    FEMALE = 1,
  }},
  {label = 'Slot', module = Slot, expected = {
    CHARM       = 0,
    LEFTEAR     = 1,
    HEAD        = 2,
    FACE        = 3,
    RIGHTEAR    = 4,
    NECK        = 5,
    SHOULDER    = 6,
    ARMS        = 7,
    BACK        = 8,
    LEFTWRIST   = 9,
    RIGHTWRIST  = 10,
    RANGED      = 11,
    HANDS       = 12,
    MAINHAND    = 13,
    OFFHAND     = 14,
    LEFTFINGER  = 15,
    RIGHTFINGER = 16,
    CHEST       = 17,
    LEGS        = 18,
    FEET        = 19,
    WAIST       = 20,
    POWERSOURCE = 21,
    AMMO        = 22,
  }},
  {label = 'SpellType', module = SpellType, expected = {
    NUKE                       = 0,
    REGULAR_HEAL               = 1,
    ROOT                       = 2,
    BUFF                       = 3,
    ESCAPE                     = 4,
    PET                        = 5,
    LIFETAP                    = 6,
    SNARE                      = 7,
    DAMAGE_OVER_TIME           = 8,
    DISPEL                     = 9,
    IN_COMBAT_BUFF             = 10,
    MESMERIZE                  = 11,
    CHARM                      = 12,
    SLOW                       = 13,
    DEBUFF                     = 14,
    CURE                       = 15,
    RESURRECT                  = 16,
    HATE_REDUCTION             = 17,
    IN_COMBAT_BUFF_SONG        = 18,
    OUT_OF_COMBAT_BUFF_SONG    = 19,
    PRE_COMBAT_BUFF            = 20,
    PRE_COMBAT_BUFF_SONG       = 21,
    FEAR                       = 22,
    STUN                       = 23,
    HATE_LINE                  = 24,
    GROUP_CURES                = 25,
    COMPLETE_HEAL              = 26,
    FAST_HEALS                 = 27,
    VERY_FAST_HEALS            = 28,
    GROUP_HEALS                = 29,
    GROUP_COMPLETE_HEALS       = 30,
    GROUP_HEAL_OVER_TIME_HEALS = 31,
    HEAL_OVER_TIME_HEALS       = 32,
    AE_NUKES                   = 33,
    AE_RAINS                   = 34,
    AE_MESMERIZE               = 35,
    AE_STUN                    = 36,
    AE_DEBUFF                  = 37,
    AE_SLOW                    = 38,
    AE_SNARE                   = 39,
    AE_FEAR                    = 40,
    AE_DISPEL                  = 41,
    AE_ROOT                    = 42,
    AE_DAMAGE_OVER_TIME        = 43,
    AE_LIFETAP                 = 44,
    AE_HATE_LINE               = 45,
    POINT_BLANK_AE_NUKE        = 46,
    PET_BUFFS                  = 47,
    PET_REGULAR_HEALS          = 48,
    PET_COMPLETE_HEALS         = 49,
    PET_FAST_HEALS             = 50,
    PET_VERY_FAST_HEALS        = 51,
    PET_HEAL_OVER_TIME_HEALS   = 52,
    PET_CURES                  = 53,
    DAMAGE_SHIELDS             = 54,
    RESIST_BUFFS               = 55,
    PET_DAMAGE_SHIELDS         = 56,
    PET_RESIST_BUFFS           = 57,
    TELEPORT                   = 100,
    LULL                       = 101,
    SUCCOR                     = 102,
    BIND_AFFINITY              = 103,
    IDENTIFY                   = 104,
    LEVITATE                   = 105,
    RUNE                       = 106,
    WATER_BREATHING            = 107,
    SIZE                       = 108,
    INVISIBILITY               = 109,
    MOVEMENT_SPEED             = 110,
    SEND_HOME                  = 111,
    SUMMON_CORPSE              = 112,
    AE_LULL                    = 113,
    DISCIPLINE_ALL             = 200,
    DISCIPLINE_AGGRESSIVE      = 201,
    DISCIPLINE_DEFENSIVE       = 202,
    DISCIPLINE_UTILITY         = 203,
  }},
  {label = 'SpellDelayCategory', module = SpellDelayCategory, expected = {
    NUKES           = 'nukes',
    DOTS            = 'dots',
    SLOWS           = 'slows',
    DEBUFFS         = 'debuffs',
    STUNS           = 'stuns',
    COMPLETE_HEALS  = 'completeheals',
    FAST_HEALS      = 'fastheals',
    VERY_FAST_HEALS = 'veryfastheals',
  }},
  {label = 'SpellHoldCategory', module = SpellHoldCategory, expected = {
    NUKES                = 'nukes',
    REGULAR_HEALS        = 'regularheals',
    ROOTS                = 'roots',
    PETS                 = 'pets',
    SNARES               = 'snares',
    DOTS                 = 'dots',
    SLOWS                = 'slows',
    DEBUFFS              = 'debuffs',
    CURES                = 'cures',
    STUNS                = 'stuns',
    COMPLETE_HEALS       = 'completeheals',
    GROUP_HEALS          = 'groupheals',
    GROUP_COMPLETE_HEALS = 'groupcompleteheals',
    GROUP_HOT_HEALS      = 'grouphotheals',
    HOT_HEALS            = 'hotheals',
    AE_DEBUFFS           = 'aedebuffs',
    AE_SLOWS             = 'aeslows',
    PET_REGULAR_HEALS    = 'petregularheals',
    PET_HOT_HEALS        = 'pethotheals',
    PET_COMPLETE_HEALS   = 'petcompleteheals',
    PET_CURES            = 'petcures',
    PET_DAMAGE_SHIELDS   = 'petdamageshields',
    PET_RESIST_BUFFS     = 'petresistbuffs',
  }},
  {label = 'Stance', module = Stance, expected = {
    PASSIVE     = 1,
    BALANCED    = 2,
    EFFICIENT   = 3,
    REACTIVE    = 4,
    AGGRESSIVE  = 5,
    ASSIST      = 6,
    BURN        = 7,
    EFFICIENT_2 = 8,
    BURN_AE     = 9,
  }},
  {label = 'MaterialSlot', module = MaterialSlot, expected = {
    ALL   = '*',
    HEAD  = 1,
    CHEST = 2,
    ARMS  = 3,
    WRISTS = 4,
    HANDS = 5,
    LEGS  = 6,
    FEET  = 7,
  }},
  {label = 'PetType', module = PetType, expected = {
    AIR   = 'air',
    WATER = 'water',
    FIRE  = 'fire',
    EARTH = 'earth',
    EPIC  = 'epic',
  }},
}

for _, data in ipairs(enum_tests) do
  describe(data.label .. ' enumeration', function()
    it('matches EQEmu values', function()
      assert.are.same(data.expected, data.module)
    end)

    it('is exposed on LuaBots', function()
      assert.are.equal(data.module, LuaBots[data.label])
    end)
  end)
end

describe('Command forwarding', function()
  local actionable = Actionable.target()

  for _, def in ipairs(command_definitions) do
    local name = def.name
    if name ~= 'initialize' and name ~= 'botcreate' then
      local params = def.params
      local includes_actionable = has_act_parameter(params)
      local args = clone(default_args(name, params, includes_actionable))

      it(('sends %s command with defaults'):format(name), function()
        local to_call = clone(args)
        if includes_actionable then
          table.insert(to_call, actionable)
        end
        local output = capture(function()
          LuaBots[name](LuaBots, table.unpack(to_call))
        end)
        assert.are.equal(
          expected_message(name, args, includes_actionable, actionable),
          output
        )
      end)

      if includes_actionable then
        it(('sends %s command without actionable'):format(name), function()
          local output = capture(function()
            LuaBots[name](LuaBots, table.unpack(args))
          end)
          assert.are.equal(expected_message(name, args, false, actionable), output)
        end)
      end
    end
  end
end)

describe('botcreate helper', function()
  it('formats the creation request and returns metadata', function()
    local args = {'Testbot', Class.WARRIOR, Race.HUMAN, Gender.MALE}
    local result
    local output = capture(function()
      result = LuaBots:botcreate(table.unpack(args))
    end)

    assert.are.equal(
      expected_message('botcreate', args, false, nil),
      output
    )

    assert.are.same({
      Name = 'Testbot',
      Class = Class.WARRIOR,
      Race = Race.HUMAN,
      Gender = Gender.MALE,
    }, result)
  end)
end)
