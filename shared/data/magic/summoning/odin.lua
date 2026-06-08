---============================================================================
--- SUMMONING DATABASE - Odin (Dark Avatar)
---============================================================================
--- Odin summon spell and Blood Pact ability (main job only, Astral Flow).
---
--- @file odin.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-06-08
---============================================================================

local ODIN = {}

ODIN.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Odin"] = {
        description             = "Summons Odin.",
        category                = "Avatar Summon",
        element                 = "Dark",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 75,
        mp_cost                 = 7,
        restriction             = "main_job_only",
        notes                   = "Dark-based special avatar. SMN main job only. Used almost exclusively for his Astral Flow Blood Pact (Zantetsuken).",
    },

}

ODIN.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Astral Flow)
    --============================================================

    ["Zantetsuken"] = {
        description             = "Attempts instant KO (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Odin",
        type                    = "magical",
        damage_type             = "Magical",
        level                   = 75,
        mp_cost                 = 0,
        astral_flow             = true,
        restriction             = "two_hour",
        notes                   = "Astral Flow ability. Attempts instant death on enemies in range; deals heavy dark damage otherwise. MP: 0. Requires Astral Flow active. SMN main job only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ODIN
