---============================================================================
--- SUMMONING DATABASE - Shiva (Ice Avatar)
---============================================================================
--- Shiva summon spell and Blood Pact abilities
---
--- @file shiva.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local SHIVA = {}

SHIVA.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Shiva"] = {
        description = "Summons Shiva.",
        category = "Avatar Summon",
        element = "Ice",
        magic_type = "Summoning",
        type = "summon",
        SMN = 1,
        mp_cost = 7,
        notes = "Ice-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in ice magic damage (Blizzard series, Diamond Dust) and evasion buffs (Frost Armor). Strong against wind, weak to fire. SMN (subjob OK).",
    },

}

SHIVA.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Axe Kick"] = {
        description = "Deals physical dmg.",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "physical",
        damage_type = "Blunt",
        level = 1,
        mp_cost = 9,
        skillchain = "Liquefaction",
        notes = "Physical blunt damage. MP: 9. Recast: Instant. Damage: Pet STR. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Blizzard II"] = {
        description = "Deals ice damage.",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "magical",
        level = 10,
        mp_cost = 24,
        notes = "Ice-based magical damage. MP: 24. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Double Slap"] = {
        description = "Deals 2-fold physical dmg.",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "physical",
        damage_type = "Blunt",
        level = 50,
        mp_cost = 36,
        skillchain = "Impaction",
        notes = "Double-hit physical blunt damage. MP: 36. Recast: Instant. Damage: Pet STR (×2 hits). Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Blizzard IV"] = {
        description = "Deals ice damage.",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "magical",
        level = 60,
        mp_cost = 118,
        notes = "Enhanced ice-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Magic burst compatible. Single target. SMN (subjob OK).",
    },

    ["Rush"] = {
        description = "Deals 4-fold physical dmg.",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "physical",
        damage_type = "Blunt",
        level = 70,
        mp_cost = 118,
        skillchain = "Liquefaction",
        notes = "Quad-hit physical blunt damage. MP: 118. Recast: Instant. Damage: Pet STR (×4 hits). Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Heavenly Strike"] = {
        description = "Deals ice physical dmg (AoE).",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "physical",
        level = 75,
        mp_cost = 182,
        merit = true,
        notes = "Ice-based physical AoE damage. MP: 182. Recast: Instant. Damage: Pet STR + INT. Merit-based ability. AoE range. SMN (subjob OK).",
    },

    ["Diamond Dust"] = {
        description = "Deals ice damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Ice",
        avatar = "Shiva",
        type = "magical",
        level = 1,
        mp_cost = 0,
        astral_flow = true,
        notes = "Ultimate ice-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Frost Armor"] = {
        description = "Grants ice spikes.",
        category = "Blood Pact: Ward",
        element = "Ice",
        avatar = "Shiva",
        type = "buff",
        level = 28,
        mp_cost = 63,
        notes = "Ice Spikes effect (ice damage to attackers). MP: 63. Recast: Instant. Duration: 180s. Target: Single party member. SMN (subjob OK).",
    },

    ["Sleepga"] = {
        description = "Inflicts sleep (AoE).",
        category = "Blood Pact: Ward",
        element = "Ice",
        avatar = "Shiva",
        type = "debuff",
        level = 39,
        mp_cost = 84,
        notes = "Sleep status AoE (no damage). MP: 84. Recast: Instant. Duration: 90s. Range: 10 yalms. Enemies only. SMN (subjob OK).",
    },

    ["Diamond Storm"] = {
        description = "Deals ice damage (AoE).",
        category = "Blood Pact: Ward",
        element = "Ice",
        avatar = "Shiva",
        type = "magical",
        level = 90,
        mp_cost = 182,
        notes = "Ice-based magical AoE damage. MP: 182. Recast: Instant. Damage: Pet MAB + level. Range: 15 yalms. Ultimate Ward ability. SMN (subjob OK).",
    },

    ["Crystal Blessing"] = {
        description = "Boosts max HP (AoE).",
        category = "Blood Pact: Ward",
        element = "Ice",
        avatar = "Shiva",
        type = "buff",
        level = 99,
        mp_cost = 118,
        notes = "Max HP +10%. MP: 118. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SHIVA
