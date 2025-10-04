local mq = require('mq')

-- Provide module aliases when running directly from the repository.
local function alias(module_name, target)
    if not package.loaded[module_name] then
        package.loaded[module_name] = require(target)
    end
end

alias('ELBA.Actionable', 'Actionable')
alias('ELBA.enums.Class', 'enums.Class')
alias('ELBA.enums.Gender', 'enums.Gender')
alias('ELBA.enums.Race', 'enums.Race')
alias('ELBA.enums.Slot', 'enums.Slot')
alias('ELBA.enums.Stance', 'enums.Stance')
alias('ELBA.enums.SpellType', 'enums.SpellType')

if not package.loaded['ELBA.init'] and not package.preload['ELBA.init'] then
    package.preload['ELBA.init'] = function()
        return require('init')
    end
end

if not package.loaded['mq.PackageMan'] then
    package.loaded['mq.PackageMan'] = {
        Require = function(_, _, _)
            error('PackageMan is not available in this environment.')
        end,
    }
end

local Elba = require('ELBA.init')
local Actionable = Elba.Actionable
local Class = Elba.Class
local Stance = Elba.Stance

local function configure_bots()
    mq.cmd('/echo \ao Clearing my target')
    mq.cmd('/target clear')
    mq.delay(1000)

    mq.cmd('/echo \ao Resetting all stances to 2 (Balanced)')
    Elba:stance(Stance.BALANCED, Actionable.spawned())
    mq.delay(1000)

    mq.cmd('/echo \ao Restoring all settings to default')
    Elba:defaultsettings('all', Actionable.spawned())
    mq.delay(1000)

    mq.cmd('/echo \ao Setting Warriors to stance 2 (Blanaced) -- No auto taunt, let SK tank.')
    Elba:stance(Stance.BALANCED, Actionable.byclass(Class.WARRIOR))
    mq.delay(1000)

    mq.cmd('/echo \ao Setting Shadowknights to stance 5 (Aggressive) -- Let them auto taunt and cast their hate line (Main Tanks"')
    Elba:stance(Stance.AGGRESSIVE, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(1000)

    mq.cmd('/echo \ao Setting Behind Mob for Monks, Rogues, Beastlords and Berserkers')

    Elba:behindmob(1, Actionable.byclass(Class.MONK))
    mq.delay(200)
    Elba:behindmob(1, Actionable.byclass(Class.ROGUE))
    mq.delay(200)
    Elba:behindmob(1, Actionable.byclass(Class.BEASTLORD))
    mq.delay(200)
    Elba:behindmob(1, Actionable.byclass(Class.BERSERKER))
    mq.delay(200)

    mq.cmd('/echo \ao Setting Illusion Block for all bots.')

    Elba:illusionblock(1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ao Setting Ranged Distance for Druids, Shaman, Casters, Rangers and Bards')
    mq.cmd('/echo \ap We want Bards at 50, Druids and Shaman at 125, Necromancers, Wizards, Magicians and Enchanters at 135 and Rangers at 150.')

    Elba:distanceranged(150, Actionable.byclass(Class.RANGER))
    mq.delay(200)
    Elba:distanceranged(125, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:distanceranged(50, Actionable.byclass(Class.BARD))
    mq.delay(200)
    Elba:distanceranged(125, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:distanceranged(135, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:distanceranged(135, Actionable.byclass(Class.WIZARD))
    mq.delay(200)
    Elba:distanceranged(135, Actionable.byclass(Class.MAGICIAN))
    mq.delay(200)
    Elba:distanceranged(135, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ao Setting Rangers to be Ranged')

    Elba:bottoggleranged(1, Actionable.byclass(Class.RANGER))
    mq.delay(200)

    mq.cmd('/echo \ao Setting Holds for classes...')

    mq.cmd('/echo \ap We only want Druids, Shamans, Necromancers, Wizards, Magicians and Enchanters nuking.')
    Elba:spellholds('nukes', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('nukes', 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds('nukes', 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds('nukes', 0, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:spellholds('nukes', 0, Actionable.byclass(Class.WIZARD))
    mq.delay(200)
    Elba:spellholds('nukes', 0, Actionable.byclass(Class.MAGICIAN))
    mq.delay(200)
    Elba:spellholds('nukes', 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druids and Shamans casting regular heals.')
    Elba:spellholds('regularheals', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('regularheals', 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds('regularheals', 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone rooting.')
    Elba:spellholds('roots', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want Shadowknights casting pets.')
    Elba:spellholds('pets', 1, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druid\'s snaring.')
    Elba:spellholds('snares', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('snares', 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druids, Bards, Shamans, Necromancers and Enchanters dotting.')
    Elba:spellholds('dots', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('dots', 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds('dots', 0, Actionable.byclass(Class.BARD))
    mq.delay(200)
    Elba:spellholds('dots', 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds('dots', 0, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:spellholds('dots', 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Shamans and Enchanters slowing.')
    Elba:spellholds('slows', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('slows', 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds('slows', 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druids, Bards, Shamans, Necromancers, Magicians and Enchanters debuffing.')
    Elba:spellholds('debuffs', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('debuffs', 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds('debuffs', 0, Actionable.byclass(Class.BARD))
    mq.delay(200)
    Elba:spellholds('debuffs', 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds('debuffs', 0, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:spellholds('debuffs', 0, Actionable.byclass(Class.MAGICIAN))
    mq.delay(200)
    Elba:spellholds('debuffs', 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want Clerics, Paladins, Rangers or Beastlords curing.')
    Elba:spellholds('cures', 1, Actionable.byclass(Class.CLERIC))
    mq.delay(200)
    Elba:spellholds('cures', 1, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellholds('cures', 1, Actionable.byclass(Class.RANGER))
    mq.delay(200)
    Elba:spellholds('cures', 1, Actionable.byclass(Class.BEASTLORD))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Paladins stunning.')
    Elba:spellholds('stuns', 1, Actionable.byclass(Class.CLERIC))
    mq.delay(200)
    Elba:spellholds('stuns', 0, Actionable.byclass(Class.PALADIN))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Warriors, Paladins and Shadowknights receiving complete heals.')
    Elba:spellholds('completeheals', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('completeheals', 0, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellholds('completeheals', 0, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellholds('completeheals', 0, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone accepting group heals.')
    Elba:spellholds('groupheals', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone accepting group complete heals.')
    Elba:spellholds('groupcompleteheals', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone accepting group HoT complete heals.')
    Elba:spellholds('grouphotheals', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We only want Warriors, Paladins and Shadowknights receiving HoT heals.')
    Elba:spellholds('hotheals', 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds('hotheals', 0, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellholds('hotheals', 0, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellholds('hotheals', 0, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting AE debuffs.')
    Elba:spellholds('aedebuffs', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting AE slows.')
    Elba:spellholds('aeslows', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet regular heals.')
    Elba:spellholds('petregularheals', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet HoT heals.')
    Elba:spellholds('pethotheals', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet complete heals.')
    Elba:spellholds('petcompleteheals', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet cures.')
    Elba:spellholds('petcures', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet damage shields.')
    Elba:spellholds('petdamageshields', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet pet resist buffs.')
    Elba:spellholds('petresistbuffs', 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ao Setting Delays for classes...')

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to receive complete heals on a 3 second chain.')
    Elba:spelldelays('completeheals', 3000, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spelldelays('completeheals', 3000, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spelldelays('completeheals', 3000, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to nuke as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays('nukes', 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to DoT as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays('dots', 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to Slow as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays('slows', 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to Debuff as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays('debuffs', 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to Stun as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays('stuns', 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ao Setting Maximum Thresholds for classes...')

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving complete heals at 85% health.')
    Elba:spellmaxthresholds('completeheals', 85, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds('completeheals', 85, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds('completeheals', 85, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone to start receiving fast heals at 40% health.')
    Elba:spellmaxthresholds('fastheals', 40, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving fast heals at 65% health.')
    Elba:spellmaxthresholds('fastheals', 65, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds('fastheals', 65, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds('fastheals', 65, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone to start receiving very fast heals at 25% health.')
    Elba:spellmaxthresholds('veryfastheals', 25, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving very fast heals at 40% health.')
    Elba:spellmaxthresholds('veryfastheals', 40, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds('veryfastheals', 40, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds('veryfastheals', 40, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving HoT heals at 95% health.')
    Elba:spellmaxthresholds('hotheals', 95, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds('hotheals', 95, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds('hotheals', 95, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(1000)

    mq.cmd('/echo \ao Setting Illusion Block for myself')
    mq.cmd('/target myself')
    mq.delay(1000)
    mq.cmd('/say #illusionblock 1')
    mq.delay(200)

    mq.cmd('/echo \ao Setting my own Delays')
    mq.cmd('/target myself')
    mq.delay(1000)

    mq.cmd("/echo \ap I want to receive fast heals every 1 second.")
    Elba:spelldelays('fastheals', 1000)
    mq.delay(200)

    mq.cmd("/echo \ap I want to receive fast heals every .5 seconds.")
    Elba:spelldelays('veryfastheals', 500)
    mq.delay(200)

    mq.cmd('/echo \ao Setting my own Maximum Thresholds')
    mq.cmd('/target myself')
    mq.delay(1000)

    mq.cmd("/echo \ap I want to start receiving regular heals at 70% health.")
    Elba:spellmaxthresholds('regularheals', 70)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive complete heals.")
    Elba:spellmaxthresholds('completeheals', 0)
    mq.delay(200)

    mq.cmd("/echo \ap I want to start receiving fast heals at 55% health.")
    Elba:spellmaxthresholds('fastheals', 55)
    mq.delay(200)

    mq.cmd("/echo \ap I want to start receiving very fast heals at 45% health.")
    Elba:spellmaxthresholds('veryfastheals', 45)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive group heals.")
    Elba:spellmaxthresholds('groupheals', 0)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive group complete heals.")
    Elba:spellmaxthresholds('groupcompleteheals', 0)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive group HoT heals.")
    Elba:spellmaxthresholds('grouphotheals', 0)
    mq.delay(200)

    mq.cmd("/echo \ap I want to start receiving HoT heals at 90% health.")
    Elba:spellmaxthresholds('hotheals', 90)
    mq.delay(200)
end

return configure_bots
