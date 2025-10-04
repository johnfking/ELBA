local function setup_package_aliases()
  local function alias(name, target)
    if not package.preload[name] and not package.loaded[name] then
      package.preload[name] = function() return require(target) end
    end
  end

  alias('ELBA.init', 'init')
  alias('ELBA.Actionable', 'Actionable')
  alias('ELBA.enums.Slot', 'enums.Slot')
  alias('ELBA.enums.Class', 'enums.Class')
  alias('ELBA.enums.Gender', 'enums.Gender')
  alias('ELBA.enums.Race', 'enums.Race')
  alias('ELBA.enums.SpellType', 'enums.SpellType')
  alias('ELBA.enums.SpellDelayCategory', 'enums.SpellDelayCategory')
  alias('ELBA.enums.Stance', 'enums.Stance')
  alias('ELBA.enums.SpellHoldCategory', 'enums.SpellHoldCategory')
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
local Elba = require('ELBA.init')
local Actionable = require('Actionable')
local PetType = require('enums.PetType')
local Slot = require('enums.Slot')
local SpellType = require('enums.SpellType')
local Stance = require('enums.Stance')
local SpellDelayCategory = require('enums.SpellDelayCategory')
local SpellHoldCategory = require('enums.SpellHoldCategory')

describe('SpellType enumeration', function()
  it('values are numeric', function()
    assert.are.equal('number', type(SpellType.NUKE))
    assert.are.equal('number', type(SpellType.FAST_HEALS))
  end)
end)

describe('SpellDelayCategory enumeration', function()
  it('values are strings', function()
    assert.are.equal('string', type(SpellDelayCategory.NUKES))
    assert.are.equal('string', type(SpellDelayCategory.FAST_HEALS))
  end)
end)

describe('Stance enumeration', function()
  it('values are numeric', function()
    assert.are.equal('number', type(Stance.PASSIVE))
    assert.are.equal('number', type(Stance.BURN))
  end)
end)

local function capture(fn)
  local output = {}
  local orig = io.write
  io.write = function(str) table.insert(output, str) end
  fn()
  io.write = orig
  return table.concat(output)
end

describe('Elba commands with Actionable', function()
  local actions = {
    {name = 'target',                   ctor = Actionable.target},
    {name = 'byname',                   ctor = function() return Actionable.byname('Bob') end},
    {name = 'ownergroup',               ctor = Actionable.ownergroup},
    {name = 'botgroup',                 ctor = function() return Actionable.botgroup('grp') end},
    {name = 'targetgroup',              ctor = Actionable.targetgroup},
    {name = 'namesgroup',               ctor = function() return Actionable.namesgroup('grp') end},
    {name = 'healrotation',             ctor = function() return Actionable.healrotation('rot') end},
    {name = 'healrotationmembers',      ctor = function() return Actionable.healrotationmembers('rot') end},
    {name = 'healrotationtargets',      ctor = function() return Actionable.healrotationtargets('rot') end},
    {name = 'spawned',                  ctor = Actionable.spawned},
    {name = 'all',                      ctor = Actionable.all},
  }

  for _, case in ipairs(actions) do
    it('stance with '..case.name, function()
      local act = case.ctor()
      local out = capture(function() Elba:stance(Stance.PASSIVE, act) end)
      assert.are.equal('/say ^stance '..tostring(Stance.PASSIVE)..' '..tostring(act)..'\n', out)
    end)
  end

  for _, case in ipairs(actions) do
    it('behindmob with '..case.name, function()
      local act = case.ctor()
      local out = capture(function() Elba:behindmob(0, act) end)
      assert.are.equal('/say ^behindmob 0 '..tostring(act)..'\n', out)
    end)
  end

  it('clickitem uses enums', function()
    local act = Actionable.target()
    local out = capture(function() Elba:clickitem(Slot.MAINHAND, act) end)
    assert.are.equal('/say ^clickitem '..tostring(Slot.MAINHAND)..' '..tostring(act)..'\n', out)
  end)

  it('petsettype uses enum', function()
    local act = Actionable.all()
    local out = capture(function() Elba:petsettype(PetType.AIR, act) end)
    assert.are.equal('/say ^petsettype '..PetType.AIR..' '..tostring(act)..'\n', out)
  end)

  it('defaultsettings without value', function()
    local act = Actionable.target()
    local out = capture(function() Elba:defaultsettings(act) end)
    assert.are.equal('/say ^defaultsettings '..tostring(act)..'\n', out)
  end)

  it('illusionblock toggled', function()
    local act = Actionable.target()
    local out = capture(function() Elba:illusionblock(1, act) end)
    assert.are.equal('/say ^illusionblock 1 '..tostring(act)..'\n', out)
  end)

  it('distanceranged numeric', function()
    local act = Actionable.all()
    local out = capture(function() Elba:distanceranged(25, act) end)
    assert.are.equal('/say ^distanceranged 25 '..tostring(act)..'\n', out)
  end)

  it('bottoggleranged toggle', function()
    local act = Actionable.all()
    local out = capture(function() Elba:bottoggleranged(0, act) end)
    assert.are.equal('/say ^bottoggleranged 0 '..tostring(act)..'\n', out)
  end)

  it('spellholds category', function()
    local act = Actionable.target()
    local out = capture(function() Elba:spellholds(SpellHoldCategory.NUKES, 1, act) end)
    assert.are.equal('/say ^spellholds '..tostring(SpellHoldCategory.NUKES)..' 1 '..tostring(act)..'\n', out)
  end)

  it('spelldelays category', function()
    local act = Actionable.target()
    local out = capture(function() Elba:spelldelays(SpellDelayCategory.FAST_HEALS, 200, act) end)
    assert.are.equal('/say ^spelldelays '..tostring(SpellDelayCategory.FAST_HEALS)..' 200 '..tostring(act)..'\n', out)
  end)

  it('spellmaxthresholds category', function()
    local act = Actionable.target()
    local out = capture(function() Elba:spellmaxthresholds(SpellType.COMPLETE_HEAL, 50, act) end)
    assert.are.equal('/say ^spellmaxthresholds '..tostring(SpellType.COMPLETE_HEAL)..' 50 '..tostring(act)..'\n', out)
  end)
end)

describe('Command methods', function()
  local commands = {
    'stance','applypoison','applypotion','attack','behindmob','blockedbuffs',
    'blockedpetbuffs','botappearance','botbeardcolor','botbeardstyle','botcamp',
    'botdetails','boteyes','botface','botfollowdistance','bothaircolor',
    'bothairstyle','botheritage','botlist','botoutofcombat','botreport',
    'botsettings','botspawn','botstance','botsuffix','botsummon','botsurname',
    'bottattoo','bottitle','bottogglearcher','bottogglehelm','bottoggleranged',
    'botupdate','botwoad','cast','casterrange','classracelist','clickitem',
    'copysettings','cure','defaultsettings','defensive','depart','discipline',
    'distanceranged','enforcespellsettings','escape','findaliases','follow',
    'guard','healrotation','healrotationaddmember','healrotationaddtarget',
    'healrotationfastheals','healrotationlist','healrotationremovemember',
    'healrotationremovetarget','healrotationresetlimits','healrotationsave',
    'healrotationstart','healrotationstop','help','hold','identify',
    'illusionblock','inventory','inventorygive','inventorylist','inventoryremove',
    'inventorywindow','invisibility','itemuse','levitation','lull',
    'maxmeleerange','mesmerize','movementspeed','owneroption','pet','petgetlost',
    'petremove','petsettype','picklock','pickpocket','portal','precombat',
    'pull','release','resistance','resurrect','rune','sendhome','setassistee',
    'sithppercent','sitincombat','sitmanapercent','size','spellaggrochecks',
    'spellannouncecasts','spelldelays','spellengagedpriority','spellholds',
    'spellidlepriority','spellinfo','spellmaxhppct','spellmaxmanapct',
    'spellmaxthresholds','spellminhppct','spellminmanapct','spellminthresholds',
    'spellpursuepriority','spellresistlimits','spells','spellsettings',
    'spellsettingsadd','spellsettingsdelete','spellsettingstoggle',
    'spellsettingsupdate','spelltargetcount','spelltypeids','spelltypenames',
    'summoncorpse','suspend','taunt','timer','track','viewcombos','waterbreathing'
  }
  local filtered = {}
  for _, name in ipairs(commands) do
    if type(Elba[name]) == 'function' then
      table.insert(filtered, name)
    end
  end

  commands = filtered

  local act = Actionable.target()
  for _, cmd in ipairs(commands) do
    it('runs '..cmd..' with target', function()
      local out = capture(function() Elba[cmd](Elba, 'foo', act) end)
      assert.are.equal('/say ^'..cmd..' foo '..tostring(act)..'\n', out)
    end)

    it('runs '..cmd..' without target', function()
      local out = capture(function() Elba[cmd](Elba, 'foo') end)
      assert.are.equal('/say ^'..cmd..' foo\n', out)
    end)
  end
end)
