---============================================================================
--- SONG DATABASE - Special Songs Module (BRD Unique Utility)
---============================================================================
--- Specialized songs with unique utility effects (2 total)
---
--- @file song_special.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local SONG_SPECIAL = {}

SONG_SPECIAL.spells = {

    --============================================================
    -- MAZURKAS (Movement Speed)
    --============================================================

    ["Raptor Mazurka"] = {
        description = "Raises movement speed.",
        category = "Mazurka",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        effect = "Movement Speed +10%",
        BRD = 37,
        notes = "Movement speed +10%. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Chocobo Mazurka"] = {
        description = "Raises movement speed.",
        category = "Mazurka",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        effect = "Movement Speed +20%",
        BRD = 73,
        main_job_only = true,
        notes = "Movement speed +20%. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SONG_SPECIAL
