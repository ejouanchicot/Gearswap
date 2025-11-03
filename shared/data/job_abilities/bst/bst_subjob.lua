---============================================================================
--- BST Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Beastmaster abilities accessible as subjob (6 total)
---
--- Contents:
---   - Charm (Lv1) - Tame monster as pet
---   - Gauge (Lv10) - Check charm success rate
---   - Reward (Lv12) - Restore pet HP (food required)
---   - Call Beast (Lv23) - Summon jug pet (consumes jug)
---   - Bestial Loyalty (Lv23) - Summon jug pet (no consume)
---   - Tame (Lv30) - Lower enemy resistance to charm
---
--- @file bst_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Beastmaster
---============================================================================

local BST_SUBJOB = {}

BST_SUBJOB.abilities = {
    ['Charm'] = {
        description = 'Tame monster as pet',
        level = 1,
        recast = 15,  -- 15 seconds
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Gauge'] = {
        description = 'Check charm success rate',
        level = 10,
        recast = 30,  -- 30 seconds
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Reward'] = {
        description = 'Restore pet HP (food required)',
        level = 12,
        recast = 90,  -- 1.5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Call Beast'] = {
        description = 'Summon jug pet (consumes jug)',
        level = 23,
        recast = 300,  -- 5 minutes (base)
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Bestial Loyalty'] = {
        description = 'Summon jug pet (no consume)',
        level = 23,
        recast = 1200,  -- 20 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Tame'] = {
        description = 'Lower enemy resistance to charm',
        level = 30,
        recast = 600,  -- 10 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BST_SUBJOB
