---============================================================================
--- HEALING MAGIC DATABASE - Status Removal Spells Module
---============================================================================
--- Status ailment removal spells (9 total)
---
--- @file healing_status.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local HEALING_STATUS = {}

HEALING_STATUS.spells = {

    --============================================================
    -- -NA SPELLS (Single-Target Status Removal)
    --============================================================

    ["Blindna"] = {
        description = "Removes blindness.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 14, SCH = 17,
        notes = "Removes blind status from target. Success rate: Healing Magic skill. WHM/SCH (SCH requires Addendum: White).",
    },

    ["Cursna"] = {
        description = "Removes curse or doom.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 29, SCH = 32,
        notes = "Removes curse, bane, or doom from target. Doom removal: Variable success rate based on Healing Magic skill + Cursna+ gear. WHM/SCH (SCH requires Addendum: White).",
    },

    ["Paralyna"] = {
        description = "Removes paralysis.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 9, SCH = 12,
        notes = "Removes paralysis status from target. Success rate: Healing Magic skill. WHM/SCH (SCH requires Addendum: White).",
    },

    ["Poisona"] = {
        description = "Removes poison.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 6, SCH = 10,
        notes = "Removes poison status from target. Success rate: Healing Magic skill. WHM/SCH (SCH requires Addendum: White).",
    },

    ["Silena"] = {
        description = "Removes silence.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 19, SCH = 22,
        notes = "Removes silence status from target. Cannot remove Mute status. Success rate: Healing Magic skill. WHM/SCH (SCH requires Addendum: White).",
    },

    ["Stona"] = {
        description = "Removes petrification.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 39, SCH = 50,
        notes = "Removes petrification status from target. Success rate: Healing Magic skill. WHM/SCH (SCH requires Addendum: White).",
    },

    ["Viruna"] = {
        description = "Removes disease.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 34, SCH = 46,
        notes = "Removes disease and plague status from target. Success rate: Healing Magic skill. WHM/SCH (SCH requires Addendum: White).",
    },

    --============================================================
    -- ESUNA (AoE Status Removal)
    --============================================================

    ["Esuna"] = {
        description = "Removes ailments (AOE).",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 61,
        main_job_only = true,
        notes = "Removes one enfeebling effect from party members within 10 yalm range. Must have the status yourself to remove it. Afflatus Misery: Removes up to 2 ailments + curse/eraseable effects. WHM-only.",
    },

    --============================================================
    -- SACRIFICE (Transfer Enfeebling Effect)
    --============================================================

    ["Sacrifice"] = {
        description = "Transfers ailment to self.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 65,
        main_job_only = true,
        notes = "Transfers one enfeebling effect from target party member to caster. Afflatus Solace: Increased effect removal potency. WHM-only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return HEALING_STATUS
