---============================================================================
--- DRG Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Dragoon abilities accessible as subjob (5 total)
---
--- Contents:
---   - Ancient Circle (Lv5) - Attack/ACC vs Dragons
---   - Jump (Lv10) - Basic jump attack, -enmity
---   - Spirit Link (Lv25) - Transfer HP/buffs/debuffs to Wyvern
---   - High Jump (Lv35) - Enhanced jump, greater -enmity
---   - Super Jump (Lv50) - Maximum -enmity (requires Master Levels)
---
--- @file drg_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
---============================================================================

local DRG_SUBJOB = {}

DRG_SUBJOB.abilities = {
    ['Ancient Circle'] = {
        description = 'ATK/ACC/DEF+ vs Dragons (party AoE)',
        level = 5,
        recast = 300, -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Jump'] = {
        description = 'Jumping attack',
        level = 10,
        recast = 60, -- 1 minute
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Spirit Link'] = {
        description = 'Transfer HP/status to wyvern',
        level = 25,
        recast = 60, -- 1 minute
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['High Jump'] = {
        description = 'Jumping attack, enmity -50%',
        level = 35,
        recast = 120, -- 2 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Super Jump'] = {
        description = 'Reset enmity to 1',
        level = 50,
        recast = 180, -- 3 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

return DRG_SUBJOB
