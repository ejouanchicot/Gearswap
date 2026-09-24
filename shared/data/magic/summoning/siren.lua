---============================================================================
--- SUMMONING DATABASE - Siren (Wind Avatar)
---============================================================================
--- Siren summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/siren.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
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
        SMN                     = 1,
        mp_cost                 = 7,
        notes                   = "Wind-based avatar. MP cost: 7. Blood Pacts include debuffs (Lunatic Voice, Bitter Elegy) and party wards (Katabatic Blades, Chinook, Wind's Blessing). Obtained from the quest The Silent Forest or Winds of Eternity. SMN (subjob OK).",
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
        damage_type             = "Slashing",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Scission",
        notes                   = "Physical slashing damage. MP: 9. Single target. SMN (subjob OK).",
    },

    ["Roundhouse"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 25,
        mp_cost                 = 52,
        skillchain              = "Detonation",
        notes                   = "Physical blunt damage. MP: 52. Single target. SMN (subjob OK).",
    },

    ["Sonic Buffet"] = {
        description             = "Deals wind dmg + dispel.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "magical",
        level                   = 65,
        mp_cost                 = 164,
        notes                   = "Wind-based magical damage + Dispel (removes 1 buff, procs regardless of damage). MP: 164. Damage: Pet INT. Single target. SMN (main job only).",
    },

    ["Tornado II"] = {
        description             = "Deals wind damage.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        notes                   = "Wind-based magical damage. MP: 182. Damage: Pet INT. Single target. SMN (main job only).",
    },

    ["Hysteric Assault"] = {
        description             = "Deals triple attack + HP drain.",
        category                = "Blood Pact: Rage",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 99,
        mp_cost                 = 222,
        skillchain              = "Fragmentation/Transfixion",
        notes                   = "Three-hit physical piercing damage + HP drain (also works on undead). MP: 222. Damage: Pet DEX + INT. Single target. SMN (main job only).",
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
        notes                   = "Ultimate wind-based magical AoE damage. Requires MP = caster's level x2. Uses all MP (Astral Flow). Only usable during Astral Flow. Damage: Pet INT. Also grants Siren Attack/Defense +25% and Evasion +50 for 3 min. SMN (main job only).",
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
        mp_cost                 = 37,
        notes                   = "Silences enemies in area (10'). MP: 37. Duration: 90s (unresisted). Overwrites and is overwritten by Silence. SMN (subjob OK).",
    },

    ["Katabatic Blades"] = {
        description             = "Grants enaero (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "buff",
        level                   = 31,
        mp_cost                 = 52,
        notes                   = "Enaero effect (adds wind damage to attacks). MP: 52. Duration: 120s. Potency scales with Summoning Magic skill. Party AoE. SMN (subjob OK).",
    },

    ["Chinook"] = {
        description             = "Grants aquaveil (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "buff",
        level                   = 42,
        mp_cost                 = 118,
        notes                   = "Aquaveil effect (prevents up to 3 spell interruptions). MP: 118. Duration: 15 min. Party AoE. SMN (subjob OK).",
    },

    ["Bitter Elegy"] = {
        description             = "Inflicts elegy.",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "debuff",
        level                   = 50,
        mp_cost                 = 96,
        notes                   = "Elegy effect (50% wind-aligned Slow). MP: 96. Duration: 180s. Single enemy. SMN (subjob OK).",
    },

    ["Wind's Blessing"] = {
        description             = "Grants magic shield (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Wind",
        avatar                  = "Siren",
        type                    = "buff",
        level                   = 88,
        mp_cost                 = 135,
        notes                   = "Magic Shield effect (reduces magic damage only, by Siren's MND/5). MP: 135. Duration: 60s (affected by Summoning Magic skill). Party AoE. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SIREN
