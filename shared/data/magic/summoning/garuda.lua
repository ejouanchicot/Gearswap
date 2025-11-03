---============================================================================
--- SUMMONING DATABASE - Garuda (Wind Avatar)
---============================================================================
--- Garuda summon spell and Blood Pact abilities
---
--- @file garuda.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local GARUDA = {}

GARUDA.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Garuda"] = {
        description = "Summons Garuda.",
        category = "Avatar Summon",
        element = "Wind",
        magic_type = "Summoning",
        type = "summon",
        SMN = 1,
        mp_cost = 7,
        notes = "Wind-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in wind magic damage (Aero series, Aerial Blast) and evasion buffs (Aerial Armor). Strong against ice, weak to earth. SMN (subjob OK).",
    },

}

GARUDA.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Claw"] = {
        description = "Deals physical dmg.",
        category = "Blood Pact: Rage",
        element = "Wind",
        avatar = "Garuda",
        type = "physical",
        damage_type = "Slashing",
        level = 1,
        mp_cost = 9,
        skillchain = "Transfixion",
        notes = "Physical slashing damage. MP: 9. Recast: Instant. Damage: Pet STR. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Aero II"] = {
        description = "Deals wind damage.",
        category = "Blood Pact: Rage",
        element = "Wind",
        avatar = "Garuda",
        type = "magical",
        level = 10,
        mp_cost = 24,
        notes = "Wind-based magical damage. MP: 24. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Aero IV"] = {
        description = "Deals wind damage.",
        category = "Blood Pact: Rage",
        element = "Wind",
        avatar = "Garuda",
        type = "magical",
        level = 60,
        mp_cost = 118,
        notes = "Enhanced wind-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Magic burst compatible. Single target. SMN (subjob OK).",
    },

    ["Predator Claws"] = {
        description = "Deals wind physical dmg.",
        category = "Blood Pact: Rage",
        element = "Wind",
        avatar = "Garuda",
        type = "physical",
        damage_type = "Slashing",
        level = 70,
        mp_cost = 118,
        skillchain = "Transfixion",
        notes = "Enhanced wind-based physical slashing damage. MP: 118. Recast: Instant. Damage: Pet STR + INT. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Wind Blade"] = {
        description = "Deals wind physical dmg.",
        category = "Blood Pact: Rage",
        element = "Wind",
        avatar = "Garuda",
        type = "physical",
        level = 75,
        mp_cost = 182,
        merit = true,
        notes = "Wind-based physical damage. MP: 182. Recast: Instant. Damage: Pet STR + INT. Merit-based ability. Single target. SMN (subjob OK).",
    },

    ["Aerial Blast"] = {
        description = "Deals wind damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Wind",
        avatar = "Garuda",
        type = "magical",
        level = 1,
        mp_cost = 0,
        astral_flow = true,
        notes = "Ultimate wind-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Aerial Armor"] = {
        description = "Boosts evasion.",
        category = "Blood Pact: Ward",
        element = "Wind",
        avatar = "Garuda",
        type = "buff",
        level = 25,
        mp_cost = 56,
        notes = "Evasion +30%. MP: 56. Recast: Instant. Duration: 90s. Target: Single party member. SMN (subjob OK).",
    },

    ["Whispering Wind"] = {
        description = "Restores HP (AoE).",
        category = "Blood Pact: Ward",
        element = "Wind",
        avatar = "Garuda",
        type = "healing",
        level = 36,
        mp_cost = 80,
        notes = "Party HP recovery. MP: 80. Recast: Instant. Healing: Pet MND + Avatar level. Target: Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Hastega"] = {
        description = "Boosts attack speed (AoE).",
        category = "Blood Pact: Ward",
        element = "Wind",
        avatar = "Garuda",
        type = "buff",
        level = 48,
        mp_cost = 108,
        notes = "Haste +15%. MP: 108. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Fleet Wind"] = {
        description = "Deals wind damage (AoE).",
        category = "Blood Pact: Ward",
        element = "Wind",
        avatar = "Garuda",
        type = "magical",
        level = 86,
        mp_cost = 210,
        notes = "Multi-hit wind-based magical AoE damage. MP: 210. Recast: Instant. Damage: Pet MAB + level (×3 hits). Range: Area effect. SMN (subjob OK).",
    },

    ["Hastega II"] = {
        description = "Boosts attack speed (AoE).",
        category = "Blood Pact: Ward",
        element = "Wind",
        avatar = "Garuda",
        type = "buff",
        level = 99,
        mp_cost = 118,
        notes = "Enhanced Haste +30%. MP: 118. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return GARUDA
