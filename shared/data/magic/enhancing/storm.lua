---============================================================================
--- ENHANCING MAGIC DATABASE - Storm Spells Module
---============================================================================
--- SCH-exclusive weather effect spells (16 total)
---
--- @file storm.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local STORM = {}

STORM.spells = {

    ---========================================================================
    --- STORM SPELLS - SCH-Exclusive Weather Effects
    ---========================================================================

    ["Aurorastorm"] = {
        description = "Creates light weather effect.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 48,
        main_job_only = false,
        notes = "Changes weather to 'glittering' (Light). Enhances light-based damage and resistance. SCH-only.",
    },

    ["Aurorastorm II"] = {
        description = "Creates light weather effect.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced light weather effect ('glittering'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Firestorm"] = {
        description = "Creates fire weather effect.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 44,
        main_job_only = true,
        notes = "Changes weather to 'hot' (Fire). Enhances fire-based damage and resistance. SCH-only.",
    },

    ["Firestorm II"] = {
        description = "Creates fire weather effect.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced fire weather effect ('hot'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Hailstorm"] = {
        description = "Creates ice weather effect.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 45,
        main_job_only = true,
        notes = "Changes weather to 'cold' (Ice). Enhances ice-based damage and resistance. SCH-only.",
    },

    ["Hailstorm II"] = {
        description = "Creates ice weather effect.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced ice weather effect ('cold'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Rainstorm"] = {
        description = "Creates water weather effect.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 42,
        main_job_only = false,
        notes = "Changes weather to 'rainy' (Water). Enhances water-based damage and resistance. SCH-only.",
    },

    ["Rainstorm II"] = {
        description = "Creates water weather effect.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced water weather effect ('rainy'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Sandstorm"] = {
        description = "Creates earth weather effect.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 41,
        main_job_only = false,
        notes = "Changes weather to 'dusty' (Earth). Enhances earth-based damage and resistance. SCH-only.",
    },

    ["Sandstorm II"] = {
        description = "Creates earth weather effect.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced earth weather effect ('dusty'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Thunderstorm"] = {
        description = "Creates lightning weather effect.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 46,
        main_job_only = true,
        notes = "Changes weather to 'stormy' (Lightning). Enhances lightning-based damage and resistance. SCH-only.",
    },

    ["Thunderstorm II"] = {
        description = "Creates lightning weather effect.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced lightning weather effect ('stormy'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Voidstorm"] = {
        description = "Creates dark weather effect.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 47,
        main_job_only = true,
        notes = "Changes weather to 'dark'. Enhances dark-based damage and resistance. SCH-only.",
    },

    ["Voidstorm II"] = {
        description = "Creates dark weather effect.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced dark weather effect. Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

    ["Windstorm"] = {
        description = "Creates wind weather effect.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        tier = "I",
        SCH = 43,
        main_job_only = true,
        notes = "Changes weather to 'windy' (Wind). Enhances wind-based damage and resistance. SCH-only.",
    },

    ["Windstorm II"] = {
        description = "Creates wind weather effect.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 100,
        main_job_only = true,
        notes = "Enhanced wind weather effect ('windy'). Stronger elemental damage and resistance boost. Job Point ability (SCH).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return STORM
