---============================================================================
--- SONG DATABASE - Debuff Songs Module (BRD Enemy Weakening)
---============================================================================
--- Songs that debuff and damage enemies (32 total)
---
--- @file shared/data/magic/song/song_debuffs.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local SONG_DEBUFFS = {}

SONG_DEBUFFS.spells = {

    --============================================================
    -- REQUIEMS (Sonic Damage)
    --============================================================

    ["Foe Requiem"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 7,
        notes                   = "Light-based DoT on an enemy: 2 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD (subjob OK).",
    },

    ["Foe Requiem II"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 17,
        notes                   = "Light-based DoT on an enemy: 3 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD (subjob OK).",
    },

    ["Foe Requiem III"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "III",
        BRD                     = 37,
        notes                   = "Light-based DoT on an enemy: 4 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD (subjob OK).",
    },

    ["Foe Requiem IV"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "IV",
        BRD                     = 47,
        notes                   = "Light-based DoT on an enemy: 5 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD (subjob OK).",
    },

    ["Foe Requiem V"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "V",
        BRD                     = 57,
        subjob_master_only      = true,
        notes                   = "Light-based DoT on an enemy: 6 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD (subjob master OK).",
    },

    ["Foe Requiem VI"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "VI",
        BRD                     = 67,
        main_job_only           = true,
        notes                   = "Light-based DoT on an enemy: 7 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD-only (main job).",
    },

    ["Foe Requiem VII"] = {
        description             = "Deals damage.",
        category                = "Requiem",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "VII",
        BRD                     = 76,
        main_job_only           = true,
        notes                   = "Light-based DoT on an enemy: 8 HP/tick base cap (before Requiem gear; Requiem job points add +3 HP DoT per level). Duration varies. BRD-only (main job).",
    },

    --============================================================
    -- THRENODIES (Elemental Resistance Down)
    --============================================================

    ["Light Threnody"] = {
        description             = "Lowers resistance against Light.",
        category                = "Threnody",
        element                 = "Dark",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Light",
        tier                    = "I",
        BRD                     = 10,
        notes                   = "Light magic evasion -50 (base, before Threnody gear). Duration: 1 min. Only one Threnody at a time. BRD (subjob OK).",
    },

    ["Light Threnody II"] = {
        description             = "Lowers resistance against Light.",
        category                = "Threnody",
        element                 = "Dark",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Light",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Light magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Dark Threnody"] = {
        description             = "Lowers resistance against Dark.",
        category                = "Threnody",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Dark",
        tier                    = "I",
        BRD                     = 12,
        notes                   = "Dark resistance -50. Duration: 60s. BRD (subjob OK).",
    },

    ["Dark Threnody II"] = {
        description             = "Lowers resistance against Dark.",
        category                = "Threnody",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Dark",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Dark magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Earth Threnody"] = {
        description             = "Lowers resistance against Earth.",
        category                = "Threnody",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Earth",
        tier                    = "I",
        BRD                     = 14,
        notes                   = "Earth resistance -50. Duration: 60s. BRD (subjob OK).",
    },

    ["Earth Threnody II"] = {
        description             = "Lowers resistance against Earth.",
        category                = "Threnody",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Earth",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Earth magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Water Threnody"] = {
        description             = "Lowers resistance against Water.",
        category                = "Threnody",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Water",
        tier                    = "I",
        BRD                     = 16,
        notes                   = "Water magic evasion -50 (base, before Threnody gear). Duration: 1 min. Only one Threnody at a time. BRD (subjob OK).",
    },

    ["Water Threnody II"] = {
        description             = "Lowers resistance against Water.",
        category                = "Threnody",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Water",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Water magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Wind Threnody"] = {
        description             = "Lowers resistance against Wind.",
        category                = "Threnody",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Wind",
        tier                    = "I",
        BRD                     = 18,
        notes                   = "Wind magic evasion -50 (base, before Threnody gear). Duration: 1 min. Only one Threnody at a time. BRD (subjob OK).",
    },

    ["Wind Threnody II"] = {
        description             = "Lowers resistance against Wind.",
        category                = "Threnody",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Wind",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Wind magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Fire Threnody"] = {
        description             = "Lowers resistance against Fire.",
        category                = "Threnody",
        element                 = "Water",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Fire",
        tier                    = "I",
        BRD                     = 20,
        notes                   = "Fire resistance -50. Duration: 60s. BRD (subjob OK).",
    },

    ["Fire Threnody II"] = {
        description             = "Lowers resistance against Fire.",
        category                = "Threnody",
        element                 = "Water",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Fire",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Fire magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Ice Threnody"] = {
        description             = "Lowers resistance against Ice.",
        category                = "Threnody",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Ice",
        tier                    = "I",
        BRD                     = 22,
        notes                   = "Ice magic evasion -50 (base, before Threnody gear). Duration: 1 min. Only one Threnody at a time. BRD (subjob OK).",
    },

    ["Ice Threnody II"] = {
        description             = "Lowers resistance against Ice.",
        category                = "Threnody",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Ice",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Ice magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    ["Ltng. Threnody"] = {
        description             = "Lowers resistance against Lightning.",
        category                = "Threnody",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Lightning",
        tier                    = "I",
        BRD                     = 24,
        notes                   = "Lightning magic evasion -50 (base, before Threnody gear). Duration: 1 min. Only one Threnody at a time. BRD (subjob OK).",
    },

    ["Ltng. Threnody II"] = {
        description             = "Lowers resistance against Lightning.",
        category                = "Threnody",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Lightning",
        tier                    = "II",
        BRD                     = 100,
        job_points              = true,
        notes                   = "Lightning magic evasion -160 (base, before Threnody gear). Duration: 1.5 min. Only one Threnody at a time. BRD Job Point spell (100 JP).",
    },

    --============================================================
    -- LULLABIES (Sleep)
    --============================================================

    ["Foe Lullaby"] = {
        description             = "Puts an enemy to sleep.",
        category                = "Lullaby",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "single",
        tier                    = "I",
        BRD                     = 16,
        notes                   = "Inflicts Light-based Sleep on a single enemy. Duration: 30s base (before Lullaby gear); Singing skill has no effect. BRD (subjob OK).",
    },

    ["Foe Lullaby II"] = {
        description             = "Puts an enemy to sleep.",
        category                = "Lullaby",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "single",
        tier                    = "II",
        BRD                     = 83,
        main_job_only           = true,
        notes                   = "Inflicts Light-based Sleep on a single enemy. Duration: 60s base (before Lullaby gear); Singing skill has no effect. BRD-only (main job).",
    },

    ["Horde Lullaby"] = {
        description             = "Puts enemies to sleep.",
        category                = "Lullaby",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 27,
        notes                   = "Inflicts Light-based Sleep on enemies in an area. Duration: 30s base (before Lullaby gear). Radius: 4 yalms, up to 8 with String skill on a string instrument (wind instruments stay at 4); Singing and Wind skill have no effect. BRD (subjob OK).",
    },

    ["Horde Lullaby II"] = {
        description             = "Puts enemies to sleep.",
        category                = "Lullaby",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 92,
        main_job_only           = true,
        notes                   = "Inflicts Light-based Sleep on enemies in an area. Duration: 60s base (before Lullaby gear). Radius: 4 yalms, up to 8 with String skill on a string instrument (wind instruments stay at 4); Singing and Wind skill have no effect. BRD-only (main job).",
    },

    --============================================================
    -- ELEGIES (Attack Speed Down)
    --============================================================

    ["Battlefield Elegy"] = {
        description             = "Lowers attack speed.",
        category                = "Elegy",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 39,
        notes                   = "Slow effect: Attack speed -25%. BRD (subjob OK).",
    },

    ["Carnage Elegy"] = {
        description             = "Lowers attack speed.",
        category                = "Elegy",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 59,
        subjob_master_only      = true,
        notes                   = "Enhanced Slow effect: Attack speed -50%. BRD (subjob master OK).",
    },

    --============================================================
    -- SPECIAL DEBUFFS
    --============================================================

    ["Magic Finale"] = {
        description             = "Removes one beneficial magic effect from an enemy.",
        category                = "Special",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "single",
        effect                  = "Dispel",
        BRD                     = 33,
        notes                   = "Dispels one beneficial magic effect from an enemy (similar to Dispel). Built-in +175 magic accuracy. Single target. BRD (subjob OK).",
    },

    ["Maiden's Virelai"] = {
        description             = "Charms an enemy.",
        category                = "Special",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "single",
        effect                  = "Charm",
        BRD                     = 75,
        main_job_only           = true,
        notes                   = "Inflicts Charm (the enemy attacks what you attack; it cannot be ordered). Duration: 30s base (Virelai gear +10% each; Song duration gear has no effect). Removes shadows even when the charm fails. Cast 4s, recast 1 min; range depends on the instrument. Single target. BRD-only (main job).",
    },

    ["Pining Nocturne"] = {
        description             = "Lowers magic accuracy, Raises cast time.",
        category                = "Nocturne",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Magic Accuracy Down + Cast Time Up",
        BRD                     = 95,
        main_job_only           = true,
        notes                   = "Addle effect: enemy magic accuracy -15 and casting time +15% (base, before Song+ gear). Duration: 2-4 min. Does not overwrite Addle and is overwritten by it. BRD-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SONG_DEBUFFS
