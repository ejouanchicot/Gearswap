---============================================================================
--- SMN Avatars - Full Avatar Summon Data
---============================================================================
--- Contains all 14 full avatars (quest-based summons)
--- @file internal/smn/avatars.lua
--- @author Tetsouo
---============================================================================
local avatars = {}

---============================================================================
--- SUMMONS - AVATARS (Full Avatars)
---============================================================================

avatars.avatars = {
    ["Carbuncle"] = {
        element = "Light",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Cait Sith"] = {
        element = "Light",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Ifrit"] = {
        element = "Fire",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Shiva"] = {
        element = "Ice",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Garuda"] = {
        element = "Wind",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Titan"] = {
        element = "Earth",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Ramuh"] = {
        element = "Thunder",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Leviathan"] = {
        element = "Water",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Fenrir"] = {
        element = "Dark",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Diabolos"] = {
        element = "Dark",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Siren"] = {
        element = "Wind",
        type = "Avatar",
        restriction = nil,
        SMN = 1
    },
    ["Atomos"] = {
        element = "Dark",
        type = "Avatar",
        restriction = "main_job_only",
        SMN = 75
    },
    ["Alexander"] = {
        element = "Light",
        type = "Avatar",
        restriction = "main_job_only",
        SMN = 75
    },
    ["Odin"] = {
        element = "Dark",
        type = "Avatar",
        restriction = "main_job_only",
        SMN = 75
    }
}

return avatars
