---============================================================================
--- COR Job Abilities - Phantom Rolls (Sub-Job Accessible)
---============================================================================
--- Corsair Phantom Rolls accessible as subjob (18 rolls, Lv5-58)
--- Subjobs can maintain 1 active roll (vs 2 for main job)
---
--- Note: Rolls Lv52-58 require Master Levels to access as subjob
---
--- @file cor_rolls.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Category:Phantom_Roll
---============================================================================

local COR_ROLLS = {}

COR_ROLLS.abilities = {
    ["Corsair's Roll"] = {
        description             = "EXP/CP/EP bonus",
        level                   = 5,
        recast                  = 0,  -- Shared Phantom Roll timer
        main_job_only           = false,
        lucky                   = 5,
        unlucky                 = 9
    },
    ["Ninja Roll"] = {
        description             = "Evasion+",
        level                   = 8,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Hunter's Roll"] = {
        description             = "Accuracy/Ranged Accuracy+",
        level                   = 11,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Chaos Roll"] = {
        description             = "Attack+",
        level                   = 14,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Magus's Roll"] = {
        description             = "Magic Defense+",
        level                   = 17,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 2,
        unlucky                 = 6
    },
    ["Healer's Roll"] = {
        description             = "Cure potency+",
        level                   = 20,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 3,
        unlucky                 = 7
    },
    ["Drachen Roll"] = {
        description             = "Pet Accuracy/Ranged Accuracy+",
        level                   = 23,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Choral Roll"] = {
        description             = "Spell interruption rate-",
        level                   = 26,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 2,
        unlucky                 = 6
    },
    ["Monk's Roll"] = {
        description             = "Subtle Blow+",
        level                   = 31,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 3,
        unlucky                 = 7
    },
    ["Beast Roll"] = {
        description             = "Pet Attack/Ranged Attack+",
        level                   = 34,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Samurai Roll"] = {
        description             = "Store TP+",
        level                   = 37,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 2,
        unlucky                 = 6
    },
    ["Evoker's Roll"] = {
        description             = "Refresh (MP regen)",
        level                   = 40,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 5,
        unlucky                 = 9
    },
    ["Rogue's Roll"] = {
        description             = "Critical hit rate+",
        level                   = 43,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 5,
        unlucky                 = 9
    },
    ["Warlock's Roll"] = {
        description             = "Magic Accuracy+",
        level                   = 46,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Fighter's Roll"] = {
        description             = "Double Attack rate+",
        level                   = 49,
        recast                  = 0,
        main_job_only           = false,
        lucky                   = 5,
        unlucky                 = 9
    },

    ---========================================================================
    --- MASTER LEVEL ROLLS (Lv52-58, require Master Levels for subjob access)
    ---========================================================================

    ["Puppet Roll"] = {
        description             = "Pet Magic Attack/Magic Accuracy+",
        level                   = 52,
        recast                  = 0,
        main_job_only           = false,  -- Accessible as subjob with Master Levels
        lucky                   = 3,
        unlucky                 = 7
    },
    ["Gallant's Roll"] = {
        description             = "Defense+",
        level                   = 55,
        recast                  = 0,
        main_job_only           = false,  -- Accessible as subjob with Master Levels
        lucky                   = 3,
        unlucky                 = 7
    },
    ["Wizard's Roll"] = {
        description             = "Magic Attack+",
        level                   = 58,
        recast                  = 0,
        main_job_only           = false,  -- Accessible as subjob with Master Levels
        lucky                   = 5,
        unlucky                 = 9
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return COR_ROLLS
