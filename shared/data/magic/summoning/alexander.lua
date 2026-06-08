---============================================================================
--- SUMMONING DATABASE - Alexander (Light Avatar)
---============================================================================
--- Alexander summon spell and Blood Pact ability (main job only, Astral Flow).
---
--- @file alexander.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-06-08
---============================================================================

local ALEXANDER = {}

ALEXANDER.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Alexander"] = {
        description             = "Summons Alexander.",
        category                = "Avatar Summon",
        element                 = "Light",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 75,
        mp_cost                 = 7,
        restriction             = "main_job_only",
        notes                   = "Light-based special avatar. SMN main job only. Used almost exclusively for his Astral Flow Blood Pact (Perfect Defense).",
    },

}

ALEXANDER.blood_pacts = {

    --============================================================
    -- BLOOD PACT: WARD (Astral Flow)
    --============================================================

    ["Perfect Defense"] = {
        description             = "Grants party invincibility.",
        category                = "Blood Pact: Ward",
        element                 = "Light",
        avatar                  = "Alexander",
        type                    = "buff",
        level                   = 75,
        mp_cost                 = 0,
        astral_flow             = true,
        restriction             = "two_hour",
        notes                   = "Astral Flow ability. Grants party-wide damage immunity for a short duration (scales with summon duration). MP: 0. Requires Astral Flow active. SMN main job only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ALEXANDER
