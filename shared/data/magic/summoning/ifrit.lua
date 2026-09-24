---============================================================================
--- SUMMONING DATABASE - Ifrit (Fire Avatar)
---============================================================================
--- Ifrit summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/ifrit.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local IFRIT = {}

IFRIT.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Ifrit"] = {
        description             = "Summons Ifrit.",
        category                = "Avatar Summon",
        element                 = "Fire",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Fire-based avatar. MP cost: 7. Blood Pacts include Crimson Howl (Warcry-like attack boost) and Inferno Howl (Enfire). Highly resistant to fire and ice, weak to water. SMN (subjob OK).",
    },

}

IFRIT.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Punch"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Liquefaction",
        notes                   = "Physical blunt damage. MP: 9. Damage: Pet STR. Accuracy bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Fire II"] = {
        description             = "Deals fire damage.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Fire-based magical damage. MP: 24. Damage: Pet INT. Damage affected by pet TP. Single target. SMN (subjob OK).",
    },

    ["Burning Strike"] = {
        description             = "Deals fire physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 23,
        mp_cost                 = 48,
        skillchain              = "Impaction",
        notes                   = "Fire-enhanced physical blunt damage. MP: 48. Damage: Pet STR + INT. Accuracy bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Double Punch"] = {
        description             = "Deals 2-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 30,
        mp_cost                 = 56,
        skillchain              = "Compression",
        notes                   = "Two-hit physical blunt damage. MP: 56. Damage: Pet STR. Damage varies with TP (fTP carries to all hits). Single target. SMN (subjob OK).",
    },

    ["Fire IV"] = {
        description             = "Deals fire damage.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Fire-based magical damage. MP: 118. Damage: Pet INT. Single target. SMN (main job only).",
    },

    ["Flaming Crush"] = {
        description             = "Deals 3-fold fire dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 70,
        mp_cost                 = 164,
        skillchain              = "Fusion/Reverberation",
        notes                   = "Hybrid three-hit attack (2 physical hits + 1 magical fire hit). MP: 164. Damage: Pet STR + INT. Accuracy bonus varies with TP. Single target. SMN (main job only).",
    },

    ["Meteor Strike"] = {
        description             = "Deals fire dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Fire-based magical damage. MP: 182. Damage: Pet INT. Damage varies with avatar TP; each extra merit level adds +400 TP Bonus. Merit-based ability. Single target. SMN (main job only).",
    },

    ["Conflag Strike"] = {
        description             = "Deals fire dmg + burn.",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "physical",
        level                   = 99,
        mp_cost                 = 141,
        notes                   = "Fire breath damage + Burn (30 HP/tick, INT -63, 1 min). MP: 141. Damage: Pet INT. Can be resisted. Single target. SMN (main job only).",
    },

    ["Inferno"] = {
        description             = "Deals fire damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate fire-based magical AoE damage. Requires MP = caster's level x2. Uses all MP (Astral Flow). Only usable during Astral Flow. Damage: Pet INT. SMN (main job only).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Crimson Howl"] = {
        description             = "Boosts attack (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "buff",
        level                   = 38,
        mp_cost                 = 84,
        notes                   = "Attack boost for party. MP: 84. Duration: 60s. Effect: Attack +11.2% (at level 99). Overwrites Warcry/Blood Rage. Party AoE. SMN (subjob OK).",
    },

    ["Inferno Howl"] = {
        description             = "Grants enfire (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Fire",
        avatar                  = "Ifrit",
        type                    = "buff",
        level                   = 88,
        mp_cost                 = 72,
        notes                   = "Enfire effect for party. MP: 72. Duration: 60s. Damage increases with Summoning Magic skill. Party AoE. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return IFRIT
