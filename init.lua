--
-- Emu Lua Bot API (LuaBots)
--

local mq = require('mq')

---@class LuaBots
local LuaBots = {}

-- Load Modules
LuaBots.Actionable  = require('LuaBots.Actionable')
LuaBots.Class       = require('LuaBots.enums.Class')
LuaBots.Slot        = require('LuaBots.enums.Slot')
LuaBots.Gender      = require('LuaBots.enums.Gender')
LuaBots.Race        = require('LuaBots.enums.Race')
LuaBots.SpellType   = require('LuaBots.enums.SpellType')
LuaBots.SpellDelayCategory = require('LuaBots.enums.SpellDelayCategory')
LuaBots.SpellHoldCategory = require('LuaBots.enums.SpellHoldCategory')
LuaBots.Stance      = require('LuaBots.enums.Stance')
LuaBots.MaterialSlot = require('LuaBots.enums.MaterialSlot')
LuaBots.PetType     = require('LuaBots.enums.PetType')

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

LuaBots.__index = LuaBots

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

local PackageMan = require('mq.PackageMan')
local socket
local json
local http
local ltn12

function LuaBots:initialize()

    http =  PackageMan.Require('luasocket', 'socket.http')
    ltn12 = PackageMan.Require('luasocket', 'ltn12')
    json   = PackageMan.Require('lua-cjson', 'cjson')

end


--- Changes the statnce (e.g. Passive, Agressive, Balanced, etc.) of Bots.
---@param value any?
---@param act Actionable?
function LuaBots:stance(value, act)
    run('stance', value, act)
end

--- Execute the 'applypoison' command.
---@param value any?
---@param act Actionable?
function LuaBots:applypoison(value, act)
    run('applypoison', value, act)
end

--- Execute the 'applypotion' command.
---@param value any?
---@param act Actionable?
function LuaBots:applypotion(value, act)
    run('applypotion', value, act)
end

--- Execute the 'attack' command.
---@param value any?
---@param act Actionable?
function LuaBots:attack(value, act)
    run('attack', value, act)
end

--- Execute the 'behindmob' command.
---@param value any?
---@param act Actionable?
function LuaBots:behindmob(value, act)
    run('behindmob', value, act)
end

--- Execute the 'bindaffinity' command.
---@param value any?
---@param act Actionable?
function LuaBots:bindaffinity(value, act)
    run('bindaffinity', value, act)
end

--- Execute the 'blockedbuffs' command.
---@param value any?
---@param act Actionable?
function LuaBots:blockedbuffs(value, act)
    run('blockedbuffs', value, act)
end

--- Execute the 'blockedpetbuffs' command.
---@param value any?
---@param act Actionable?
function LuaBots:blockedpetbuffs(value, act)
    run('blockedpetbuffs', value, act)
end

--- Execute the 'botappearance' command.
---@param value any?
---@param act Actionable?
function LuaBots:botappearance(value, act)
    run('botappearance', value, act)
end

--- Execute the 'botbeardcolor' command.
---@param value any?
---@param act Actionable?
function LuaBots:botbeardcolor(value, act)
    run('botbeardcolor', value, act)
end

--- Execute the 'botbeardstyle' command.
---@param value any?
---@param act Actionable?
function LuaBots:botbeardstyle(value, act)
    run('botbeardstyle', value, act)
end

--- Execute the 'botcamp' command.
---@param value any?
---@param act Actionable?
function LuaBots:botcamp(value, act)
    run('botcamp', value, act)
end

---Creates a bot
---@param name string
---@param class Class | number
---@param race Race | number
---@param gender Gender | number
function LuaBots:botcreate(name, class, race, gender)
    if name == "AUTO" then
        local api_race = race_enum_map[race] or "human"
        local api_gender = gender_enum_map[gender] or "male"
        local url = string.format("https://names.ironarachne.com/race/%s/%s/1", api_race, api_gender)

        local response = {}
        local _, code = http.request{
            url = url,
            sink = ltn12.sink.table(response)
        }

        if code == 200 then
            local body = table.concat(response)
            local body = json.decode(body)
            local names = body["names"]
            if type(names) == "table" and #names > 0 then
                name = names[1]
                print(string.format("[LuaBots] Auto-generated bot name: %s", name))
            else
                print("[LuaBots] Failed to get valid name from API.")
                return
            end
        else
            print(string.format("[LuaBots] Name API request failed. HTTP %d", code or 0))
            return
        end
    end
    mq.cmdf("/say ^botcreate %s %d %d %d", name, class, race, gender )
    return { Name = name, Class = class, Race = race, Gender = gender }

end

--- Execute the 'botdelete' command.
---@param value any?
---@param act Actionable?
function LuaBots:botdelete(value, act)
    run('botdelete', value, act)
end

--- Execute the 'botdetails' command.
---@param value any?
---@param act Actionable?
function LuaBots:botdetails(value, act)
    run('botdetails', value, act)
end

--- Execute the 'botdyearmor' command.
---@param materialSlot MaterialSlot | string
---@param red number
---@param blue number
---@param green number
---@param act Actionable?
function LuaBots:botdyearmor(materialSlot, red, blue, green, act)
    local value = materialSlot .. ' ' .. red .. ' ' .. blue .. ' ' .. green
    run('botdyearmor', value, act)
end

--- Execute the 'boteyes' command.
---@param value any?
---@param act Actionable?
function LuaBots:boteyes(value, act)
    run('boteyes', value, act)
end

--- Execute the 'botface' command.
---@param value any?
---@param act Actionable?
function LuaBots:botface(value, act)
    run('botface', value, act)
end

--- Execute the 'botfollowdistance' command.
---@param value any?
---@param act Actionable?
function LuaBots:botfollowdistance(value, act)
    run('botfollowdistance', value, act)
end

--- Execute the 'bothaircolor' command.
---@param value any?
---@param act Actionable?
function LuaBots:bothaircolor(value, act)
    run('bothaircolor', value, act)
end

--- Execute the 'bothairstyle' command.
---@param value any?
---@param act Actionable?
function LuaBots:bothairstyle(value, act)
    run('bothairstyle', value, act)
end

--- Execute the 'botheritage' command.
---@param value any?
---@param act Actionable?
function LuaBots:botheritage(value, act)
    run('botheritage', value, act)
end

--- Execute the 'botinspectmessage' command.
---@param value any?
---@param act Actionable?
function LuaBots:botinspectmessage(value, act)
    run('botinspectmessage', value, act)
end

--- Execute the 'botlist' command.
---@param value any?
---@param act Actionable?
function LuaBots:botlist(value, act)
    run('botlist', value, act)
end

--- Execute the 'botoutofcombat' command.
---@param value any?
---@param act Actionable?
function LuaBots:botoutofcombat(value, act)
    run('botoutofcombat', value, act)
end

--- Execute the 'botreport' command.
---@param value any?
---@param act Actionable?
function LuaBots:botreport(value, act)
    run('botreport', value, act)
end

--- Execute the 'botsettings' command.
---@param value any?
---@param act Actionable?
function LuaBots:botsettings(value, act)
    run('botsettings', value, act)
end

--- Execute the 'botspawn' command.
---@param value any?
---@param act Actionable?
function LuaBots:botspawn(value, act)
    run('botspawn', value, act)
end

--- Execute the 'botstance' command.
---@param value any?
---@param act Actionable?
function LuaBots:botstance(value, act)
    run('botstance', value, act)
end

--- Execute the 'botstopmeleelevel' command.
---@param value any?
---@param act Actionable?
function LuaBots:botstopmeleelevel(value, act)
    run('botstopmeleelevel', value, act)
end

--- Execute the 'botsuffix' command.
---@param value any?
---@param act Actionable?
function LuaBots:botsuffix(value, act)
    run('botsuffix', value, act)
end

--- Execute the 'botsummon' command.
---@param value any?
---@param act Actionable?
function LuaBots:botsummon(value, act)
    run('botsummon', value, act)
end

--- Execute the 'botsurname' command.
---@param value any?
---@param act Actionable?
function LuaBots:botsurname(value, act)
    run('botsurname', value, act)
end

--- Execute the 'bottattoo' command.
---@param value any?
---@param act Actionable?
function LuaBots:bottattoo(value, act)
    run('bottattoo', value, act)
end

--- Execute the 'bottitle' command.
---@param value any?
---@param act Actionable?
function LuaBots:bottitle(value, act)
    run('bottitle', value, act)
end

--- Execute the 'bottogglearcher' command.
---@param value any?
---@param act Actionable?
function LuaBots:bottogglearcher(value, act)
    run('bottogglearcher', value, act)
end

--- Execute the 'bottogglehelm' command.
---@param value any?
---@param act Actionable?
function LuaBots:bottogglehelm(value, act)
    run('bottogglehelm', value, act)
end

--- Execute the 'bottoggleranged' command.
---@param value any?
---@param act Actionable?
function LuaBots:bottoggleranged(value, act)
    run('bottoggleranged', value, act)
end

--- Execute the 'botupdate' command.
---@param value any?
---@param act Actionable?
function LuaBots:botupdate(value, act)
    run('botupdate', value, act)
end

--- Execute the 'botwoad' command.
---@param value any?
---@param act Actionable?
function LuaBots:botwoad(value, act)
    run('botwoad', value, act)
end

--- Instructs Bots to cast the spell on your target.
---@param value SpellType | number
---@param act Actionable?
function LuaBots:cast(value, act)
    run('cast', value, act)
end

--- Execute the 'casterrange' command.
---@param value any?
---@param act Actionable?
function LuaBots:casterrange(value, act)
    run('casterrange', value, act)
end

--- Execute the 'charm' command.
---@param value any?
---@param act Actionable?
function LuaBots:charm(value, act)
    run('charm', value, act)
end

--- Execute the 'circle' command.
---@param value any?
---@param act Actionable?
function LuaBots:circle(value, act)
    run('circle', value, act)
end

--- Execute the 'classracelist' command.
---@param value any?
---@param act Actionable?
function LuaBots:classracelist(value, act)
    run('classracelist', value, act)
end

--- Execute the 'clickitem' command.
---@param value any?
---@param act Actionable?
function LuaBots:clickitem(value, act)
    run('clickitem', value, act)
end

--- Execute the 'copysettings' command.
---@param value any?
---@param act Actionable?
function LuaBots:copysettings(value, act)
    run('copysettings', value, act)
end

--- Execute the 'cure' command.
---@param value any?
---@param act Actionable?
function LuaBots:cure(value, act)
    run('cure', value, act)
end

--- Execute the 'defaultsettings' command.
---@param value any?
---@param act Actionable?
function LuaBots:defaultsettings(value, act)
    run('defaultsettings', value, act)
end

--- Execute the 'defensive' command.
---@param value any?
---@param act Actionable?
function LuaBots:defensive(value, act)
    run('defensive', value, act)
end

--- Execute the 'depart' command.
---@param value any?
---@param act Actionable?
function LuaBots:depart(value, act)
    run('depart', value, act)
end

--- Execute the 'discipline' command.
---@param value any?
---@param act Actionable?
function LuaBots:discipline(value, act)
    run('discipline', value, act)
end

--- Execute the 'distanceranged' command.
---@param value any?
---@param act Actionable?
function LuaBots:distanceranged(value, act)
    run('distanceranged', value, act)
end

--- Execute the 'enforcespellsettings' command.
---@param value any?
---@param act Actionable?
function LuaBots:enforcespellsettings(value, act)
    run('enforcespellsettings', value, act)
end

--- Execute the 'escape' command.
---@param value any?
---@param act Actionable?
function LuaBots:escape(value, act)
    run('escape', value, act)
end

--- Execute the 'findaliases' command.
---@param value any?
---@param act Actionable?
function LuaBots:findaliases(value, act)
    run('findaliases', value, act)
end

--- Execute the 'follow' command.
---@param value any?
---@param act Actionable?
function LuaBots:follow(value, act)
    run('follow', value, act)
end

--- Execute the 'guard' command.
---@param value any?
---@param act Actionable?
function LuaBots:guard(value, act)
    run('guard', value, act)
end

--- Execute the 'healrotation' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotation(value, act)
    run('healrotation', value, act)
end

--- Execute the 'healrotationadaptivetargeting' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationadaptivetargeting(value, act)
    run('healrotationadaptivetargeting', value, act)
end

--- Execute the 'healrotationaddmember' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationaddmember(value, act)
    run('healrotationaddmember', value, act)
end

--- Execute the 'healrotationaddtarget' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationaddtarget(value, act)
    run('healrotationaddtarget', value, act)
end

--- Execute the 'healrotationadjustcritical' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationadjustcritical(value, act)
    run('healrotationadjustcritical', value, act)
end

--- Execute the 'healrotationadjustsafe' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationadjustsafe(value, act)
    run('healrotationadjustsafe', value, act)
end

--- Execute the 'healrotationcastingoverride' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationcastingoverride(value, act)
    run('healrotationcastingoverride', value, act)
end

--- Execute the 'healrotationchangeinterval' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationchangeinterval(value, act)
    run('healrotationchangeinterval', value, act)
end

--- Execute the 'healrotationclearhot' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationclearhot(value, act)
    run('healrotationclearhot', value, act)
end

--- Execute the 'healrotationcleartargets' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationcleartargets(value, act)
    run('healrotationcleartargets', value, act)
end

--- Execute the 'healrotationcreate' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationcreate(value, act)
    run('healrotationcreate', value, act)
end

--- Execute the 'healrotationdelete' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationdelete(value, act)
    run('healrotationdelete', value, act)
end

--- Execute the 'healrotationfastheals' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationfastheals(value, act)
    run('healrotationfastheals', value, act)
end

--- Execute the 'healrotationlist' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationlist(value, act)
    run('healrotationlist', value, act)
end

--- Execute the 'healrotationremovemember' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationremovemember(value, act)
    run('healrotationremovemember', value, act)
end

--- Execute the 'healrotationremovetarget' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationremovetarget(value, act)
    run('healrotationremovetarget', value, act)
end

--- Execute the 'healrotationresetlimits' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationresetlimits(value, act)
    run('healrotationresetlimits', value, act)
end

--- Execute the 'healrotationsave' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationsave(value, act)
    run('healrotationsave', value, act)
end

--- Execute the 'healrotationsethot' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationsethot(value, act)
    run('healrotationsethot', value, act)
end

--- Execute the 'healrotationstart' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationstart(value, act)
    run('healrotationstart', value, act)
end

--- Execute the 'healrotationstop' command.
---@param value any?
---@param act Actionable?
function LuaBots:healrotationstop(value, act)
    run('healrotationstop', value, act)
end

--- Execute the 'help' command.
---@param value any?
---@param act Actionable?
function LuaBots:help(value, act)
    run('help', value, act)
end

--- Execute the 'hold' command.
---@param value any?
---@param act Actionable?
function LuaBots:hold(value, act)
    run('hold', value, act)
end

--- Execute the 'identify' command.
---@param value any?
---@param act Actionable?
function LuaBots:identify(value, act)
    run('identify', value, act)
end

--- Execute the 'illusionblock' command.
---@param value any?
---@param act Actionable?
function LuaBots:illusionblock(value, act)
    run('illusionblock', value, act)
end

--- Execute the 'inventory' command.
---@param value any?
---@param act Actionable?
function LuaBots:inventory(value, act)
    run('inventory', value, act)
end

--- Execute the 'inventorygive' command.
---@param value any?
---@param act Actionable?
function LuaBots:inventorygive(value, act)
    run('inventorygive', value, act)
end

--- Execute the 'inventorylist' command.
---@param value any?
---@param act Actionable?
function LuaBots:inventorylist(value, act)
    run('inventorylist', value, act)
end

--- Execute the 'inventoryremove' command.
---@param value any?
---@param act Actionable?
function LuaBots:inventoryremove(value, act)
    run('inventoryremove', value, act)
end

--- Execute the 'inventorywindow' command.
---@param value any?
---@param act Actionable?
function LuaBots:inventorywindow(value, act)
    run('inventorywindow', value, act)
end

--- Execute the 'invisibility' command.
---@param value any?
---@param act Actionable?
function LuaBots:invisibility(value, act)
    run('invisibility', value, act)
end

--- Execute the 'itemuse' command.
---@param value any?
---@param act Actionable?
function LuaBots:itemuse(value, act)
    run('itemuse', value, act)
end

--- Execute the 'levitation' command.
---@param value any?
---@param act Actionable?
function LuaBots:levitation(value, act)
    run('levitation', value, act)
end

--- Execute the 'lull' command.
---@param value any?
---@param act Actionable?
function LuaBots:lull(value, act)
    run('lull', value, act)
end

--- Execute the 'maxmeleerange' command.
---@param value any?
---@param act Actionable?
function LuaBots:maxmeleerange(value, act)
    run('maxmeleerange', value, act)
end

--- Execute the 'mesmerize' command.
---@param value any?
---@param act Actionable?
function LuaBots:mesmerize(value, act)
    run('mesmerize', value, act)
end

--- Execute the 'movementspeed' command.
---@param value any?
---@param act Actionable?
function LuaBots:movementspeed(value, act)
    run('movementspeed', value, act)
end

--- Execute the 'owneroption' command.
---@param value any?
---@param act Actionable?
function LuaBots:owneroption(value, act)
    run('owneroption', value, act)
end

--- Execute the 'pet' command.
---@param value any?
---@param act Actionable?
function LuaBots:pet(value, act)
    run('pet', value, act)
end

--- Execute the 'petgetlost' command.
---@param value any?
---@param act Actionable?
function LuaBots:petgetlost(value, act)
    run('petgetlost', value, act)
end

--- Execute the 'petremove' command.
---@param value any?
---@param act Actionable?
function LuaBots:petremove(value, act)
    run('petremove', value, act)
end

--- Execute the 'petsettype' command.
---@param value any?
---@param act Actionable?
function LuaBots:petsettype(value, act)
    run('petsettype', value, act)
end

--- Execute the 'picklock' command.
---@param value any?
---@param act Actionable?
function LuaBots:picklock(value, act)
    run('picklock', value, act)
end

--- Execute the 'pickpocket' command.
---@param value any?
---@param act Actionable?
function LuaBots:pickpocket(value, act)
    run('pickpocket', value, act)
end

--- Execute the 'portal' command.
---@param value any?
---@param act Actionable?
function LuaBots:portal(value, act)
    run('portal', value, act)
end

--- Execute the 'precombat' command.
---@param value any?
---@param act Actionable?
function LuaBots:precombat(value, act)
    run('precombat', value, act)
end

--- Execute the 'pull' command.
---@param value any?
---@param act Actionable?
function LuaBots:pull(value, act)
    run('pull', value, act)
end

--- Execute the 'release' command.
---@param value any?
---@param act Actionable?
function LuaBots:release(value, act)
    run('release', value, act)
end

--- Execute the 'resistance' command.
---@param value any?
---@param act Actionable?
function LuaBots:resistance(value, act)
    run('resistance', value, act)
end

--- Execute the 'resurrect' command.
---@param value any?
---@param act Actionable?
function LuaBots:resurrect(value, act)
    run('resurrect', value, act)
end

--- Execute the 'rune' command.
---@param value any?
---@param act Actionable?
function LuaBots:rune(value, act)
    run('rune', value, act)
end

--- Execute the 'sendhome' command.
---@param value any?
---@param act Actionable?
function LuaBots:sendhome(value, act)
    run('sendhome', value, act)
end

--- Execute the 'setassistee' command.
---@param value any?
---@param act Actionable?
function LuaBots:setassistee(value, act)
    run('setassistee', value, act)
end

--- Execute the 'sithppercent' command.
---@param value any?
---@param act Actionable?
function LuaBots:sithppercent(value, act)
    run('sithppercent', value, act)
end

--- Execute the 'sitincombat' command.
---@param value any?
---@param act Actionable?
function LuaBots:sitincombat(value, act)
    run('sitincombat', value, act)
end

--- Execute the 'sitmanapercent' command.
---@param value any?
---@param act Actionable?
function LuaBots:sitmanapercent(value, act)
    run('sitmanapercent', value, act)
end

--- Execute the 'size' command.
---@param value any?
---@param act Actionable?
function LuaBots:size(value, act)
    run('size', value, act)
end

--- Execute the 'spellaggrochecks' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellaggrochecks(value, act)
    run('spellaggrochecks', value, act)
end

--- Execute the 'spellannouncecasts' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellannouncecasts(value, act)
    run('spellannouncecasts', value, act)
end

--- Execute the 'spelldelays' command.
---@param category any?
---@param delay any?
---@param act Actionable?
function LuaBots:spelldelays(category, delay, act)
    run('spelldelays', category, delay, act)
end

--- Execute the 'spellengagedpriority' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellengagedpriority(value, act)
    run('spellengagedpriority', value, act)
end

--- Execute the 'spellholds' command.
---@param category any?
---@param hold any?
---@param act Actionable?
function LuaBots:spellholds(category, hold, act)
    run('spellholds', category, hold, act)
end

--- Execute the 'spellidlepriority' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellidlepriority(value, act)
    run('spellidlepriority', value, act)
end

--- Execute the 'spellinfo' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellinfo(value, act)
    run('spellinfo', value, act)
end

--- Execute the 'spellmaxhppct' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellmaxhppct(value, act)
    run('spellmaxhppct', value, act)
end

--- Execute the 'spellmaxmanapct' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellmaxmanapct(value, act)
    run('spellmaxmanapct', value, act)
end

--- Execute the 'spellmaxthresholds' command.
---@param category any?
---@param threshold any?
---@param act Actionable?
function LuaBots:spellmaxthresholds(category, threshold, act)
    run('spellmaxthresholds', category, threshold, act)
end

--- Execute the 'spellminhppct' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellminhppct(value, act)
    run('spellminhppct', value, act)
end

--- Execute the 'spellminmanapct' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellminmanapct(value, act)
    run('spellminmanapct', value, act)
end

--- Execute the 'spellminthresholds' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellminthresholds(value, act)
    run('spellminthresholds', value, act)
end

--- Execute the 'spellpursuepriority' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellpursuepriority(value, act)
    run('spellpursuepriority', value, act)
end

--- Execute the 'spellresistlimits' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellresistlimits(value, act)
    run('spellresistlimits', value, act)
end

--- Execute the 'spells' command.
---@param value any?
---@param act Actionable?
function LuaBots:spells(value, act)
    run('spells', value, act)
end

--- Execute the 'spellsettings' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellsettings(value, act)
    run('spellsettings', value, act)
end

--- Execute the 'spellsettingsadd' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingsadd(value, act)
    run('spellsettingsadd', value, act)
end

--- Execute the 'spellsettingsdelete' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingsdelete(value, act)
    run('spellsettingsdelete', value, act)
end

--- Execute the 'spellsettingstoggle' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingstoggle(value, act)
    run('spellsettingstoggle', value, act)
end

--- Execute the 'spellsettingsupdate' command.
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingsupdate(value, act)
    run('spellsettingsupdate', value, act)
end

--- Execute the 'spelltargetcount' command.
---@param value any?
---@param act Actionable?
function LuaBots:spelltargetcount(value, act)
    run('spelltargetcount', value, act)
end

--- Execute the 'spelltypeids' command.
---@param value any?
---@param act Actionable?
function LuaBots:spelltypeids(value, act)
    run('spelltypeids', value, act)
end

--- Execute the 'spelltypenames' command.
---@param value any?
---@param act Actionable?
function LuaBots:spelltypenames(value, act)
    run('spelltypenames', value, act)
end

--- Execute the 'summoncorpse' command.
---@param value any?
---@param act Actionable?
function LuaBots:summoncorpse(value, act)
    run('summoncorpse', value, act)
end

--- Execute the 'suspend' command.
---@param value any?
---@param act Actionable?
function LuaBots:suspend(value, act)
    run('suspend', value, act)
end

--- Execute the 'taunt' command.
---@param value any?
---@param act Actionable?
function LuaBots:taunt(value, act)
    run('taunt', value, act)
end

--- Execute the 'timer' command.
---@param value any?
---@param act Actionable?
function LuaBots:timer(value, act)
    run('timer', value, act)
end

--- Execute the 'track' command.
---@param value any?
---@param act Actionable?
function LuaBots:track(value, act)
    run('track', value, act)
end

--- Execute the 'viewcombos' command.
---@param value any?
---@param act Actionable?
function LuaBots:viewcombos(value, act)
    run('viewcombos', value, act)
end

--- Execute the 'waterbreathing' command.
---@param value any?
---@param act Actionable?
function LuaBots:waterbreathing(value, act)
    run('waterbreathing', value, act)
end


return LuaBots
