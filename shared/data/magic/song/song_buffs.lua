---============================================================================
--- BARD SONGS DATABASE - Buff Songs Module
---============================================================================
--- Party support songs (73 total)
---
--- @file shared/data/magic/song/song_buffs.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
---============================================================================

local SONG_BUFFS = {}

SONG_BUFFS.spells = {

    --============================================================
    -- MINUETS (Attack Boost)
    --============================================================

    ["Valor Minuet"] = {
        description             = "Boosts attack.",
        category                = "Minuet",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 3,
        notes                   = "Attack and Ranged Attack +32 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Valor Minuet II"] = {
        description             = "Boosts attack.",
        category                = "Minuet",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 23,
        notes                   = "Attack and Ranged Attack +64 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Valor Minuet III"] = {
        description             = "Boosts attack.",
        category                = "Minuet",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "III",
        BRD                     = 43,
        notes                   = "Attack and Ranged Attack +96 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Valor Minuet IV"] = {
        description             = "Boosts attack.",
        category                = "Minuet",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "IV",
        BRD                     = 63,
        main_job_only           = true,
        notes                   = "Attack and Ranged Attack +112 (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },
    ["Valor Minuet V"] = {
        description             = "Boosts attack.",
        category                = "Minuet",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "V",
        BRD                     = 87,
        main_job_only           = true,
        notes                   = "Attack and Ranged Attack +124 (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- PAEONS (HP Regen)
    --============================================================

    ["Army's Paeon"] = {
        description             = "Restores HP.",
        category                = "Paeon",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 5,
        notes                   = "HP +2/tick (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Army's Paeon II"] = {
        description             = "Restores HP.",
        category                = "Paeon",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 15,
        notes                   = "HP +3/tick (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Army's Paeon III"] = {
        description             = "Restores HP.",
        category                = "Paeon",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "III",
        BRD                     = 35,
        notes                   = "HP +4/tick (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Army's Paeon IV"] = {
        description             = "Restores HP.",
        category                = "Paeon",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "IV",
        BRD                     = 45,
        notes                   = "HP +5/tick (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Army's Paeon V"] = {
        description             = "Restores HP.",
        category                = "Paeon",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "V",
        BRD                     = 65,
        main_job_only           = true,
        notes                   = "HP +7/tick (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },
    ["Army's Paeon VI"] = {
        description             = "Restores HP.",
        category                = "Paeon",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "VI",
        BRD                     = 78,
        main_job_only           = true,
        notes                   = "HP +8/tick (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- MARCHES (Haste)
    --============================================================

    ["Advancing March"] = {
        description             = "Boosts attack speed.",
        category                = "March",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 29,
        notes                   = "Haste +10.55% (base, 108/1024). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Victory March"] = {
        description             = "Boosts attack speed.",
        category                = "March",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 60,
        main_job_only           = true,
        notes                   = "Haste +15.92% (base, 163/1024). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },
    ["Honor March"] = {
        description             = "Boosts attack speed, attack and accuracy.",
        category                = "March",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "III",
        BRD                     = 99,
        main_job_only           = true,
        master_level            = true,
        notes                   = "Haste +12.3%, Attack and Ranged Attack +168, Accuracy and Ranged Accuracy +42 (base, Marsyas only). Requires Marsyas equipped. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- MADRIGALS (Accuracy)
    --============================================================

    ["Sword Madrigal"] = {
        description             = "Boosts melee accuracy.",
        category                = "Madrigal",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 11,
        notes                   = "Accuracy +45 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Blade Madrigal"] = {
        description             = "Boosts melee accuracy.",
        category                = "Madrigal",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 51,
        subjob_master_only      = true,
        notes                   = "Accuracy +60 (base). Duration: 2 min base (song gear extends). BRD-only (subjob master OK).",
    },

    --============================================================
    -- BALLADS (MP Regen)
    --============================================================

    ["Mage's Ballad"] = {
        description             = "Restores MP.",
        category                = "Ballad",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 25,
        notes                   = "MP +1/tick (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Mage's Ballad II"] = {
        description             = "Restores MP.",
        category                = "Ballad",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 55,
        subjob_master_only      = true,
        notes                   = "MP +2/tick (base). Duration: 2 min base (song gear extends). BRD-only (subjob master OK).",
    },
    ["Mage's Ballad III"] = {
        description             = "Restores MP.",
        category                = "Ballad",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "III",
        BRD                     = 85,
        main_job_only           = true,
        notes                   = "MP +3/tick (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- MINNES (Defense)
    --============================================================

    ["Knight's Minne"] = {
        description             = "Boosts defense.",
        category                = "Minne",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 1,
        notes                   = "Defense +30 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Knight's Minne II"] = {
        description             = "Boosts defense.",
        category                = "Minne",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 21,
        notes                   = "Defense +69 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Knight's Minne III"] = {
        description             = "Boosts defense.",
        category                = "Minne",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "III",
        BRD                     = 41,
        notes                   = "Defense +108 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Knight's Minne IV"] = {
        description             = "Boosts defense.",
        category                = "Minne",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "IV",
        BRD                     = 61,
        main_job_only           = true,
        notes                   = "Defense +164 (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },
    ["Knight's Minne V"] = {
        description             = "Boosts defense.",
        category                = "Minne",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "V",
        BRD                     = 80,
        main_job_only           = true,
        notes                   = "Defense +204 (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- ETUDES (Stat Boosts - Single Target)
    --============================================================

    ["Enchanting Etude"] = {
        description             = "Boosts charisma.",
        category                = "Etude",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "CHR",
        BRD                     = 22,
        notes                   = "CHR +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Bewitching Etude"] = {
        description             = "Boosts charisma.",
        category                = "Etude",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "CHR",
        BRD                     = 62,
        main_job_only           = true,
        notes                   = "CHR +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Spirited Etude"] = {
        description             = "Boosts mind.",
        category                = "Etude",
        element                 = "Water",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "MND",
        BRD                     = 24,
        notes                   = "MND +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Logical Etude"] = {
        description             = "Boosts mind.",
        category                = "Etude",
        element                 = "Water",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "MND",
        BRD                     = 64,
        main_job_only           = true,
        notes                   = "MND +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Learned Etude"] = {
        description             = "Boosts intelligence.",
        category                = "Etude",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "INT",
        BRD                     = 26,
        notes                   = "INT +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Sage Etude"] = {
        description             = "Boosts intelligence.",
        category                = "Etude",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "INT",
        BRD                     = 66,
        main_job_only           = true,
        notes                   = "INT +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Quick Etude"] = {
        description             = "Boosts agility.",
        category                = "Etude",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "AGI",
        BRD                     = 28,
        notes                   = "AGI +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Swift Etude"] = {
        description             = "Boosts agility.",
        category                = "Etude",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "AGI",
        BRD                     = 68,
        main_job_only           = true,
        notes                   = "AGI +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Vivacious Etude"] = {
        description             = "Boosts vitality.",
        category                = "Etude",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "VIT",
        BRD                     = 30,
        notes                   = "VIT +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Vital Etude"] = {
        description             = "Boosts vitality.",
        category                = "Etude",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "VIT",
        BRD                     = 70,
        main_job_only           = true,
        notes                   = "VIT +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Dextrous Etude"] = {
        description             = "Boosts dexterity.",
        category                = "Etude",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "DEX",
        BRD                     = 32,
        notes                   = "DEX +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Uncanny Etude"] = {
        description             = "Boosts dexterity.",
        category                = "Etude",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "DEX",
        BRD                     = 72,
        main_job_only           = true,
        notes                   = "DEX +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Sinewy Etude"] = {
        description             = "Boosts strength.",
        category                = "Etude",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "STR",
        BRD                     = 34,
        notes                   = "STR +9 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Herculean Etude"] = {
        description             = "Boosts strength.",
        category                = "Etude",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        stat                    = "STR",
        BRD                     = 74,
        main_job_only           = true,
        notes                   = "STR +15 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- CAROLS (Elemental Resistance)
    --============================================================

    ["Light Carol"] = {
        description             = "Boosts light resist.",
        category                = "Carol",
        element                 = "Dark",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Light",
        tier                    = "I",
        BRD                     = 36,
        notes                   = "Light resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Light Carol II"] = {
        description             = "Boosts light resist; may nullify light damage.",
        category                = "Carol",
        element                 = "Dark",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Light",
        tier                    = "II",
        BRD                     = 99,
        main_job_only           = true,
        notes                   = "Light resistance +100 and 15% chance to nullify light damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Dark Carol"] = {
        description             = "Boosts dark resist.",
        category                = "Carol",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Dark",
        tier                    = "I",
        BRD                     = 50,
        subjob_master_only      = true,
        notes                   = "Dark resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only (subjob master OK).",
    },
    ["Dark Carol II"] = {
        description             = "Boosts dark resist; may nullify dark damage.",
        category                = "Carol",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Dark",
        tier                    = "II",
        BRD                     = 99,
        main_job_only           = true,
        notes                   = "Dark resistance +100 and 15% chance to nullify dark damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Earth Carol"] = {
        description             = "Boosts earth resist.",
        category                = "Carol",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Earth",
        tier                    = "I",
        BRD                     = 38,
        notes                   = "Earth resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Earth Carol II"] = {
        description             = "Boosts earth resist; may nullify earth damage.",
        category                = "Carol",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Earth",
        tier                    = "II",
        BRD                     = 81,
        main_job_only           = true,
        notes                   = "Earth resistance +100 and 15% chance to nullify earth damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Water Carol"] = {
        description             = "Boosts water resist.",
        category                = "Carol",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Water",
        tier                    = "I",
        BRD                     = 40,
        notes                   = "Water resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Water Carol II"] = {
        description             = "Boosts water resist; may nullify water damage.",
        category                = "Carol",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Water",
        tier                    = "II",
        BRD                     = 84,
        main_job_only           = true,
        notes                   = "Water resistance +100 and 15% chance to nullify water damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Wind Carol"] = {
        description             = "Boosts wind resist.",
        category                = "Carol",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Wind",
        tier                    = "I",
        BRD                     = 42,
        notes                   = "Wind resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Wind Carol II"] = {
        description             = "Boosts wind resist; may nullify wind damage.",
        category                = "Carol",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Wind",
        tier                    = "II",
        BRD                     = 87,
        main_job_only           = true,
        notes                   = "Wind resistance +100 and 15% chance to nullify wind damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Fire Carol"] = {
        description             = "Boosts fire resist.",
        category                = "Carol",
        element                 = "Water",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Fire",
        tier                    = "I",
        BRD                     = 44,
        notes                   = "Fire resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Fire Carol II"] = {
        description             = "Boosts fire resist; may nullify fire damage.",
        category                = "Carol",
        element                 = "Water",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Fire",
        tier                    = "II",
        BRD                     = 90,
        main_job_only           = true,
        notes                   = "Fire resistance +100 and 15% chance to nullify fire damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Ice Carol"] = {
        description             = "Boosts ice resist.",
        category                = "Carol",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Ice",
        tier                    = "I",
        BRD                     = 46,
        notes                   = "Ice resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Ice Carol II"] = {
        description             = "Boosts ice resist; may nullify ice damage.",
        category                = "Carol",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Ice",
        tier                    = "II",
        BRD                     = 93,
        main_job_only           = true,
        notes                   = "Ice resistance +100 and 15% chance to nullify ice damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Lightning Carol"] = {
        description             = "Boosts lightning resist.",
        category                = "Carol",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Lightning",
        tier                    = "I",
        BRD                     = 48,
        notes                   = "Lightning resistance +80 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Lightning Carol II"] = {
        description             = "Boosts lightning resist; may nullify lightning damage.",
        category                = "Carol",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        resist_element          = "Lightning",
        tier                    = "II",
        BRD                     = 96,
        main_job_only           = true,
        notes                   = "Lightning resistance +100 and 15% chance to nullify lightning damage (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- PRELUDE (Ranged Accuracy - Single Target)
    --============================================================

    ["Hunter's Prelude"] = {
        description             = "Boosts ranged accuracy.",
        category                = "Prelude",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 31,
        notes                   = "Ranged Accuracy +45 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Archer's Prelude"] = {
        description             = "Boosts ranged accuracy.",
        category                = "Prelude",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 71,
        main_job_only           = true,
        notes                   = "Ranged Accuracy +60 (base). Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- MAMBO (Evasion Boost)
    --============================================================

    ["Sheepfoe Mambo"] = {
        description             = "Boosts evasion.",
        category                = "Mambo",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "I",
        BRD                     = 13,
        notes                   = "Evasion +48 (base). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Dragonfoe Mambo"] = {
        description             = "Boosts evasion.",
        category                = "Mambo",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        tier                    = "II",
        BRD                     = 53,
        subjob_master_only      = true,
        notes                   = "Evasion +72 (base). Duration: 2 min base (song gear extends). BRD-only (subjob master OK).",
    },

    --============================================================
    -- SPECIAL BUFFS (Status Resistance & Utility)
    --============================================================

    ["Scop's Operetta"] = {
        description             = "Boosts silence resist.",
        category                = "Operetta",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Silence",
        BRD                     = 19,
        notes                   = "Boosts silence resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only.",
    },
    ["Puppet's Operetta"] = {
        description             = "Boosts silence resist.",
        category                = "Operetta",
        element                 = "Ice",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Silence",
        BRD                     = 69,
        main_job_only           = true,
        notes                   = "Boosts silence resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Herb Pastoral"] = {
        description             = "Boosts poison resist.",
        category                = "Pastoral",
        element                 = "Lightning",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Poison",
        BRD                     = 9,
        notes                   = "Boosts poison resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only.",
    },

    ["Fowl Aubade"] = {
        description             = "Boosts sleep resist.",
        category                = "Aubade",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Sleep",
        BRD                     = 33,
        notes                   = "Boosts sleep resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only.",
    },

    ["Goblin Gavotte"] = {
        description             = "Boosts bind resist.",
        category                = "Gavotte",
        element                 = "Fire",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Bind",
        BRD                     = 49,
        notes                   = "Boosts bind resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only.",
    },

    ["Gold Capriccio"] = {
        description             = "Boosts petrification resist.",
        category                = "Capriccio",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Petrification",
        BRD                     = 54,
        subjob_master_only      = true,
        notes                   = "Boosts petrification resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only (subjob master OK).",
    },

    ["Shining Fantasia"] = {
        description             = "Boosts blindness resist.",
        category                = "Fantasia",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Blindness",
        BRD                     = 56,
        subjob_master_only      = true,
        notes                   = "Boosts blindness resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only (subjob master OK).",
    },

    ["Sentinel's Scherzo"] = {
        description             = "Mitigates severe damage.",
        category                = "Scherzo",
        element                 = "Earth",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Damage Mitigation (Stoneskin)",
        BRD                     = 82,
        main_job_only           = true,
        notes                   = "Reduces damage from severely damaging attacks by 45% (base). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Goddess's Hymnus"] = {
        description             = "Grants reraise.",
        category                = "Hymnus",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Reraise",
        BRD                     = 71,
        main_job_only           = true,
        notes                   = "Grants Reraise I (returns 50% of lost EXP). Skill and gear do not change potency. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Warding Round"] = {
        description             = "Boosts curse resist.",
        category                = "Round",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        resist_status           = "Curse",
        BRD                     = 73,
        main_job_only           = true,
        notes                   = "Boosts curse resistance (potency unknown). Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Foe Sirvente"] = {
        description             = "Reduces enmity loss.",
        category                = "Sirvente",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Enmity Loss Reduction",
        BRD                     = 75,
        main_job_only           = true,
        notes                   = "Reduces cumulative enmity loss by 35% (base); volatile enmity is unaffected. Party AoE. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    ["Adventurer's Dirge"] = {
        description             = "Reduces enmity.",
        category                = "Dirge",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Enmity Down",
        BRD                     = 75,
        main_job_only           = true,
        notes                   = "Enmity -32. Song gear only extends its duration. Party AoE. Duration: 2 min base. BRD-only (main job).",
    },

    ["Aria of Passion"] = {
        description             = "Boosts physical dmg limit.",
        category                = "Aria",
        element                 = "Light",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Physical Damage Limit+",
        BRD                     = 99,
        main_job_only           = true,
        master_level            = true,
        notes                   = "Physical damage limit +15.6% at the lowest listed song bonus (+2). Requires an advanced-stage Loughnashade equipped. Duration: 2 min base (song gear extends). BRD-only (main job).",
    },

    --============================================================
    -- MAZURKA (Movement Speed)
    --============================================================

    ["Raptor Mazurka"] = {
        description             = "Boosts movement speed.",
        category                = "Mazurka",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Movement Speed +10%",
        BRD                     = 37,
        notes                   = "Movement speed +10%. Skill and gear do not change potency. Duration: 2 min base (Mazurka gear extends). Overwritten by Chocobo Mazurka. BRD-only.",
    },
    ["Chocobo Mazurka"] = {
        description             = "Boosts movement speed.",
        category                = "Mazurka",
        element                 = "Wind",
        magic_type              = "Song",
        type                    = "aoe",
        effect                  = "Movement Speed +20%",
        BRD                     = 73,
        main_job_only           = true,
        notes                   = "Movement speed +20%. Skill and gear do not change potency. Duration: 2 min base (Mazurka gear extends). Overwrites Raptor Mazurka. BRD-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SONG_BUFFS
