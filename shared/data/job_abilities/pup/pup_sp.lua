---============================================================================
--- PUP Job Abilities - SP Abilities Module
---============================================================================
--- Puppetmaster special abilities (2 SP total)
---
--- Contents:
---   - Overdrive (SP1, Lv1) - Automaton max power, no overload (3min)
---   - Heady Artifice (SP2, Lv96) - Head-specific special ability
---
--- @file pup_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Puppetmaster
--- @source https://www.bg-wiki.com/ffxi/Overdrive
--- @source https://www.bg-wiki.com/ffxi/Heady_Artifice
---============================================================================

local PUP_SP = {}

PUP_SP.abilities = {
    ['Overdrive'] = {
        description = "Automaton max power, no overload (3min)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Heady Artifice'] = {
        description = "Head-specific special ability",
        level = 96,
        recast = 3600,  -- 1 hour (SP2)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PUP_SP
