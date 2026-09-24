---============================================================================
--- SUMMONING DATABASE - Ramuh (Thunder Avatar)
---============================================================================
--- Ramuh summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/ramuh.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local RAMUH = {}

RAMUH.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Ramuh"] = {
        description             = "Summons Ramuh.",
        category                = "Avatar Summon",
        element                 = "Thunder",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Thunder-based avatar. MP cost: 7. Blood Pacts include stuns (Shock Strike, Chaotic Strike, Volt Strike, Shock Squall) and paralyze (Thunderspark). Highly resistant to thunder and water, weak to earth. SMN (subjob OK).",
    },

}

RAMUH.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Shock Strike"] = {
        description             = "Deals physical dmg + stun.",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 6,
        skillchain              = "Impaction",
        notes                   = "Physical blunt damage + Stun. MP: 6. Damage: Pet STR + INT. Critical hit rate varies with TP. Single target. SMN (subjob OK).",
    },

    ["Thunder II"] = {
        description             = "Deals thunder damage.",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Thunder-based magical damage. MP: 24. Damage: Pet INT. Damage affected by pet TP. Single target. SMN (subjob OK).",
    },

    ["Thunderspark"] = {
        description             = "Deals thunder dmg + paralyze (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "magical",
        level                   = 19,
        mp_cost                 = 38,
        notes                   = "Thunder-based magical damage + Paralyze. MP: 38. Damage: Pet INT. AoE (10' centered on Ramuh). SMN (subjob OK).",
    },

    ["Thunder IV"] = {
        description             = "Deals thunder damage.",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Thunder-based magical damage. MP: 118. Damage: Pet INT. Single target. SMN (main job only).",
    },

    ["Chaotic Strike"] = {
        description             = "Deals 3-fold physical dmg + stun.",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 70,
        mp_cost                 = 164,
        skillchain              = "Fragmentation/Transfixion",
        notes                   = "Three-hit physical damage + long Stun. MP: 164. Damage: Pet STR + INT. Critical hit rate varies with TP. Single target. SMN (main job only).",
    },

    ["Thunderstorm"] = {
        description             = "Deals thunder dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Thunder-based magical damage. MP: 182. Damage: Pet INT. Damage varies with avatar TP; each extra merit level adds +400 TP Bonus. Merit-based ability. Single target. SMN (main job only).",
    },

    ["Volt Strike"] = {
        description             = "Deals 3-fold physical dmg + stun.",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 99,
        mp_cost                 = 229,
        skillchain              = "Fragmentation/Scission",
        notes                   = "Three-hit physical damage + Stun (15s unresisted). MP: 229. Damage: Pet STR + INT. Critical hit rate varies with TP. Single target. SMN (main job only).",
    },

    ["Judgment Bolt"] = {
        description             = "Deals thunder damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate thunder-based magical AoE damage. Requires MP = caster's level x2. Uses all MP (Astral Flow). Only usable during Astral Flow. Damage: Pet INT. SMN (main job only).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Rolling Thunder"] = {
        description             = "Grants enthunder (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "buff",
        level                   = 31,
        mp_cost                 = 52,
        notes                   = "Enthunder effect (adds thunder damage to attacks). MP: 52. Duration: 120s. Potency scales with Summoning Magic skill. Party AoE. SMN (subjob OK).",
    },

    ["Lightning Armor"] = {
        description             = "Grants shock spikes (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "buff",
        level                   = 42,
        mp_cost                 = 91,
        notes                   = "Shock Spikes effect (damages attackers, may stun them). MP: 91. Duration: 180s. Party AoE. SMN (subjob OK).",
    },

    ["Shock Squall"] = {
        description             = "Inflicts stun (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Thunder",
        avatar                  = "Ramuh",
        type                    = "debuff",
        level                   = 92,
        mp_cost                 = 67,
        notes                   = "Stuns enemies in area (10' around target). MP: 67. Duration: 15s (unresisted). SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RAMUH
