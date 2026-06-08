---============================================================================
--- NINJUTSU DATABASE - Elemental Nukes Module
---============================================================================
--- Enemy-target elemental Ninjutsu nukes (18 total: 6 elements x 3 tiers). Range 17'.
--- Each nuke also lowers the `weakens` element's resistance by 30.
--- Data source: bg-wiki.com (individual spell pages).
---
--- Tiers (unified): Ichi (v=28, m=0.5), Ni (v=69, m=1.0), San (v=134, m=1.5, main-only).
---   v = base value, m = dINT multiplier (damage = [v + mDMG + dINT*m] * modifiers).
---
--- Elements:
---   - Katon  (Fire,      weakens Water)
---   - Suiton (Water,     weakens Lightning)
---   - Raiton (Lightning, weakens Earth)      -- wiki shows "Thunder", stored Lightning
---   - Doton  (Earth,     weakens Wind)
---   - Huton  (Wind,      weakens Ice)
---   - Hyoton (Ice,       weakens Fire)
---
--- @file shared/data/magic/ninjutsu/ninjutsu_nukes.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-06-07
--- @source https://www.bg-wiki.com/ffxi/Category:Ninjutsu
---============================================================================

local NINJUTSU_NUKES = {}

NINJUTSU_NUKES.spells = {

    -- Katon (Fire, weakens Water)
    ["Katon: Ichi"] = {
        description             = "Fire damage; lowers Water resistance.",
        category                = "Ninjutsu",
        element                 = "Fire",
        weakens                 = "Water",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 15,
        tool                    = "Uchitake",
        v                       = 28,
        m                       = 0.5,
    },
    ["Katon: Ni"] = {
        description             = "Fire damage; lowers Water resistance.",
        category                = "Ninjutsu",
        element                 = "Fire",
        weakens                 = "Water",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 40,
        tool                    = "Uchitake",
        v                       = 69,
        m                       = 1.0,
    },
    ["Katon: San"] = {
        description             = "Fire damage; lowers Water resistance.",
        category                = "Ninjutsu",
        element                 = "Fire",
        weakens                 = "Water",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 75,
        tool                    = "Uchitake",
        v                       = 134,
        m                       = 1.5,
    },

    -- Suiton (Water, weakens Lightning)
    ["Suiton: Ichi"] = {
        description             = "Water damage; lowers Lightning resistance.",
        category                = "Ninjutsu",
        element                 = "Water",
        weakens                 = "Lightning",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 15,
        tool                    = "Mizu-Deppo",
        v                       = 28,
        m                       = 0.5,
    },
    ["Suiton: Ni"] = {
        description             = "Water damage; lowers Lightning resistance.",
        category                = "Ninjutsu",
        element                 = "Water",
        weakens                 = "Lightning",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 40,
        tool                    = "Mizu-Deppo",
        v                       = 69,
        m                       = 1.0,
    },
    ["Suiton: San"] = {
        description             = "Water damage; lowers Lightning resistance.",
        category                = "Ninjutsu",
        element                 = "Water",
        weakens                 = "Lightning",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 75,
        tool                    = "Mizu-Deppo",
        v                       = 134,
        m                       = 1.5,
    },

    -- Raiton (Lightning, weakens Earth) -- wiki shows "Thunder", stored Lightning
    ["Raiton: Ichi"] = {
        description             = "Lightning damage; lowers Earth resistance.",
        category                = "Ninjutsu",
        element                 = "Lightning",
        weakens                 = "Earth",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 15,
        tool                    = "Hiraishin",
        v                       = 28,
        m                       = 0.5,
    },
    ["Raiton: Ni"] = {
        description             = "Lightning damage; lowers Earth resistance.",
        category                = "Ninjutsu",
        element                 = "Lightning",
        weakens                 = "Earth",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 40,
        tool                    = "Hiraishin",
        v                       = 69,
        m                       = 1.0,
    },
    ["Raiton: San"] = {
        description             = "Lightning damage; lowers Earth resistance.",
        category                = "Ninjutsu",
        element                 = "Lightning",
        weakens                 = "Earth",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 75,
        tool                    = "Hiraishin",
        v                       = 134,
        m                       = 1.5,
    },

    -- Doton (Earth, weakens Wind)
    ["Doton: Ichi"] = {
        description             = "Earth damage; lowers Wind resistance.",
        category                = "Ninjutsu",
        element                 = "Earth",
        weakens                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 15,
        tool                    = "Makibishi",
        v                       = 28,
        m                       = 0.5,
    },
    ["Doton: Ni"] = {
        description             = "Earth damage; lowers Wind resistance.",
        category                = "Ninjutsu",
        element                 = "Earth",
        weakens                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 40,
        tool                    = "Makibishi",
        v                       = 69,
        m                       = 1.0,
    },
    ["Doton: San"] = {
        description             = "Earth damage; lowers Wind resistance.",
        category                = "Ninjutsu",
        element                 = "Earth",
        weakens                 = "Wind",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 75,
        tool                    = "Makibishi",
        v                       = 134,
        m                       = 1.5,
    },

    -- Huton (Wind, weakens Ice)
    ["Huton: Ichi"] = {
        description             = "Wind damage; lowers Ice resistance.",
        category                = "Ninjutsu",
        element                 = "Wind",
        weakens                 = "Ice",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 15,
        tool                    = "Kawahori-Ogi",
        v                       = 28,
        m                       = 0.5,
    },
    ["Huton: Ni"] = {
        description             = "Wind damage; lowers Ice resistance.",
        category                = "Ninjutsu",
        element                 = "Wind",
        weakens                 = "Ice",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 40,
        tool                    = "Kawahori-Ogi",
        v                       = 69,
        m                       = 1.0,
    },
    ["Huton: San"] = {
        description             = "Wind damage; lowers Ice resistance.",
        category                = "Ninjutsu",
        element                 = "Wind",
        weakens                 = "Ice",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 75,
        tool                    = "Kawahori-Ogi",
        v                       = 134,
        m                       = 1.5,
    },

    -- Hyoton (Ice, weakens Fire)
    ["Hyoton: Ichi"] = {
        description             = "Ice damage; lowers Fire resistance.",
        category                = "Ninjutsu",
        element                 = "Ice",
        weakens                 = "Fire",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "I",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 15,
        tool                    = "Tsurara",
        v                       = 28,
        m                       = 0.5,
    },
    ["Hyoton: Ni"] = {
        description             = "Ice damage; lowers Fire resistance.",
        category                = "Ninjutsu",
        element                 = "Ice",
        weakens                 = "Fire",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "II",
        main_job_only           = false,
        subjob_master_only      = false,
        NIN                     = 40,
        tool                    = "Tsurara",
        v                       = 69,
        m                       = 1.0,
    },
    ["Hyoton: San"] = {
        description             = "Ice damage; lowers Fire resistance.",
        category                = "Ninjutsu",
        element                 = "Ice",
        weakens                 = "Fire",
        magic_type              = "Ninjutsu",
        type                    = "single",
        tier                    = "III",
        main_job_only           = true,
        subjob_master_only      = false,
        NIN                     = 75,
        tool                    = "Tsurara",
        v                       = 134,
        m                       = 1.5,
    },

}

return NINJUTSU_NUKES
