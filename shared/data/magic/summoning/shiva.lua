---============================================================================
--- SUMMONING DATABASE - Shiva (Ice Avatar)
---============================================================================
--- Shiva summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/shiva.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local SHIVA = {}

SHIVA.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Shiva"] = {
        description             = "Summons Shiva.",
        category                = "Avatar Summon",
        element                 = "Ice",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Ice-based avatar. MP cost: 7. Specializes in ice magic damage (Blizzard series, Diamond Dust) and Ice Spikes (Frost Armor). Resists ice and wind, weak to fire. SMN (subjob OK).",
    },

}

SHIVA.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Axe Kick"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 10,
        skillchain              = "Induration",
        notes                   = "Physical blunt damage. MP: 10. Damage: Pet STR. Damage varies with TP. Single target. SMN (subjob OK).",
    },

    ["Blizzard II"] = {
        description             = "Deals ice damage.",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "magical",
        level                   = 10,
        mp_cost                 = 24,
        notes                   = "Ice-based magical damage. MP: 24. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Double Slap"] = {
        description             = "Deals 2-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 50,
        mp_cost                 = 96,
        skillchain              = "Scission",
        notes                   = "Double-hit physical blunt damage. MP: 96. Damage: Pet CHR. Accuracy bonus varies with TP. Single target. SMN (subjob OK).",
    },

    ["Blizzard IV"] = {
        description             = "Deals ice damage.",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "magical",
        level                   = 60,
        mp_cost                 = 118,
        notes                   = "Enhanced ice-based magical damage. MP: 118. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Rush"] = {
        description             = "Deals 5-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 70,
        mp_cost                 = 164,
        skillchain              = "Distortion/Scission",
        notes                   = "Five-hit physical damage. MP: 164. Damage: Pet STR + DEX. Accuracy bonus varies with TP. Single target. SMN (main job only).",
    },

    ["Heavenly Strike"] = {
        description             = "Deals ice damage.",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        merit                   = true,
        notes                   = "Ice magical damage. MP: 182. Damage: Pet INT. Damage varies with avatar TP. Merit-based ability. Single target. SMN (main job only).",
    },

    ["Diamond Dust"] = {
        description             = "Deals ice damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ice magical AoE damage. Uses all MP (Astral Flow). Requires MP of caster's level x2. Only available during Astral Flow. Damage: Pet INT. SMN (main job only).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs)
    --============================================================

    ["Frost Armor"] = {
        description             = "Grants ice spikes (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "buff",
        level                   = 28,
        mp_cost                 = 63,
        notes                   = "Ice Spikes effect. MP: 63. Duration: 180s. Party AoE. SMN (subjob OK).",
    },

    ["Sleepga"] = {
        description             = "Inflicts sleep (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "debuff",
        level                   = 39,
        mp_cost                 = 54,
        notes                   = "Sleep status AoE (no damage). MP: 54. Duration: 90s. Range: 10 yalms. Enemies only. SMN (subjob OK).",
    },

    ["Diamond Storm"] = {
        description             = "Lowers evasion (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "debuff",
        level                   = 90,
        mp_cost                 = 138,
        notes                   = "Evasion -25 to enemies in range. MP: 138. Duration: 180s. Range: 10 yalms. SMN (main job only).",
    },

    ["Crystal Blessing"] = {
        description             = "Grants TP bonus (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Ice",
        avatar                  = "Shiva",
        type                    = "buff",
        level                   = 99,
        mp_cost                 = 201,
        notes                   = "TP Bonus +250. MP: 201. Duration: 180s. Party AoE. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SHIVA
