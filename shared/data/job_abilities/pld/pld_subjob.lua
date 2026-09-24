---============================================================================
--- PLD Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Paladin abilities accessible as subjob (4 total)
---
--- Contents:
---   - Holy Circle (Lv5) - Party resistance vs Undead
---   - Shield Bash (Lv15) - Stun attack
---   - Sentinel (Lv30) - Damage reduction + enmity
---   - Cover (Lv35) - Redirect ally damage
---
--- @file shared/data/job_abilities/pld/pld_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Paladin
---============================================================================

local PLD_SUBJOB = {}

PLD_SUBJOB.abilities = {
    ['Holy Circle'] = {
        description             = 'Party AoE: dmg dealt+/taken- vs Undead',
        level                   = 5,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 5
    },
    ['Shield Bash'] = {
        description             = 'Stun attack',
        level                   = 15,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 450,
        volatile_enmity         = 900
    },
    ['Sentinel'] = {
        description             = 'Physical damage -90>>-50%, +enmity',
        level                   = 30,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 900
    },
    ['Cover'] = {
        description             = 'Redirect ally damage to self',
        level                   = 35,
        recast                  = 180,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 1
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLD_SUBJOB
