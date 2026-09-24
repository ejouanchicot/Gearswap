---============================================================================
--- SUMMONING DATABASE - Carbuncle (Light Avatar)
---============================================================================
--- Carbuncle summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/carbuncle.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
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
        notes                   = "Light-based avatar. MP cost: 5. Specializes in healing (Healing Ruby series) and support abilities. Gains Auto Regen at level 25. SMN (subjob OK).",
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
        notes                   = "Physical piercing damage with poison effect. MP: 11. Damage: Pet DEX. Accuracy bonus scales with TP. Single target. SMN (subjob OK).",
    },

    ["Meteorite"] = {
        description             = "Deals light dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "magical",
        level                   = 55,
        mp_cost                 = 108,
        notes                   = "Light-based magical damage. MP: 108. Stat: Pet INT (fTP 3.5-4.25 based on TP). Can Magic Burst. SMN (subjob OK).",
    },

    ["Holy Mist"] = {
        description             = "Deals light dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "magical",
        level                   = 76,
        mp_cost                 = 152,
        notes                   = "Light-based magical damage to one enemy. MP: 152. SMN (main job only).",
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
        notes                   = "Astral Flow ability. Light-based magical damage to enemies in range. Requires MP of at least caster's level x2. Stat: Pet INT. Uses all MP (Astral Flow). SMN (main job only).",
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
        notes                   = "Single-target HP recovery. MP: 6. Healing: Pet MND + Avatar level. Target: Single party member. SMN (subjob OK).",
    },

    ["Shining Ruby"] = {
        description             = "Grants Protect + Shell (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "buff",
        level                   = 24,
        mp_cost                 = 44,
        notes                   = "Protect + Shell effect on party members in range: DEF about +10% (25/256), magic damage taken about -4% (10/256). MP: 44. Duration: 180s. SMN (subjob OK).",
    },

    ["Glittering Ruby"] = {
        description             = "Boosts a random attribute (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "buff",
        level                   = 44,
        mp_cost                 = 62,
        notes                   = "Boosts one random attribute on each party member in range. Potency: about 3 + floor(level/5). MP: 62. Duration: 180s. SMN (subjob OK).",
    },

    ["Healing Ruby II"] = {
        description             = "Restores HP (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 65,
        mp_cost                 = 124,
        notes                   = "Restores HP to party members in range. Potency based on Carbuncle's max HP and TP. MP: 124. SMN (main job only).",
    },

    ["Soothing Ruby"] = {
        description             = "Removes ailments (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "healing",
        level                   = 94,
        mp_cost                 = 74,
        notes                   = "Removes up to 6 status ailments from each party member in range (number removed scales with Summoning Magic skill). Does not remove Curse. MP: 74. SMN (main job only).",
    },

    ["Pacifying Ruby"] = {
        description             = "Reduces a party member's enmity.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Carbuncle",
        type                    = "support",
        level                   = 99,
        mp_cost                 = 83,
        notes                   = "Reduces the target party member's enmity by 25% (removed, not transferred to Carbuncle). MP: 83. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return CARBUNCLE
