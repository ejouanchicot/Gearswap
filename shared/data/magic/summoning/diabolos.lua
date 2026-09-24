---============================================================================
--- SUMMONING DATABASE - Diabolos (Dark Avatar)
---============================================================================
--- Diabolos summon spell and Blood Pact abilities
---
--- @file shared/data/magic/summoning/diabolos.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local DIABOLOS = {}

DIABOLOS.spells = {

    --============================================================
    -- AVATAR SUMMON
    --============================================================

    ["Diabolos"] = {
        description             = "Summons Diabolos.",
        category                = "Avatar Summon",
        element                 = "Dark",
        magic_type              = "Summoning",
        type                    = "summon",
        SMN                     = 1,
        mp_cost                 = 15,
        notes                   = "Dark-based avatar. MP cost: 15. Sleep and debuff Blood Pacts (Nightmare, Somnolence, Ultimate Terror) and darkness damage (Nether Blast, Night Terror). Obtained from the quest Waking Dreams. SMN (subjob OK).",
    },

}

DIABOLOS.blood_pacts = {

    --============================================================
    -- BLOOD PACT: RAGE (Offensive)
    --============================================================

    ["Camisado"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "physical",
        damage_type             = "Blunt",
        level                   = 1,
        mp_cost                 = 20,
        skillchain              = "Compression",
        notes                   = "Physical blunt damage. MP: 20. Stat: Pet STR + MND. Accuracy bonus varies with TP. SMN (subjob OK).",
    },

    ["Nether Blast"] = {
        description             = "Deals dark damage.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "magical",
        level                   = 65,
        mp_cost                 = 109,
        notes                   = "Darkness breath damage (ranged). Level-based: (avatar level + 2) x 5, not affected by pet TP. MP: 109. SMN (main job only).",
    },

    ["Night Terror"] = {
        description             = "Deals dark dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "magical",
        level                   = 80,
        mp_cost                 = 177,
        notes                   = "Dark-based magical damage to one enemy. Stat: Pet INT. +40% damage to sleeping targets. MP: 177. SMN (main job only).",
    },

    ["Blindside"] = {
        description             = "Deals physical dmg.",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "physical",
        damage_type             = "Slashing",
        level                   = 99,
        mp_cost                 = 147,
        skillchain              = "Gravitation/Transfixion",
        notes                   = "Physical slashing damage. MP: 147. Stat: Pet STR + MND. Damage varies with TP. SMN (main job only).",
    },

    ["Ruinous Omen"] = {
        description             = "Cuts enemy HP by a random % (AoE).",
        category                = "Blood Pact: Rage",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "magical",
        level                   = 1,
        mp_cost                 = 0,
        astral_flow             = true,
        notes                   = "Astral Flow ability. Reduces the HP of enemies in range by a random percentage (caps around 10% on NMs). Requires MP of at least caster's level x2. Uses all MP (Astral Flow). SMN (main job only).",
    },

    --============================================================
    -- BLOOD PACT: WARD (Support/Buffs/Debuffs)
    --============================================================

    ["Somnolence"] = {
        description             = "Deals dark dmg + weight.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 20,
        mp_cost                 = 30,
        notes                   = "Inflicts Weight on the target (about -26% movement speed, same as Gravity) and deals magical dark damage. MP: 30. SMN (subjob OK).",
    },

    ["Nightmare"] = {
        description             = "Inflicts sleep + bio dmg (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 29,
        mp_cost                 = 42,
        notes                   = "Sleep + Bio (2 HP/tick) on enemies in range. MP: 42. Duration: 90s (unresisted). Range: 10'. SMN (subjob OK).",
    },

    ["Ultimate Terror"] = {
        description             = "Lowers attributes (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 37,
        mp_cost                 = 27,
        notes                   = "Absorbs 0-7 random attributes from each enemy in range and adds them to Diabolos. MP: 27. Range: 10' around Diabolos. SMN (subjob OK).",
    },

    ["Noctoshield"] = {
        description             = "Grants Phalanx (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "buff",
        level                   = 49,
        mp_cost                 = 92,
        notes                   = "Phalanx effect (-13 damage taken) on party members in range; overwritten by the Phalanx spells. MP: 92. Duration: 180s. SMN (subjob OK).",
    },

    ["Dream Shroud"] = {
        description             = "Boosts magic attack + magic defense (AoE).",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "buff",
        level                   = 56,
        mp_cost                 = 121,
        notes                   = "Magic Attack Bonus and Magic Defense Bonus +1 to +13 depending on time of day (MAB +13 at 0:00, MDB +13 at 12:00). MP: 121. Duration: 180s. Party AoE. SMN (subjob OK).",
    },

    ["Pavor Nocturnus"] = {
        description             = "Inflicts death or dispel.",
        category                = "Blood Pact: Ward",
        element                 = "Dark",
        avatar                  = "Diabolos",
        type                    = "debuff",
        level                   = 98,
        mp_cost                 = 246,
        notes                   = "Attempts to inflict Death on the target; if Death misses, Dispels instead. Death almost never lands unless the target is asleep; does not work on NMs. MP: 246. SMN (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DIABOLOS
