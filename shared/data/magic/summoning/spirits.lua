---============================================================================
--- SUMMONING DATABASE - Elemental Spirits
---============================================================================
--- Elemental Spirit summon spells (Light, Fire, Ice, Air, Earth, Thunder, Water, Dark)
---
--- @file spirits.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local SPIRITS = {}

SPIRITS.spells = {

    --============================================================
    -- ELEMENTAL SPIRITS
    --============================================================

    ["Light Spirit"] = {
        description = "Summons Light Spirit.",
        category = "Spirit Summon",
        element = "Light",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Light-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Apollo's -3, Light -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts light-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Fire Spirit"] = {
        description = "Summons Fire Spirit.",
        category = "Spirit Summon",
        element = "Fire",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Fire-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Vulcan's -3, Fire -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts fire-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Ice Spirit"] = {
        description = "Summons Ice Spirit.",
        category = "Spirit Summon",
        element = "Ice",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Ice-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Aquilo's -3, Ice -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts ice-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Air Spirit"] = {
        description = "Summons Air Spirit.",
        category = "Spirit Summon",
        element = "Wind",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Wind-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Auster's -3, Air -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts wind-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Earth Spirit"] = {
        description = "Summons Earth Spirit.",
        category = "Spirit Summon",
        element = "Earth",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Earth-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Terra's -3, Earth -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts earth-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Thunder Spirit"] = {
        description = "Summons Thunder Spirit.",
        category = "Spirit Summon",
        element = "Thunder",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Thunder-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Jupiter's -3, Thunder -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts thunder-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Water Spirit"] = {
        description = "Summons Water Spirit.",
        category = "Spirit Summon",
        element = "Water",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Water-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Neptune's -3, Water -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts water-element magic. No Blood Pacts. SMN (subjob OK).",
    },

    ["Dark Spirit"] = {
        description = "Summons Dark Spirit.",
        category = "Spirit Summon",
        element = "Dark",
        magic_type = "Summoning",
        type = "spirit",
        SMN = 1,
        mp_cost = 10,
        notes = "Dark-element spirit. MP cost: 10. Perpetuation: Variable (reduced by staves: Pluto's -3, Dark -2, Dragon -1, Nirvana -8). Casting: 1s. Recast: 10s. Fights by your side and casts dark-element magic. No Blood Pacts. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SPIRITS
