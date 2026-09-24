---============================================================================
--- SUMMONING DATABASE - Cait Sith (Light Avatar)
---============================================================================
--- Cait Sith summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/cait_sith.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
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
        SMN                     = 1,
        mp_cost                 = 5,
        notes                   = "Light-based avatar. MP cost: 5. Support Blood Pacts (Raise II, Reraise II, Mewing Lullaby, Eerie Eye) and light damage (Level ? Holy). Obtained from the quest Champion of the Dawn. SMN (subjob OK).",
    },

}

CAIT_SITH.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Regal Scratch"] = {
        description             = "Deals 3-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "physical",
        damage_type             = "Slashing",
        level                   = 1,
        mp_cost                 = 5,
        skillchain              = "Scission",
        notes                   = "Three-hit physical attack. MP: 5. Stat: Pet INT. Accuracy bonus varies with TP. SMN (subjob OK).",
    },

    ["Level ? Holy"] = {
        description             = "Deals light dmg by die roll (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "magical",
        level                   = 75,
        mp_cost                 = 235,
        notes                   = "Rolls a die: deals light damage to nearby enemies whose level is divisible by the number rolled, higher rolls dealing more damage. Stat: Pet INT. MP: 235. SMN (main job only).",
    },

    ["Regal Gash"] = {
        description             = "Deals 3-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "physical",
        level                   = 99,
        mp_cost                 = 118,
        skillchain              = "Distortion/Detonation",
        notes                   = "Three-hit physical attack. MP: 118. Stat: Pet DEX. Accuracy bonus varies with TP. SMN (main job only).",
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
        mp_cost                 = 160,
        notes                   = "Revives KO'd party member with 25% HP/MP. MP: 160. Target: Single party member. SMN (subjob OK).",
    },

    ["Mewing Lullaby"] = {
        description             = "Inflicts sleep + TP reduction (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "debuff",
        level                   = 25,
        mp_cost                 = 61,
        notes                   = "Sleep + TP reset on enemies in range; the TP reset lands even if the sleep is resisted. MP: 61. Duration: 35s (unresisted). Range: 10'. SMN (subjob OK).",
    },

    ["Reraise II"] = {
        description             = "Grants reraise.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "buff",
        level                   = 30,
        mp_cost                 = 80,
        notes                   = "Grants Reraise II to the targeted party member. MP: 80. Duration: 60 min. SMN (subjob OK).",
    },

    ["Eerie Eye"] = {
        description             = "Inflicts silence + amnesia (gaze).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "debuff",
        level                   = 55,
        mp_cost                 = 134,
        notes                   = "Gaze attack: inflicts Silence and Amnesia on the target (the target must be facing Cait Sith when it lands). Amnesia: 12-15s. MP: 134. SMN (subjob OK).",
    },

    ["Altana's Favor"] = {
        description             = "Grants Arise or Reraise III (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Cait Sith",
        type                    = "buff",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Astral Flow ability. Grants Arise to KO'd party members or Reraise III to living ones in range (party members only). Uses all MP (Astral Flow). SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return CAIT_SITH
