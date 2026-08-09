---============================================================================
--- THF Alt Commands - what the alt does when it is on THF
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether THF is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in THF_ALT_CUSTOM.lua, which is
--- merged on top of this file and never regenerated.
---
--- Sources: the project's own data decides what exists and at which level
--- (shared/data/job_abilities/ and shared/data/magic/), res/spells.lua and
--- res/job_abilities.lua supply targeting.
---
--- Abilities carry `level`, spells carry every tier with the level it needs.
--- The engine picks the highest the alt is high enough for, from the level it
--- reported - a subjob caps far below a main (Master Level 50 reaches sub 58).
--- `main_only` entries disappear entirely when the job is the subjob.
---
--- @file    config/alt/THF_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    accomplice       = { action = 'ja', spell = 'Accomplice',             target = 'lastst', level = 65, main_only = true, group = 'ja', desc = 'Steal 50% enmity from ally' },
    assassinscharge  = { action = 'ja', spell = "Assassin's Charge",      target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Force triple/quad attack' },
    bully            = { action = 'ja', spell = 'Bully',                  target = 'lastst', level = 93, main_only = true, group = 'ja', desc = 'Intimidate target' },
    collaborator     = { action = 'ja', spell = 'Collaborator',           target = 'lastst', level = 65, main_only = true, group = 'ja', desc = 'Transfer 25% enmity to ally' },
    conspirator      = { action = 'ja', spell = 'Conspirator',            target = 'me', level = 87, main_only = true, group = 'ja', desc = 'Party ACC+, Subtle Blow+' },
    despoil          = { action = 'ja', spell = 'Despoil',                target = 'lastst', level = 77, main_only = true, group = 'ja', desc = 'Steal items, inflict debuff' },
    feint            = { action = 'ja', spell = 'Feint',                  target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Enemy evasion -150>>-50' },
    flee             = { action = 'ja', spell = 'Flee',                   target = 'me', level = 25, group = 'ja', desc = 'Movement speed +60%' },
    hide             = { action = 'ja', spell = 'Hide',                   target = 'me', level = 45, group = 'ja', desc = 'Invisible, reset enmity' },
    larceny          = { action = 'ja', spell = 'Larceny',                target = 'lastst', level = 96, main_only = true, group = 'ja', desc = 'Steal buff from enemy' },
    mug              = { action = 'ja', spell = 'Mug',                    target = 'lastst', level = 35, group = 'ja', desc = 'Steal gil, drain HP' },
    perfectdodge     = { action = 'ja', spell = 'Perfect Dodge',          target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Dodge all melee attacks' },
    sneakattack      = { action = 'ja', spell = 'Sneak Attack',           target = 'me', level = 15, group = 'ja', desc = 'Crit from behind, +DEX damage' },
    steal            = { action = 'ja', spell = 'Steal',                  target = 'lastst', level = 5, group = 'ja', desc = 'Steal items from enemy' },
    trickattack      = { action = 'ja', spell = 'Trick Attack',           target = 'me', level = 30, group = 'ja', desc = 'Behind ally: Crit, +AGI, transfer enmity' },
}

return M
