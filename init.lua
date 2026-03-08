--
-- Emu Lua Bot API (LuaBots)
--
-- SIDE EFFECTS DOCUMENTATION:
--
-- This module follows a functional programming approach where command construction
-- is separated from command execution. Functions are categorized as follows:
--
-- PURE FUNCTIONS (No Side Effects):
--   - All functions in LuaBots.CommandBuilder module
--   - These functions only construct command strings without executing them
--   - They do not perform I/O, modify global state, or make network calls
--   - Examples: CommandBuilder.build_stance(), CommandBuilder.build_attack(), etc.
--
-- FUNCTIONS WITH SIDE EFFECTS:
--   - All LuaBots command functions (stance, attack, botcreate, etc.)
--   - Side Effect Type: I/O operation via mq.cmd() or mq.cmdf()
--   - Special Cases:
--     * LuaBots:initialize() - Modifies module-level variables (http, ltn12, json)
--     * LuaBots:botcreate() with name="AUTO" - Additional network I/O for name generation
--
-- Each function with side effects is annotated with LuaDoc comments specifying:
--   - The specific side effects (I/O, state mutation, network)
--   - What operations are performed
--
-- For more details on side effects and functional patterns, see docs/side-effects.md
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

-- Load refactored modules for functional programming approach
local CommandBuilder = require('LuaBots.CommandBuilder')
local CommandExecutor = require('LuaBots.CommandExecutor')
local NameGenerator = require('LuaBots.NameGenerator')
local HTTPClient = require('LuaBots.HTTPClient')

LuaBots.__index = LuaBots

--- Send a bot command with up to two values and an optional Actionable.
--- 
--- Side Effects: Executes bot command via mq.cmdf() (I/O operation)
--- 
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

--- Initialize LuaBots dependencies
--- 
--- Side Effects: Modifies module-level variables (http, ltn12, json) by loading external packages
--- 
function LuaBots:initialize()

    http =  PackageMan.Require('luasocket', 'socket.http')
    ltn12 = PackageMan.Require('luasocket', 'ltn12')
    json   = PackageMan.Require('lua-cjson', 'cjson')

end


--- Changes the statnce (e.g. Passive, Agressive, Balanced, etc.) of Bots.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:stance(value, act)
    local cmd = CommandBuilder.build_stance(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'applypoison' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:applypoison(value, act)
    local cmd = CommandBuilder.build_applypoison(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'applypotion' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:applypotion(value, act)
    local cmd = CommandBuilder.build_applypotion(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'attack' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:attack(value, act)
    local cmd = CommandBuilder.build_attack(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'behindmob' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:behindmob(value, act)
    local cmd = CommandBuilder.build_behindmob(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bindaffinity' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bindaffinity(value, act)
    local cmd = CommandBuilder.build_bindaffinity(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'blockedbuffs' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:blockedbuffs(value, act)
    local cmd = CommandBuilder.build_blockedbuffs(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'blockedpetbuffs' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:blockedpetbuffs(value, act)
    local cmd = CommandBuilder.build_blockedpetbuffs(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botappearance' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botappearance(value, act)
    local cmd = CommandBuilder.build_botappearance(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botbeardcolor' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botbeardcolor(value, act)
    local cmd = CommandBuilder.build_botbeardcolor(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botbeardstyle' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botbeardstyle(value, act)
    local cmd = CommandBuilder.build_botbeardstyle(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botcamp' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botcamp(value, act)
    local cmd = CommandBuilder.build_botcamp(value, act)
    CommandExecutor.execute(cmd)
end

---Creates a bot
--- 
--- Side Effects: 
---   - HTTP request for name generation when name="AUTO" (network I/O)
---   - Executes bot command via mq.cmd() (I/O operation)
---   - Prints to stdout (I/O operation)
--- 
---@param name string bot name or "AUTO" for generated name
---@param class Class | number class ID
---@param race Race | number race ID
---@param gender Gender | number gender ID
---@param http_client HTTPClient? optional HTTP client (for testing)
---@return table|nil bot_info bot information or nil on failure
function LuaBots:botcreate(name, class, race, gender, http_client)
    -- Use default HTTP client if not provided (backward compatibility)
    if name == "AUTO" then
        http_client = http_client or HTTPClient.create_default_http_client()
        
        local generated_name, err = NameGenerator.generate_name(race, gender, http_client)
        if not generated_name then
            print(string.format("[LuaBots] Name generation failed: %s", err))
            return nil
        end
        name = generated_name
        print(string.format("[LuaBots] Auto-generated bot name: %s", name))
    end
    
    local cmd = CommandBuilder.build_botcreate(name, class, race, gender)
    CommandExecutor.execute(cmd)
    
    return { Name = name, Class = class, Race = race, Gender = gender }
end

--- Execute the 'botdelete' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botdelete(value, act)
    local cmd = CommandBuilder.build_botdelete(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botdetails' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botdetails(value, act)
    local cmd = CommandBuilder.build_botdetails(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botdyearmor' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param materialSlot MaterialSlot | string
---@param red number
---@param blue number
---@param green number
---@param act Actionable?
function LuaBots:botdyearmor(materialSlot, red, blue, green, act)
    local cmd = CommandBuilder.build_botdyearmor(materialSlot, red, blue, green, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'boteyes' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:boteyes(value, act)
    local cmd = CommandBuilder.build_boteyes(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botface' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botface(value, act)
    local cmd = CommandBuilder.build_botface(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botfollowdistance' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botfollowdistance(value, act)
    local cmd = CommandBuilder.build_botfollowdistance(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bothaircolor' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bothaircolor(value, act)
    local cmd = CommandBuilder.build_bothaircolor(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bothairstyle' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bothairstyle(value, act)
    local cmd = CommandBuilder.build_bothairstyle(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botheritage' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botheritage(value, act)
    local cmd = CommandBuilder.build_botheritage(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botinspectmessage' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botinspectmessage(value, act)
    local cmd = CommandBuilder.build_botinspectmessage(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botlist' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botlist(value, act)
    local cmd = CommandBuilder.build_botlist(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botoutofcombat' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botoutofcombat(value, act)
    local cmd = CommandBuilder.build_botoutofcombat(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botreport' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botreport(value, act)
    local cmd = CommandBuilder.build_botreport(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botsettings' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botsettings(value, act)
    local cmd = CommandBuilder.build_botsettings(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botspawn' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botspawn(value, act)
    local cmd = CommandBuilder.build_botspawn(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botstance' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botstance(value, act)
    local cmd = CommandBuilder.build_botstance(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botstopmeleelevel' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botstopmeleelevel(value, act)
    local cmd = CommandBuilder.build_botstopmeleelevel(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botsuffix' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botsuffix(value, act)
    local cmd = CommandBuilder.build_botsuffix(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botsummon' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botsummon(value, act)
    local cmd = CommandBuilder.build_botsummon(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botsurname' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botsurname(value, act)
    local cmd = CommandBuilder.build_botsurname(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bottattoo' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bottattoo(value, act)
    local cmd = CommandBuilder.build_bottattoo(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bottitle' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bottitle(value, act)
    local cmd = CommandBuilder.build_bottitle(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bottogglearcher' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bottogglearcher(value, act)
    local cmd = CommandBuilder.build_bottogglearcher(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bottogglehelm' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bottogglehelm(value, act)
    local cmd = CommandBuilder.build_bottogglehelm(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'bottoggleranged' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:bottoggleranged(value, act)
    local cmd = CommandBuilder.build_bottoggleranged(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botupdate' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botupdate(value, act)
    local cmd = CommandBuilder.build_botupdate(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'botwoad' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:botwoad(value, act)
    local cmd = CommandBuilder.build_botwoad(value, act)
    CommandExecutor.execute(cmd)
end

--- Instructs Bots to cast the spell on your target.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value SpellType | number
---@param act Actionable?
function LuaBots:cast(value, act)
    local cmd = CommandBuilder.build_cast(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'casterrange' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:casterrange(value, act)
    local cmd = CommandBuilder.build_casterrange(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'charm' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:charm(value, act)
    local cmd = CommandBuilder.build_charm(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'circle' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:circle(value, act)
    local cmd = CommandBuilder.build_circle(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'classracelist' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:classracelist(value, act)
    local cmd = CommandBuilder.build_classracelist(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'clickitem' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:clickitem(value, act)
    local cmd = CommandBuilder.build_clickitem(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'copysettings' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:copysettings(value, act)
    local cmd = CommandBuilder.build_copysettings(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'cure' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:cure(value, act)
    local cmd = CommandBuilder.build_cure(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'defaultsettings' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:defaultsettings(value, act)
    local cmd = CommandBuilder.build_defaultsettings(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'defensive' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:defensive(value, act)
    local cmd = CommandBuilder.build_defensive(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'depart' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:depart(value, act)
    local cmd = CommandBuilder.build_depart(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'discipline' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:discipline(value, act)
    local cmd = CommandBuilder.build_discipline(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'distanceranged' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:distanceranged(value, act)
    local cmd = CommandBuilder.build_distanceranged(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'enforcespellsettings' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:enforcespellsettings(value, act)
    local cmd = CommandBuilder.build_enforcespellsettings(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'escape' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:escape(value, act)
    local cmd = CommandBuilder.build_escape(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'findaliases' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:findaliases(value, act)
    local cmd = CommandBuilder.build_findaliases(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'follow' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:follow(value, act)
    local cmd = CommandBuilder.build_follow(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'guard' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:guard(value, act)
    local cmd = CommandBuilder.build_guard(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotation' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotation(value, act)
    local cmd = CommandBuilder.build_healrotation(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationadaptivetargeting' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationadaptivetargeting(value, act)
    local cmd = CommandBuilder.build_healrotationadaptivetargeting(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationaddmember' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationaddmember(value, act)
    local cmd = CommandBuilder.build_healrotationaddmember(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationaddtarget' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationaddtarget(value, act)
    local cmd = CommandBuilder.build_healrotationaddtarget(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationadjustcritical' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationadjustcritical(value, act)
    local cmd = CommandBuilder.build_healrotationadjustcritical(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationadjustsafe' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationadjustsafe(value, act)
    local cmd = CommandBuilder.build_healrotationadjustsafe(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationcastingoverride' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationcastingoverride(value, act)
    local cmd = CommandBuilder.build_healrotationcastingoverride(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationchangeinterval' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationchangeinterval(value, act)
    local cmd = CommandBuilder.build_healrotationchangeinterval(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationclearhot' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationclearhot(value, act)
    local cmd = CommandBuilder.build_healrotationclearhot(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationcleartargets' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationcleartargets(value, act)
    local cmd = CommandBuilder.build_healrotationcleartargets(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationcreate' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationcreate(value, act)
    local cmd = CommandBuilder.build_healrotationcreate(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationdelete' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationdelete(value, act)
    local cmd = CommandBuilder.build_healrotationdelete(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationfastheals' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationfastheals(value, act)
    local cmd = CommandBuilder.build_healrotationfastheals(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationlist' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationlist(value, act)
    local cmd = CommandBuilder.build_healrotationlist(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationremovemember' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationremovemember(value, act)
    local cmd = CommandBuilder.build_healrotationremovemember(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationremovetarget' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationremovetarget(value, act)
    local cmd = CommandBuilder.build_healrotationremovetarget(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationresetlimits' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationresetlimits(value, act)
    local cmd = CommandBuilder.build_healrotationresetlimits(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationsave' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationsave(value, act)
    local cmd = CommandBuilder.build_healrotationsave(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationsethot' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationsethot(value, act)
    local cmd = CommandBuilder.build_healrotationsethot(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationstart' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationstart(value, act)
    local cmd = CommandBuilder.build_healrotationstart(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'healrotationstop' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:healrotationstop(value, act)
    local cmd = CommandBuilder.build_healrotationstop(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'help' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:help(value, act)
    local cmd = CommandBuilder.build_help(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'hold' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:hold(value, act)
    local cmd = CommandBuilder.build_hold(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'identify' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:identify(value, act)
    local cmd = CommandBuilder.build_identify(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'illusionblock' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:illusionblock(value, act)
    local cmd = CommandBuilder.build_illusionblock(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'inventory' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:inventory(value, act)
    local cmd = CommandBuilder.build_inventory(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'inventorygive' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:inventorygive(value, act)
    local cmd = CommandBuilder.build_inventorygive(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'inventorylist' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:inventorylist(value, act)
    local cmd = CommandBuilder.build_inventorylist(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'inventoryremove' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:inventoryremove(value, act)
    local cmd = CommandBuilder.build_inventoryremove(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'inventorywindow' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:inventorywindow(value, act)
    local cmd = CommandBuilder.build_inventorywindow(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'invisibility' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:invisibility(value, act)
    local cmd = CommandBuilder.build_invisibility(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'itemuse' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:itemuse(value, act)
    local cmd = CommandBuilder.build_itemuse(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'levitation' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:levitation(value, act)
    local cmd = CommandBuilder.build_levitation(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'lull' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:lull(value, act)
    local cmd = CommandBuilder.build_lull(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'maxmeleerange' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:maxmeleerange(value, act)
    local cmd = CommandBuilder.build_maxmeleerange(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'mesmerize' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:mesmerize(value, act)
    local cmd = CommandBuilder.build_mesmerize(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'movementspeed' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:movementspeed(value, act)
    local cmd = CommandBuilder.build_movementspeed(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'owneroption' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:owneroption(value, act)
    local cmd = CommandBuilder.build_owneroption(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'pet' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:pet(value, act)
    local cmd = CommandBuilder.build_pet(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'petgetlost' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:petgetlost(value, act)
    local cmd = CommandBuilder.build_petgetlost(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'petremove' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:petremove(value, act)
    local cmd = CommandBuilder.build_petremove(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'petsettype' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:petsettype(value, act)
    local cmd = CommandBuilder.build_petsettype(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'picklock' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:picklock(value, act)
    local cmd = CommandBuilder.build_picklock(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'pickpocket' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:pickpocket(value, act)
    local cmd = CommandBuilder.build_pickpocket(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'portal' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:portal(value, act)
    local cmd = CommandBuilder.build_portal(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'precombat' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:precombat(value, act)
    local cmd = CommandBuilder.build_precombat(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'pull' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:pull(value, act)
    local cmd = CommandBuilder.build_pull(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'release' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:release(value, act)
    local cmd = CommandBuilder.build_release(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'resistance' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:resistance(value, act)
    local cmd = CommandBuilder.build_resistance(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'resurrect' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:resurrect(value, act)
    local cmd = CommandBuilder.build_resurrect(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'rune' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:rune(value, act)
    local cmd = CommandBuilder.build_rune(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'sendhome' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:sendhome(value, act)
    local cmd = CommandBuilder.build_sendhome(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'setassistee' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:setassistee(value, act)
    local cmd = CommandBuilder.build_setassistee(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'sithppercent' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:sithppercent(value, act)
    local cmd = CommandBuilder.build_sithppercent(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'sitincombat' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:sitincombat(value, act)
    local cmd = CommandBuilder.build_sitincombat(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'sitmanapercent' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:sitmanapercent(value, act)
    local cmd = CommandBuilder.build_sitmanapercent(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'size' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:size(value, act)
    local cmd = CommandBuilder.build_size(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellaggrochecks' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellaggrochecks(value, act)
    local cmd = CommandBuilder.build_spellaggrochecks(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellannouncecasts' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellannouncecasts(value, act)
    local cmd = CommandBuilder.build_spellannouncecasts(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spelldelays' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param category any?
---@param delay any?
---@param act Actionable?
function LuaBots:spelldelays(category, delay, act)
    local cmd = CommandBuilder.build_spelldelays(category, delay, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellengagedpriority' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellengagedpriority(value, act)
    local cmd = CommandBuilder.build_spellengagedpriority(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellholds' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param category any?
---@param hold any?
---@param act Actionable?
function LuaBots:spellholds(category, hold, act)
    local cmd = CommandBuilder.build_spellholds(category, hold, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellidlepriority' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellidlepriority(value, act)
    local cmd = CommandBuilder.build_spellidlepriority(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellinfo' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellinfo(value, act)
    local cmd = CommandBuilder.build_spellinfo(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellmaxhppct' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellmaxhppct(value, act)
    local cmd = CommandBuilder.build_spellmaxhppct(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellmaxmanapct' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellmaxmanapct(value, act)
    local cmd = CommandBuilder.build_spellmaxmanapct(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellmaxthresholds' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param category any?
---@param threshold any?
---@param act Actionable?
function LuaBots:spellmaxthresholds(category, threshold, act)
    local cmd = CommandBuilder.build_spellmaxthresholds(category, threshold, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellminhppct' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellminhppct(value, act)
    local cmd = CommandBuilder.build_spellminhppct(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellminmanapct' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellminmanapct(value, act)
    local cmd = CommandBuilder.build_spellminmanapct(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellminthresholds' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellminthresholds(value, act)
    local cmd = CommandBuilder.build_spellminthresholds(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellpursuepriority' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellpursuepriority(value, act)
    local cmd = CommandBuilder.build_spellpursuepriority(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellresistlimits' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellresistlimits(value, act)
    local cmd = CommandBuilder.build_spellresistlimits(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spells' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spells(value, act)
    local cmd = CommandBuilder.build_spells(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellsettings' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellsettings(value, act)
    local cmd = CommandBuilder.build_spellsettings(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellsettingsadd' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingsadd(value, act)
    local cmd = CommandBuilder.build_spellsettingsadd(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellsettingsdelete' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingsdelete(value, act)
    local cmd = CommandBuilder.build_spellsettingsdelete(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellsettingstoggle' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingstoggle(value, act)
    local cmd = CommandBuilder.build_spellsettingstoggle(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spellsettingsupdate' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spellsettingsupdate(value, act)
    local cmd = CommandBuilder.build_spellsettingsupdate(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spelltargetcount' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spelltargetcount(value, act)
    local cmd = CommandBuilder.build_spelltargetcount(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spelltypeids' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spelltypeids(value, act)
    local cmd = CommandBuilder.build_spelltypeids(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'spelltypenames' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:spelltypenames(value, act)
    local cmd = CommandBuilder.build_spelltypenames(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'summoncorpse' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:summoncorpse(value, act)
    local cmd = CommandBuilder.build_summoncorpse(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'suspend' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:suspend(value, act)
    local cmd = CommandBuilder.build_suspend(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'taunt' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:taunt(value, act)
    local cmd = CommandBuilder.build_taunt(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'timer' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:timer(value, act)
    local cmd = CommandBuilder.build_timer(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'track' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:track(value, act)
    local cmd = CommandBuilder.build_track(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'viewcombos' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:viewcombos(value, act)
    local cmd = CommandBuilder.build_viewcombos(value, act)
    CommandExecutor.execute(cmd)
end

--- Execute the 'waterbreathing' command.
--- 
--- Side Effects: Executes bot command via mq.cmd() (I/O operation)
--- 
---@param value any?
---@param act Actionable?
function LuaBots:waterbreathing(value, act)
    local cmd = CommandBuilder.build_waterbreathing(value, act)
    CommandExecutor.execute(cmd)
end


return LuaBots
