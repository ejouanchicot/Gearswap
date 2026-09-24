---============================================================================
--- SUMMONING DATABASE - Leviathan (Water Avatar)
---============================================================================
--- Leviathan summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/leviathan.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
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
        notes                   = "Water-based avatar. MP cost: 7. Specializes in water magic damage (Water series, Tidal Wave) and healing (Spring Water). Resists water and fire, weak to lightning. SMN (subjob OK).",
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
        damage_type             = "Slashing",
        level                   = 1,
        mp_cost                 = 8,
        skillchain              = "Reverberation",
        notes                   = "Physical slashing damage. MP: 8. Damage: Pet STR. Accuracy bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Water II"] = {
        description             = "Deals water damage.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Water-based magical damage. MP: 24. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Tail Whip"] = {
        description             = "Deals physical dmg + weight.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 26,
        mp_cost                 = 49,
        skillchain              = "Detonation",
        notes                   = "Physical blunt damage + Weight. MP: 49. Damage: Pet VIT. Damage varies with TP. Single target. SMN (subjob OK).",
    },

    ["Water IV"] = {
        description             = "Deals water damage.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Enhanced water-based magical damage. MP: 118. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Spinning Dive"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 70,
        mp_cost                 = 164,
        skillchain              = "Distortion/Detonation",
        notes                   = "Physical damage. MP: 164. Damage: Pet STR. Accuracy bonus varies with TP. Single target. SMN (main job only).",
    },

    ["Grand Fall"] = {
        description             = "Deals water damage.",
        category                = "Blood Pact: Rage",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Water magical damage. MP: 182. Damage: Pet INT. Damage varies with avatar TP. Ignores shadows. Merit-based ability. Single target. SMN (main job only).",
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
        notes                   = "Water magical AoE damage. Uses all MP (Astral Flow). Requires MP of caster's level x2. Only available during Astral Flow. Damage: Pet INT. SMN (main job only).",
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
        mp_cost                 = 48,
        notes                   = "Slow (~30%) to enemies in range. MP: 48. Range: 10 yalms. SMN (subjob OK).",
    },

    ["Spring Water"] = {
        description             = "Restores HP, removes ailments (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "healing",
        level                   = 47,
        mp_cost                 = 99,
        notes                   = "Party HP recovery + removes most -na status ailments (not Curse). MP: 99. Potency based on avatar max HP; TP only widens the area. Party AoE. SMN (subjob OK).",
    },

    ["Tidal Roar"] = {
        description             = "Lowers attack (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "debuff",
        level                   = 84,
        mp_cost                 = 138,
        notes                   = "Attack Down 25% to enemies in range. MP: 138. Duration: 90s. Range: 10 yalms. SMN (main job only).",
    },

    ["Soothing Current"] = {
        description             = "Boosts cure potency (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Water",
        avatar                  = "Leviathan",
        type                    = "buff",
        level                   = 99,
        mp_cost                 = 95,
        notes                   = "Cure potency received +15% (does not bypass the 30% cap). MP: 95. Duration: 180s. Party AoE. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return LEVIATHAN
