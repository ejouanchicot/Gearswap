---============================================================================
--- DRG Alt Commands - what the alt does when it is on DRG
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether DRG is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in DRG_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/DRG_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    ancientcircle    = { action = 'ja', spell = 'Ancient Circle',         target = 'me', level = 5, group = 'ja', desc = 'ATK/ACC/DEF+ vs Dragons (party AoE)' },
    angon            = { action = 'ja', spell = 'Angon',                  target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Enemy defense down' },
    callwyvern       = { action = 'ja', spell = 'Call Wyvern',            target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Summons wyvern' },
    deepbreathing    = { action = 'ja', spell = 'Deep Breathing',         target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Next wyvern breath x2' },
    dismiss          = { action = 'ja', spell = 'Dismiss',                target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Sends wyvern away' },
    dragonbreaker    = { action = 'ja', spell = 'Dragon Breaker',         target = 'lastst', level = 87, main_only = true, group = 'ja', desc = 'Dragon debuff (ACC/EVA/MACC/MEVA/TP down)' },
    flyhigh          = { action = 'ja', spell = 'Fly High',               target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Reset Jump timers, 10s recast' },
    highjump         = { action = 'ja', spell = 'High Jump',              target = 'lastst', level = 35, group = 'ja', desc = 'Jumping attack, enmity -50%' },
    jump             = { action = 'ja', spell = 'Jump',                   target = 'lastst', level = 10, group = 'ja', desc = 'Jumping attack' },
    restoringbreath  = { action = 'ja', spell = 'Restoring Breath',       target = 'me', level = 90, main_only = true, group = 'ja', desc = 'Orders wyvern to heal with breath' },
    smitingbreath    = { action = 'ja', spell = 'Smiting Breath',         target = 'lastst', level = 90, main_only = true, group = 'ja', desc = 'Orders wyvern to attack with breath' },
    souljump         = { action = 'ja', spell = 'Soul Jump',              target = 'lastst', level = 85, main_only = true, group = 'ja', desc = 'High jump, enmity suppression' },
    spiritbond       = { action = 'ja', spell = 'Spirit Bond',            target = 'lastst', level = 65, main_only = true, group = 'ja', desc = 'Take damage for wyvern' },
    spiritjump       = { action = 'ja', spell = 'Spirit Jump',            target = 'lastst', level = 77, main_only = true, group = 'ja', desc = 'Jump, enmity suppression' },
    spiritlink       = { action = 'ja', spell = 'Spirit Link',            target = 'me', level = 25, group = 'ja', desc = 'Transfer HP/status to wyvern' },
    spiritsurge      = { action = 'ja', spell = 'Spirit Surge',           target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Adds wyvern' },
    steadywing       = { action = 'ja', spell = 'Steady Wing',            target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Create barrier that absorbs damage to wyvern' },
    superjump        = { action = 'ja', spell = 'Super Jump',             target = 'lastst', level = 50, group = 'ja', desc = 'Reset enmity to 1' },
}

return M
