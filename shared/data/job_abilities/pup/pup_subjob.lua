---============================================================================
--- PUP Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Puppetmaster abilities accessible as subjob (2 total)
---
--- Contents:
---   - Activate (Lv1) - Summon automaton
---   - Repair (Lv15) - Restore automaton HP (oil required)
---
--- @file pup_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Puppetmaster
---============================================================================

local PUP_SUBJOB = {}

PUP_SUBJOB.abilities = {
    ['Activate'] = {
        description             = 'Summon automaton',
        level                   = 1,
        recast                  = 1200,  -- 20min
        main_job_only           = false,
        cumulative_enmity       = 1,
        volatile_enmity         = 80
    },
    ['Repair'] = {
        description             = 'Restore automaton HP (oil required)',
        level                   = 15,
        recast                  = 90,  -- 1.5 minutes
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PUP_SUBJOB
