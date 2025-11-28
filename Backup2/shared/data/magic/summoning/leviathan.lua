---============================================================================
--- SUMMONING DATABASE - Leviathan (Water Avatar)
---============================================================================
--- Leviathan summon spell and Blood Pact abilities
---
--- @file leviathan.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local LEVIATHAN = {}

LEVIATHAN.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Leviathan"] = {
        description             = "Summons Leviathan.",
        category                = "Avatar Summon",
        element                 = "Water",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Water-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in water magic damage (Water series, Tidal Wave) and magic defense buffs (Spring Water). Strong against fire, weak to thunder. SMN (subjob OK).",
    },

}

LEVIATHAN.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Barracuda Dive"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Reverberation",
        notes                   = "Physical piercing damage. MP: 9. Recast: Instant. Damage: Pet STR. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Water II"] = {
        description             = "Deals water damage.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Water-based magical damage. MP: 24. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Tail Whip"] = {
        description             = "Deals water physical dmg (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 26,
        mp_cost                 = 58,
        skillchain              = "Reverberation",
        notes                   = "Water-enhanced physical blunt AoE damage. MP: 58. Recast: Instant. Damage: Pet STR. Accuracy bonus scales with TP. AoE range. SMN (subjob OK).",
    },

    ["Water IV"] = {
        description             = "Deals water damage.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Enhanced water-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Magic burst compatible. Single target. SMN (subjob OK).",
    },

    ["Spinning Dive"] = {
        description             = "Deals water physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 70,
        mp_cost                 = 118,
        skillchain              = "Fragmentation",
        notes                   = "Enhanced water-based physical piercing damage. MP: 118. Recast: Instant. Damage: Pet STR + INT. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Grand Fall"] = {
        description             = "Deals water physical dmg (multi-hit).",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "physical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Multi-hit water-based physical damage. MP: 182. Recast: Instant. Damage: Pet STR (×5 hits). Merit-based ability. Single target. SMN (subjob OK).",
    },

    ["Tidal Wave"] = {
        description             = "Deals water damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate water-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Slowga"] = {
        description             = "Inflicts slow (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "debuff",
        level                   = 33,
        mp_cost                 = 73,
        notes                   = "Slow status to enemies in range. MP: 73. Recast: Instant. Duration: 180s. Range: Area effect. SMN (subjob OK).",
    },

    ["Spring Water"] = {
        description             = "Restores HP.",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "healing",
        level                   = 47,
        mp_cost                 = 105,
        notes                   = "HP recovery over time. MP: 105. Recast: Instant. Duration: 90s. Regen: HP +5/tick. Target: Single party member. SMN (subjob OK).",
    },

    ["Tidal Roar"] = {
        description             = "Removes beneficial effects (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "debuff",
        level                   = 84,
        mp_cost                 = 118,
        notes                   = "Dispels beneficial effects from enemies. MP: 118. Recast: Instant. Range: Area effect. SMN (subjob OK).",
    },

    ["Soothing Current"] = {
        description             = "Boosts cure potency (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "buff",
        level                   = 99,
        mp_cost                 = 118,
        notes                   = "Cure Potency Received +15%. MP: 118. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return LEVIATHAN
