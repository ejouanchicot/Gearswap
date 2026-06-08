---============================================================================
--- SUMMONING DATABASE - Atomos (Dark Avatar)
---============================================================================
--- Atomos summon spell and Blood Pact: Ward abilities (main job only).
---
--- @file atomos.lua
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
        mp_cost                 = 7,
        restriction             = "main_job_only",
        notes                   = "Dark-based special avatar. SMN main job only. Provides support Blood Pacts (Chronoshift, Deconstruction).",
    },

}

ATOMOS.blood_pacts = {

    --============================================================
    -- BLOOD PACT: WARD (Support/Debuff)
    --============================================================

    ["Chronoshift"] = {
        description             = "Party Haste; enemy Slow.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Atomos",
        type                    = "buff",
        level                   = 75,
        mp_cost                 = 0,
        notes                   = "Grants Haste to the party and inflicts Slow on nearby enemies. SMN main job only.",
    },

    ["Deconstruction"] = {
        description             = "Lowers defense (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Atomos",
        type                    = "debuff",
        level                   = 75,
        mp_cost                 = 0,
        notes                   = "AoE Defense Down on enemies. SMN main job only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ATOMOS
