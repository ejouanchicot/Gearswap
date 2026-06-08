---============================================================================
--- NINJUTSU DATABASE - Debuffs Module
---============================================================================
--- Enemy-target Ninjutsu debuffs (8 total). Range 17'.
--- Static potency while the spell lands; higher tier = stronger + faster cast.
--- Data source: bg-wiki.com (individual spell pages).
---
--- Contents:
---   - Kurayami: Ichi/Ni (Blind)
---   - Hojo: Ichi/Ni (Slow)
---   - Dokumori: Ichi (Poison), Jubaku: Ichi (Paralysis)
---   - Aisha: Ichi (Attack down), Yurin: Ichi (Inhibit TP)
---
--- Note: Jubaku: Ni is mob-only (not player-castable, excluded).
---
--- @file shared/data/magic/ninjutsu/ninjutsu_debuffs.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-06-07
--- @source https://www.bg-wiki.com/ffxi/Category:Ninjutsu
---============================================================================

local NINJUTSU_DEBUFFS = {}

NINJUTSU_DEBUFFS.spells = {

    ["Kurayami: Ichi"] = {
        description             = "Blind; lowers target accuracy.",
        category                = "Ninjutsu",
        element                 = "Dark",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 19,
        tool                    = "Sairui-Ran",
        notes                   = "Blind: target Accuracy -20.",
    },

    ["Kurayami: Ni"] = {
        description             = "Blind; lowers target accuracy.",
        category                = "Ninjutsu",
        element                 = "Dark",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 44,
        tool                    = "Sairui-Ran",
        notes                   = "Blind: target Accuracy -30. Overwrites Kurayami: Ichi and Blind.",
    },

    ["Hojo: Ichi"] = {
        description             = "Slow; lowers target attack speed.",
        category                = "Ninjutsu",
        element                 = "Earth",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 23,
        tool                    = "Kaginawa",
        notes                   = "Static Slow 15% (150/1024).",
    },

    ["Hojo: Ni"] = {
        description             = "Slow; lowers target attack speed.",
        category                = "Ninjutsu",
        element                 = "Earth",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 48,
        tool                    = "Kaginawa",
        notes                   = "Static Slow 20% (200/1024).",
    },

    ["Dokumori: Ichi"] = {
        description             = "Poison damage over time.",
        category                = "Ninjutsu",
        element                 = "Water",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 27,
        tool                    = "Kodoku",
        notes                   = "Poison DoT (3 dmg/tick, ~1 min).",
    },

    ["Jubaku: Ichi"] = {
        description             = "Paralysis.",
        category                = "Ninjutsu",
        element                 = "Ice",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 30,
        tool                    = "Jusatsu",
        notes                   = "Paralysis (~20% proc). Only Jubaku tier obtainable by players (Jubaku: Ni is mob-only).",
    },

    ["Aisha: Ichi"] = {
        description             = "Attack -15%.",
        category                = "Ninjutsu",
        element                 = "Water",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 78,
        tool                    = "Soshi",
        notes                   = "Target Attack -15%. NIN-only.",
    },

    ["Yurin: Ichi"] = {
        description             = "Inhibit TP; lowers target TP gain.",
        category                = "Ninjutsu",
        element                 = "Dark",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 83,
        tool                    = "Jinko",
        notes                   = "Inhibit TP 10%. Applied separately from Subtle Blow (uncapped). NIN-only.",
    },

}

return NINJUTSU_DEBUFFS
