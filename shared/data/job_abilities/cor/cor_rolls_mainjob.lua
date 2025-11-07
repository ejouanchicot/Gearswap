---============================================================================
--- COR Job Abilities - Phantom Rolls (Main Job Only)
---============================================================================
--- Corsair Phantom Rolls restricted to main job (13 rolls, Lv61-97)
--- These rolls cannot be used when COR is a subjob
---
--- @file cor_rolls_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Category:Phantom_Roll
---============================================================================

local COR_ROLLS_MAINJOB = {}

COR_ROLLS_MAINJOB.abilities = {
    ["Dancer's Roll"] = {
        description             = "Regen (HP/tick)",
        level                   = 61,
        recast                  = 0,  -- Shared Phantom Roll timer
        main_job_only           = true,
        lucky                   = 3,
        unlucky                 = 7
    },
    ["Scholar's Roll"] = {
        description             = "Conserve MP+",
        level                   = 64,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 2,
        unlucky                 = 6
    },
    ["Naturalist's Roll"] = {
        description             = "Enhancing magic duration+",
        level                   = 67,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 3,
        unlucky                 = 7
    },
    ["Runeist's Roll"] = {
        description             = "Magic Evasion+",
        level                   = 70,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 4,
        unlucky                 = 8
    },
    ["Bolter's Roll"] = {
        description             = "Movement speed+",
        level                   = 76,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 3,
        unlucky                 = 9
    },
    ["Caster's Roll"] = {
        description             = "Fast Cast+",
        level                   = 79,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 2,
        unlucky                 = 7
    },
    ["Courser's Roll"] = {
        description             = "Snapshot+",
        level                   = 81,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 3,
        unlucky                 = 9
    },
    ["Blitzer's Roll"] = {
        description             = "Attack delay-",
        level                   = 83,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 4,
        unlucky                 = 9
    },
    ["Tactician's Roll"] = {
        description             = "Regain (TP/tick)",
        level                   = 86,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 5,
        unlucky                 = 8
    },
    ["Allies' Roll"] = {
        description             = "Skillchain damage+",
        level                   = 89,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 3,
        unlucky                 = 10
    },
    ["Miser's Roll"] = {
        description             = "Save TP",
        level                   = 92,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 5,
        unlucky                 = 7
    },
    ["Companion's Roll"] = {
        description             = "Pet Regain/Regen",
        level                   = 95,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 2,
        unlucky                 = 10
    },
    ["Avenger's Roll"] = {
        description             = "Counter rate+",
        level                   = 97,
        recast                  = 0,
        main_job_only           = true,
        lucky                   = 4,
        unlucky                 = 8
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return COR_ROLLS_MAINJOB
