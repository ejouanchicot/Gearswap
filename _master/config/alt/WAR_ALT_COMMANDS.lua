---============================================================================
--- WAR Alt Commands - what the alt does when it is on WAR
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether WAR is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in WAR_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/WAR_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    aggressor        = { action = 'ja', spell = 'Aggressor',              target = 'me', level = 45, group = 'ja', desc = 'ACC+25 EVA-25' },
    berserk          = { action = 'ja', spell = 'Berserk',                target = 'me', level = 15, group = 'ja', desc = 'ATK+25% DEF-25%' },
    bloodrage        = { action = 'ja', spell = 'Blood Rage',             target = 'me', level = 87, main_only = true, group = 'ja', desc = 'Party critical hit rate +20%' },
    brazenrush       = { action = 'ja', spell = 'Brazen Rush',            target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Double attack 100%' },
    defender         = { action = 'ja', spell = 'Defender',               target = 'me', level = 25, group = 'ja', desc = 'DEF+25% ATK-25%' },
    mightystrikes    = { action = 'ja', spell = 'Mighty Strikes',         target = 'me', level = 1, main_only = true, group = 'ja', desc = 'All attacks critical' },
    provoke          = { action = 'ja', spell = 'Provoke',                target = 'lastst', level = 5, group = 'ja', desc = 'Generate enmity' },
    restraint        = { action = 'ja', spell = 'Restraint',              target = 'me', level = 77, main_only = true, group = 'ja', desc = 'Build WS damage bonus (max +30%)' },
    retaliation      = { action = 'ja', spell = 'Retaliation',            target = 'me', level = 60, main_only = true, group = 'ja', desc = 'Counterattack 40%' },
    tomahawk         = { action = 'ja', spell = 'Tomahawk',               target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Throw: Physical resistance -25%' },
    warcry           = { action = 'ja', spell = 'Warcry',                 target = 'me', level = 35, group = 'ja', desc = 'Party ATK boost' },
    warriorscharge   = { action = 'ja', spell = "Warrior's Charge",       target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Force double/triple attack' },
}

return M
