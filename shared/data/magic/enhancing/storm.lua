---============================================================================
--- ENHANCING MAGIC DATABASE - Storm Spells Module
---============================================================================
--- SCH-exclusive weather effect spells (16 total)
---
--- Storm Spells:
---   - Creates elemental weather effects that enhance matching element damage/resistance
---   - Duration scales with Enhancing Magic skill (cap 500 = 300 seconds)
---   - Equipment: Duration gear (Telchine set) - no specific Storm potency gear found
---
--- @file storm.lua
--- @author Tetsouo
--- @version 2.0 - Standardized with spell_family
--- @date Created: 2025-10-30 | Updated: 2025-11-05
---============================================================================

local STORM = {}

STORM.spells = {

    ---========================================================================
    --- STORM SPELLS - SCH-Exclusive Weather Effects
    ---========================================================================

    ["Aurorastorm"] = {
        description = "Changes weather to light, enhancing light-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Light weather: +10% magic damage, +10% magic resistance",
        SCH = 48,
    },

    ["Aurorastorm II"] = {
        description = "Changes weather to light, enhancing light-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Light weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Firestorm"] = {
        description = "Changes weather to fire, enhancing fire-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Fire",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Fire weather: +10% magic damage, +10% magic resistance",
        SCH = 44,
        main_job_only = true,
    },

    ["Firestorm II"] = {
        description = "Changes weather to fire, enhancing fire-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Fire",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Fire weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Hailstorm"] = {
        description = "Changes weather to ice, enhancing ice-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Ice",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Ice weather: +10% magic damage, +10% magic resistance",
        SCH = 45,
        main_job_only = true,
    },

    ["Hailstorm II"] = {
        description = "Changes weather to ice, enhancing ice-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Ice",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Ice weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Rainstorm"] = {
        description = "Changes weather to water, enhancing water-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Water weather: +10% magic damage, +10% magic resistance",
        SCH = 42,
    },

    ["Rainstorm II"] = {
        description = "Changes weather to water, enhancing water-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Water weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Sandstorm"] = {
        description = "Changes weather to earth, enhancing earth-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Earth",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Earth weather: +10% magic damage, +10% magic resistance",
        SCH = 41,
    },

    ["Sandstorm II"] = {
        description = "Changes weather to earth, enhancing earth-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Earth",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Earth weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Thunderstorm"] = {
        description = "Changes weather to lightning, enhancing lightning-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Thunder",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Thunder weather: +10% magic damage, +10% magic resistance",
        SCH = 46,
        main_job_only = true,
    },

    ["Thunderstorm II"] = {
        description = "Changes weather to lightning, enhancing lightning-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Thunder",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Thunder weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Voidstorm"] = {
        description = "Changes weather to dark, enhancing dark-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Dark",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Dark weather: +10% magic damage, +10% magic resistance",
        SCH = 47,
        main_job_only = true,
    },

    ["Voidstorm II"] = {
        description = "Changes weather to dark, enhancing dark-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Dark",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Dark weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

    ["Windstorm"] = {
        description = "Changes weather to wind, enhancing wind-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "I",
        element = "Wind",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Wind weather: +10% magic damage, +10% magic resistance",
        SCH = 43,
        main_job_only = true,
    },

    ["Windstorm II"] = {
        description = "Changes weather to wind, enhancing wind-based damage and resistance.",
        skill = "Enhancing Magic",
        spell_family = "Storm",
        target_type = "single",
        tier = "II",
        element = "Wind",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Wind weather: +15% magic damage, +15% magic resistance",
        SCH = 100,
        main_job_only = true,
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return STORM
