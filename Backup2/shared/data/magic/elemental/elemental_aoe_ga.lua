---============================================================================
--- Elemental Magic Database - AOE -ga Spells Module
---============================================================================
--- Area of Effect elemental spells tier I-III (-ga suffix)
---
--- @file elemental_aoe_ga.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---============================================================================

local elemental_aoe_ga = {}

elemental_aoe_ga.spells = {
    ---========================================================================
    --- TIER I (-ga spells, levels 15-36)
    ---========================================================================

    ["Stonega"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 15,
        notes                   = "AOE earth damage (~10y range). BLM-only.",
    },

    ["Waterga"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 19,
        notes                   = "AOE water damage (~10y range). BLM-only.",
    },

    ["Aeroga"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 23,
        notes                   = "AOE wind damage (~10y range). BLM-only.",
    },

    ["Firaga"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 28,
        notes                   = "AOE fire damage (~10y range). BLM-only.",
    },

    ["Blizzaga"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 32,
        notes                   = "AOE ice damage (~10y range). BLM-only.",
    },

    ["Thundaga"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 36,
        notes                   = "AOE thunder damage (~10y range). BLM-only.",
    },

    ---========================================================================
    --- TIER II (-ga II spells, levels 40-61)
    ---========================================================================

    ["Stonega II"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 40,
        notes                   = "AOE earth damage (~10y range). BLM-only.",
    },

    ["Waterga II"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 44,
        notes                   = "AOE water damage (~10y range). BLM-only.",
    },

    ["Aeroga II"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 48,
        notes                   = "AOE wind damage (~10y range). BLM-only.",
    },

    ["Firaga II"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 53,
        notes                   = "AOE fire damage (~10y range). BLM-only.",
    },

    ["Blizzaga II"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 57,
        notes                   = "AOE ice damage (~10y range). BLM-only.",
    },

    ["Thundaga II"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 61,
        notes                   = "AOE thunder damage (~10y range). BLM-only.",
    },

    ---========================================================================
    --- TIER III (-ga III spells, levels 63-73)
    ---========================================================================

    ["Stonega III"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 63,
        notes                   = "AOE earth damage (~10y range). BLM-only.",
    },

    ["Waterga III"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 65,
        notes                   = "AOE water damage (~10y range). BLM-only.",
    },

    ["Aeroga III"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 67,
        notes                   = "AOE wind damage (~10y range). BLM-only.",
    },

    ["Firaga III"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 69,
        notes                   = "AOE fire damage (~10y range). BLM-only.",
    },

    ["Blizzaga III"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 71,
        notes                   = "AOE ice damage (~10y range). BLM-only.",
    },

    ["Thundaga III"] = {
        description             = "Deals AOE dmg.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 73,
        notes                   = "AOE thunder damage (~10y range). BLM-only.",
    },
}

return elemental_aoe_ga
