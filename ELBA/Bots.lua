--
-- Emu Lua Bot API (ELBA)
--

local mq = require('mq')

---@class Elba
local Elba = {}

-- Modules live at the repository root, so require them directly
Elba.Actionable  = require('Actionable')
Elba.Slot        = require('enums.Slot')
Elba.Class       = require('enums.Class')
Elba.Gender      = require('enums.Gender')
Elba.Race        = require('enums.Race')
Elba.SpellType   = require('enums.SpellType')
Elba.Stance      = require('enums.Stance')

Elba.__index = Elba

-- List of available bot commands
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

-- Execute a bot command by concatenating arguments
local function exec(cmd, ...)
    local parts = { '/say ^' .. cmd }
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        if arg ~= nil then
            table.insert(parts, tostring(arg))
        end
    end
    mq.cmdf(table.concat(parts, ' '))
end

-- Generate methods for each command
for _, cmd in ipairs(commands) do
    Elba[cmd] = function(self, ...)
        exec(cmd, ...)
    end
end

return Elba
