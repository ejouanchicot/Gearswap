---============================================================================
--- BST Alt Commands - what the alt does when it is on BST
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether BST is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in BST_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/BST_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    bestialloyalty   = { action = 'ja', spell = 'Bestial Loyalty',        target = 'me', level = 23, group = 'ja', desc = 'Summon jug pet (no consume)' },
    callbeast        = { action = 'ja', spell = 'Call Beast',             target = 'me', level = 23, group = 'ja', desc = 'Summon jug pet (consumes jug)' },
    charm            = { action = 'ja', spell = 'Charm',                  target = 'lastst', level = 1, group = 'ja', desc = 'Tame monster as pet' },
    familiar         = { action = 'ja', spell = 'Familiar',               target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Pet powers enhanced' },
    feralhowl        = { action = 'ja', spell = 'Feral Howl',             target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Terrorize target' },
    fight            = { action = 'ja', spell = 'Fight',                  target = 'lastst', level = 1, group = 'ja', desc = 'Pet attacks target' },
    gauge            = { action = 'ja', spell = 'Gauge',                  target = 'lastst', level = 10, group = 'ja', desc = 'Check charm success rate' },
    heel             = { action = 'ja', spell = 'Heel',                   target = 'me', level = 10, group = 'ja', desc = 'Pet returns to master' },
    killerinstinct   = { action = 'ja', spell = 'Killer Instinct',        target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Grant pet' },
    leave            = { action = 'ja', spell = 'Leave',                  target = 'me', level = 35, group = 'ja', desc = 'Dismiss pet' },
    ready            = { action = 'ja', spell = 'Ready',                  target = 'lastst', level = 25, main_only = true, group = 'ja', desc = 'Pet uses selected TP move (charge system)' },
    reward           = { action = 'ja', spell = 'Reward',                 target = 'lastst', level = 12, group = 'ja', desc = 'Restore pet HP (food required)' },
    runwild          = { action = 'ja', spell = 'Run Wild',               target = 'lastst', level = 93, main_only = true, group = 'ja', desc = 'Pet stats +25%, pet vanishes after' },
    sic              = { action = 'ja', spell = 'Sic',                    target = 'lastst', level = 25, group = 'ja', desc = 'Pet uses random TP move' },
    snarl            = { action = 'ja', spell = 'Snarl',                  target = 'lastst', level = 45, main_only = true, group = 'ja', desc = 'Transfer 99% enmity to pet' },
    spur             = { action = 'ja', spell = 'Spur',                   target = 'lastst', level = 83, main_only = true, group = 'ja', desc = 'Pet Store TP +20' },
    stay             = { action = 'ja', spell = 'Stay',                   target = 'me', level = 15, group = 'ja', desc = 'Pet holds position' },
    tame             = { action = 'ja', spell = 'Tame',                   target = 'lastst', level = 30, group = 'ja', desc = 'Lower enemy resistance to charm' },
    unleash          = { action = 'ja', spell = 'Unleash',                target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Charm 95% success, Sic/Ready no recast' },
}

return M
