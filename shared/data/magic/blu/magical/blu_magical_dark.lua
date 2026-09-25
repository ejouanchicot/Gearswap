---============================================================================
--- BLUE MAGIC DATABASE - Magical Dark Spells
---============================================================================
--- Dark-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_dark.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_DARK = {}

BLU_MAGICAL_DARK.spells = {

    ["Blood Drain"] = {
        description             = "Steals HP from enemy.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 20,
        mp_cost                 = 10,
        notes                   = "Dark-based magical HP drain. MP: 10. Level: 20. Trait: None. HP drained = Blue Magic Skill x 0.33, not modified by INT. Ineffective against undead. Single target. BLU only.",
    },

    ["Death Ray"] = {
        description             = "Deals dark dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 34,
        mp_cost                 = 49,
        notes                   = "Dark-based magical damage. MP: 49. Level: 34. Trait: None. Single target. BLU only.",
    },

    ["Digest"] = {
        description             = "Steals HP from enemy.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 36,
        mp_cost                 = 20,
        notes                   = "Dark-based magical HP drain. MP: 20. Level: 36. Trait: None. HP drained = Blue Magic Skill x 0.55. Ineffective against undead. Single target. BLU only.",
    },

    ["MP Drainkiss"] = {
        description             = "Steals MP from enemy.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 42,
        mp_cost                 = 20,
        notes                   = "Dark-based magical MP drain. MP: 20. Level: 42. Trait: None. Soft cap 165 MP before Magic Burst/day/weather/affinity; not enhanced by Magic Attack Bonus. Ineffective against undead. Single target. BLU only.",
    },

    ["Blood Saber"] = {
        description             = "Steals HP (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 48,
        mp_cost                 = 48,
        notes                   = "Dark-based magical HP drain (AoE). Level: 48. Trait: None. HP drained = (Blue Magic Skill x 0.11) x 3.5. Ineffective against undead. BLU only.",
    },

    ["Eyes On Me"] = {
        description             = "Deals dark dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 61,
        mp_cost                 = 112,
        notes                   = "Dark-based magical damage. MP: 112. Level: 61. Trait: Magic Attack Bonus. Ignores Copy Image. Recast: 29.25s. Single target. BLU only.",
    },

    ["Osmosis"] = {
        description             = "Steals one buff + drain.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Magic Defense Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 84,
        mp_cost                 = 47,
        notes                   = "Dark-based magical HP drain + buff steal. MP: 47. Level: 84. Trait: Magic Defense Bonus. Steals one beneficial status effect (cannot miss). HP drained = (Blue Magic Skill x 0.11) x 7. Ineffective against undead. Recast: 120s. Single target. BLU only.",
    },

    ["Evryone. Grudge"] = {
        description             = "Deals dark dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        unbridled               = false,
        BLU                     = 90,
        mp_cost                 = 185,
        notes                   = "Dark-based magical damage. MP: 185. Level: 90. Trait: Gilfinder/Treasure Hunter. Single target. BLU only.",
    },

    ["Dark Orb"] = {
        description             = "Deals dark dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Counter",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 93,
        mp_cost                 = 124,
        notes                   = "Dark-based magical damage. MP: 124. Level: 93. Trait: Counter. Single target. BLU only.",
    },

    ["Atra. Libations"] = {
        description             = "Steals HP (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 164,
        notes                   = "Dark-based magical HP drain (AoE). MP: 164. Level: 99. Trait: Defense Bonus. HP drained = (Blue Magic Skill x 0.11) x 9. Not enhanced by Drain Potency gear. Ineffective against undead. Recast: 180s. BLU only.",
    },

    ["Tenebral Crush"] = {
        description             = "Deals dark dmg + defense down.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Magic Accuracy Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Dark-based magical damage + Defense Down (AoE). MP: 116. Level: 99. Trait: Magic Accuracy Bonus. Additional effect: Defense -20% (180s, halved on NMs). Recast: 60s. Range: ~10'. BLU only.",
    },

    ["Palling Salvo"] = {
        description             = "Deals dark dmg + bio.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Tenacity",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 175,
        notes                   = "Dark-based magical damage + Bio (AoE). MP: 175. Level: 99. Trait: Tenacity. Additional effect: Bio (-15 HP/tick, -10% attack, 60-90s). Recast: 45s. BLU only.",
    },

    ["Cruel Joke"] = {
        description             = "Inflicts doom (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 187,
        notes                   = "Dark-based magical doom (unbridled, AoE). MP: 187. Level: 99. Trait: None. Requires: Unbridled Learning/Wisdom. Inflicts Doom (KO after 60s). Wears off if caster moves more than 10' from the target. Does not affect NMs. Recast: 30s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_DARK

