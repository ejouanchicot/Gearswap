---============================================================================
--- ENHANCING MAGIC DATABASE - Buff Spells Module
---============================================================================
--- Defensive and regeneration buffs (32 total)
---
--- @file enhancing_buffs.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local ENHANCING_BUFFS = {}

ENHANCING_BUFFS.spells = {

    --============================================================
    -- UTILITY BUFFS
    --============================================================
    ["Aquaveil"] = {
        description = "Prevents spell interruption.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        WHM = 10, RDM = 12, SCH = 13, RUN = 15,
        notes = "Reduces spell interruption. Absorbs ~10 hits. Duration: Enhancing Magic skill. WHM/RDM/SCH/RUN.",
    },

    ["Auspice"] = {
        description = "Boosts accuracy & holy dmg.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 55,
        notes = "Accuracy +10, Subtle Blow +10%. Adds light damage to attacks. Duration: Enhancing Magic skill. WHM-only.",
    },

    --============================================================
    -- PROTECT FAMILY (Single)
    --============================================================
    ["Protect"] = {
        description = "Boosts defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 7, RDM = 7, PLD = 10, SCH = 10, RUN = 20,
        notes = "Defense +20-40. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Protect II"] = {
        description = "Boosts defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "II",
        WHM = 27, RDM = 27, PLD = 30, SCH = 30, RUN = 40,
        notes = "Defense +40-60. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Protect III"] = {
        description = "Boosts defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "III",
        WHM = 47, RDM = 47, PLD = 50, SCH = 50, RUN = 60,
        notes = "Defense +60-80. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Protect IV"] = {
        description = "Boosts defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "IV",
        WHM = 63, RDM = 63, PLD = 70, SCH = 70, RUN = 80,
        notes = "Defense +80-100. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Protect V"] = {
        description = "Boosts defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "V",
        WHM = 76, RDM = 77, PLD = 90, SCH = 80,
        notes = "Defense +100-130. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH.",
    },

    --============================================================
    -- PROTECTRA FAMILY (AoE)
    --============================================================
    ["Protectra"] = {
        description = "Boosts defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 7,
        notes = "Defense +20-40. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Protectra II"] = {
        description = "Boosts defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "II",
        WHM = 27,
        notes = "Defense +40-60. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Protectra III"] = {
        description = "Boosts defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "III",
        WHM = 47,
        notes = "Defense +60-80. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Protectra IV"] = {
        description = "Boosts defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "IV",
        WHM = 63,
        notes = "Defense +80-100. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Protectra V"] = {
        description = "Boosts defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "V",
        WHM = 75,
        notes = "Defense +100-130. Duration: Enhancing Magic skill. WHM-only.",
    },

    --============================================================
    -- REFRESH FAMILY (MP Regen)
    --============================================================
    ["Refresh"] = {
        description = "Restores MP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        RDM = 41, RUN = 62,
        notes = "MP +3/tick (every 3s). Duration: Enhancing Magic skill. RDM/RUN.",
    },

    ["Refresh II"] = {
        description = "Restores MP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "II",
        RDM = 82,
        notes = "MP +4/tick (every 3s). Composure: MP +5/tick. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Refresh III"] = {
        description = "Restores MP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "III",
        RDM = 99,
        notes = "MP +5/tick (every 3s). Composure: MP +6/tick. Job Point ability (RDM).",
    },

    --============================================================
    -- REGEN FAMILY (HP Regen)
    --============================================================
    ["Regen"] = {
        description = "Restores HP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        SCH = 18, WHM = 21, RDM = 21, RUN = 23,
        notes = "HP +5/tick (every 3s). Potency: MND + Enhancing Magic skill. SCH/WHM/RDM/RUN.",
    },

    ["Regen II"] = {
        description = "Restores HP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "II",
        SCH = 37, WHM = 44, RUN = 48, RDM = 76,
        notes = "HP +12/tick (every 3s). Potency: MND + Enhancing Magic skill. SCH/WHM/RDM/RUN.",
    },

    ["Regen III"] = {
        description = "Restores HP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "III",
        SCH = 59, WHM = 66, RUN = 70,
        notes = "HP +20/tick (every 3s). Potency: MND + Enhancing Magic skill. SCH/WHM/RUN.",
    },

    ["Regen IV"] = {
        description = "Restores HP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "IV",
        SCH = 79, WHM = 86, RUN = 99,
        notes = "HP +30/tick (every 3s). Potency: MND + Enhancing Magic skill. SCH/WHM/RUN.",
    },

    ["Regen V"] = {
        description = "Restores HP over time.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "V",
        SCH = 99,
        notes = "HP +40/tick (every 3s). Potency: MND + Enhancing Magic skill. Job Point ability (SCH).",
    },

    --============================================================
    -- SHELL FAMILY (Single)
    --============================================================
    ["Shell"] = {
        description = "Boosts magic defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 17, RDM = 17, PLD = 20, SCH = 20, RUN = 10,
        notes = "Magic Evasion +20-40. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Shell II"] = {
        description = "Boosts magic defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "II",
        WHM = 37, RDM = 37, PLD = 40, SCH = 40, RUN = 30,
        notes = "Magic Evasion +40-60. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Shell III"] = {
        description = "Boosts magic defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "III",
        WHM = 57, RDM = 57, PLD = 60, SCH = 60, RUN = 50,
        notes = "Magic Evasion +60-80. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Shell IV"] = {
        description = "Boosts magic defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "IV",
        WHM = 68, RDM = 68, PLD = 80, SCH = 71, RUN = 70,
        notes = "Magic Evasion +80-100. Duration: Enhancing Magic skill. WHM/RDM/PLD/SCH/RUN.",
    },

    ["Shell V"] = {
        description = "Boosts magic defense.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        tier = "V",
        WHM = 76, RDM = 87, SCH = 90, RUN = 90,
        notes = "Magic Evasion +100-130. Duration: Enhancing Magic skill. WHM/RDM/SCH/RUN.",
    },

    --============================================================
    -- SHELLRA FAMILY (AoE)
    --============================================================
    ["Shellra"] = {
        description = "Boosts magic defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 17,
        notes = "Magic Evasion +20-40. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Shellra II"] = {
        description = "Boosts magic defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "II",
        WHM = 37,
        notes = "Magic Evasion +40-60. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Shellra III"] = {
        description = "Boosts magic defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "III",
        WHM = 57,
        notes = "Magic Evasion +60-80. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Shellra IV"] = {
        description = "Boosts magic defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "IV",
        WHM = 68,
        notes = "Magic Evasion +80-100. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Shellra V"] = {
        description = "Boosts magic defense (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        tier = "V",
        WHM = 75,
        notes = "Magic Evasion +100-130. Duration: Enhancing Magic skill. WHM-only.",
    },
}

return ENHANCING_BUFFS
