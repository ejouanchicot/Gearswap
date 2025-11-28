---============================================================================
--- PUP Job Abilities - Main Job Only Module
---============================================================================
--- Puppetmaster abilities restricted to main job (6 total)
---
--- Contents:
---   - Deus Ex Automata (Lv5) - Summon automaton low HP (1min recast)
---   - Maintenance (Lv30) - Remove automaton status (oil required)
---   - Ventriloquy (Lv75 Merit) - Swap enmity with automaton
---   - Role Reversal (Lv75 Merit) - Swap HP with automaton
---   - Tactical Switch (Lv79) - Swap TP with automaton
---   - Cooldown (Lv95) - Reduce burden, remove overload
---
--- @file pup_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Puppetmaster
---============================================================================

local PUP_MAINJOB = {}

PUP_MAINJOB.abilities = {
    ['Deus Ex Automata'] = {
        description             = 'Summon automaton low HP (1min recast)',
        level                   = 5,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Maintenance'] = {
        description             = 'Remove automaton status (oil required)',
        level                   = 30,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Ventriloquy'] = {
        description             = 'Swap enmity with automaton',
        level                   = 75,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Role Reversal'] = {
        description             = 'Swap HP with automaton',
        level                   = 75,
        recast                  = 120,  -- 2min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Tactical Switch'] = {
        description             = 'Swap TP with automaton',
        level                   = 79,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Cooldown'] = {
        description             = 'Reduce burden, remove overload',
        level                   = 95,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PUP_MAINJOB
