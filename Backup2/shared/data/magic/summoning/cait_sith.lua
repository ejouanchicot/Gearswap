---============================================================================
--- SUMMONING DATABASE - Cait Sith (Light Avatar)
---============================================================================
--- Cait Sith summon spell and Blood Pact abilities
---
--- @file cait_sith.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local CAIT_SITH = {}

CAIT_SITH.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Cait Sith"] = {
        description             = "Summons Cait Sith.",
        category                = "Avatar Summon",
        element                 = "Light",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 30,
        mp_cost                 = 5,
        notes                   = "Light-based avatar. MP cost: 5. Perpetuation: 3 MP/3s. Specializes in support buffs (Raise II, regen, hastega) and TP manipulation (Level ? Holy). Quest required. SMN (subjob OK).",
    },

}

CAIT_SITH.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Regal Scratch"] = {
        description             = "Deals physical dmg + dispel.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "physical",
        damage_type             = "Slashing",
        level                   = 1,
        mp_cost                 = 9,
        skillchain              = "Transfixion",
        notes                   = "Physical slashing damage with dispel effect. MP: 9. Recast: Instant. Damage: Pet STR. Dispels one beneficial effect from enemy. Single target. SMN (subjob OK).",
    },

    ["Level ? Holy"] = {
        description             = "Deals light damage (level-based).",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 182,
        notes                   = "Light-based magical damage (potency based on pet level). MP: 182. Recast: Instant. Damage: 1000 if enemy level is multiple of pet level, else 0. Single target. SMN (subjob OK).",
    },

    ["Regal Gash"] = {
        description             = "Restores HP + removes ailments.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "healing",
        level                   = 99,
        mp_cost                 = 150,
        notes                   = "Party HP recovery + status ailment removal. MP: 150. Recast: Instant. Healing: Pet MND + Avatar level. Removes Poison, Paralysis, Blindness. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Healing)
    --============================================================

    ["Raise II"] = {
        description             = "Revives with HP + MP.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "healing",
        level                   = 15,
        mp_cost                 = 150,
        notes                   = "Revives KO'd party member with 25% HP/MP. MP: 150. Recast: Instant. Target: Single party member. SMN (subjob OK).",
    },

    ["Mewing Lullaby"] = {
        description             = "Inflicts sleep + TP reduction (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "debuff",
        level                   = 25,
        mp_cost                 = 56,
        notes                   = "Sleep status + TP reduction to enemies in range. MP: 56. Recast: Instant. Duration: 90s. Range: Area effect. SMN (subjob OK).",
    },

    ["Reraise II"] = {
        description             = "Grants reraise.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "buff",
        level                   = 30,
        mp_cost                 = 96,
        notes                   = "Reraise effect (auto-revive on KO with 25% HP/MP). MP: 96. Recast: Instant. Duration: 60 minutes. Target: Single party member. SMN (subjob OK).",
    },

    ["Eerie Eye"] = {
        description             = "Inflicts silence + amnesia (cone).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "debuff",
        level                   = 55,
        mp_cost                 = 123,
        notes                   = "Silence + Amnesia status to enemies in cone. MP: 123. Recast: Instant. Duration: 60s. Range: Conal AoE. SMN (subjob OK).",
    },

    ["Altana's Favor"] = {
        description             = "Grants party buffs.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "buff",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Ultimate party support buff. MP: 0. Recast: N/A. Only available during Astral Flow. Grants multiple beneficial effects to party. Party AoE. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return CAIT_SITH
