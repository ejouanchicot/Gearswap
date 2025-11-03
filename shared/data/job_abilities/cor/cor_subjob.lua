---============================================================================
--- COR Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Corsair abilities accessible as subjob (3 abilities + 15 Phantom Rolls)
--- Note: Phantom Rolls are in separate cor_rolls.lua module
---
--- Contents:
---   - Double-Up (Lv5) - Reroll last phantom roll (max 11)
---   - Quick Draw (Lv40) - Ranged elemental damage
---   - Random Deal (Lv50) - Random party ability reset
---
--- @file cor_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Corsair
--- @source https://www.bg-wiki.com/ffxi/Double-Up
--- @source https://www.bg-wiki.com/ffxi/Quick_Draw
--- @source https://www.bg-wiki.com/ffxi/Random_Deal
---============================================================================

local COR_SUBJOB = {}

COR_SUBJOB.abilities = {
    ['Double-Up'] = {
        description = "Reroll last roll (max 11)",
        level = 5,
        recast = 5,  -- 5 seconds
        main_job_only = false,  -- Accessible as subjob
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Quick Draw'] = {
        description = "Ranged elemental damage",
        level = 40,
        recast = 60,  -- 1 minute (reducible with merits)
        main_job_only = false,  -- Accessible as subjob
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Random Deal'] = {
        description = "Random party ability reset",
        level = 50,
        recast = 1200,  -- 20 minutes (reducible with merits)
        main_job_only = false,  -- Accessible as subjob
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return COR_SUBJOB
