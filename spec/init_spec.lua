-- local function setup_package_aliases()
--   package.preload['ELBA.Actionable'] = function() return require('Actionable') end
--   package.preload['ELBA.enums.Slot'] = function() return require('enums.Slot') end
--   package.preload['ELBA.enums.Class'] = function() return require('enums.Class') end
--   package.preload['ELBA.enums.Gender'] = function() return require('enums.Gender') end
--   package.preload['ELBA.enums.Race'] = function() return require('enums.Race') end
--   package.preload['ELBA.enums.SpellType'] = function() return require('enums.SpellType') end
--   package.preload['ELBA.enums.Stance'] = function() return require('enums.Stance') end
-- end

--setup_package_aliases()
local Elba = require('ELBA.Bots')
local Actionable = require('Actionable')
local PetType = require('enums.PetType')
local Slot = require('enums.Slot')
local SpellType = require('enums.SpellType')
local Stance = require('enums.Stance')

describe('SpellType enumeration', function()
  it('values are numeric', function()
    assert.are.equal('number', type(SpellType.NUKE))
    assert.are.equal('number', type(SpellType.FAST_HEALS))
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
    local out = capture(function() Elba:spellholds(SpellType.NUKE, 1, act) end)
    assert.are.equal('/say ^spellholds '..tostring(SpellType.NUKE)..' 1 '..tostring(act)..'\n', out)
  end)

  it('spelldelays category', function()
    local act = Actionable.target()
    local out = capture(function() Elba:spelldelays(SpellType.FAST_HEALS, 200, act) end)
    assert.are.equal('/say ^spelldelays '..tostring(SpellType.FAST_HEALS)..' 200 '..tostring(act)..'\n', out)
  end)

  it('spellmaxthresholds category', function()
    local act = Actionable.target()
    local out = capture(function() Elba:spellmaxthresholds(SpellType.COMPLETE_HEAL, 50, act) end)
    assert.are.equal('/say ^spellmaxthresholds '..tostring(SpellType.COMPLETE_HEAL)..' 50 '..tostring(act)..'\n', out)
  end)
end)

describe('Command methods', function()
  local commands = {
    'stance','actionable','aggressive','applypoison','applypotion','attack','behindmob',
    'bindaffinity','blockedbuffs','blockedpetbuffs','bot','botappearance',
    'botbeardcolor','botbeardstyle','botcamp','botclone','botcreate','botdelete',
    'botdetails','botdyearmor','boteyes','botface','botfollowdistance',
    'bothaircolor','bothairstyle','botheritage','botinspectmessage','botlist',
    'botoutofcombat','botreport','botsettings','botspawn','botstance',
    'botstopmeleelevel','botsuffix','botsummon','botsurname','bottattoo',
    'bottitle','bottogglearcher','bottogglehelm','bottoggleranged','botupdate',
    'botwoad','cast','casterrange','charm','circle','classracelist','clickitem',
    'copysettings','cure','defaultsettings','defensive','depart','discipline',
    'distanceranged','enforcespellsettings','escape','findaliases','follow',
    'guard','healrotation','healrotationadaptivetargeting','healrotationaddmember',
    'healrotationaddtarget','healrotationadjustcritical','healrotationadjustsafe',
    'healrotationcastingoverride','healrotationchangeinterval','healrotationclearhot',
    'healrotationcleartargets','healrotationcreate','healrotationdelete',
    'healrotationfastheals','healrotationlist','healrotationremovemember',
    'healrotationremovetarget','healrotationresetlimits','healrotationsave',
    'healrotationsethot','healrotationstart','healrotationstop','help','hold',
    'identify','illusionblock','inventory','inventorygive','inventorylist',
    'inventoryremove','inventorywindow','invisibility','itemuse','levitation',
    'lull','maxmeleerange','mesmerize','movementspeed','owneroption','pet',
    'petgetlost','petremove','petsettype','picklock','pickpocket','portal',
    'precombat','pull','release','resistance','resurrect','rune','sendhome',
    'setassistee','sithppercent','sitincombat','sitmanapercent','size',
    'spellaggrochecks','spellannouncecasts','spelldelays','spellengagedpriority',
    'spellholds','spellidlepriority','spellinfo','spellmaxhppct','spellmaxmanapct',
    'spellmaxthresholds','spellminhppct','spellminmanapct','spellminthresholds',
    'spellpursuepriority','spellresistlimits','spells','spellsettings',
    'spellsettingsadd','spellsettingsdelete','spellsettingstoggle',
    'spellsettingsupdate','spelltargetcount','spelltypeids','spelltypenames',
    'summoncorpse','suspend','taunt','timer','track','viewcombos','waterbreathing'
  }
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
