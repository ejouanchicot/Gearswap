---============================================================================
--- SUMMONING DATABASE - Titan (Earth Avatar)
---============================================================================
--- Titan summon spell and Blood Pact abilities
---
--- @file titan.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local TITAN = {}

TITAN.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Titan"] = {
        description             = "Summons Titan.",
        category                = "Avatar Summon",
        element                 = "Earth",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Earth-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in physical damage (Rock Throw, Earthen Fury) and defense buffs (Earthen Armor, Earthen Ward). Strong against thunder, weak to wind. SMN (subjob OK).",
    },

}

TITAN.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Rock Throw"] = {
        description             = "Deals physical dmg + slow.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Scission",
        notes                   = "Physical blunt ranged damage with slow effect. MP: 9. Recast: Instant. Damage: Pet STR. Inflicts Slow. Single target. SMN (subjob OK).",
    },

    ["Stone II"] = {
        description             = "Deals earth damage.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Earth-based magical damage. MP: 24. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Rock Buster"] = {
        description             = "Deals earth physical dmg + bind.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 21,
        mp_cost                 = 48,
        skillchain              = "Impaction",
        notes                   = "Earth-enhanced physical blunt damage with bind effect. MP: 48. Recast: Instant. Damage: Pet STR + INT. Inflicts Bind. Single target. SMN (subjob OK).",
    },

    ["Megalith Throw"] = {
        description             = "Deals physical dmg + slow.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 35,
        mp_cost                 = 78,
        skillchain              = "Scission",
        notes                   = "Enhanced physical blunt ranged damage with slow effect. MP: 78. Recast: Instant. Damage: Pet STR. Inflicts Slow. Single target. SMN (subjob OK).",
    },

    ["Stone IV"] = {
        description             = "Deals earth damage.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Enhanced earth-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Magic burst compatible. Single target. SMN (subjob OK).",
    },

    ["Mountain Buster"] = {
        description             = "Deals earth physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 70,
        mp_cost                 = 118,
        skillchain              = "Induration",
        notes                   = "Enhanced earth-based physical blunt damage. MP: 118. Recast: Instant. Damage: Pet STR + INT. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Geocrush"] = {
        description             = "Deals earth physical dmg (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Earth-based physical AoE damage. MP: 182. Recast: Instant. Damage: Pet STR + INT. Merit-based ability. AoE range. SMN (subjob OK).",
    },

    ["Crag Throw"] = {
        description             = "Deals earth physical dmg + slow.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 99,
        mp_cost                 = 200,
        notes                   = "Multi-hit earth-based physical damage. MP: 200. Recast: Instant. Damage: Pet STR (×5 hits). Inflicts Slow 30% for 2 minutes. SMN (subjob OK).",
    },

    ["Earthen Fury"] = {
        description             = "Deals earth damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate earth-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Earthen Ward"] = {
        description             = "Grants stoneskin (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "buff",
        level                   = 46,
        mp_cost                 = 103,
        notes                   = "Stoneskin effect (absorbs damage). MP: 103. Recast: Instant. Duration: Until absorbed. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Earthen Armor"] = {
        description             = "Boosts defense (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "buff",
        level                   = 88,
        mp_cost                 = 118,
        notes                   = "Defense boost for party. MP: 118. Recast: Instant. Duration: 90s. Effect: Defense +30%. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return TITAN
