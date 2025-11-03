---============================================================================
--- ENFEEBLING MAGIC DATABASE - Crowd Control & Utility Module
---============================================================================
--- Crowd control and utility enfeebling spells (9 total)
---
--- Contents:
---   - Sleep family (4): Sleep I/II, Sleepga I/II (Put target to sleep)
---   - Break family (2): Break, Breakga (Petrify)
---   - Utility (3): Bind (Immobilize), Silence (Prevent spellcasting), Dispel (Remove buffs)
---
--- @file enfeebling_control.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local ENFEEBLING_CONTROL = {}

ENFEEBLING_CONTROL.spells = {

    ---========================================================================
    --- SLEEP FAMILY - Dark Element (Put Target to Sleep)
    ---========================================================================
    --- Enfeebling Type: DURATION

    ["Sleep"] = {
        description = "Inflicts sleep.",
        element = "Dark",
        tier = "I",
        category = "Enfeebling",
        magic_type = "Black",
        type = "single",
        enfeebling_type = "duration",
        BLM = 20,
        DRK = 30,
        GEO = 35,
        RDM = 25,
        SCH = 30,
        notes = "Prevents target actions. Duration: Enfeebling Magic skill. BLM/DRK/GEO/RDM/SCH.",
    },

    ["Sleep II"] = {
        description = "Inflicts sleep.",
        element = "Dark",
        tier = "II",
        category = "Enfeebling",
        magic_type = "Black",
        type = "single",
        enfeebling_type = "duration",
        BLM = 41,
        DRK = 56,
        GEO = 70,
        RDM = 46,
        SCH = 65,
        notes = "Enhanced sleep. Prevents target actions. Duration: Enfeebling Magic skill. BLM/DRK/GEO/RDM/SCH.",
    },

    ["Sleepga"] = {
        description = "Inflicts sleep (AOE).",
        element = "Dark",
        tier = "I",
        category = "Enfeebling",
        magic_type = "Black",
        type = "aoe",
        enfeebling_type = "duration",
        BLM = 31,
        notes = "AOE sleep. Prevents targets actions. Duration: Enfeebling Magic skill. BLM-only.",
    },

    ["Sleepga II"] = {
        description = "Inflicts sleep (AOE).",
        element = "Dark",
        tier = "II",
        category = "Enfeebling",
        magic_type = "Black",
        type = "aoe",
        enfeebling_type = "duration",
        BLM = 56,
        notes = "Enhanced AOE sleep. Prevents targets actions. Duration: Enfeebling Magic skill. BLM-only.",
    },

    ---========================================================================
    --- BREAK FAMILY - Earth Element (Petrify)
    ---========================================================================
    --- Enfeebling Type: DURATION

    ["Break"] = {
        description = "Inflicts petrify.",
        element = "Earth",
        category = "Enfeebling",
        magic_type = "Black",
        type = "single",
        enfeebling_type = "duration",
        BLM = 85,
        DRK = 95,
        RDM = 87,
        SCH = 90,
        notes = "Petrification. Prevents target actions. Duration: Enfeebling Magic skill. BLM/DRK/RDM/SCH.",
    },

    ["Breakga"] = {
        description = "Inflicts petrify (AOE).",
        element = "Earth",
        category = "Enfeebling",
        magic_type = "Black",
        type = "aoe",
        enfeebling_type = "duration",
        BLM = 95,
        notes = "AOE petrification. Prevents targets actions. Duration: Enfeebling Magic skill. BLM-only.",
    },

    ---========================================================================
    --- UTILITY ENFEEBLING
    ---========================================================================
    --- Enfeebling Type: DURATION (Bind, Silence) / MACC (Dispel)

    ["Bind"] = {
        description = "Immobilizes target.",
        element = "Ice",
        category = "Enfeebling",
        magic_type = "Black",
        type = "single",
        enfeebling_type = "duration",
        BLM = 7,
        DRK = 20,
        RDM = 11,
        notes = "Prevents movement. Duration: Enfeebling Magic skill. BLM/DRK/RDM.",
    },

    ["Silence"] = {
        description = "Prevents spellcasting.",
        element = "Wind",
        category = "Enfeebling",
        magic_type = "White",
        type = "single",
        enfeebling_type = "duration",
        RDM = 18,
        WHM = 15,
        notes = "Prevents magic casting. Duration: Enfeebling Magic skill. RDM/WHM.",
    },

    ["Dispel"] = {
        description = "Removes 1 buff.",
        element = "Dark",
        category = "Enfeebling",
        magic_type = "Black",
        type = "single",
        enfeebling_type = "macc",
        RDM = 32,
        SCH = 32,
        notes = "Removes one beneficial status effect. Success rate: Magic Accuracy. RDM/SCH.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENFEEBLING_CONTROL
