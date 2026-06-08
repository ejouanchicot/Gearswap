---============================================================================
--- NINJUTSU DATABASE - Buffs Module
---============================================================================
--- Self-target Ninjutsu buffs (11 total).
--- Data source: bg-wiki.com (individual spell pages).
---
--- Contents:
---   - Tonko: Ichi/Ni (Invisible)
---   - Utsusemi: Ichi/Ni/San (shadows)
---   - Monomi: Ichi (Sneak)
---   - Myoshu: Ichi (Subtle Blow), Migawari: Ichi (damage negation)
---   - Gekka/Yain: Ichi (enmity +/-), Kakka: Ichi (Store TP)
---
--- @file shared/data/magic/ninjutsu/ninjutsu_buffs.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-06-07
--- @source https://www.bg-wiki.com/ffxi/Category:Ninjutsu
---============================================================================

local NINJUTSU_BUFFS = {}

NINJUTSU_BUFFS.spells = {

    ["Tonko: Ichi"] = {
        description             = "Grants Invisible; lowers sight detection.",
        category                = "Ninjutsu",
        element                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 9,
        tool                    = "Shinobi-Tabi",
        notes                   = "Status Invisible (~7 min). Reduces detection by sight.",
    },

    ["Tonko: Ni"] = {
        description             = "Grants Invisible; lowers sight detection.",
        category                = "Ninjutsu",
        element                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 34,
        tool                    = "Shinobi-Tabi",
        notes                   = "Status Invisible (~10 min). Longer duration than Tonko: Ichi.",
    },

    ["Utsusemi: Ichi"] = {
        description             = "Creates 3 shadows that absorb attacks.",
        category                = "Ninjutsu",
        element                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 12,
        tool                    = "Shihei",
        notes                   = "Copy Image +3. Each shadow absorbs one melee hit or single-target spell. Overwritten by Utsusemi: Ni.",
    },

    ["Utsusemi: Ni"] = {
        description             = "Creates 4 shadows that absorb attacks.",
        category                = "Ninjutsu",
        element                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 37,
        tool                    = "Shihei",
        notes                   = "Copy Image +4 (4 shadows main job, 3 as subjob). Fast cast. Overwrites Utsusemi: Ichi and itself.",
    },

    ["Utsusemi: San"] = {
        description             = "Creates 5 shadows that absorb attacks.",
        category                = "Ninjutsu",
        element                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 100,
        tool                    = "Shihei",
        notes                   = "Copy Image +5. Job Point Gift (NIN Lv.100). Overwrites Utsusemi: Ichi, Ni and itself.",
    },

    ["Monomi: Ichi"] = {
        description             = "Grants Sneak; lowers sound detection.",
        category                = "Ninjutsu",
        element                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 25,
        tool                    = "Sanjaku-Tenugui",
        notes                   = "Status Sneak (~7 min). Reduces detection by sound.",
    },

    ["Myoshu: Ichi"] = {
        description             = "Grants Subtle Blow +10.",
        category                = "Ninjutsu",
        element                 = "Light",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 85,
        tool                    = "Kabenro",
        notes                   = "Subtle Blow +10 (subject to the +50 Subtle Blow cap). NIN-only.",
    },

    ["Migawari: Ichi"] = {
        description             = "Negates the next severe hit.",
        category                = "Ninjutsu",
        element                 = "Earth",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 88,
        tool                    = "Mokujin",
        notes                   = "Nullifies the next hit exceeding a % of max HP, then expires. Threshold scales with Ninjutsu skill. NIN-only.",
    },

    ["Gekka: Ichi"] = {
        description             = "Enmity +30.",
        category                = "Ninjutsu",
        element                 = "Dark",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 88,
        tool                    = "Ranka",
        notes                   = "Enmity +30. NIN-only.",
    },

    ["Yain: Ichi"] = {
        description             = "Enmity -15.",
        category                = "Ninjutsu",
        element                 = "Light",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 91,
        tool                    = "Furusumi",
        notes                   = "Enmity -15. NIN-only.",
    },

    ["Kakka: Ichi"] = {
        description             = "Store TP +10.",
        category                = "Ninjutsu",
        element                 = "Light",
        magic_type              = "Ninjutsu",
        type                    = "self",
        tier                    = "I",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 93,
        tool                    = "Ryuno",
        notes                   = "Store TP +10. NIN-only.",
    },

}

return NINJUTSU_BUFFS
