---============================================================================
--- SUMMONING DATABASE - Ifrit (Fire Avatar)
---============================================================================
--- Ifrit summon spell and Blood Pact abilities
---
--- @file ifrit.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local IFRIT = {}

IFRIT.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Ifrit"] = {
        description = "Summons Ifrit.",
        category = "Avatar Summon",
        element = "Fire",
        magic_type = "Summoning",
        type = "summon",
        SMN = 1,
        mp_cost = 7,
        notes = "Fire-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in physical melee attacks and attack buffs (Crimson Howl). Strong against ice, weak to water. SMN (subjob OK).",
    },

}

IFRIT.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Punch"] = {
        description = "Deals physical dmg.",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "physical",
        damage_type = "Blunt",
        level = 1,
        mp_cost = 9,
        skillchain = "Liquefaction",
        notes = "Physical blunt damage. MP: 9. Recast: Instant. Damage: Pet STR. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Fire II"] = {
        description = "Deals fire damage.",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "magical",
        level = 10,
        mp_cost = 24,
        notes = "Fire-based magical damage. MP: 24. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Burning Strike"] = {
        description = "Deals fire physical dmg.",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "physical",
        damage_type = "Blunt",
        level = 23,
        mp_cost = 48,
        skillchain = "Impaction",
        notes = "Fire-enhanced physical blunt damage. MP: 48. Recast: Instant. Damage: Pet STR + INT. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Double Punch"] = {
        description = "Deals 2-fold physical dmg.",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "physical",
        damage_type = "Blunt",
        level = 30,
        mp_cost = 36,
        skillchain = "Impaction",
        notes = "Double-hit physical blunt damage. MP: 36. Recast: Instant. Damage: Pet STR (×2 hits). Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Fire IV"] = {
        description = "Deals fire damage.",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "magical",
        level = 60,
        mp_cost = 118,
        notes = "Enhanced fire-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Magic burst compatible. Single target. SMN (subjob OK).",
    },

    ["Flaming Crush"] = {
        description = "Deals fire physical dmg.",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "physical",
        damage_type = "Blunt",
        level = 70,
        mp_cost = 118,
        skillchain = "Liquefaction",
        notes = "Enhanced fire-based physical blunt damage. MP: 118. Recast: Instant. Damage: Pet STR + INT. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Meteor Strike"] = {
        description = "Deals fire physical dmg (AoE).",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "physical",
        level = 75,
        mp_cost = 182,
        merit = true,
        notes = "Fire-based physical AoE damage. MP: 182. Recast: Instant. Damage: Pet INT. TP Bonus: +400 per merit level. Merit-based ability. AoE range. SMN (subjob OK).",
    },

    ["Conflag Strike"] = {
        description = "Deals fire physical dmg (multi-hit).",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "physical",
        level = 99,
        mp_cost = 200,
        notes = "Multi-hit fire-based physical damage with burn effect. MP: 200. Recast: Instant. Damage: Pet STR (×5 hits). Inflicts Burn status. Breath damage. SMN (subjob OK).",
    },

    ["Inferno"] = {
        description = "Deals fire damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Fire",
        avatar = "Ifrit",
        type = "magical",
        level = 1,
        mp_cost = 0,
        astral_flow = true,
        notes = "Ultimate fire-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Crimson Howl"] = {
        description = "Boosts attack (AoE).",
        category = "Blood Pact: Ward",
        element = "Fire",
        avatar = "Ifrit",
        type = "buff",
        level = 38,
        mp_cost = 84,
        notes = "Attack boost for party. MP: 84. Recast: Instant. Duration: 60s. Effect: Attack +11.2% (at level 99). Overwrites Warcry/Blood Rage. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Inferno Howl"] = {
        description = "Boosts attack + accuracy (AoE).",
        category = "Blood Pact: Ward",
        element = "Fire",
        avatar = "Ifrit",
        type = "buff",
        level = 88,
        mp_cost = 118,
        notes = "Enhanced attack + accuracy boost for party. MP: 118. Recast: Instant. Duration: 90s. Effect: Attack +15%, Accuracy +20. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return IFRIT
