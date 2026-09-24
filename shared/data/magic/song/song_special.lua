---============================================================================
--- SONG DATABASE - Special Songs Module (BRD Unique Utility)
---============================================================================
--- Specialized songs with unique utility effects (2 total)
---
--- @file shared/data/magic/song/song_special.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local SONG_SPECIAL = {}

SONG_SPECIAL.spells = {

    --============================================================
    -- MAZURKAS (Movement Speed)
    --============================================================

    ["Raptor Mazurka"] = {
        description             = "Raises movement speed.",
        category                = "Mazurka",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Movement Speed +10%",
        BRD                     = 37,
        notes                   = "Movement speed +10%. BRD (subjob OK).",
    },

    ["Chocobo Mazurka"] = {
        description             = "Raises movement speed.",
        category                = "Mazurka",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Movement Speed +20%",
        BRD                     = 73,
        main_job_only           = true,
        notes                   = "Movement speed +20%. BRD-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SONG_SPECIAL
