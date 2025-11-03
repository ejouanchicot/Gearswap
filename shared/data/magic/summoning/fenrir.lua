---============================================================================
--- SUMMONING DATABASE - Fenrir (Dark Avatar)
---============================================================================
--- Fenrir summon spell and Blood Pact abilities
---
--- @file fenrir.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local FENRIR = {}

FENRIR.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Fenrir"] = {
        description = "Summons Fenrir.",
        category = "Avatar Summon",
        element = "Dark",
        magic_type = "Summoning",
        type = "summon",
        SMN = 1,
        mp_cost = 7,
        notes = "Dark-based avatar. MP cost: 7. Perpetuation: 2 MP/3s. Specializes in physical attacks with additional effects (Eclipse Bite, Howling Moon) and unique buffs/debuffs. Quest required. SMN (subjob OK).",
    },

}

FENRIR.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Moonlit Charge"] = {
        description = "Deals physical dmg + blindness.",
        category = "Blood Pact: Rage",
        element = "Dark",
        avatar = "Fenrir",
        type = "physical",
        damage_type = "Blunt",
        level = 5,
        mp_cost = 11,
        skillchain = "Impaction",
        notes = "Physical blunt damage with blindness effect. MP: 11. Recast: Instant. Damage: Pet STR. Inflicts Blind. Single target. SMN (subjob OK).",
    },

    ["Crescent Fang"] = {
        description = "Deals 3-fold physical dmg + paralyze.",
        category = "Blood Pact: Rage",
        element = "Dark",
        avatar = "Fenrir",
        type = "physical",
        damage_type = "Piercing",
        level = 10,
        mp_cost = 24,
        skillchain = "Gravitation",
        notes = "Triple-hit physical piercing damage with paralysis. MP: 24. Recast: Instant. Damage: Pet STR (×3 hits). Inflicts Paralysis. Single target. SMN (subjob OK).",
    },

    ["Eclipse Bite"] = {
        description = "Deals physical dmg + blindness.",
        category = "Blood Pact: Rage",
        element = "Dark",
        avatar = "Fenrir",
        type = "physical",
        damage_type = "Slashing",
        level = 65,
        mp_cost = 118,
        skillchain = "Umbra",
        notes = "Enhanced physical slashing damage with blindness. MP: 118. Recast: Instant. Damage: Pet STR + INT. Inflicts Blind. Single target. SMN (subjob OK).",
    },

    ["Lunar Bay"] = {
        description = "Deals dark damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Dark",
        avatar = "Fenrir",
        type = "magical",
        level = 78,
        mp_cost = 174,
        notes = "Dark-based magical AoE damage. MP: 174. Recast: Instant. Damage: Pet MAB + level. AoE range. SMN (subjob OK).",
    },

    ["Impact"] = {
        description = "Deals dark damage + stat down (AoE).",
        category = "Blood Pact: Rage",
        element = "Dark",
        avatar = "Fenrir",
        type = "magical",
        level = 99,
        mp_cost = 200,
        notes = "Enhanced dark-based magical AoE damage. MP: 200. Recast: Instant. Damage: Pet MAB + level. Reduces enemy attributes. AoE range. SMN (subjob OK).",
    },

    ["Howling Moon"] = {
        description = "Deals dark damage (AoE).",
        category = "Blood Pact: Rage",
        element = "Dark",
        avatar = "Fenrir",
        type = "magical",
        level = 1,
        mp_cost = 0,
        astral_flow = true,
        notes = "Ultimate dark-based magical AoE damage. MP: 0. Recast: N/A. Only available during Astral Flow. Extreme damage. Wide AoE range. SMN (subjob OK).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs/Debuffs)
    --============================================================

    ["Lunar Cry"] = {
        description = "Lowers accuracy + evasion (AoE).",
        category = "Blood Pact: Ward",
        element = "Dark",
        avatar = "Fenrir",
        type = "debuff",
        level = 21,
        mp_cost = 47,
        notes = "Accuracy -20, Evasion -20 to enemies. MP: 47. Recast: Instant. Duration: 90s. Range: Area effect. SMN (subjob OK).",
    },

    ["Lunar Roar"] = {
        description = "Removes beneficial effects (AoE).",
        category = "Blood Pact: Ward",
        element = "Dark",
        avatar = "Fenrir",
        type = "debuff",
        level = 32,
        mp_cost = 71,
        notes = "Dispels up to 2 beneficial effects from enemies. MP: 71. Recast: Instant. Range: Area effect. SMN (subjob OK).",
    },

    ["Ecliptic Growl"] = {
        description = "Boosts accuracy + evasion.",
        category = "Blood Pact: Ward",
        element = "Dark",
        avatar = "Fenrir",
        type = "buff",
        level = 43,
        mp_cost = 96,
        notes = "Accuracy +15%, Evasion +15%. MP: 96. Recast: Instant. Duration: 90s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Ecliptic Howl"] = {
        description = "Boosts accuracy + evasion (AoE).",
        category = "Blood Pact: Ward",
        element = "Dark",
        avatar = "Fenrir",
        type = "buff",
        level = 54,
        mp_cost = 121,
        notes = "Accuracy +20%, Evasion +20%. MP: 121. Recast: Instant. Duration: 90s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

    ["Heavenward Howl"] = {
        description = "Grants drain + aspir effect.",
        category = "Blood Pact: Ward",
        element = "Dark",
        avatar = "Fenrir",
        type = "buff",
        level = 96,
        mp_cost = 214,
        notes = "Grants party members drain/aspir effect on attacks. MP: 214. Recast: Instant. Duration: 90s. Party AoE. Range: Area effect. SMN (subjob OK).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return FENRIR
