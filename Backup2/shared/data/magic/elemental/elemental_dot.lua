---============================================================================
--- Elemental Magic Database - DOT Spells Module
---============================================================================
--- Damage Over Time elemental spells (debuff + gradual HP reduction)
---
--- @file elemental_dot.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @verified bg-wiki.com (2025-10-30) - ALL 6 spells individually verified
---
--- NOTES:
--- - All DOT spells are BLM-only
--- - Six elements: Fire (Burn), Ice (Frost), Wind (Choke),
---   Earth (Rasp), Thunder (Shock), Water (Drown)
--- - Each spell lowers a specific enemy stat AND deals gradual HP damage
--- - Duration: 90 seconds (1.5 minutes)
--- - DOT damage scales with Intelligence
---============================================================================

local elemental_dot = {}

elemental_dot.spells = {
    ["Shock"] = {
        description             = "Lowers mind, drains HP.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 16,
        notes                   = "DOT spell. Lowers enemy Mind. Damage over time scales with Intelligence."
    },

    ["Rasp"] = {
        description             = "Lowers dexterity, drains HP.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 18,
        notes                   = "DOT spell. Lowers enemy Dexterity. Damage over time scales with Intelligence."
    },

    ["Choke"] = {
        description             = "Lowers vitality, drains HP.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 20,
        notes                   = "DOT spell. Lowers enemy Vitality. Damage over time scales with Intelligence."
    },

    ["Frost"] = {
        description             = "Lowers intelligence, drains HP.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 22,
        notes                   = "DOT spell. Lowers enemy Agility. Damage over time scales with Intelligence."
    },

    ["Burn"] = {
        description             = "Lowers intelligence, drains HP.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 24,
        notes                   = "DOT spell. Lowers enemy Intelligence. Damage over time scales with Intelligence."
    },

    ["Drown"] = {
        description             = "Lowers strength, drains HP.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 27,
        notes                   = "DOT spell. Lowers enemy Strength. Damage over time scales with Intelligence."
    },
}

return elemental_dot
