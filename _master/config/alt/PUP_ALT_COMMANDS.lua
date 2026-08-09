---============================================================================
--- PUP Alt Commands - what the alt does when it is on PUP
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether PUP is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in PUP_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/PUP_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    activate         = { action = 'ja', spell = 'Activate',               target = 'me', level = 1, group = 'ja', desc = 'Summon automaton' },
    cooldown         = { action = 'ja', spell = 'Cooldown',               target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Reduce burden, remove overload' },
    darkmaneuver     = { action = 'ja', spell = 'Dark Maneuver',          target = 'me', level = 1, group = 'ja', desc = 'MP recovery' },
    deactivate       = { action = 'ja', spell = 'Deactivate',             target = 'me', level = 1, group = 'ja', desc = 'Deactivate automaton' },
    deploy           = { action = 'ja', spell = 'Deploy',                 target = 'lastst', level = 1, group = 'ja', desc = 'Orders automaton to attack' },
    deusexautomata   = { action = 'ja', spell = 'Deus Ex Automata',       target = 'me', level = 5, main_only = true, group = 'ja', desc = 'Summon automaton low HP (1min recast)' },
    earthmaneuver    = { action = 'ja', spell = 'Earth Maneuver',         target = 'me', level = 1, group = 'ja', desc = 'Physical defense (VIT+)' },
    firemaneuver     = { action = 'ja', spell = 'Fire Maneuver',          target = 'me', level = 1, group = 'ja', desc = 'Physical attack (STR+)' },
    headyartifice    = { action = 'ja', spell = 'Heady Artifice',         target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Head-specific special ability' },
    icemaneuver      = { action = 'ja', spell = 'Ice Maneuver',           target = 'me', level = 1, group = 'ja', desc = 'Magic attack/MACC (INT+)' },
    lightmaneuver    = { action = 'ja', spell = 'Light Maneuver',         target = 'me', level = 1, group = 'ja', desc = 'HP recovery (CHR+)' },
    maintenance      = { action = 'ja', spell = 'Maintenance',            target = 'me', level = 30, main_only = true, group = 'ja', desc = 'Remove automaton status (oil required)' },
    overdrive        = { action = 'ja', spell = 'Overdrive',              target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Automaton max power, no overload' },
    repair           = { action = 'ja', spell = 'Repair',                 target = 'me', level = 15, group = 'ja', desc = 'Restore automaton HP (oil required)' },
    retrieve         = { action = 'ja', spell = 'Retrieve',               target = 'me', level = 10, group = 'ja', desc = 'Orders automaton to return' },
    rolereversal     = { action = 'ja', spell = 'Role Reversal',          target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Swap HP with automaton' },
    tacticalswitch   = { action = 'ja', spell = 'Tactical Switch',        target = 'me', level = 79, main_only = true, group = 'ja', desc = 'Swap TP with automaton' },
    thundermaneuver  = { action = 'ja', spell = 'Thunder Maneuver',       target = 'me', level = 1, group = 'ja', desc = 'Accuracy (DEX+)' },
    ventriloquy      = { action = 'ja', spell = 'Ventriloquy',            target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Swap enmity with automaton' },
    watermaneuver    = { action = 'ja', spell = 'Water Maneuver',         target = 'me', level = 1, group = 'ja', desc = 'Magic defense (MND+)' },
    windmaneuver     = { action = 'ja', spell = 'Wind Maneuver',          target = 'me', level = 1, group = 'ja', desc = 'Evasion/Haste (AGI+)' },
}

return M
