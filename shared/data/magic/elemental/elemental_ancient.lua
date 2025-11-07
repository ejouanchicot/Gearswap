---============================================================================
--- Elemental Magic Database - Ancient Magic Spells Module
---============================================================================
--- Ancient Magic spells (tier I-II) - High-power single-target elemental
---
--- @file elemental_ancient.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---============================================================================

local elemental_ancient = {}

elemental_ancient.spells = {
    ---========================================================================
    --- TIER I (Ancient Magic, levels 50-60)
    ---========================================================================

    ["Freeze"] = {
        description             = "Deals ice dmg, lowers fire resist.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 50,
        notes                   = "Ancient Magic. Lowers enemy Fire resist by 30 for 10s. BLM-only.",
    },

    ["Tornado"] = {
        description             = "Deals wind dmg, lowers ice resist.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 52,
        notes                   = "Ancient Magic. Lowers enemy Ice resist by 30 for 10s. BLM-only.",
    },

    ["Quake"] = {
        description             = "Deals earth dmg, lowers wind resist.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 54,
        notes                   = "Ancient Magic. Lowers enemy Wind resist by 30 for 10s. BLM-only.",
    },

    ["Burst"] = {
        description             = "Deals thunder dmg, lowers earth resist.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 56,
        notes                   = "Ancient Magic. Lowers enemy Earth resist by 30 for 10s. BLM-only.",
    },

    ["Flood"] = {
        description             = "Deals water dmg, lowers thunder resist.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 58,
        notes                   = "Ancient Magic. Lowers enemy Thunder resist by 30 for 10s. BLM-only.",
    },

    ["Flare"] = {
        description             = "Deals fire dmg, lowers water resist.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 60,
        notes                   = "Ancient Magic. Lowers enemy Water resist by 30 for 10s. BLM-only.",
    },

    ---========================================================================
    --- TIER II (Ancient Magic II, all level 75)
    ---========================================================================

    ["Freeze II"] = {
        description             = "Deals ice dmg, lowers fire resist.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 75,
        notes                   = "Ancient Magic. Lowers enemy Fire resist by 30 for 10s. BLM-only.",
    },

    ["Tornado II"] = {
        description             = "Deals wind dmg, lowers ice resist.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 75,
        notes                   = "Ancient Magic. Lowers enemy Ice resist by 30 for 10s. BLM-only.",
    },

    ["Quake II"] = {
        description             = "Deals earth dmg, lowers wind resist.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 75,
        notes                   = "Ancient Magic. Lowers enemy Wind resist by 30 for 10s. BLM-only.",
    },

    ["Burst II"] = {
        description             = "Deals thunder dmg, lowers earth resist.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 75,
        notes                   = "Ancient Magic. Lowers enemy Earth resist by 30 for 10s. BLM-only.",
    },

    ["Flood II"] = {
        description             = "Deals water dmg, lowers thunder resist.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 75,
        notes                   = "Ancient Magic. Lowers enemy Thunder resist by 30 for 10s. BLM-only.",
    },

    ["Flare II"] = {
        description             = "Deals fire dmg, lowers water resist.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 75,
        notes                   = "Ancient Magic. Lowers enemy Water resist by 30 for 10s. BLM-only.",
    },
}

return elemental_ancient
