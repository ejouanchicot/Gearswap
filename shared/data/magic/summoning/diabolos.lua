---============================================================================
--- SUMMONING DATABASE - Diabolos (Dark Avatar)
---============================================================================
--- Diabolos summon spell and Blood Pact abilities
---
--- @file diabolos.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local DIABOLOS = {}

DIABOLOS.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Diabolos"] = {
        description             = "Summons Diabolos.",
        category                = "Avatar Summon",
        element                 = "Dark",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 20,
        mp_cost                 = 7,
        notes                   = "Dark-based avatar. MP cost: 7. Perpetuation: 3 MP/3s. Specializes in gravity effects, darkness damage (Night Terror, Ruinous Omen), and drain-type abilities. Quest required. SMN (subjob OK).",
    },

}

DIABOLOS.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Camisado"] = {
        description             = "Deals physical dmg + darkness.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Gravitation",
        notes                   = "Physical blunt damage with darkness effect. MP: 9. Recast: Instant. Damage: Pet STR. Inflicts Darkness (-50 accuracy). Single target. SMN (subjob OK).",
    },

    ["Nether Blast"] = {
        description             = "Deals dark damage.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "magical",
        level                   = 65,
        mp_cost                 = 118,
        notes                   = "Dark-based magical damage. MP: 118. Recast: Instant. Damage: Pet INT. Single target. SMN (subjob OK).",
    },

    ["Night Terror"] = {
        description             = "Deals dark damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "magical",
        level                   = 80,
        mp_cost                 = 178,
        notes                   = "Dark-based magical AoE damage. MP: 178. Recast: Instant. Damage: Pet MAB + level. AoE range. SMN (subjob OK).",
    },

    ["Blindside"] = {
        description             = "Deals physical dmg (ignores Utsusemi).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 99,
        mp_cost                 = 150,
        skillchain              = "Fragmentation",
        notes                   = "Physical piercing damage that ignores shadows. MP: 150. Recast: Instant. Damage: Pet STR. Bypasses Utsusemi/Blink. Single target. SMN (subjob OK).",
    },

    ["Ruinous Omen"] = {
        description             = "Deals dark damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate dark-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs/Debuffs)
    --============================================================

    ["Somnolence"] = {
        description             = "Restores HP + MP + gravity.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "healing",
        level                   = 20,
        mp_cost                 = 44,
        notes                   = "HP and MP recovery over time + Gravity effect. MP: 44. Recast: Instant. Duration: 90s. Regen: HP +3/tick, MP +1/tick. Gravity: Movement speed down. Target: Single party member. SMN (subjob OK).",
    },

    ["Nightmare"] = {
        description             = "Inflicts sleep + bio dmg (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 29,
        mp_cost                 = 65,
        notes                   = "Sleep status + Bio damage over time to enemies. MP: 65. Recast: Instant. Duration: 60s. Range: Area effect. SMN (subjob OK).",
    },

    ["Ultimate Terror"] = {
        description             = "Inflicts terror (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 37,
        mp_cost                 = 82,
        notes                   = "Terror status to enemies (prevents action). MP: 82. Recast: Instant. Duration: 15s. Range: Area effect. SMN (subjob OK).",
    },

    ["Noctoshield"] = {
        description             = "Grants damage shield (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "buff",
        level                   = 49,
        mp_cost                 = 110,
        notes                   = "Phalanx-like effect (absorbs damage). MP: 110. Recast: Instant. Duration: 180s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Dream Shroud"] = {
        description             = "Boosts magic attack + accuracy (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "buff",
        level                   = 56,
        mp_cost                 = 125,
        notes                   = "Magic Attack Bonus +30%, Magic Defense Bonus +30%. MP: 125. Recast: Instant. Duration: 90s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Pavor Nocturnus"] = {
        description             = "Inflicts death or dispel (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 98,
        mp_cost                 = 218,
        notes                   = "Instant death OR dispel to enemies (priority: Death on weak enemies). MP: 218. Recast: Instant. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DIABOLOS
