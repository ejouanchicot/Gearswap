---============================================================================
--- SUMMONING DATABASE - Fenrir (Dark Avatar)
---============================================================================
--- Fenrir summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/fenrir.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local FENRIR = {}

FENRIR.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Fenrir"] = {
        description             = "Summons Fenrir.",
        category                = "Avatar Summon",
        element                 = "Dark",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 15,
        notes                   = "Dark-based avatar. MP cost: 15. Moon-phase Blood Pacts (Ecliptic Growl, Ecliptic Howl, Lunar Cry, Heavenward Howl) and physical pacts with added effects (Moonlit Charge, Crescent Fang). Obtained from the quest The Moonlit Path. SMN (subjob OK).",
    },

}

FENRIR.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Moonlit Charge"] = {
        description             = "Deals physical dmg + blindness.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 5,
        mp_cost                 = 17,
        skillchain              = "Compression",
        notes                   = "Physical blunt damage + Blind. MP: 17. Stat: Pet VIT. Accuracy bonus varies with TP. SMN (subjob OK).",
    },

    ["Crescent Fang"] = {
        description             = "Deals physical dmg + paralyze.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "physical",
        damage_type             = "Piercing",
        level                   = 10,
        mp_cost                 = 19,
        skillchain              = "Transfixion",
        notes                   = "Physical piercing damage + Paralysis. MP: 19. Stat: Pet STR. Damage varies with TP. SMN (subjob OK).",
    },

    ["Eclipse Bite"] = {
        description             = "Deals 3-fold physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "physical",
        damage_type             = "Slashing",
        level                   = 65,
        mp_cost                 = 109,
        skillchain              = "Gravitation/Scission",
        notes                   = "Three-hit physical slashing attack. MP: 109. Stat: Pet DEX. Damage varies with TP (fTP carries to all hits). SMN (main job only).",
    },

    ["Lunar Bay"] = {
        description             = "Deals dark dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "magical",
        level                   = 78,
        mp_cost                 = 174,
        notes                   = "Dark-based magical damage to one enemy. Stat: Pet INT. MP: 174. SMN (main job only).",
    },

    ["Impact"] = {
        description             = "Deals dark damage + stat down (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "magical",
        level                   = 99,
        mp_cost                 = 222,
        notes                   = "Enhanced dark-based magical AoE damage. MP: 222. Damage: Pet MAB + level. Reduces enemy attributes. AoE range. SMN (subjob OK).",
    },

    ["Howling Moon"] = {
        description             = "Deals dark damage (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Astral Flow ability. Darkness damage to enemies in range. Requires MP of at least caster's level x2. Stat: Pet INT. Uses all MP (Astral Flow). SMN (main job only).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs/Debuffs)
    --============================================================

    ["Lunar Cry"] = {
        description             = "Lowers accuracy + evasion.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "debuff",
        level                   = 21,
        mp_cost                 = 41,
        notes                   = "Lowers the target's Accuracy and Evasion by moon phase: Full Moon Accuracy -31, New Moon Evasion -31 (-16/-16 at 50%). MP: 41. SMN (subjob OK).",
    },

    ["Lunar Roar"] = {
        description             = "Removes beneficial effects (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "debuff",
        level                   = 32,
        mp_cost                 = 27,
        notes                   = "Removes two beneficial magic effects from enemies in range. MP: 27. Range: 10'. SMN (subjob OK).",
    },

    ["Ecliptic Growl"] = {
        description             = "Boosts attributes (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "buff",
        level                   = 43,
        mp_cost                 = 46,
        notes                   = "Attributes +1 to +7 depending on moon phase, for party members in range. Not overwritten by Glittering Ruby. MP: 46. Duration: 180s. SMN (subjob OK).",
    },

    ["Ecliptic Howl"] = {
        description             = "Boosts accuracy + evasion (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "buff",
        level                   = 54,
        mp_cost                 = 57,
        notes                   = "Accuracy + Evasion boost for party members in range: +26 total split by moon phase (Full Moon mostly accuracy, New Moon mostly evasion; +1 to +25 each). MP: 57. Duration: 180s. SMN (subjob OK).",
    },

    ["Heavenward Howl"] = {
        description             = "Grants Endrain or Enaspir (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Fenrir",
        type                    = "buff",
        level                   = 96,
        mp_cost                 = 96,
        notes                   = "Grants party members in range Endrain (5-15%) or Enaspir (1-5%) depending on moon phase. MP: 96. Duration: 60s. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return FENRIR
