---============================================================================
--- SUMMONING DATABASE - Siren (Wind Avatar)
---============================================================================
--- Siren summon spell and Blood Pact abilities
---
--- @file siren.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local SIREN = {}

SIREN.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Siren"] = {
        description             = "Summons Siren.",
        category                = "Avatar Summon",
        element                 = "Wind",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 75,
        mp_cost                 = 7,
        notes                   = "Wind-based avatar. MP cost: 7. Perpetuation: 3 MP/3s. Specializes in debuffs via songs (Lunatic Voice, Hysteric Assault) and status ailments. Quest required. SMN (subjob OK).",
    },

}

SIREN.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Welt"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Transfixion",
        notes                   = "Physical blunt damage. MP: 9. Recast: Instant. Damage: Pet STR. Single target. SMN (subjob OK).",
    },

    ["Roundhouse"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 25,
        mp_cost                 = 56,
        skillchain              = "Reverberation",
        notes                   = "Enhanced physical blunt damage. MP: 56. Recast: Instant. Damage: Pet STR. Single target. SMN (subjob OK).",
    },

    ["Sonic Buffet"] = {
        description             = "Deals wind damage + dispel (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "magical",
        level                   = 65,
        mp_cost                 = 118,
        notes                   = "Wind-based magical AoE damage with dispel effect. MP: 118. Recast: Instant. Damage: Pet MAB + level. Dispels one beneficial effect from enemies. AoE range. SMN (subjob OK).",
    },

    ["Tornado II"] = {
        description             = "Deals wind damage.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        notes                   = "Wind-based magical damage. MP: 182. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Hysteric Assault"] = {
        description             = "Deals triple attack + HP drain.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 99,
        mp_cost                 = 200,
        skillchain              = "Fragmentation",
        notes                   = "Triple-hit physical damage with HP drain. MP: 200. Recast: Instant. Damage: Pet STR (×3 hits). Drains HP from enemy. Single target. SMN (subjob OK).",
    },

    ["Clarsach Call"] = {
        description             = "Deals wind damage + buffs (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate wind-based magical AoE damage + buffs Siren. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage + enhances Siren's stats. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Debuffs)
    --============================================================

    ["Lunatic Voice"] = {
        description             = "Inflicts silence (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "debuff",
        level                   = 15,
        mp_cost                 = 33,
        notes                   = "Silence status to enemies (prevents spellcasting). MP: 33. Recast: Instant. Duration: 60s. Range: Area effect. SMN (subjob OK).",
    },

    ["Katabatic Blades"] = {
        description             = "Grants enaero (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "buff",
        level                   = 31,
        mp_cost                 = 69,
        notes                   = "Enaero effect (adds wind damage to attacks). MP: 69. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Chinook"] = {
        description             = "Grants aquaveil (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "buff",
        level                   = 42,
        mp_cost                 = 94,
        notes                   = "Aquaveil effect (reduces spell interruption). MP: 94. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Bitter Elegy"] = {
        description             = "Inflicts elegy.",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "debuff",
        level                   = 50,
        mp_cost                 = 112,
        notes                   = "Elegy effect (slow + haste down). MP: 112. Recast: Instant. Duration: 180s. Target: Single enemy. SMN (subjob OK).",
    },

    ["Wind's Blessing"] = {
        description             = "Grants magic shield (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "buff",
        level                   = 88,
        mp_cost                 = 196,
        notes                   = "Magic Shield effect (absorbs magical damage). MP: 196. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SIREN
