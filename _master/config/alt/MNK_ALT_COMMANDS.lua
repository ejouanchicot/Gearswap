---============================================================================
--- MNK Alt Commands - what the alt does when it is on MNK
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether MNK is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in MNK_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/MNK_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    boost            = { action = 'ja', spell = 'Boost',                  target = 'me', level = 5, group = 'ja', desc = 'Enhance next attack' },
    chakra           = { action = 'ja', spell = 'Chakra',                 target = 'me', level = 35, group = 'ja', desc = 'Restore HP, remove Blind/Poison' },
    chiblast         = { action = 'ja', spell = 'Chi Blast',              target = 'lastst', level = 41, group = 'ja', desc = 'Ranged attack (TP based)' },
    counterstance    = { action = 'ja', spell = 'Counterstance',          target = 'me', level = 45, group = 'ja', desc = 'Counter boost, DEF penalty' },
    dodge            = { action = 'ja', spell = 'Dodge',                  target = 'me', level = 15, group = 'ja', desc = 'Evasion boost' },
    focus            = { action = 'ja', spell = 'Focus',                  target = 'me', level = 25, group = 'ja', desc = 'Accuracy boost' },
    footwork         = { action = 'ja', spell = 'Footwork',               target = 'me', level = 65, main_only = true, group = 'ja', desc = 'Kick attack rate/damage +20%' },
    formlessstrikes  = { action = 'ja', spell = 'Formless Strikes',       target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Bypass physical immunities' },
    hundredfists     = { action = 'ja', spell = 'Hundred Fists',          target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Attack speed +75%' },
    impetus          = { action = 'ja', spell = 'Impetus',                target = 'me', level = 88, main_only = true, group = 'ja', desc = 'Attack boost per hit (stacks)' },
    innerstrength    = { action = 'ja', spell = 'Inner Strength',         target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Max HP x2, Counter/Guard 100%' },
    mantra           = { action = 'ja', spell = 'Mantra',                 target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Party max HP boost' },
    perfectcounter   = { action = 'ja', spell = 'Perfect Counter',        target = 'me', level = 79, main_only = true, group = 'ja', desc = 'Counter rate 100%' },
}

return M
