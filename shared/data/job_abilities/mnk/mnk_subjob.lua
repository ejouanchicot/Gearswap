---============================================================================
--- MNK Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Monk abilities accessible as subjob (6 total)
---
--- Contents:
---   - Boost (Lv5) - Enhance next attack
---   - Dodge (Lv15) - Evasion boost
---   - Focus (Lv25) - Accuracy boost
---   - Chakra (Lv35) - HP recovery, status removal
---   - Chi Blast (Lv41) - Ranged attack (TP based)
---   - Counterstance (Lv45) - Counter boost, defense penalty
---
--- @file mnk_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Monk
---============================================================================

local MNK_SUBJOB = {}

MNK_SUBJOB.abilities = {
    ['Boost'] = {
        description = 'Enhance next attack',
        level = 5,
        recast = 60,  -- 1 minute
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Dodge'] = {
        description = 'Evasion boost',
        level = 15,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Focus'] = {
        description = 'Accuracy boost',
        level = 25,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Chakra'] = {
        description = 'Restore HP, remove Blind/Poison',
        level = 35,
        recast = 180,  -- 3 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Chi Blast'] = {
        description = 'Ranged attack (TP based)',
        level = 41,
        recast = 180,  -- 3 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Counterstance'] = {
        description = 'Counter boost, DEF penalty',
        level = 45,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return MNK_SUBJOB
