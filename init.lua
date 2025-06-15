--
-- Emu Lua Bot API (ELBA)
--

local mq = require('mq')

---@class Elba
local Elba = {}

-- Load Modules
Elba.Actionable  = require('ELBA.Actionable')
Elba.Class       = require('ELBA.enums.Class')
Elba.Slot        = require('ELBA.enums.Slot')
Elba.Gender      = require('ELBA.enums.Gender')
Elba.Race        = require('ELBA.enums.Race')
Elba.SpellType   = require('ELBA.enums.SpellType')
Elba.Stance      = require('ELBA.enums.Stance')

local race_enum_map = {
    [1]   = "human",
    [2]   = "human",     -- barbarian
    [3]   = "human",     -- erudite
    [4]   = "elf",
    [5]   = "elf",
    [6]   = "elf",
    [7]   = "half-elf",
    [8]   = "dwarf",
    [9]   = "troll",
    [10]  = "orc",       -- ogre -> orc
    [11]  = "halfling",
    [12]  = "gnome",
    [128] = "dragonborn", -- iksar -> close enough
    [130] = "tiefling",   -- vah shir -> best match
    [330] = "goblin",     -- froglock -> best effort
    [522] = "dragonborn", -- drakkin -> dragonborn-adjacent
}

local gender_enum_map = {
    [0] = "male",
    [1] = "female"
}

Elba.__index = Elba

--- Send a bot command with up to two values and an optional Actionable.
---@param cmd string
---@param val1 any?
---@param val2 any?
---@param act Actionable?
local function run(cmd, val1, val2, act)
    local parts = { '/say ^' .. cmd }
    if val1 ~= nil then table.insert(parts, tostring(val1)) end
    if val2 ~= nil then table.insert(parts, tostring(val2)) end
    if act ~= nil then table.insert(parts, tostring(act)) end
    mq.cmdf(table.concat(parts, ' '))
end

function Elba:initialize()
    local PackageMan = require('mq.PackageMan')

    local socket = PackageMan.Require('luasocket')
    local json   = PackageMan.Require('lua-cjson', 'cjson')

    local http = require('socket.http')
    local ltn12 = require('ltn12')

end


--- Changes the statnce (e.g. Passive, Agressive, Balanced, etc.) of Bots.
---@param value any?
---@param act Actionable?
function Elba:stance(value, act)
    run('stance', value, act)
end

--- Execute the 'applypoison' command.
---@param value any?
---@param act Actionable?
function Elba:applypoison(value, act)
    run('applypoison', value, act)
end

--- Execute the 'applypotion' command.
---@param value any?
---@param act Actionable?
function Elba:applypotion(value, act)
    run('applypotion', value, act)
end

--- Execute the 'attack' command.
---@param value any?
---@param act Actionable?
function Elba:attack(value, act)
    run('attack', value, act)
end

--- Execute the 'behindmob' command.
---@param value any?
---@param act Actionable?
function Elba:behindmob(value, act)
    run('behindmob', value, act)
end

--- Execute the 'bindaffinity' command.
---@param value any?
---@param act Actionable?
function Elba:bindaffinity(value, act)
    run('bindaffinity', value, act)
end

--- Execute the 'blockedbuffs' command.
---@param value any?
---@param act Actionable?
function Elba:blockedbuffs(value, act)
    run('blockedbuffs', value, act)
end

--- Execute the 'blockedpetbuffs' command.
---@param value any?
---@param act Actionable?
function Elba:blockedpetbuffs(value, act)
    run('blockedpetbuffs', value, act)
end

--- Execute the 'botappearance' command.
---@param value any?
---@param act Actionable?
function Elba:botappearance(value, act)
    run('botappearance', value, act)
end

--- Execute the 'botbeardcolor' command.
---@param value any?
---@param act Actionable?
function Elba:botbeardcolor(value, act)
    run('botbeardcolor', value, act)
end

--- Execute the 'botbeardstyle' command.
---@param value any?
---@param act Actionable?
function Elba:botbeardstyle(value, act)
    run('botbeardstyle', value, act)
end

--- Execute the 'botcamp' command.
---@param value any?
---@param act Actionable?
function Elba:botcamp(value, act)
    run('botcamp', value, act)
end

---Creates a bot
---@param name string
---@param class Class | number
---@param race Race | number
---@param gener Gender | number
function Elba:botcreate(name, class, race, gener)
    if name == "AUTO" then
        local api_race = race_enum_map[race] or "human"
        local api_gender = gender_enum_map[gener] or "male"
        local url = string.format("https://names.ironarachne.com/race/%s/%s/1", api_race, api_gender)

        local response = {}
        local _, code = http.request{
            url = url,
            sink = ltn12.sink.table(response)
        }

        if code == 200 then
            local body = table.concat(response)
            local names = json.decode(body)
            if type(names) == "table" and #names > 0 then
                name = names[1]
                print(string.format("[Elba] Auto-generated bot name: %s", name))
            else
                print("[Elba] Failed to get valid name from API.")
                return
            end
        else
            print(string.format("[Elba] Name API request failed. HTTP %d", code or 0))
            return
        end
    end
    mq.cmdf("/say ^botcreate %s %d %d %d")
end

--- Execute the 'botdelete' command.
---@param value any?
---@param act Actionable?
function Elba:botdelete(value, act)
    run('botdelete', value, act)
end

--- Execute the 'botdetails' command.
---@param value any?
---@param act Actionable?
function Elba:botdetails(value, act)
    run('botdetails', value, act)
end

--- Execute the 'botdyearmor' command.
---@param materialSlot MaterialSlot | string
---@param red number
---@param blue number
---@param green number
---@param act Actionable?
function Elba:botdyearmor(materialSlot, red, blue, green, act)
    local value = materialSlot .. ' ' .. red .. ' ' .. blue .. ' ' .. green
    run('botdyearmor', value, act)
end

--- Execute the 'boteyes' command.
---@param value any?
---@param act Actionable?
function Elba:boteyes(value, act)
    run('boteyes', value, act)
end

--- Execute the 'botface' command.
---@param value any?
---@param act Actionable?
function Elba:botface(value, act)
    run('botface', value, act)
end

--- Execute the 'botfollowdistance' command.
---@param value any?
---@param act Actionable?
function Elba:botfollowdistance(value, act)
    run('botfollowdistance', value, act)
end

--- Execute the 'bothaircolor' command.
---@param value any?
---@param act Actionable?
function Elba:bothaircolor(value, act)
    run('bothaircolor', value, act)
end

--- Execute the 'bothairstyle' command.
---@param value any?
---@param act Actionable?
function Elba:bothairstyle(value, act)
    run('bothairstyle', value, act)
end

--- Execute the 'botheritage' command.
---@param value any?
---@param act Actionable?
function Elba:botheritage(value, act)
    run('botheritage', value, act)
end

--- Execute the 'botinspectmessage' command.
---@param value any?
---@param act Actionable?
function Elba:botinspectmessage(value, act)
    run('botinspectmessage', value, act)
end

--- Execute the 'botlist' command.
---@param value any?
---@param act Actionable?
function Elba:botlist(value, act)
    run('botlist', value, act)
end

--- Execute the 'botoutofcombat' command.
---@param value any?
---@param act Actionable?
function Elba:botoutofcombat(value, act)
    run('botoutofcombat', value, act)
end

--- Execute the 'botreport' command.
---@param value any?
---@param act Actionable?
function Elba:botreport(value, act)
    run('botreport', value, act)
end

--- Execute the 'botsettings' command.
---@param value any?
---@param act Actionable?
function Elba:botsettings(value, act)
    run('botsettings', value, act)
end

--- Execute the 'botspawn' command.
---@param value any?
---@param act Actionable?
function Elba:botspawn(value, act)
    run('botspawn', value, act)
end

--- Execute the 'botstance' command.
---@param value any?
---@param act Actionable?
function Elba:botstance(value, act)
    run('botstance', value, act)
end

--- Execute the 'botstopmeleelevel' command.
---@param value any?
---@param act Actionable?
function Elba:botstopmeleelevel(value, act)
    run('botstopmeleelevel', value, act)
end

--- Execute the 'botsuffix' command.
---@param value any?
---@param act Actionable?
function Elba:botsuffix(value, act)
    run('botsuffix', value, act)
end

--- Execute the 'botsummon' command.
---@param value any?
---@param act Actionable?
function Elba:botsummon(value, act)
    run('botsummon', value, act)
end

--- Execute the 'botsurname' command.
---@param value any?
---@param act Actionable?
function Elba:botsurname(value, act)
    run('botsurname', value, act)
end

--- Execute the 'bottattoo' command.
---@param value any?
---@param act Actionable?
function Elba:bottattoo(value, act)
    run('bottattoo', value, act)
end

--- Execute the 'bottitle' command.
---@param value any?
---@param act Actionable?
function Elba:bottitle(value, act)
    run('bottitle', value, act)
end

--- Execute the 'bottogglearcher' command.
---@param value any?
---@param act Actionable?
function Elba:bottogglearcher(value, act)
    run('bottogglearcher', value, act)
end

--- Execute the 'bottogglehelm' command.
---@param value any?
---@param act Actionable?
function Elba:bottogglehelm(value, act)
    run('bottogglehelm', value, act)
end

--- Execute the 'bottoggleranged' command.
---@param value any?
---@param act Actionable?
function Elba:bottoggleranged(value, act)
    run('bottoggleranged', value, act)
end

--- Execute the 'botupdate' command.
---@param value any?
---@param act Actionable?
function Elba:botupdate(value, act)
    run('botupdate', value, act)
end

--- Execute the 'botwoad' command.
---@param value any?
---@param act Actionable?
function Elba:botwoad(value, act)
    run('botwoad', value, act)
end

--- Instructs Bots to cast the spell on your target.
---@param value SpellType | number
---@param act Actionable?
function Elba:cast(value, act)
    run('cast', value, act)
end

--- Execute the 'casterrange' command.
---@param value any?
---@param act Actionable?
function Elba:casterrange(value, act)
    run('casterrange', value, act)
end

--- Execute the 'charm' command.
---@param value any?
---@param act Actionable?
function Elba:charm(value, act)
    run('charm', value, act)
end

--- Execute the 'circle' command.
---@param value any?
---@param act Actionable?
function Elba:circle(value, act)
    run('circle', value, act)
end

--- Execute the 'classracelist' command.
---@param value any?
---@param act Actionable?
function Elba:classracelist(value, act)
    run('classracelist', value, act)
end

--- Execute the 'clickitem' command.
---@param value any?
---@param act Actionable?
function Elba:clickitem(value, act)
    run('clickitem', value, act)
end

--- Execute the 'copysettings' command.
---@param value any?
---@param act Actionable?
function Elba:copysettings(value, act)
    run('copysettings', value, act)
end

--- Execute the 'cure' command.
---@param value any?
---@param act Actionable?
function Elba:cure(value, act)
    run('cure', value, act)
end

--- Execute the 'defaultsettings' command.
---@param value any?
---@param act Actionable?
function Elba:defaultsettings(value, act)
    run('defaultsettings', value, act)
end

--- Execute the 'defensive' command.
---@param value any?
---@param act Actionable?
function Elba:defensive(value, act)
    run('defensive', value, act)
end

--- Execute the 'depart' command.
---@param value any?
---@param act Actionable?
function Elba:depart(value, act)
    run('depart', value, act)
end

--- Execute the 'discipline' command.
---@param value any?
---@param act Actionable?
function Elba:discipline(value, act)
    run('discipline', value, act)
end

--- Execute the 'distanceranged' command.
---@param value any?
---@param act Actionable?
function Elba:distanceranged(value, act)
    run('distanceranged', value, act)
end

--- Execute the 'enforcespellsettings' command.
---@param value any?
---@param act Actionable?
function Elba:enforcespellsettings(value, act)
    run('enforcespellsettings', value, act)
end

--- Execute the 'escape' command.
---@param value any?
---@param act Actionable?
function Elba:escape(value, act)
    run('escape', value, act)
end

--- Execute the 'findaliases' command.
---@param value any?
---@param act Actionable?
function Elba:findaliases(value, act)
    run('findaliases', value, act)
end

--- Execute the 'follow' command.
---@param value any?
---@param act Actionable?
function Elba:follow(value, act)
    run('follow', value, act)
end

--- Execute the 'guard' command.
---@param value any?
---@param act Actionable?
function Elba:guard(value, act)
    run('guard', value, act)
end

--- Execute the 'healrotation' command.
---@param value any?
---@param act Actionable?
function Elba:healrotation(value, act)
    run('healrotation', value, act)
end

--- Execute the 'healrotationadaptivetargeting' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationadaptivetargeting(value, act)
    run('healrotationadaptivetargeting', value, act)
end

--- Execute the 'healrotationaddmember' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationaddmember(value, act)
    run('healrotationaddmember', value, act)
end

--- Execute the 'healrotationaddtarget' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationaddtarget(value, act)
    run('healrotationaddtarget', value, act)
end

--- Execute the 'healrotationadjustcritical' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationadjustcritical(value, act)
    run('healrotationadjustcritical', value, act)
end

--- Execute the 'healrotationadjustsafe' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationadjustsafe(value, act)
    run('healrotationadjustsafe', value, act)
end

--- Execute the 'healrotationcastingoverride' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationcastingoverride(value, act)
    run('healrotationcastingoverride', value, act)
end

--- Execute the 'healrotationchangeinterval' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationchangeinterval(value, act)
    run('healrotationchangeinterval', value, act)
end

--- Execute the 'healrotationclearhot' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationclearhot(value, act)
    run('healrotationclearhot', value, act)
end

--- Execute the 'healrotationcleartargets' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationcleartargets(value, act)
    run('healrotationcleartargets', value, act)
end

--- Execute the 'healrotationcreate' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationcreate(value, act)
    run('healrotationcreate', value, act)
end

--- Execute the 'healrotationdelete' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationdelete(value, act)
    run('healrotationdelete', value, act)
end

--- Execute the 'healrotationfastheals' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationfastheals(value, act)
    run('healrotationfastheals', value, act)
end

--- Execute the 'healrotationlist' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationlist(value, act)
    run('healrotationlist', value, act)
end

--- Execute the 'healrotationremovemember' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationremovemember(value, act)
    run('healrotationremovemember', value, act)
end

--- Execute the 'healrotationremovetarget' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationremovetarget(value, act)
    run('healrotationremovetarget', value, act)
end

--- Execute the 'healrotationresetlimits' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationresetlimits(value, act)
    run('healrotationresetlimits', value, act)
end

--- Execute the 'healrotationsave' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationsave(value, act)
    run('healrotationsave', value, act)
end

--- Execute the 'healrotationsethot' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationsethot(value, act)
    run('healrotationsethot', value, act)
end

--- Execute the 'healrotationstart' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationstart(value, act)
    run('healrotationstart', value, act)
end

--- Execute the 'healrotationstop' command.
---@param value any?
---@param act Actionable?
function Elba:healrotationstop(value, act)
    run('healrotationstop', value, act)
end

--- Execute the 'help' command.
---@param value any?
---@param act Actionable?
function Elba:help(value, act)
    run('help', value, act)
end

--- Execute the 'hold' command.
---@param value any?
---@param act Actionable?
function Elba:hold(value, act)
    run('hold', value, act)
end

--- Execute the 'identify' command.
---@param value any?
---@param act Actionable?
function Elba:identify(value, act)
    run('identify', value, act)
end

--- Execute the 'illusionblock' command.
---@param value any?
---@param act Actionable?
function Elba:illusionblock(value, act)
    run('illusionblock', value, act)
end

--- Execute the 'inventory' command.
---@param value any?
---@param act Actionable?
function Elba:inventory(value, act)
    run('inventory', value, act)
end

--- Execute the 'inventorygive' command.
---@param value any?
---@param act Actionable?
function Elba:inventorygive(value, act)
    run('inventorygive', value, act)
end

--- Execute the 'inventorylist' command.
---@param value any?
---@param act Actionable?
function Elba:inventorylist(value, act)
    run('inventorylist', value, act)
end

--- Execute the 'inventoryremove' command.
---@param value any?
---@param act Actionable?
function Elba:inventoryremove(value, act)
    run('inventoryremove', value, act)
end

--- Execute the 'inventorywindow' command.
---@param value any?
---@param act Actionable?
function Elba:inventorywindow(value, act)
    run('inventorywindow', value, act)
end

--- Execute the 'invisibility' command.
---@param value any?
---@param act Actionable?
function Elba:invisibility(value, act)
    run('invisibility', value, act)
end

--- Execute the 'itemuse' command.
---@param value any?
---@param act Actionable?
function Elba:itemuse(value, act)
    run('itemuse', value, act)
end

--- Execute the 'levitation' command.
---@param value any?
---@param act Actionable?
function Elba:levitation(value, act)
    run('levitation', value, act)
end

--- Execute the 'lull' command.
---@param value any?
---@param act Actionable?
function Elba:lull(value, act)
    run('lull', value, act)
end

--- Execute the 'maxmeleerange' command.
---@param value any?
---@param act Actionable?
function Elba:maxmeleerange(value, act)
    run('maxmeleerange', value, act)
end

--- Execute the 'mesmerize' command.
---@param value any?
---@param act Actionable?
function Elba:mesmerize(value, act)
    run('mesmerize', value, act)
end

--- Execute the 'movementspeed' command.
---@param value any?
---@param act Actionable?
function Elba:movementspeed(value, act)
    run('movementspeed', value, act)
end

--- Execute the 'owneroption' command.
---@param value any?
---@param act Actionable?
function Elba:owneroption(value, act)
    run('owneroption', value, act)
end

--- Execute the 'pet' command.
---@param value any?
---@param act Actionable?
function Elba:pet(value, act)
    run('pet', value, act)
end

--- Execute the 'petgetlost' command.
---@param value any?
---@param act Actionable?
function Elba:petgetlost(value, act)
    run('petgetlost', value, act)
end

--- Execute the 'petremove' command.
---@param value any?
---@param act Actionable?
function Elba:petremove(value, act)
    run('petremove', value, act)
end

--- Execute the 'petsettype' command.
---@param value any?
---@param act Actionable?
function Elba:petsettype(value, act)
    run('petsettype', value, act)
end

--- Execute the 'picklock' command.
---@param value any?
---@param act Actionable?
function Elba:picklock(value, act)
    run('picklock', value, act)
end

--- Execute the 'pickpocket' command.
---@param value any?
---@param act Actionable?
function Elba:pickpocket(value, act)
    run('pickpocket', value, act)
end

--- Execute the 'portal' command.
---@param value any?
---@param act Actionable?
function Elba:portal(value, act)
    run('portal', value, act)
end

--- Execute the 'precombat' command.
---@param value any?
---@param act Actionable?
function Elba:precombat(value, act)
    run('precombat', value, act)
end

--- Execute the 'pull' command.
---@param value any?
---@param act Actionable?
function Elba:pull(value, act)
    run('pull', value, act)
end

--- Execute the 'release' command.
---@param value any?
---@param act Actionable?
function Elba:release(value, act)
    run('release', value, act)
end

--- Execute the 'resistance' command.
---@param value any?
---@param act Actionable?
function Elba:resistance(value, act)
    run('resistance', value, act)
end

--- Execute the 'resurrect' command.
---@param value any?
---@param act Actionable?
function Elba:resurrect(value, act)
    run('resurrect', value, act)
end

--- Execute the 'rune' command.
---@param value any?
---@param act Actionable?
function Elba:rune(value, act)
    run('rune', value, act)
end

--- Execute the 'sendhome' command.
---@param value any?
---@param act Actionable?
function Elba:sendhome(value, act)
    run('sendhome', value, act)
end

--- Execute the 'setassistee' command.
---@param value any?
---@param act Actionable?
function Elba:setassistee(value, act)
    run('setassistee', value, act)
end

--- Execute the 'sithppercent' command.
---@param value any?
---@param act Actionable?
function Elba:sithppercent(value, act)
    run('sithppercent', value, act)
end

--- Execute the 'sitincombat' command.
---@param value any?
---@param act Actionable?
function Elba:sitincombat(value, act)
    run('sitincombat', value, act)
end

--- Execute the 'sitmanapercent' command.
---@param value any?
---@param act Actionable?
function Elba:sitmanapercent(value, act)
    run('sitmanapercent', value, act)
end

--- Execute the 'size' command.
---@param value any?
---@param act Actionable?
function Elba:size(value, act)
    run('size', value, act)
end

--- Execute the 'spellaggrochecks' command.
---@param value any?
---@param act Actionable?
function Elba:spellaggrochecks(value, act)
    run('spellaggrochecks', value, act)
end

--- Execute the 'spellannouncecasts' command.
---@param value any?
---@param act Actionable?
function Elba:spellannouncecasts(value, act)
    run('spellannouncecasts', value, act)
end

--- Execute the 'spelldelays' command.
---@param category any?
---@param delay any?
---@param act Actionable?
function Elba:spelldelays(category, delay, act)
    run('spelldelays', category, delay, act)
end

--- Execute the 'spellengagedpriority' command.
---@param value any?
---@param act Actionable?
function Elba:spellengagedpriority(value, act)
    run('spellengagedpriority', value, act)
end

--- Execute the 'spellholds' command.
---@param category any?
---@param hold any?
---@param act Actionable?
function Elba:spellholds(category, hold, act)
    run('spellholds', category, hold, act)
end

--- Execute the 'spellidlepriority' command.
---@param value any?
---@param act Actionable?
function Elba:spellidlepriority(value, act)
    run('spellidlepriority', value, act)
end

--- Execute the 'spellinfo' command.
---@param value any?
---@param act Actionable?
function Elba:spellinfo(value, act)
    run('spellinfo', value, act)
end

--- Execute the 'spellmaxhppct' command.
---@param value any?
---@param act Actionable?
function Elba:spellmaxhppct(value, act)
    run('spellmaxhppct', value, act)
end

--- Execute the 'spellmaxmanapct' command.
---@param value any?
---@param act Actionable?
function Elba:spellmaxmanapct(value, act)
    run('spellmaxmanapct', value, act)
end

--- Execute the 'spellmaxthresholds' command.
---@param category any?
---@param threshold any?
---@param act Actionable?
function Elba:spellmaxthresholds(category, threshold, act)
    run('spellmaxthresholds', category, threshold, act)
end

--- Execute the 'spellminhppct' command.
---@param value any?
---@param act Actionable?
function Elba:spellminhppct(value, act)
    run('spellminhppct', value, act)
end

--- Execute the 'spellminmanapct' command.
---@param value any?
---@param act Actionable?
function Elba:spellminmanapct(value, act)
    run('spellminmanapct', value, act)
end

--- Execute the 'spellminthresholds' command.
---@param value any?
---@param act Actionable?
function Elba:spellminthresholds(value, act)
    run('spellminthresholds', value, act)
end

--- Execute the 'spellpursuepriority' command.
---@param value any?
---@param act Actionable?
function Elba:spellpursuepriority(value, act)
    run('spellpursuepriority', value, act)
end

--- Execute the 'spellresistlimits' command.
---@param value any?
---@param act Actionable?
function Elba:spellresistlimits(value, act)
    run('spellresistlimits', value, act)
end

--- Execute the 'spells' command.
---@param value any?
---@param act Actionable?
function Elba:spells(value, act)
    run('spells', value, act)
end

--- Execute the 'spellsettings' command.
---@param value any?
---@param act Actionable?
function Elba:spellsettings(value, act)
    run('spellsettings', value, act)
end

--- Execute the 'spellsettingsadd' command.
---@param value any?
---@param act Actionable?
function Elba:spellsettingsadd(value, act)
    run('spellsettingsadd', value, act)
end

--- Execute the 'spellsettingsdelete' command.
---@param value any?
---@param act Actionable?
function Elba:spellsettingsdelete(value, act)
    run('spellsettingsdelete', value, act)
end

--- Execute the 'spellsettingstoggle' command.
---@param value any?
---@param act Actionable?
function Elba:spellsettingstoggle(value, act)
    run('spellsettingstoggle', value, act)
end

--- Execute the 'spellsettingsupdate' command.
---@param value any?
---@param act Actionable?
function Elba:spellsettingsupdate(value, act)
    run('spellsettingsupdate', value, act)
end

--- Execute the 'spelltargetcount' command.
---@param value any?
---@param act Actionable?
function Elba:spelltargetcount(value, act)
    run('spelltargetcount', value, act)
end

--- Execute the 'spelltypeids' command.
---@param value any?
---@param act Actionable?
function Elba:spelltypeids(value, act)
    run('spelltypeids', value, act)
end

--- Execute the 'spelltypenames' command.
---@param value any?
---@param act Actionable?
function Elba:spelltypenames(value, act)
    run('spelltypenames', value, act)
end

--- Execute the 'summoncorpse' command.
---@param value any?
---@param act Actionable?
function Elba:summoncorpse(value, act)
    run('summoncorpse', value, act)
end

--- Execute the 'suspend' command.
---@param value any?
---@param act Actionable?
function Elba:suspend(value, act)
    run('suspend', value, act)
end

--- Execute the 'taunt' command.
---@param value any?
---@param act Actionable?
function Elba:taunt(value, act)
    run('taunt', value, act)
end

--- Execute the 'timer' command.
---@param value any?
---@param act Actionable?
function Elba:timer(value, act)
    run('timer', value, act)
end

--- Execute the 'track' command.
---@param value any?
---@param act Actionable?
function Elba:track(value, act)
    run('track', value, act)
end

--- Execute the 'viewcombos' command.
---@param value any?
---@param act Actionable?
function Elba:viewcombos(value, act)
    run('viewcombos', value, act)
end

--- Execute the 'waterbreathing' command.
---@param value any?
---@param act Actionable?
function Elba:waterbreathing(value, act)
    run('waterbreathing', value, act)
end


return Elba
