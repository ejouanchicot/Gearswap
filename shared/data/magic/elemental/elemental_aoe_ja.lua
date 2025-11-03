---============================================================================
--- Elemental Magic Database - AOE -ja Spells Module
---============================================================================
--- Area of Effect elemental spells tier IV (-ja suffix)
---
--- @file elemental_aoe_ja.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---============================================================================

local elemental_aoe_ja = {}

elemental_aoe_ja.spells = {
    ["Stoneja"] = {
        description = "Deals AOE dmg (stacks).",
        category = "Elemental",
        element = "Earth",
        magic_type = "Black",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        BLM = 81,
        notes = "AOE earth damage (~10y range). Cumulative magic: potency increases with successive casts. BLM-only.",
    },

    ["Waterja"] = {
        description = "Deals AOE dmg (stacks).",
        category = "Elemental",
        element = "Water",
        magic_type = "Black",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        BLM = 84,
        notes = "AOE water damage (~10y range). Cumulative magic: potency increases with successive casts. BLM-only.",
    },

    ["Aeroja"] = {
        description = "Deals AOE dmg (stacks).",
        category = "Elemental",
        element = "Wind",
        magic_type = "Black",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        BLM = 87,
        notes = "AOE wind damage (~10y range). Cumulative magic: potency increases with successive casts. BLM-only.",
    },

    ["Firaja"] = {
        description = "Deals AOE dmg (stacks).",
        category = "Elemental",
        element = "Fire",
        magic_type = "Black",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        BLM = 90,
        notes = "AOE fire damage (~10y range). Cumulative magic: potency increases with successive casts. BLM-only.",
    },

    ["Blizzaja"] = {
        description = "Deals AOE dmg (stacks).",
        category = "Elemental",
        element = "Ice",
        magic_type = "Black",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        BLM = 93,
        notes = "AOE ice damage (~10y range). Cumulative magic: potency increases with successive casts. BLM-only.",
    },

    ["Thundaja"] = {
        description = "Deals AOE dmg (stacks).",
        category = "Elemental",
        element = "Thunder",
        magic_type = "Black",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        BLM = 96,
        notes = "AOE thunder damage (~10y range). Cumulative magic: potency increases with successive casts. BLM-only.",
    },
}

return elemental_aoe_ja
