---
--- CommandBuilder Module
---
--- This module provides pure functions for building bot command strings.
--- These functions construct command strings without executing them or
--- performing any side effects (no I/O, no global state modification).
---
--- All builder functions follow the pattern:
---   - Accept command parameters (values, actionables)
---   - Return a command string ready for execution
---   - Do NOT call mq.cmd() or mq.cmdf()
---   - Do NOT modify global state
---   - Do NOT perform I/O operations
---
---@class CommandBuilder
local CommandBuilder = {}

--- Build a command string from parts
--- This is a helper function used by all command builders
---@param cmd string The command name (e.g., 'stance', 'attack')
---@param val1 any? First optional value
---@param val2 any? Second optional value
---@param act Actionable? Optional actionable target
---@return string command The complete command string
local function build_command(cmd, val1, val2, act)
    local parts = { '/say ^' .. cmd }
    if val1 ~= nil then table.insert(parts, tostring(val1)) end
    if val2 ~= nil then table.insert(parts, tostring(val2)) end
    if act ~= nil then table.insert(parts, tostring(act)) end
    return table.concat(parts, ' ')
end

--- Build a stance command string
--- Changes the stance (e.g. Passive, Aggressive, Balanced, etc.) of Bots.
---@param value any? stance value
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_stance(value, act)
    return build_command('stance', value, nil, act)
end

--- Build an attack command string
--- Instructs bots to attack
---@param value any? attack parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_attack(value, act)
    return build_command('attack', value, nil, act)
end

--- Build a guard command string
--- Instructs bots to guard
---@param value any? guard parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_guard(value, act)
    return build_command('guard', value, nil, act)
end

--- Build a follow command string
--- Instructs bots to follow
---@param value any? follow parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_follow(value, act)
    return build_command('follow', value, nil, act)
end

--- Build a botcreate command string
--- Creates a bot with the specified name, class, race, and gender
---@param name string bot name
---@param class number class ID
---@param race number race ID
---@param gender number gender ID
---@return string command string ready for execution
function CommandBuilder.build_botcreate(name, class, race, gender)
    return string.format("/say ^botcreate %s %d %d %d", name, class, race, gender)
end

--- Build an applypoison command string
---@param value any? applypoison parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_applypoison(value, act)
    return build_command('applypoison', value, nil, act)
end

--- Build an applypotion command string
---@param value any? applypotion parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_applypotion(value, act)
    return build_command('applypotion', value, nil, act)
end

--- Build a behindmob command string
---@param value any? behindmob parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_behindmob(value, act)
    return build_command('behindmob', value, nil, act)
end

--- Build a bindaffinity command string
---@param value any? bindaffinity parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bindaffinity(value, act)
    return build_command('bindaffinity', value, nil, act)
end

--- Build a blockedbuffs command string
---@param value any? blockedbuffs parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_blockedbuffs(value, act)
    return build_command('blockedbuffs', value, nil, act)
end

--- Build a blockedpetbuffs command string
---@param value any? blockedpetbuffs parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_blockedpetbuffs(value, act)
    return build_command('blockedpetbuffs', value, nil, act)
end

--- Build a botappearance command string
---@param value any? botappearance parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botappearance(value, act)
    return build_command('botappearance', value, nil, act)
end

--- Build a botbeardcolor command string
---@param value any? botbeardcolor parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botbeardcolor(value, act)
    return build_command('botbeardcolor', value, nil, act)
end

--- Build a botbeardstyle command string
---@param value any? botbeardstyle parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botbeardstyle(value, act)
    return build_command('botbeardstyle', value, nil, act)
end

--- Build a botcamp command string
---@param value any? botcamp parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botcamp(value, act)
    return build_command('botcamp', value, nil, act)
end

--- Build a botdelete command string
---@param value any? botdelete parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botdelete(value, act)
    return build_command('botdelete', value, nil, act)
end

--- Build a botdetails command string
---@param value any? botdetails parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botdetails(value, act)
    return build_command('botdetails', value, nil, act)
end

--- Build a botdyearmor command string
---@param materialSlot any material slot
---@param red number red value
---@param blue number blue value
---@param green number green value
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botdyearmor(materialSlot, red, blue, green, act)
    local value = materialSlot .. ' ' .. red .. ' ' .. blue .. ' ' .. green
    return build_command('botdyearmor', value, nil, act)
end

--- Build a boteyes command string
---@param value any? boteyes parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_boteyes(value, act)
    return build_command('boteyes', value, nil, act)
end

--- Build a botface command string
---@param value any? botface parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botface(value, act)
    return build_command('botface', value, nil, act)
end

--- Build a botfollowdistance command string
---@param value any? botfollowdistance parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botfollowdistance(value, act)
    return build_command('botfollowdistance', value, nil, act)
end

--- Build a bothaircolor command string
---@param value any? bothaircolor parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bothaircolor(value, act)
    return build_command('bothaircolor', value, nil, act)
end

--- Build a bothairstyle command string
---@param value any? bothairstyle parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bothairstyle(value, act)
    return build_command('bothairstyle', value, nil, act)
end

--- Build a botheritage command string
---@param value any? botheritage parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botheritage(value, act)
    return build_command('botheritage', value, nil, act)
end

--- Build a botinspectmessage command string
---@param value any? botinspectmessage parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botinspectmessage(value, act)
    return build_command('botinspectmessage', value, nil, act)
end

--- Build a botlist command string
---@param value any? botlist parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botlist(value, act)
    return build_command('botlist', value, nil, act)
end

--- Build a botoutofcombat command string
---@param value any? botoutofcombat parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botoutofcombat(value, act)
    return build_command('botoutofcombat', value, nil, act)
end

--- Build a botreport command string
---@param value any? botreport parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botreport(value, act)
    return build_command('botreport', value, nil, act)
end

--- Build a botsettings command string
---@param value any? botsettings parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botsettings(value, act)
    return build_command('botsettings', value, nil, act)
end

--- Build a botspawn command string
---@param value any? botspawn parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botspawn(value, act)
    return build_command('botspawn', value, nil, act)
end

--- Build a botstance command string
---@param value any? botstance parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botstance(value, act)
    return build_command('botstance', value, nil, act)
end

--- Build a botstopmeleelevel command string
---@param value any? botstopmeleelevel parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botstopmeleelevel(value, act)
    return build_command('botstopmeleelevel', value, nil, act)
end

--- Build a botsuffix command string
---@param value any? botsuffix parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botsuffix(value, act)
    return build_command('botsuffix', value, nil, act)
end

--- Build a botsummon command string
---@param value any? botsummon parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botsummon(value, act)
    return build_command('botsummon', value, nil, act)
end

--- Build a botsurname command string
---@param value any? botsurname parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botsurname(value, act)
    return build_command('botsurname', value, nil, act)
end

--- Build a bottattoo command string
---@param value any? bottattoo parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bottattoo(value, act)
    return build_command('bottattoo', value, nil, act)
end

--- Build a bottitle command string
---@param value any? bottitle parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bottitle(value, act)
    return build_command('bottitle', value, nil, act)
end

--- Build a bottogglearcher command string
---@param value any? bottogglearcher parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bottogglearcher(value, act)
    return build_command('bottogglearcher', value, nil, act)
end

--- Build a bottogglehelm command string
---@param value any? bottogglehelm parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bottogglehelm(value, act)
    return build_command('bottogglehelm', value, nil, act)
end

--- Build a bottoggleranged command string
---@param value any? bottoggleranged parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_bottoggleranged(value, act)
    return build_command('bottoggleranged', value, nil, act)
end

--- Build a botupdate command string
---@param value any? botupdate parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botupdate(value, act)
    return build_command('botupdate', value, nil, act)
end

--- Build a botwoad command string
---@param value any? botwoad parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_botwoad(value, act)
    return build_command('botwoad', value, nil, act)
end

--- Build a cast command string
---@param value any? cast parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_cast(value, act)
    return build_command('cast', value, nil, act)
end

--- Build a casterrange command string
---@param value any? casterrange parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_casterrange(value, act)
    return build_command('casterrange', value, nil, act)
end

--- Build a charm command string
---@param value any? charm parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_charm(value, act)
    return build_command('charm', value, nil, act)
end

--- Build a circle command string
---@param value any? circle parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_circle(value, act)
    return build_command('circle', value, nil, act)
end

--- Build a classracelist command string
---@param value any? classracelist parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_classracelist(value, act)
    return build_command('classracelist', value, nil, act)
end

--- Build a clickitem command string
---@param value any? clickitem parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_clickitem(value, act)
    return build_command('clickitem', value, nil, act)
end

--- Build a copysettings command string
---@param value any? copysettings parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_copysettings(value, act)
    return build_command('copysettings', value, nil, act)
end

--- Build a cure command string
---@param value any? cure parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_cure(value, act)
    return build_command('cure', value, nil, act)
end

--- Build a defaultsettings command string
---@param value any? defaultsettings parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_defaultsettings(value, act)
    return build_command('defaultsettings', value, nil, act)
end

--- Build a defensive command string
---@param value any? defensive parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_defensive(value, act)
    return build_command('defensive', value, nil, act)
end

--- Build a depart command string
---@param value any? depart parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_depart(value, act)
    return build_command('depart', value, nil, act)
end

--- Build a discipline command string
---@param value any? discipline parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_discipline(value, act)
    return build_command('discipline', value, nil, act)
end

--- Build a distanceranged command string
---@param value any? distanceranged parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_distanceranged(value, act)
    return build_command('distanceranged', value, nil, act)
end

--- Build an enforcespellsettings command string
---@param value any? enforcespellsettings parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_enforcespellsettings(value, act)
    return build_command('enforcespellsettings', value, nil, act)
end

--- Build an escape command string
---@param value any? escape parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_escape(value, act)
    return build_command('escape', value, nil, act)
end

--- Build a findaliases command string
---@param value any? findaliases parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_findaliases(value, act)
    return build_command('findaliases', value, nil, act)
end

--- Build a pull command string
---@param value any? pull parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_pull(value, act)
    return build_command('pull', value, nil, act)
end

--- Build a healrotation command string
---@param value any? healrotation parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotation(value, act)
    return build_command('healrotation', value, nil, act)
end

--- Build a healrotationadaptivetargeting command string
---@param value any? healrotationadaptivetargeting parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationadaptivetargeting(value, act)
    return build_command('healrotationadaptivetargeting', value, nil, act)
end

--- Build a healrotationaddmember command string
---@param value any? healrotationaddmember parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationaddmember(value, act)
    return build_command('healrotationaddmember', value, nil, act)
end

--- Build a healrotationaddtarget command string
---@param value any? healrotationaddtarget parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationaddtarget(value, act)
    return build_command('healrotationaddtarget', value, nil, act)
end

--- Build a healrotationadjustcritical command string
---@param value any? healrotationadjustcritical parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationadjustcritical(value, act)
    return build_command('healrotationadjustcritical', value, nil, act)
end

--- Build a healrotationadjustsafe command string
---@param value any? healrotationadjustsafe parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationadjustsafe(value, act)
    return build_command('healrotationadjustsafe', value, nil, act)
end

--- Build a healrotationcastingoverride command string
---@param value any? healrotationcastingoverride parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationcastingoverride(value, act)
    return build_command('healrotationcastingoverride', value, nil, act)
end

--- Build a healrotationchangeinterval command string
---@param value any? healrotationchangeinterval parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationchangeinterval(value, act)
    return build_command('healrotationchangeinterval', value, nil, act)
end

--- Build a healrotationclearhot command string
---@param value any? healrotationclearhot parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationclearhot(value, act)
    return build_command('healrotationclearhot', value, nil, act)
end

--- Build a healrotationcleartargets command string
---@param value any? healrotationcleartargets parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationcleartargets(value, act)
    return build_command('healrotationcleartargets', value, nil, act)
end

--- Build a healrotationcreate command string
---@param value any? healrotationcreate parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationcreate(value, act)
    return build_command('healrotationcreate', value, nil, act)
end

--- Build a healrotationdelete command string
---@param value any? healrotationdelete parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationdelete(value, act)
    return build_command('healrotationdelete', value, nil, act)
end

--- Build a healrotationfastheals command string
---@param value any? healrotationfastheals parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationfastheals(value, act)
    return build_command('healrotationfastheals', value, nil, act)
end

--- Build a healrotationlist command string
---@param value any? healrotationlist parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationlist(value, act)
    return build_command('healrotationlist', value, nil, act)
end

--- Build a healrotationremovemember command string
---@param value any? healrotationremovemember parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationremovemember(value, act)
    return build_command('healrotationremovemember', value, nil, act)
end

--- Build a healrotationremovetarget command string
---@param value any? healrotationremovetarget parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationremovetarget(value, act)
    return build_command('healrotationremovetarget', value, nil, act)
end

--- Build a healrotationresetlimits command string
---@param value any? healrotationresetlimits parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationresetlimits(value, act)
    return build_command('healrotationresetlimits', value, nil, act)
end

--- Build a healrotationsave command string
---@param value any? healrotationsave parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationsave(value, act)
    return build_command('healrotationsave', value, nil, act)
end

--- Build a healrotationsethot command string
---@param value any? healrotationsethot parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationsethot(value, act)
    return build_command('healrotationsethot', value, nil, act)
end

--- Build a healrotationstart command string
---@param value any? healrotationstart parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationstart(value, act)
    return build_command('healrotationstart', value, nil, act)
end

--- Build a healrotationstop command string
---@param value any? healrotationstop parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_healrotationstop(value, act)
    return build_command('healrotationstop', value, nil, act)
end

--- Build a help command string
---@param value any? help parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_help(value, act)
    return build_command('help', value, nil, act)
end

--- Build a hold command string
---@param value any? hold parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_hold(value, act)
    return build_command('hold', value, nil, act)
end

--- Build an identify command string
---@param value any? identify parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_identify(value, act)
    return build_command('identify', value, nil, act)
end

--- Build an illusionblock command string
---@param value any? illusionblock parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_illusionblock(value, act)
    return build_command('illusionblock', value, nil, act)
end

--- Build an inventory command string
---@param value any? inventory parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_inventory(value, act)
    return build_command('inventory', value, nil, act)
end

--- Build an inventorygive command string
---@param value any? inventorygive parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_inventorygive(value, act)
    return build_command('inventorygive', value, nil, act)
end

--- Build an inventorylist command string
---@param value any? inventorylist parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_inventorylist(value, act)
    return build_command('inventorylist', value, nil, act)
end

--- Build an inventoryremove command string
---@param value any? inventoryremove parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_inventoryremove(value, act)
    return build_command('inventoryremove', value, nil, act)
end

--- Build an inventorywindow command string
---@param value any? inventorywindow parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_inventorywindow(value, act)
    return build_command('inventorywindow', value, nil, act)
end

--- Build an invisibility command string
---@param value any? invisibility parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_invisibility(value, act)
    return build_command('invisibility', value, nil, act)
end

--- Build an itemuse command string
---@param value any? itemuse parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_itemuse(value, act)
    return build_command('itemuse', value, nil, act)
end

--- Build a levitation command string
---@param value any? levitation parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_levitation(value, act)
    return build_command('levitation', value, nil, act)
end

--- Build a lull command string
---@param value any? lull parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_lull(value, act)
    return build_command('lull', value, nil, act)
end

--- Build a maxmeleerange command string
---@param value any? maxmeleerange parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_maxmeleerange(value, act)
    return build_command('maxmeleerange', value, nil, act)
end

--- Build a mesmerize command string
---@param value any? mesmerize parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_mesmerize(value, act)
    return build_command('mesmerize', value, nil, act)
end

--- Build a movementspeed command string
---@param value any? movementspeed parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_movementspeed(value, act)
    return build_command('movementspeed', value, nil, act)
end

--- Build an owneroption command string
---@param value any? owneroption parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_owneroption(value, act)
    return build_command('owneroption', value, nil, act)
end

--- Build a pet command string
---@param value any? pet parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_pet(value, act)
    return build_command('pet', value, nil, act)
end

--- Build a petgetlost command string
---@param value any? petgetlost parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_petgetlost(value, act)
    return build_command('petgetlost', value, nil, act)
end

--- Build a petremove command string
---@param value any? petremove parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_petremove(value, act)
    return build_command('petremove', value, nil, act)
end

--- Build a petsettype command string
---@param value any? petsettype parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_petsettype(value, act)
    return build_command('petsettype', value, nil, act)
end

--- Build a picklock command string
---@param value any? picklock parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_picklock(value, act)
    return build_command('picklock', value, nil, act)
end

--- Build a pickpocket command string
---@param value any? pickpocket parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_pickpocket(value, act)
    return build_command('pickpocket', value, nil, act)
end

--- Build a portal command string
---@param value any? portal parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_portal(value, act)
    return build_command('portal', value, nil, act)
end

--- Build a precombat command string
---@param value any? precombat parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_precombat(value, act)
    return build_command('precombat', value, nil, act)
end

--- Build a release command string
---@param value any? release parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_release(value, act)
    return build_command('release', value, nil, act)
end

--- Build a resistance command string
---@param value any? resistance parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_resistance(value, act)
    return build_command('resistance', value, nil, act)
end

--- Build a resurrect command string
---@param value any? resurrect parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_resurrect(value, act)
    return build_command('resurrect', value, nil, act)
end

--- Build a rune command string
---@param value any? rune parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_rune(value, act)
    return build_command('rune', value, nil, act)
end

--- Build a sendhome command string
---@param value any? sendhome parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_sendhome(value, act)
    return build_command('sendhome', value, nil, act)
end

--- Build a setassistee command string
---@param value any? setassistee parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_setassistee(value, act)
    return build_command('setassistee', value, nil, act)
end

--- Build a sithppercent command string
---@param value any? sithppercent parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_sithppercent(value, act)
    return build_command('sithppercent', value, nil, act)
end

--- Build a sitincombat command string
---@param value any? sitincombat parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_sitincombat(value, act)
    return build_command('sitincombat', value, nil, act)
end

--- Build a sitmanapercent command string
---@param value any? sitmanapercent parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_sitmanapercent(value, act)
    return build_command('sitmanapercent', value, nil, act)
end

--- Build a size command string
---@param value any? size parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_size(value, act)
    return build_command('size', value, nil, act)
end

--- Build a spellaggrochecks command string
---@param value any? spellaggrochecks parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellaggrochecks(value, act)
    return build_command('spellaggrochecks', value, nil, act)
end

--- Build a spellannouncecasts command string
---@param value any? spellannouncecasts parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellannouncecasts(value, act)
    return build_command('spellannouncecasts', value, nil, act)
end

--- Build a spelldelays command string
---@param category any? category parameter
---@param delay any? delay parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spelldelays(category, delay, act)
    return build_command('spelldelays', category, delay, act)
end

--- Build a spellengagedpriority command string
---@param value any? spellengagedpriority parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellengagedpriority(value, act)
    return build_command('spellengagedpriority', value, nil, act)
end

--- Build a spellholds command string
---@param category any? category parameter
---@param hold any? hold parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellholds(category, hold, act)
    return build_command('spellholds', category, hold, act)
end

--- Build a spellidlepriority command string
---@param value any? spellidlepriority parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellidlepriority(value, act)
    return build_command('spellidlepriority', value, nil, act)
end

--- Build a spellinfo command string
---@param value any? spellinfo parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellinfo(value, act)
    return build_command('spellinfo', value, nil, act)
end

--- Build a spellmaxhppct command string
---@param value any? spellmaxhppct parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellmaxhppct(value, act)
    return build_command('spellmaxhppct', value, nil, act)
end

--- Build a spellmaxmanapct command string
---@param value any? spellmaxmanapct parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellmaxmanapct(value, act)
    return build_command('spellmaxmanapct', value, nil, act)
end

--- Build a spellmaxthresholds command string
---@param category any? category parameter
---@param threshold any? threshold parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellmaxthresholds(category, threshold, act)
    return build_command('spellmaxthresholds', category, threshold, act)
end

--- Build a spellminhppct command string
---@param value any? spellminhppct parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellminhppct(value, act)
    return build_command('spellminhppct', value, nil, act)
end

--- Build a spellminmanapct command string
---@param value any? spellminmanapct parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellminmanapct(value, act)
    return build_command('spellminmanapct', value, nil, act)
end

--- Build a spellminthresholds command string
---@param value any? spellminthresholds parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellminthresholds(value, act)
    return build_command('spellminthresholds', value, nil, act)
end

--- Build a spellpursuepriority command string
---@param value any? spellpursuepriority parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellpursuepriority(value, act)
    return build_command('spellpursuepriority', value, nil, act)
end

--- Build a spellresistlimits command string
---@param value any? spellresistlimits parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellresistlimits(value, act)
    return build_command('spellresistlimits', value, nil, act)
end

--- Build a spells command string
---@param value any? spells parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spells(value, act)
    return build_command('spells', value, nil, act)
end

--- Build a spellsettings command string
---@param value any? spellsettings parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellsettings(value, act)
    return build_command('spellsettings', value, nil, act)
end

--- Build a spellsettingsadd command string
---@param value any? spellsettingsadd parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellsettingsadd(value, act)
    return build_command('spellsettingsadd', value, nil, act)
end

--- Build a spellsettingsdelete command string
---@param value any? spellsettingsdelete parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellsettingsdelete(value, act)
    return build_command('spellsettingsdelete', value, nil, act)
end

--- Build a spellsettingstoggle command string
---@param value any? spellsettingstoggle parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellsettingstoggle(value, act)
    return build_command('spellsettingstoggle', value, nil, act)
end

--- Build a spellsettingsupdate command string
---@param value any? spellsettingsupdate parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spellsettingsupdate(value, act)
    return build_command('spellsettingsupdate', value, nil, act)
end

--- Build a spelltargetcount command string
---@param value any? spelltargetcount parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spelltargetcount(value, act)
    return build_command('spelltargetcount', value, nil, act)
end

--- Build a spelltypeids command string
---@param value any? spelltypeids parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spelltypeids(value, act)
    return build_command('spelltypeids', value, nil, act)
end

--- Build a spelltypenames command string
---@param value any? spelltypenames parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_spelltypenames(value, act)
    return build_command('spelltypenames', value, nil, act)
end

--- Build a summoncorpse command string
---@param value any? summoncorpse parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_summoncorpse(value, act)
    return build_command('summoncorpse', value, nil, act)
end

--- Build a suspend command string
---@param value any? suspend parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_suspend(value, act)
    return build_command('suspend', value, nil, act)
end

--- Build a taunt command string
---@param value any? taunt parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_taunt(value, act)
    return build_command('taunt', value, nil, act)
end

--- Build a timer command string
---@param value any? timer parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_timer(value, act)
    return build_command('timer', value, nil, act)
end

--- Build a track command string
---@param value any? track parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_track(value, act)
    return build_command('track', value, nil, act)
end

--- Build a viewcombos command string
---@param value any? viewcombos parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_viewcombos(value, act)
    return build_command('viewcombos', value, nil, act)
end

--- Build a waterbreathing command string
---@param value any? waterbreathing parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_waterbreathing(value, act)
    return build_command('waterbreathing', value, nil, act)
end

return CommandBuilder
