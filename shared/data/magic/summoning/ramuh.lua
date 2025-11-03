---============================================================================
--- SUMMONING DATABASE - Ramuh (Thunder Avatar)
---============================================================================
--- Ramuh summon spell and Blood Pact abilities
---
--- @file ramuh.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local RAMUH = {}

RAMUH.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Ramuh"] = {
        description = "Summons Ramuh.",
        category = "Avatar Summon",
        element = "Thunder",
        magic_type = "Summoning",
        type = "summon",
        SMN = 1,
        mp_cost = 7,
        notes = "Thunder-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in thunder magic damage (Thunder series, Judgment Bolt) and paralysis effects. Strong against water, weak to earth. SMN (subjob OK).",
    },

}

RAMUH.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Shock Strike"] = {
        description = "Deals physical dmg + stun.",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "physical",
        damage_type = "Blunt",
        level = 1,
        mp_cost = 9,
        skillchain = "Impaction",
        notes = "Physical blunt damage with stun effect. MP: 9. Recast: Instant. Damage: Pet STR. Inflicts Stun. Single target. SMN (subjob OK).",
    },

    ["Thunder II"] = {
        description = "Deals thunder damage.",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "magical",
        level = 10,
        mp_cost = 24,
        notes = "Thunder-based magical damage. MP: 24. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Thunderspark"] = {
        description = "Deals thunder physical dmg + paralyze (AoE).",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "physical",
        damage_type = "Blunt",
        level = 19,
        mp_cost = 42,
        skillchain = "Impaction",
        notes = "Thunder-enhanced physical damage with paralyze effect. MP: 42. Recast: Instant. Damage: Pet STR + INT. Inflicts Paralysis. AoE range. SMN (subjob OK).",
    },

    ["Thunder IV"] = {
        description = "Deals thunder damage.",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "magical",
        level = 60,
        mp_cost = 118,
        notes = "Enhanced thunder-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Magic burst compatible. Single target. SMN (subjob OK).",
    },

    ["Chaotic Strike"] = {
        description = "Deals thunder physical dmg + stun.",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "physical",
        damage_type = "Blunt",
        level = 70,
        mp_cost = 118,
        skillchain = "Impaction",
        notes = "Enhanced thunder-based physical blunt damage with stun. MP: 118. Recast: Instant. Damage: Pet STR + INT. Inflicts Stun. Single target. SMN (subjob OK).",
    },

    ["Thunderstorm"] = {
        description = "Deals thunder damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "magical",
        level = 75,
        mp_cost = 182,
        merit = true,
        notes = "Thunder-based magical AoE damage. MP: 182. Recast: Instant. Damage: Pet INT. Merit-based ability. AoE range. SMN (subjob OK).",
    },

    ["Volt Strike"] = {
        description = "Deals thunder physical dmg + stun (multi-hit).",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "physical",
        damage_type = "Blunt",
        level = 99,
        mp_cost = 200,
        notes = "Multi-hit thunder-based physical damage. MP: 200. Recast: Instant. Damage: Pet STR (×5 hits). Inflicts Stun. SMN (subjob OK).",
    },

    ["Judgment Bolt"] = {
        description = "Deals thunder damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Thunder",
        avatar = "Ramuh",
        type = "magical",
        level = 1,
        mp_cost = 0,
        astral_flow = true,
        notes = "Ultimate thunder-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Rolling Thunder"] = {
        description = "Grants enthunder (AoE).",
        category = "Blood Pact: Ward",
        element = "Thunder",
        avatar = "Ramuh",
        type = "buff",
        level = 31,
        mp_cost = 69,
        notes = "Enthunder effect (adds thunder damage to attacks). MP: 69. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Lightning Armor"] = {
        description = "Grants shock spikes (AoE).",
        category = "Blood Pact: Ward",
        element = "Thunder",
        avatar = "Ramuh",
        type = "buff",
        level = 42,
        mp_cost = 94,
        notes = "Shock Spikes effect (thunder damage + paralyze to attackers). MP: 94. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Shock Squall"] = {
        description = "Inflicts stun (AoE).",
        category = "Blood Pact: Ward",
        element = "Thunder",
        avatar = "Ramuh",
        type = "debuff",
        level = 92,
        mp_cost = 118,
        notes = "Stun status to enemies. MP: 118. Recast: Instant. Duration: Instant stun effect. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RAMUH
