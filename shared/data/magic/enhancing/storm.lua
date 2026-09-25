---============================================================================
--- ENHANCING MAGIC DATABASE - Storm Spells Module
---============================================================================
--- SCH-exclusive weather effect spells (16 total)
---
--- Storm Spells:
---   - Set the weather around one party member for 3 minutes (tier II:
---     double weather)
---   - With Stormsurge merits, also raise the element's attribute
---
--- @file shared/data/magic/enhancing/storm.lua
--- @author Tetsouo
--- @version 2.1 - Improved alignment - Standardized with spell_family
--- @date Created: 2025-10-30 | Updated: 2025-11-06
---============================================================================

local STORM = {}

STORM.spells = {

    ---========================================================================
    --- STORM SPELLS - SCH-Exclusive Weather Effects
    ---========================================================================

    ["Aurorastorm"] = {
        description             = "Sets auroras weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to auroras for 3 minutes. With Stormsurge merits, also grants CHR +3 to +7.",
        SCH                     = 48,
    },

    ["Aurorastorm II"] = {
        description             = "Sets double auroras weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double auroras weather for 3 minutes. With Stormsurge merits, also grants CHR +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Firestorm"] = {
        description             = "Sets hot weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Fire",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to hot for 3 minutes. With Stormsurge merits, also grants STR +3 to +7.",
        SCH                     = 44,
        main_job_only           = true,
    },

    ["Firestorm II"] = {
        description             = "Sets double hot weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Fire",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double hot weather for 3 minutes. With Stormsurge merits, also grants STR +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Hailstorm"] = {
        description             = "Sets snowy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Ice",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to snowy for 3 minutes. With Stormsurge merits, also grants INT +3 to +7.",
        SCH                     = 45,
        main_job_only           = true,
    },

    ["Hailstorm II"] = {
        description             = "Sets double snowy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Ice",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double snowy weather for 3 minutes. With Stormsurge merits, also grants INT +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Rainstorm"] = {
        description             = "Sets rainy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to rainy for 3 minutes. With Stormsurge merits, also grants MND +3 to +7.",
        SCH                     = 42,
    },

    ["Rainstorm II"] = {
        description             = "Sets double rainy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double rainy weather for 3 minutes. With Stormsurge merits, also grants MND +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Sandstorm"] = {
        description             = "Sets dusty weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to dusty for 3 minutes. With Stormsurge merits, also grants VIT +3 to +7.",
        SCH                     = 41,
    },

    ["Sandstorm II"] = {
        description             = "Sets double dusty weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double dusty weather for 3 minutes. With Stormsurge merits, also grants VIT +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Thunderstorm"] = {
        description             = "Sets thundery weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Thunder",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to thundery for 3 minutes. With Stormsurge merits, also grants DEX +3 to +7.",
        SCH                     = 46,
        main_job_only           = true,
    },

    ["Thunderstorm II"] = {
        description             = "Sets double thundery weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Thunder",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double thundery weather for 3 minutes. With Stormsurge merits, also grants DEX +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Voidstorm"] = {
        description             = "Sets gloomy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Dark",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to gloomy for 3 minutes. With Stormsurge merits, also grants all attributes +1 to +3.",
        SCH                     = 47,
        main_job_only           = true,
    },

    ["Voidstorm II"] = {
        description             = "Sets double gloomy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Dark",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double gloomy weather for 3 minutes. With Stormsurge merits, also grants all attributes +1 to +3.",
        SCH                     = 100,
        main_job_only           = true,
    },

    ["Windstorm"] = {
        description             = "Sets windy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "I",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to windy for 3 minutes. With Stormsurge merits, also grants AGI +3 to +7.",
        SCH                     = 43,
        main_job_only           = true,
    },

    ["Windstorm II"] = {
        description             = "Sets double windy weather on a party member.",
        skill                   = "Enhancing Magic",
        spell_family            = "Storm",
        target_type             = "single",
        tier                    = "II",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Changes the weather around the target party member to double windy weather for 3 minutes. With Stormsurge merits, also grants AGI +3 to +7.",
        SCH                     = 100,
        main_job_only           = true,
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return STORM
