---============================================================================
--- PLD Job Abilities - SP Abilities Module
---============================================================================
--- Paladin special abilities (2 SP total)
---
--- Contents:
---   - Invincible (SP1, Lv1) - Physical damage immunity (30s)
---   - Intervene (SP2, Lv96) - Shield strike, ATK/ACC reduction (30s)
---
--- @file pld_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Paladin
--- @source https://www.bg-wiki.com/ffxi/Invincible
--- @source https://www.bg-wiki.com/ffxi/Intervene
---============================================================================

local PLD_SP = {}

PLD_SP.abilities = {
    ['Invincible'] = {
        description = "Physical damage immunity (30s)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Intervene'] = {
        description = "Shield strike, ATK/ACC → 1 (30s)",
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

return PLD_SP
