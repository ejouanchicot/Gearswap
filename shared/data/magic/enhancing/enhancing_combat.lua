---============================================================================
--- ENHANCING MAGIC DATABASE - Combat Enhancement Module
---============================================================================
--- Combat-focused enhancement spells (23 total)
---
--- Contents:
---   - Spike spells (3): Blaze, Ice, Shock (damage reflection)
---   - Enspells (12): Enfire/II, Enblizzard/II, etc. (elemental weapon damage)
---   - Haste family (2): Haste, Haste II (attack speed)
---   - Phalanx family (2): Phalanx, Phalanx II (damage resistance)
---   - Temper family (2): Temper, Temper II (double/triple attack)
---   - Flurry family (2): Flurry, Flurry II (ranged attack speed)
---
--- @file enhancing_combat.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local ENHANCING_COMBAT = {}

ENHANCING_COMBAT.spells = {

    --============================================================
    -- SPIKE SPELLS (Damage Reflection)
    --============================================================

    ["Blaze Spikes"] = {
        description = "Reflects fire dmg when hit.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "Black",
        type = "self",
        BLM = 10, RDM = 20, SCH = 30, RUN = 45,
        notes = "Physical attacks against you deal fire damage to attacker. Potency: INT. BLM/RDM/SCH/RUN.",
    },

    ["Ice Spikes"] = {
        description = "Reflects ice dmg when hit.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "Black",
        type = "self",
        BLM = 20, RDM = 40, SCH = 50, RUN = 65,
        notes = "Physical attacks against you deal ice damage to attacker. Potency: INT. BLM/RDM/SCH/RUN.",
    },

    ["Shock Spikes"] = {
        description = "Reflects lightning dmg when hit.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "Black",
        type = "self",
        BLM = 30, RDM = 60, SCH = 70, RUN = 85,
        notes = "Physical attacks against you deal lightning damage to attacker. Potency: INT. BLM/RDM/SCH/RUN.",
    },

    --============================================================
    -- ENSPELLS (Elemental Weapon Damage)
    --============================================================

    ["Enaero"] = {
        description = "Adds wind dmg to attacks.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        RDM = 20,
        notes = "Adds wind damage to each melee hit. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enaero II"] = {
        description = "Adds wind dmg to attacks.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 54,
        notes = "Enhanced wind damage to each melee hit. Lowers target's ice resistance. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enblizzard"] = {
        description = "Adds ice dmg to attacks.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "self",
        RDM = 22,
        notes = "Adds ice damage to each melee hit. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enblizzard II"] = {
        description = "Adds ice dmg to attacks.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 56,
        main_job_only = true,
        notes = "Enhanced ice damage to each melee hit. Lowers target's fire resistance. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enfire"] = {
        description = "Adds fire dmg to attacks.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "self",
        RDM = 24,
        main_job_only = true,
        notes = "Adds fire damage to each melee hit. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enfire II"] = {
        description = "Adds fire dmg to attacks.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 58,
        main_job_only = true,
        notes = "Enhanced fire damage to each melee hit. Lowers target's water resistance. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enstone"] = {
        description = "Adds earth dmg to attacks.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "self",
        RDM = 18,
        notes = "Adds earth damage to each melee hit. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enstone II"] = {
        description = "Adds earth dmg to attacks.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 52,
        notes = "Enhanced earth damage to each melee hit. Lowers target's wind resistance. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enthunder"] = {
        description = "Adds lightning dmg to attacks.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "self",
        RDM = 16,
        main_job_only = true,
        notes = "Adds lightning damage to each melee hit. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enthunder II"] = {
        description = "Adds lightning dmg to attacks.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 50,
        notes = "Enhanced lightning damage to each melee hit. Lowers target's earth resistance. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enwater"] = {
        description = "Adds water dmg to attacks.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        RDM = 27,
        main_job_only = true,
        notes = "Adds water damage to each melee hit. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Enwater II"] = {
        description = "Adds water dmg to attacks.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 60,
        main_job_only = true,
        notes = "Enhanced water damage to each melee hit. Lowers target's lightning resistance. Duration: Enhancing Magic skill. RDM-only.",
    },

    --============================================================
    -- FLURRY FAMILY (Ranged Attack Speed)
    --============================================================

    ["Flurry"] = {
        description = "Boosts ranged attack speed.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        RDM = 48,
        notes = "Reduces ranged attack delay (~15%). Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Flurry II"] = {
        description = "Boosts ranged attack speed.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        tier = "II",
        RDM = 96,
        main_job_only = true,
        notes = "Enhanced ranged attack delay reduction (~30%). Duration: Enhancing Magic skill. RDM-only.",
    },

    --============================================================
    -- HASTE FAMILY (Melee Attack Speed)
    --============================================================

    ["Haste"] = {
        description = "Boosts attack speed.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        WHM = 40, RDM = 48,
        notes = "Reduces melee attack delay (~15%). Duration: Enhancing Magic skill. WHM/RDM.",
    },

    ["Haste II"] = {
        description = "Boosts attack speed.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        tier = "II",
        RDM = 96,
        main_job_only = true,
        notes = "Enhanced melee attack delay reduction (~30%). Duration: Enhancing Magic skill. RDM-only.",
    },

    --============================================================
    -- PHALANX FAMILY (Damage Resistance)
    --============================================================

    ["Phalanx"] = {
        description = "Reduces damage taken.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        RDM = 33, RUN = 68, PLD = 77,
        notes = "Reduces damage taken from physical and magical attacks. Potency: Enhancing Magic skill. RDM/RUN/PLD.",
    },

    ["Phalanx II"] = {
        description = "Reduces damage taken.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 75,
        main_job_only = true,
        notes = "Enhanced damage reduction from all attacks. Potency: Enhancing Magic skill. RDM-only.",
    },

    --============================================================
    -- TEMPER FAMILY (Multi-Attack)
    --============================================================

    ["Temper"] = {
        description = "Boosts multi-attack rate.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        RDM = 95, RUN = 99,
        notes = "Grants Store TP +10. Increases Double/Triple Attack rate. Duration: Enhancing Magic skill. RDM/RUN.",
    },

    ["Temper II"] = {
        description = "Boosts multi-attack rate.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        tier = "II",
        RDM = 99,
        main_job_only = true,
        notes = "Enhanced Store TP +15. Greater Double/Triple Attack rate increase. Job Point ability (RDM).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENHANCING_COMBAT
