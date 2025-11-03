---============================================================================
--- Elemental Magic Database - AOE -ra Spells Module
---============================================================================
--- Area of Effect elemental spells tier I-III (-ra suffix)
---
--- @file elemental_aoe_ra.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---
--- NOTES:
--- - All -ra spells are GEO-only (NOT available to BLM, SCH, RDM, DRK)
--- - Six elements: Fire (Fira), Ice (Blizzara), Thunder (Thundara),
---   Water (Watera), Wind (Aerora), Earth (Stonera)
--- - Tier III requires 1200 Job Points (Job Point Gift)
--- - AOE range: 10 yards
---============================================================================

local elemental_aoe_ra = {}

elemental_aoe_ra.spells = {
    ---========================================================================
    --- TIER I (-ra spells, levels 25-50)
    ---========================================================================

    ["Stonera"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Earth",
        magic_type = "Black",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 25,
        notes = "AOE earth damage (~10y range). GEO-only.",
    },

    ["Watera"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Water",
        magic_type = "Black",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 30,
        notes = "AOE water damage (~10y range). GEO-only.",
    },

    ["Aerora"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Wind",
        magic_type = "Black",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 35,
        notes = "AOE wind damage (~10y range). GEO-only.",
    },

    ["Fira"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Fire",
        magic_type = "Black",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 40,
        notes = "AOE fire damage (~10y range). GEO-only.",
    },

    ["Blizzara"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Ice",
        magic_type = "Black",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 45,
        notes = "AOE ice damage (~10y range). GEO-only.",
    },

    ["Thundara"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Thunder",
        magic_type = "Black",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 50,
        notes = "AOE thunder damage (~10y range). GEO-only.",
    },

    ---========================================================================
    --- TIER II (-ra II spells, levels 70-95)
    ---========================================================================

    ["Stonera II"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Earth",
        magic_type = "Black",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 70,
        notes = "AOE earth damage (~10y range). GEO-only.",
    },

    ["Watera II"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Water",
        magic_type = "Black",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 75,
        notes = "AOE water damage (~10y range). GEO-only.",
    },

    ["Aerora II"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Wind",
        magic_type = "Black",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 80,
        notes = "AOE wind damage (~10y range). GEO-only.",
    },

    ["Fira II"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Fire",
        magic_type = "Black",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 85,
        notes = "AOE fire damage (~10y range). GEO-only.",
    },

    ["Blizzara II"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Ice",
        magic_type = "Black",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 90,
        notes = "AOE ice damage (~10y range). GEO-only.",
    },

    ["Thundara II"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Thunder",
        magic_type = "Black",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 95,
        notes = "AOE thunder damage (~10y range). GEO-only.",
    },

    ---========================================================================
    --- TIER III (-ra III spells, 1200 Job Points Gift)
    ---========================================================================

    ["Stonera III"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Earth",
        magic_type = "Black",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 1200,
        notes = "AOE earth damage (~10y range). Requires 1200 Job Points (Gift). GEO-only.",
    },

    ["Watera III"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Water",
        magic_type = "Black",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 1200,
        notes = "AOE water damage (~10y range). Requires 1200 Job Points (Gift). GEO-only.",
    },

    ["Aerora III"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Wind",
        magic_type = "Black",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 1200,
        notes = "AOE wind damage (~10y range). Requires 1200 Job Points (Gift). GEO-only.",
    },

    ["Fira III"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Fire",
        magic_type = "Black",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 1200,
        notes = "AOE fire damage (~10y range). Requires 1200 Job Points (Gift). GEO-only.",
    },

    ["Blizzara III"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Ice",
        magic_type = "Black",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 1200,
        notes = "AOE ice damage (~10y range). Requires 1200 Job Points (Gift). GEO-only.",
    },

    ["Thundara III"] = {
        description = "Deals AOE dmg.",
        category = "Elemental",
        element = "Thunder",
        magic_type = "Black",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        GEO = 1200,
        notes = "AOE thunder damage (~10y range). Requires 1200 Job Points (Gift). GEO-only.",
    },
}

return elemental_aoe_ra
