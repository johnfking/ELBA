package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

local ok_socket, socket_mod = pcall(require, 'socket')
if not ok_socket then
    package.loaded['socket'] = { sleep = function() end }
else
    package.loaded['socket'] = socket_mod
end

local mq = require('mq')

local configure_bots = require('examples.bot_setup_elba')
local SpellType = require('enums.SpellType')

local function capture_output(fn)
    local output = {}
    local orig_write = io.write
    io.write = function(str) table.insert(output, str) end
    fn()
    io.write = orig_write
    return table.concat(output)
end

local expected_commands = {
    '/echo \ao Clearing my target',
    '/target clear',
    '/echo \ao Resetting all stances to 2 (Balanced)',
    '/say ^stance 2 spawned',
    '/echo \ao Restoring all settings to default',
    '/say ^defaultsettings all spawned',
    '/echo \ao Setting Warriors to stance 2 (Blanaced) -- No auto taunt, let SK tank.',
    '/say ^stance 2 byclass 1',
    '/echo \ao Setting Shadowknights to stance 5 (Aggressive) -- Let them auto taunt and cast their hate line (Main Tanks"',
    '/say ^stance 5 byclass 5',
    '/echo \ao Setting Behind Mob for Monks, Rogues, Beastlords and Berserkers',
    '/say ^behindmob 1 byclass 7',
    '/say ^behindmob 1 byclass 9',
    '/say ^behindmob 1 byclass 15',
    '/say ^behindmob 1 byclass 16',
    '/echo \ao Setting Illusion Block for all bots.',
    '/say ^illusionblock 1 spawned',
    '/echo \ao Setting Ranged Distance for Druids, Shaman, Casters, Rangers and Bards',
    '/echo \ap We want Bards at 50, Druids and Shaman at 125, Necromancers, Wizards, Magicians and Enchanters at 135 and Rangers at 150.',
    '/say ^distanceranged 150 byclass 4',
    '/say ^distanceranged 125 byclass 6',
    '/say ^distanceranged 50 byclass 8',
    '/say ^distanceranged 125 byclass 10',
    '/say ^distanceranged 135 byclass 11',
    '/say ^distanceranged 135 byclass 12',
    '/say ^distanceranged 135 byclass 13',
    '/say ^distanceranged 135 byclass 14',
    '/echo \ao Setting Rangers to be Ranged',
    '/say ^bottoggleranged 1 byclass 4',
    '/echo \ao Setting Holds for classes...',
    '/echo \ap We only want Druids, Shamans, Necromancers, Wizards, Magicians and Enchanters nuking.',
    '/say ^spellholds nukes 1 spawned',
    '/say ^spellholds nukes 0 byclass 6',
    '/say ^spellholds nukes 0 byclass 10',
    '/say ^spellholds nukes 0 byclass 11',
    '/say ^spellholds nukes 0 byclass 12',
    '/say ^spellholds nukes 0 byclass 13',
    '/say ^spellholds nukes 0 byclass 14',
    '/echo \ap We only want Druids and Shamans casting regular heals.',
    '/say ^spellholds regularheals 1 spawned',
    '/say ^spellholds regularheals 0 byclass 6',
    '/say ^spellholds regularheals 0 byclass 10',
    "/echo \ap We don't want anyone rooting.",
    '/say ^spellholds roots 1 spawned',
    "/echo \ap We don't want Shadowknights casting pets.",
    '/say ^spellholds pets 1 byclass 5',
    "/echo \ap We only want Druid's snaring.",
    '/say ^spellholds snares 1 spawned',
    '/say ^spellholds snares 0 byclass 6',
    "/echo \ap We only want Druids, Bards, Shamans, Necromancers and Enchanters dotting.",
    '/say ^spellholds dots 1 spawned',
    '/say ^spellholds dots 0 byclass 6',
    '/say ^spellholds dots 0 byclass 8',
    '/say ^spellholds dots 0 byclass 10',
    '/say ^spellholds dots 0 byclass 11',
    '/say ^spellholds dots 0 byclass 14',
    "/echo \ap We only want Shamans and Enchanters slowing.",
    '/say ^spellholds slows 1 spawned',
    '/say ^spellholds slows 0 byclass 10',
    '/say ^spellholds slows 0 byclass 14',
    "/echo \ap We only want Druids, Bards, Shamans, Necromancers, Magicians and Enchanters debuffing.",
    '/say ^spellholds debuffs 1 spawned',
    '/say ^spellholds debuffs 0 byclass 6',
    '/say ^spellholds debuffs 0 byclass 8',
    '/say ^spellholds debuffs 0 byclass 10',
    '/say ^spellholds debuffs 0 byclass 11',
    '/say ^spellholds debuffs 0 byclass 13',
    '/say ^spellholds debuffs 0 byclass 14',
    "/echo \ap We don't want Clerics, Paladins, Rangers or Beastlords curing.",
    '/say ^spellholds cures 1 byclass 2',
    '/say ^spellholds cures 1 byclass 3',
    '/say ^spellholds cures 1 byclass 4',
    '/say ^spellholds cures 1 byclass 15',
    "/echo \ap We only want Paladins stunning.",
    '/say ^spellholds stuns 1 byclass 2',
    '/say ^spellholds stuns 0 byclass 3',
    "/echo \ap We only want Warriors, Paladins and Shadowknights receiving complete heals.",
    '/say ^spellholds completeheals 1 spawned',
    '/say ^spellholds completeheals 0 byclass 1',
    '/say ^spellholds completeheals 0 byclass 3',
    '/say ^spellholds completeheals 0 byclass 5',
    "/echo \ap We don't want anyone accepting group heals.",
    '/say ^spellholds groupheals 1 spawned',
    "/echo \ap We don't want anyone accepting group complete heals.",
    '/say ^spellholds groupcompleteheals 1 spawned',
    "/echo \ap We don't want anyone accepting group HoT complete heals.",
    '/say ^spellholds grouphotheals 1 spawned',
    "/echo \ap We only want Warriors, Paladins and Shadowknights receiving HoT heals.",
    '/say ^spellholds hotheals 1 spawned',
    '/say ^spellholds hotheals 0 byclass 1',
    '/say ^spellholds hotheals 0 byclass 3',
    '/say ^spellholds hotheals 0 byclass 5',
    "/echo \ap We don't want anyone casting AE debuffs.",
    '/say ^spellholds aedebuffs 1 spawned',
    "/echo \ap We don't want anyone casting AE slows.",
    '/say ^spellholds aeslows 1 spawned',
    "/echo \ap We don't want anyone casting pet regular heals.",
    '/say ^spellholds petregularheals 1 spawned',
    "/echo \ap We don't want anyone casting pet HoT heals.",
    '/say ^spellholds pethotheals 1 spawned',
    "/echo \ap We don't want anyone casting pet complete heals.",
    '/say ^spellholds petcompleteheals 1 spawned',
    "/echo \ap We don't want anyone casting pet cures.",
    '/say ^spellholds petcures 1 spawned',
    "/echo \ap We don't want anyone casting pet damage shields.",
    '/say ^spellholds petdamageshields 1 spawned',
    "/echo \ap We don't want anyone casting pet pet resist buffs.",
    '/say ^spellholds petresistbuffs 1 spawned',
    '/echo \ao Setting Delays for classes...',
    '/echo \ap We want Warriors, Paladins and Shadowknights to receive complete heals on a 3 second chain.',
    '/say ^spelldelays completeheals 3000 byclass 1',
    '/say ^spelldelays completeheals 3000 byclass 3',
    '/say ^spelldelays completeheals 3000 byclass 5',
    '/echo \ap We want everyone applicable to nuke as far as they can (let aggro checks handle aggro).',
    '/say ^spelldelays nukes 100 spawned',
    '/echo \ap We want everyone applicable to DoT as far as they can (let aggro checks handle aggro).',
    '/say ^spelldelays dots 100 spawned',
    '/echo \ap We want everyone applicable to Slow as far as they can (let aggro checks handle aggro).',
    '/say ^spelldelays slows 100 spawned',
    '/echo \ap We want everyone applicable to Debuff as far as they can (let aggro checks handle aggro).',
    '/say ^spelldelays debuffs 100 spawned',
    '/echo \ap We want everyone applicable to Stun as far as they can (let aggro checks handle aggro).',
    '/say ^spelldelays stuns 100 spawned',
    '/echo \ao Setting Maximum Thresholds for classes...',
    '/echo \ap We want Warriors, Paladins and Shadowknights to start receiving complete heals at 85% health.',
    string.format('/say ^spellmaxthresholds %s 85 byclass 1', SpellType.COMPLETE_HEAL),
    string.format('/say ^spellmaxthresholds %s 85 byclass 3', SpellType.COMPLETE_HEAL),
    string.format('/say ^spellmaxthresholds %s 85 byclass 5', SpellType.COMPLETE_HEAL),
    '/echo \ap We want everyone to start receiving fast heals at 40% health.',
    string.format('/say ^spellmaxthresholds %s 40 spawned', SpellType.FAST_HEALS),
    '/echo \ap We want Warriors, Paladins and Shadowknights to start receiving fast heals at 65% health.',
    string.format('/say ^spellmaxthresholds %s 65 byclass 1', SpellType.FAST_HEALS),
    string.format('/say ^spellmaxthresholds %s 65 byclass 3', SpellType.FAST_HEALS),
    string.format('/say ^spellmaxthresholds %s 65 byclass 5', SpellType.FAST_HEALS),
    '/echo \ap We want everyone to start receiving very fast heals at 25% health.',
    string.format('/say ^spellmaxthresholds %s 25 spawned', SpellType.VERY_FAST_HEALS),
    '/echo \ap We want Warriors, Paladins and Shadowknights to start receiving very fast heals at 40% health.',
    string.format('/say ^spellmaxthresholds %s 40 byclass 1', SpellType.VERY_FAST_HEALS),
    string.format('/say ^spellmaxthresholds %s 40 byclass 3', SpellType.VERY_FAST_HEALS),
    string.format('/say ^spellmaxthresholds %s 40 byclass 5', SpellType.VERY_FAST_HEALS),
    '/echo \ap We want Warriors, Paladins and Shadowknights to start receiving HoT heals at 95% health.',
    string.format('/say ^spellmaxthresholds %s 95 byclass 1', SpellType.HEAL_OVER_TIME_HEALS),
    string.format('/say ^spellmaxthresholds %s 95 byclass 3', SpellType.HEAL_OVER_TIME_HEALS),
    string.format('/say ^spellmaxthresholds %s 95 byclass 5', SpellType.HEAL_OVER_TIME_HEALS),
    '/echo \ao Setting Illusion Block for myself',
    '/target myself',
    '/say #illusionblock 1',
    '/echo \ao Setting my own Delays',
    '/target myself',
    '/echo \ap I want to receive fast heals every 1 second.',
    '/say ^spelldelays fastheals 1000',
    '/echo \ap I want to receive fast heals every .5 seconds.',
    '/say ^spelldelays veryfastheals 500',
    '/echo \ao Setting my own Maximum Thresholds',
    '/target myself',
    '/echo \ap I want to start receiving regular heals at 70% health.',
    string.format('/say ^spellmaxthresholds %s 70', SpellType.REGULAR_HEAL),
    "/echo \ap I don't want to receive complete heals.",
    string.format('/say ^spellmaxthresholds %s 0', SpellType.COMPLETE_HEAL),
    "/echo \ap I want to start receiving fast heals at 55% health.",
    string.format('/say ^spellmaxthresholds %s 55', SpellType.FAST_HEALS),
    "/echo \ap I want to start receiving very fast heals at 45% health.",
    string.format('/say ^spellmaxthresholds %s 45', SpellType.VERY_FAST_HEALS),
    "/echo \ap I don't want to receive group heals.",
    string.format('/say ^spellmaxthresholds %s 0', SpellType.GROUP_HEALS),
    "/echo \ap I don't want to receive group complete heals.",
    string.format('/say ^spellmaxthresholds %s 0', SpellType.GROUP_COMPLETE_HEALS),
    "/echo \ap I don't want to receive group HoT heals.",
    string.format('/say ^spellmaxthresholds %s 0', SpellType.GROUP_HEAL_OVER_TIME_HEALS),
    "/echo \ap I want to start receiving HoT heals at 90% health.",
    string.format('/say ^spellmaxthresholds %s 90', SpellType.HEAL_OVER_TIME_HEALS),
}

local expected_output = table.concat(expected_commands, '\n') .. '\n'

describe('bot setup automation', function()
    it('emits identical commands as the manual script', function()
        local original_delay = mq.delay
        mq.delay = function() end

        local ok, actual_output = pcall(capture_output, configure_bots)

        mq.delay = original_delay

        if not ok then
            error(actual_output)
        end

        assert.are.equal(expected_output, actual_output)
    end)
end)
