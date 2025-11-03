---============================================================================
--- PLD Job Abilities - Main Job Only Module
---============================================================================
--- Paladin abilities restricted to main job (7 total)
---
--- Contents:
---   - Rampart (Lv62) - Party damage reduction
---   - Majesty (Lv70) - Cure/Protect AoE enhancement
---   - Fealty (Lv75 Merit) - Enfeebling resistance
---   - Chivalry (Lv75 Merit) - TP to MP conversion
---   - Divine Emblem (Lv78) - Divine spell enhancement
---   - Sepulcher (Lv87) - Undead debuff
---   - Palisade (Lv95) - Shield block enhancement
---
--- @file pld_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Paladin
---============================================================================

local PLD_MAINJOB = {}

PLD_MAINJOB.abilities = {
    ['Rampart'] = {
        description = 'Party damage -25% (30s)',
        level = 62,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Majesty'] = {
        description = 'Cure/Protect AoE, +potency/-recast',
        level = 70,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Fealty'] = {
        description = 'Enfeebling resist, blocks Charm',
        level = 75,
        recast = 600,  -- 10 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Chivalry'] = {
        description = 'TP → MP',
        level = 75,
        recast = 600,  -- 10 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Divine Emblem'] = {
        description = 'Next divine spell MACC+, enmity+',
        level = 78,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 320
    },
    ['Sepulcher'] = {
        description = 'Undead: ACC/EVA/MACC/MEVA/TP down',
        level = 87,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Palisade'] = {
        description = 'Shield block +30%, no enmity loss',
        level = 95,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLD_MAINJOB
