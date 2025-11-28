---============================================================================
--- SUMMONING DATABASE - Carbuncle (Light Avatar)
---============================================================================
--- Carbuncle summon spell and Blood Pact abilities
---
--- @file carbuncle.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local CARBUNCLE = {}

CARBUNCLE.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Carbuncle"] = {
        description             = "Summons Carbuncle.",
        category                = "Avatar Summon",
        element                 = "Light",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 5,
        notes                   = "Light-based avatar. MP cost: 5. Perpetuation: 2 MP/3s. Specializes in healing (Healing Ruby series) and support abilities. Auto-Regen at level 25+. SMN (subjob OK).",
    },

}

CARBUNCLE.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Poison Nails"] = {
        description             = "Deals physical dmg + poison.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 5,
        mp_cost                 = 11,
        skillchain              = "Transfixion",
        notes                   = "Physical piercing damage with poison effect. MP: 11. Recast: Instant. Damage: Pet DEX. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Meteorite"] = {
        description             = "Deals light damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "magical",
        level                   = 55,
        mp_cost                 = 108,
        notes                   = "Light-based magical AoE damage. MP: 108. Recast: Instant. Damage: Pet INT (fTP 3.5-4.25 based on TP). Magic burst compatible. AoE range. SMN (subjob OK).",
    },

    ["Holy Mist"] = {
        description             = "Deals light damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "magical",
        level                   = 76,
        mp_cost                 = 118,
        notes                   = "Light-based magical AoE damage. MP: 118. Recast: Instant. Damage: Pet MND. All light-based abilities. AoE range. SMN (subjob OK).",
    },

    ["Searing Light"] = {
        description             = "Deals light damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate light-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Healing)
    --============================================================

    ["Healing Ruby"] = {
        description             = "Restores HP.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 1,
        mp_cost                 = 6,
        notes                   = "Single-target HP recovery. MP: 6. Recast: Instant. Healing: Pet MND + Avatar level. Target: Single party member. SMN (subjob OK).",
    },

    ["Shining Ruby"] = {
        description             = "Restores HP (enhanced).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 24,
        mp_cost                 = 24,
        notes                   = "Enhanced single-target HP recovery. MP: 24. Recast: Instant. Healing: Pet MND + Avatar level. Target: Single party member. SMN (subjob OK).",
    },

    ["Glittering Ruby"] = {
        description             = "Restores HP (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 44,
        mp_cost                 = 48,
        notes                   = "Party HP recovery. MP: 48. Recast: Instant. Healing: Pet MND + Avatar level. Target: Party AoE. Range: 10 yalms. SMN (subjob OK).",
    },

    ["Healing Ruby II"] = {
        description             = "Restores HP (strong).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 65,
        mp_cost                 = 96,
        notes                   = "Strong single-target HP recovery. MP: 96. Recast: Instant. Healing: Pet MND + Avatar level (enhanced). Target: Single party member. SMN (subjob OK).",
    },

    ["Soothing Ruby"] = {
        description             = "Restores HP + removes ailments.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 94,
        mp_cost                 = 128,
        notes                   = "HP recovery + status ailment removal. MP: 128. Recast: Instant. Healing: Pet MND + Avatar level. Removes poison, paralysis, blindness. Target: Single party member. SMN (subjob OK).",
    },

    ["Pacifying Ruby"] = {
        description             = "Removes one enfeebling effect.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "support",
        level                   = 99,
        mp_cost                 = 96,
        notes                   = "Removes one enfeebling effect from party. MP: 96. Recast: Instant. Target: Party members within range. Range: 10 yalms. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return CARBUNCLE
