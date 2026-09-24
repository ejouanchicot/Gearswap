---============================================================================
--- SUMMONING DATABASE - Atomos (Dark Avatar)
---============================================================================
--- Atomos summon spell and Blood Pact: Ward abilities (main job only).
---
--- @file shared/data/magic/summoning/atomos.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-06-08
---============================================================================

local ATOMOS = {}

ATOMOS.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Atomos"] = {
        description             = "Summons Atomos.",
        category                = "Avatar Summon",
        element                 = "Dark",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 75,
        mp_cost                 = 50,
        restriction             = "main_job_only",
        notes                   = "Dark-based special avatar. SMN main job only. Provides support Blood Pacts (Chronoshift, Deconstruction).",
    },

}

ATOMOS.blood_pacts = {

    --============================================================
    -- BLOOD PACT: WARD (Support/Debuff)
    --============================================================

    ["Chronoshift"] = {
        description             = "Gives party the buff taken by Deconstruction.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Atomos",
        type                    = "buff",
        level                   = 75,
        mp_cost                 = 0,
        notes                   = "Used automatically right after Deconstruction. Grants the party the beneficial effect (if any) absorbed by Deconstruction. Range: 14 yalms around Atomos. MP: 0. SMN (main job only).",
    },

    ["Deconstruction"] = {
        description             = "Absorbs a buff from an enemy.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Atomos",
        type                    = "debuff",
        level                   = 75,
        mp_cost                 = 0,
        notes                   = "Used automatically after summoning Atomos on an enemy. Absorbs a beneficial status effect from the target (not all buffs can be absorbed). MP: 0. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ATOMOS
