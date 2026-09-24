---============================================================================
--- SUMMONING DATABASE - Titan (Earth Avatar)
---============================================================================
--- Titan summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/titan.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
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
        notes                   = "Earth-based avatar. MP cost: 7. Specializes in physical damage (Rock Throw, Mountain Buster) and party wards (Earthen Ward, Earthen Armor). Resists earth and thunder, weak to wind. SMN (subjob OK).",
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
        mp_cost                 = 10,
        skillchain              = "Scission",
        notes                   = "Physical blunt damage + Slow. MP: 10. Damage: Pet STR + AGI. Accuracy bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Stone II"] = {
        description             = "Deals earth damage.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Earth-based magical damage. MP: 24. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Rock Buster"] = {
        description             = "Deals physical dmg + bind.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 21,
        mp_cost                 = 39,
        skillchain              = "Reverberation",
        notes                   = "Physical blunt damage + Bind (30s). MP: 39. Damage: Pet VIT. Damage varies with TP. Single target. SMN (subjob OK).",
    },

    ["Megalith Throw"] = {
        description             = "Deals physical dmg + slow.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 35,
        mp_cost                 = 62,
        skillchain              = "Induration",
        notes                   = "Physical blunt damage + Slow. MP: 62. Damage: Pet STR + AGI. Accuracy bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Stone IV"] = {
        description             = "Deals earth damage.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Enhanced earth-based magical damage. MP: 118. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Mountain Buster"] = {
        description             = "Deals physical dmg + bind.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 70,
        mp_cost                 = 164,
        skillchain              = "Gravitation/Induration",
        notes                   = "Physical damage + Bind (broken by further damage). MP: 164. Damage: Pet VIT. Damage varies with TP. Single target. SMN (main job only).",
    },

    ["Geocrush"] = {
        description             = "Deals earth damage + stun.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Earth magical damage + Stun. MP: 182. Damage: Pet INT. Damage varies with avatar TP. Merit-based ability. Single target. SMN (main job only).",
    },

    ["Crag Throw"] = {
        description             = "Deals physical dmg + slow.",
        category                = "Blood Pact: Rage",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 99,
        mp_cost                 = 124,
        skillchain              = "Gravitation/Scission",
        notes                   = "Physical damage + Slow (30%, 2 min). MP: 124. Damage: Pet STR + AGI. Accuracy bonus varies with TP. Single target. SMN (main job only).",
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
        notes                   = "Earth magical AoE damage. Uses all MP (Astral Flow). Requires MP of caster's level x2. Only available during Astral Flow. Damage: Pet INT. SMN (main job only).",
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
        mp_cost                 = 92,
        notes                   = "Stoneskin effect (potency 2 x level + 50). MP: 92. Duration: 900s. Party AoE. SMN (subjob OK).",
    },

    ["Earthen Armor"] = {
        description             = "Reduces heavy damage (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Earth",
        avatar                  = "Titan",
        type                    = "buff",
        level                   = 88,
        mp_cost                 = 156,
        notes                   = "Reduces any single action over 75% of max HP by 45%. MP: 156. Duration: 60s. Party AoE. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return TITAN
