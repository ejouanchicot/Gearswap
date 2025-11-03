---============================================================================
--- ENHANCING MAGIC DATABASE - Bar-Spells Module
---============================================================================
--- Bar-element and Bar-status spells (28 total)
---
--- @file enhancing_bars.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local ENHANCING_BARS = {}

ENHANCING_BARS.spells = {

    --============================================================
    -- BAR-ELEMENT SPELLS (AoE)
    --============================================================
    ["Baraera"] = {
        description = "Boosts wind resist (AOE).",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "aoe",
        WHM = 13,
        notes = "Wind resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barblizzara"] = {
        description = "Boosts ice resist (AOE).",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "aoe",
        WHM = 21,
        notes = "Ice resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barfira"] = {
        description = "Boosts fire resist (AOE).",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "aoe",
        WHM = 17,
        notes = "Fire resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barstonra"] = {
        description = "Boosts earth resist (AOE).",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "aoe",
        WHM = 5,
        notes = "Earth resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barthundra"] = {
        description = "Boosts lightning resist (AOE).",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "aoe",
        WHM = 25,
        notes = "Lightning resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barwatera"] = {
        description = "Boosts water resist (AOE).",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "aoe",
        WHM = 9,
        notes = "Water resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    --============================================================
    -- BAR-ELEMENT SPELLS (Single)
    --============================================================
    ["Baraero"] = {
        description = "Boosts wind resist.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "self",
        RUN = 12,
        RDM = 13,
        notes = "Wind resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barblizzard"] = {
        description = "Boosts ice resist.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "self",
        RUN = 20,
        RDM = 21,
        notes = "Ice resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barfire"] = {
        description = "Boosts fire resist.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        RUN = 16,
        RDM = 17,
        notes = "Fire resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barstone"] = {
        description = "Boosts earth resist.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        RUN = 4,
        RDM = 5,
        notes = "Earth resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barthunder"] = {
        description = "Boosts lightning resist.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "self",
        RUN = 24,
        RDM = 25,
        notes = "Lightning resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barwater"] = {
        description = "Boosts water resist.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "self",
        RUN = 8,
        RDM = 9,
        notes = "Water resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    --============================================================
    -- BAR-STATUS SPELLS (AoE)
    --============================================================
    ["Baramnesra"] = {
        description = "Boosts amnesia resist (AOE).",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "aoe",
        WHM = 78,
        notes = "Amnesia resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barblindra"] = {
        description = "Boosts blind resist (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 18,
        notes = "Blind resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barparalyzra"] = {
        description = "Boosts paralysis resist (AOE).",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "aoe",
        WHM = 12,
        notes = "Paralysis resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barpetra"] = {
        description = "Boosts petrify resist (AOE).",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "aoe",
        WHM = 43,
        notes = "Petrify resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barpoisonra"] = {
        description = "Boosts poison resist (AOE).",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "aoe",
        WHM = 10,
        notes = "Poison resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barsilencera"] = {
        description = "Boosts silence resist (AOE).",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "aoe",
        WHM = 23,
        notes = "Silence resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barsleepra"] = {
        description = "Boosts sleep resist (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 7,
        notes = "Sleep resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Barvira"] = {
        description = "Boosts virus resist (AOE).",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "aoe",
        WHM = 39,
        notes = "Virus resistance +40-120. Duration: Enhancing Magic skill. WHM-only.",
    },

    --============================================================
    -- BAR-STATUS SPELLS (Single)
    --============================================================
    ["Baramnesia"] = {
        description = "Boosts amnesia resist.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        RUN = 76,
        RDM = 78,
        notes = "Amnesia resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barblind"] = {
        description = "Boosts blind resist.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        RUN = 17,
        RDM = 18,
        notes = "Blind resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barparalyze"] = {
        description = "Boosts paralysis resist.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "self",
        RUN = 11,
        RDM = 12,
        notes = "Paralysis resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barpetrify"] = {
        description = "Boosts petrify resist.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        RUN = 42,
        RDM = 43,
        notes = "Petrify resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barpoison"] = {
        description = "Boosts poison resist.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "self",
        RUN = 9,
        RDM = 10,
        notes = "Poison resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barsilence"] = {
        description = "Boosts silence resist.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "self",
        RUN = 22,
        RDM = 23,
        notes = "Silence resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barsleep"] = {
        description = "Boosts sleep resist.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        RUN = 6,
        RDM = 7,
        notes = "Sleep resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },

    ["Barvirus"] = {
        description = "Boosts virus resist.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        RUN = 38,
        RDM = 39,
        notes = "Virus resistance +40-120. Duration: Enhancing Magic skill. RUN/RDM.",
    },
}

return ENHANCING_BARS
