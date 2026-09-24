---============================================================================
--- SUMMONING DATABASE - Garuda (Wind Avatar)
---============================================================================
--- Garuda summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/garuda.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local GARUDA = {}

GARUDA.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Garuda"] = {
        description             = "Summons Garuda.",
        category                = "Avatar Summon",
        element                 = "Wind",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Wind-based avatar. MP cost: 7. Specializes in wind magic damage (Aero series, Aerial Blast), Blink (Aerial Armor) and Haste (Hastega). Resists wind and earth, weak to ice. SMN (subjob OK).",
    },

}

GARUDA.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Claw"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 1,
        mp_cost                 = 7,
        skillchain              = "Detonation",
        notes                   = "Physical piercing damage. MP: 7. Critical hit rate bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Aero II"] = {
        description             = "Deals wind damage.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Wind-based magical damage. MP: 24. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Aero IV"] = {
        description             = "Deals wind damage.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Enhanced wind-based magical damage. MP: 118. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Predator Claws"] = {
        description             = "Deals 3-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "physical",
        damage_type             = "Slashing",
        level                   = 70,
        mp_cost                 = 164,
        skillchain              = "Fragmentation/Scission",
        notes                   = "Three-hit physical damage. MP: 164. Damage: Pet DEX. Critical hit rate bonus varies with TP. Single target. SMN (main job only).",
    },

    ["Wind Blade"] = {
        description             = "Deals wind damage.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Wind magical damage. MP: 182. Damage: Pet INT. Damage varies with avatar TP. Merit-based ability. Single target. SMN (main job only).",
    },

    ["Aerial Blast"] = {
        description             = "Deals wind damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Wind magical AoE damage. Uses all MP (Astral Flow). Requires MP of caster's level x2. Only available during Astral Flow. Damage: Pet INT. SMN (main job only).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Aerial Armor"] = {
        description             = "Grants Blink (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "buff",
        level                   = 25,
        mp_cost                 = 92,
        notes                   = "Blink effect (3-4 shadows). MP: 92. Duration: 900s. Party AoE. SMN (subjob OK).",
    },

    ["Whispering Wind"] = {
        description             = "Restores HP (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "healing",
        level                   = 36,
        mp_cost                 = 119,
        notes                   = "Party HP recovery. MP: 119. Potency based on avatar max HP; TP only widens the area. Party AoE. SMN (subjob OK).",
    },

    ["Hastega"] = {
        description             = "Boosts attack speed (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "buff",
        level                   = 48,
        mp_cost                 = 129,
        notes                   = "Magic haste +15%. MP: 129. Duration: 180s. Party AoE. SMN (subjob OK).",
    },

    ["Fleet Wind"] = {
        description             = "Boosts movement speed (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "buff",
        level                   = 86,
        mp_cost                 = 114,
        notes                   = "Movement speed +20%. MP: 114. Duration: 120s. Party AoE. SMN (main job only).",
    },

    ["Hastega II"] = {
        description             = "Boosts attack speed (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Garuda",
        type                    = "buff",
        level                   = 99,
        mp_cost                 = 248,
        notes                   = "Magic haste +30%. MP: 248. Duration: 180s. Party AoE. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return GARUDA
