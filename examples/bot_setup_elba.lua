local args = {...}
local enable_repository_modules = false

for _, arg in ipairs(args) do
    local normalized = tostring(arg):lower()
    if normalized == '--dev' or normalized == '--enable-module-aliases' or normalized == '--tests' or normalized == 'dev' then
        enable_repository_modules = true
        break
    end
end

local mq = require('mq')

if enable_repository_modules then
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
    alias('ELBA.enums.SpellDelayCategory', 'enums.SpellDelayCategory')
    alias('ELBA.enums.SpellHoldCategory', 'enums.SpellHoldCategory')
    alias('ELBA.enums.MaterialSlot', 'enums.MaterialSlot')
    alias('ELBA.enums.PetType', 'enums.PetType')

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
end

local Elba = require('ELBA.init')
local Actionable = Elba.Actionable
local Class = Elba.Class
local Stance = Elba.Stance
local SpellDelayCategory = Elba.SpellDelayCategory
local SpellHoldCategory = Elba.SpellHoldCategory
local SpellType = Elba.SpellType

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
    Elba:spellholds(SpellHoldCategory.NUKES, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.NUKES, 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.NUKES, 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.NUKES, 0, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.NUKES, 0, Actionable.byclass(Class.WIZARD))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.NUKES, 0, Actionable.byclass(Class.MAGICIAN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.NUKES, 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druids and Shamans casting regular heals.')
    Elba:spellholds(SpellHoldCategory.REGULAR_HEALS, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.REGULAR_HEALS, 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.REGULAR_HEALS, 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone rooting.')
    Elba:spellholds(SpellHoldCategory.ROOTS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want Shadowknights casting pets.')
    Elba:spellholds(SpellHoldCategory.PETS, 1, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druid\'s snaring.')
    Elba:spellholds(SpellHoldCategory.SNARES, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.SNARES, 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druids, Bards, Shamans, Necromancers and Enchanters dotting.')
    Elba:spellholds(SpellHoldCategory.DOTS, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DOTS, 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DOTS, 0, Actionable.byclass(Class.BARD))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DOTS, 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DOTS, 0, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DOTS, 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Shamans and Enchanters slowing.')
    Elba:spellholds(SpellHoldCategory.SLOWS, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.SLOWS, 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.SLOWS, 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Druids, Bards, Shamans, Necromancers, Magicians and Enchanters debuffing.')
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 0, Actionable.byclass(Class.DRUID))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 0, Actionable.byclass(Class.BARD))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 0, Actionable.byclass(Class.SHAMAN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 0, Actionable.byclass(Class.NECROMANCER))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 0, Actionable.byclass(Class.MAGICIAN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.DEBUFFS, 0, Actionable.byclass(Class.ENCHANTER))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want Clerics, Paladins, Rangers or Beastlords curing.')
    Elba:spellholds(SpellHoldCategory.CURES, 1, Actionable.byclass(Class.CLERIC))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.CURES, 1, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.CURES, 1, Actionable.byclass(Class.RANGER))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.CURES, 1, Actionable.byclass(Class.BEASTLORD))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Paladins stunning.')
    Elba:spellholds(SpellHoldCategory.STUNS, 1, Actionable.byclass(Class.CLERIC))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.STUNS, 0, Actionable.byclass(Class.PALADIN))
    mq.delay(200)

    mq.cmd('/echo \ap We only want Warriors, Paladins and Shadowknights receiving complete heals.')
    Elba:spellholds(SpellHoldCategory.COMPLETE_HEALS, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.COMPLETE_HEALS, 0, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.COMPLETE_HEALS, 0, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.COMPLETE_HEALS, 0, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone accepting group heals.')
    Elba:spellholds(SpellHoldCategory.GROUP_HEALS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone accepting group complete heals.')
    Elba:spellholds(SpellHoldCategory.GROUP_COMPLETE_HEALS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone accepting group HoT complete heals.')
    Elba:spellholds(SpellHoldCategory.GROUP_HOT_HEALS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We only want Warriors, Paladins and Shadowknights receiving HoT heals.')
    Elba:spellholds(SpellHoldCategory.HOT_HEALS, 1, Actionable.spawned())
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.HOT_HEALS, 0, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.HOT_HEALS, 0, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellholds(SpellHoldCategory.HOT_HEALS, 0, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting AE debuffs.')
    Elba:spellholds(SpellHoldCategory.AE_DEBUFFS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting AE slows.')
    Elba:spellholds(SpellHoldCategory.AE_SLOWS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet regular heals.')
    Elba:spellholds(SpellHoldCategory.PET_REGULAR_HEALS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet HoT heals.')
    Elba:spellholds(SpellHoldCategory.PET_HOT_HEALS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet complete heals.')
    Elba:spellholds(SpellHoldCategory.PET_COMPLETE_HEALS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet cures.')
    Elba:spellholds(SpellHoldCategory.PET_CURES, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet damage shields.')
    Elba:spellholds(SpellHoldCategory.PET_DAMAGE_SHIELDS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We don\'t want anyone casting pet pet resist buffs.')
    Elba:spellholds(SpellHoldCategory.PET_RESIST_BUFFS, 1, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ao Setting Delays for classes...')

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to receive complete heals on a 3 second chain.')
    Elba:spelldelays(SpellDelayCategory.COMPLETE_HEALS, 3000, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spelldelays(SpellDelayCategory.COMPLETE_HEALS, 3000, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spelldelays(SpellDelayCategory.COMPLETE_HEALS, 3000, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to nuke as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays(SpellDelayCategory.NUKES, 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to DoT as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays(SpellDelayCategory.DOTS, 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to Slow as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays(SpellDelayCategory.SLOWS, 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to Debuff as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays(SpellDelayCategory.DEBUFFS, 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone applicable to Stun as far as they can (let aggro checks handle aggro).')
    Elba:spelldelays(SpellDelayCategory.STUNS, 100, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ao Setting Maximum Thresholds for classes...')

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving complete heals at 85% health.')
    Elba:spellmaxthresholds(SpellType.COMPLETE_HEAL, 85, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.COMPLETE_HEAL, 85, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.COMPLETE_HEAL, 85, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone to start receiving fast heals at 40% health.')
    Elba:spellmaxthresholds(SpellType.FAST_HEALS, 40, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving fast heals at 65% health.')
    Elba:spellmaxthresholds(SpellType.FAST_HEALS, 65, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.FAST_HEALS, 65, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.FAST_HEALS, 65, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want everyone to start receiving very fast heals at 25% health.')
    Elba:spellmaxthresholds(SpellType.VERY_FAST_HEALS, 25, Actionable.spawned())
    mq.delay(200)

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving very fast heals at 40% health.')
    Elba:spellmaxthresholds(SpellType.VERY_FAST_HEALS, 40, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.VERY_FAST_HEALS, 40, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.VERY_FAST_HEALS, 40, Actionable.byclass(Class.SHADOWKNIGHT))
    mq.delay(200)

    mq.cmd('/echo \ap We want Warriors, Paladins and Shadowknights to start receiving HoT heals at 95% health.')
    Elba:spellmaxthresholds(SpellType.HEAL_OVER_TIME_HEALS, 95, Actionable.byclass(Class.WARRIOR))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.HEAL_OVER_TIME_HEALS, 95, Actionable.byclass(Class.PALADIN))
    mq.delay(200)
    Elba:spellmaxthresholds(SpellType.HEAL_OVER_TIME_HEALS, 95, Actionable.byclass(Class.SHADOWKNIGHT))
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
    Elba:spelldelays(SpellDelayCategory.FAST_HEALS, 1000)
    mq.delay(200)

    mq.cmd("/echo \ap I want to receive fast heals every .5 seconds.")
    Elba:spelldelays(SpellDelayCategory.VERY_FAST_HEALS, 500)
    mq.delay(200)

    mq.cmd('/echo \ao Setting my own Maximum Thresholds')
    mq.cmd('/target myself')
    mq.delay(1000)

    mq.cmd("/echo \ap I want to start receiving regular heals at 70% health.")
    Elba:spellmaxthresholds(SpellType.REGULAR_HEAL, 70)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive complete heals.")
    Elba:spellmaxthresholds(SpellType.COMPLETE_HEAL, 0)
    mq.delay(200)

    mq.cmd("/echo \ap I want to start receiving fast heals at 55% health.")
    Elba:spellmaxthresholds(SpellType.FAST_HEALS, 55)
    mq.delay(200)

    mq.cmd("/echo \ap I want to start receiving very fast heals at 45% health.")
    Elba:spellmaxthresholds(SpellType.VERY_FAST_HEALS, 45)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive group heals.")
    Elba:spellmaxthresholds(SpellType.GROUP_HEALS, 0)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive group complete heals.")
    Elba:spellmaxthresholds(SpellType.GROUP_COMPLETE_HEALS, 0)
    mq.delay(200)

    mq.cmd("/echo \ap I don't want to receive group HoT heals.")
    Elba:spellmaxthresholds(SpellType.GROUP_HEAL_OVER_TIME_HEALS, 0)
    mq.delay(200)

    mq.cmd("/echo \ap I want to start receiving HoT heals at 90% health.")
    Elba:spellmaxthresholds(SpellType.HEAL_OVER_TIME_HEALS, 90)
    mq.delay(200)
end

configure_bots()
