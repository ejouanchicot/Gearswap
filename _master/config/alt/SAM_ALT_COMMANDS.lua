---============================================================================
--- SAM Alt Commands - what the alt does when it is on SAM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether SAM is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in SAM_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/SAM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    bladebash        = { action = 'ja', spell = 'Blade Bash',             target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Stun attack' },
    hagakure         = { action = 'ja', spell = 'Hagakure',               target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Convert Kenki >> HP/MP/TP' },
    hamanoha         = { action = 'ja', spell = 'Hamanoha',               target = 'lastst', level = 87, main_only = true, group = 'ja', desc = 'Zanshin +100%' },
    hasso            = { action = 'ja', spell = 'Hasso',                  target = 'me', level = 25, group = 'ja', desc = 'STR/Haste/ACC+' },
    konzenittai      = { action = 'ja', spell = 'Konzen-ittai',           target = 'lastst', level = 65, main_only = true, group = 'ja', desc = 'WS TP bonus' },
    meditate         = { action = 'ja', spell = 'Meditate',               target = 'me', level = 30, group = 'ja', desc = 'Restore TP' },
    meikyoshisui     = { action = 'ja', spell = 'Meikyo Shisui',          target = 'me', level = 1, main_only = true, group = 'ja', desc = 'WS TP cost >> 1000' },
    seigan           = { action = 'ja', spell = 'Seigan',                 target = 'me', level = 35, group = 'ja', desc = 'Third Eye enhanced' },
    sekkanoki        = { action = 'ja', spell = 'Sekkanoki',              target = 'me', level = 40, group = 'ja', desc = 'Next WS TP cost >> 1000' },
    sengikori        = { action = 'ja', spell = 'Sengikori',              target = 'me', level = 77, main_only = true, group = 'ja', desc = 'Store TP boost' },
    shikikoyo        = { action = 'ja', spell = 'Shikikoyo',              target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Share TP >1000 with party member' },
    thirdeye         = { action = 'ja', spell = 'Third Eye',              target = 'me', level = 15, group = 'ja', desc = 'Anticipate/Counter next attack' },
    wardingcircle    = { action = 'ja', spell = 'Warding Circle',         target = 'me', level = 5, group = 'ja', desc = 'ATK/DEF+ vs Demons (party AoE)' },
    yaegasumi        = { action = 'ja', spell = 'Yaegasumi',              target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Evade special attacks, WS damage+' },
}

return M
