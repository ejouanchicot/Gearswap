---============================================================================
--- BARD SONGS DATABASE - Buff Songs Module
---============================================================================
--- Party support songs (82 total)
---
--- @file song_buffs.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local SONG_BUFFS = {}

SONG_BUFFS.spells = {

    --============================================================
    -- MINUETS (Attack Boost)
    --============================================================

    ["Valor Minuet"] = {
        description = "Boosts attack.",
        category = "Minuet",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 3,
        notes = "Attack +10. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Valor Minuet II"] = {
        description = "Boosts attack.",
        category = "Minuet",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 23,
        notes = "Attack +16. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Valor Minuet III"] = {
        description = "Boosts attack.",
        category = "Minuet",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        tier = "III",
        BRD = 43,
        notes = "Attack +22. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Valor Minuet IV"] = {
        description = "Boosts attack.",
        category = "Minuet",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        tier = "IV",
        BRD = 63,
        main_job_only = true,
        notes = "Attack +28. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },
    ["Valor Minuet V"] = {
        description = "Boosts attack.",
        category = "Minuet",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        tier = "V",
        BRD = 87,
        main_job_only = true,
        notes = "Attack +33. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- PAEONS (HP Regen)
    --============================================================

    ["Army's Paeon"] = {
        description = "Restores HP.",
        category = "Paeon",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 5,
        notes = "HP +4/tick (every 3s). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Army's Paeon II"] = {
        description = "Restores HP.",
        category = "Paeon",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 15,
        notes = "HP +6/tick (every 3s). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Army's Paeon III"] = {
        description = "Restores HP.",
        category = "Paeon",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "III",
        BRD = 35,
        notes = "HP +8/tick (every 3s). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Army's Paeon IV"] = {
        description = "Restores HP.",
        category = "Paeon",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "IV",
        BRD = 45,
        notes = "HP +10/tick (every 3s). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Army's Paeon V"] = {
        description = "Restores HP.",
        category = "Paeon",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "V",
        BRD = 65,
        main_job_only = true,
        notes = "HP +12/tick (every 3s). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },
    ["Army's Paeon VI"] = {
        description = "Restores HP.",
        category = "Paeon",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "VI",
        BRD = 78,
        main_job_only = true,
        notes = "HP +14/tick (every 3s). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- MARCHES (Haste)
    --============================================================

    ["Advancing March"] = {
        description = "Boosts attack speed.",
        category = "March",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 29,
        notes = "Haste +10% (base). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Victory March"] = {
        description = "Boosts attack speed.",
        category = "March",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 60,
        main_job_only = true,
        notes = "Haste +15% (base). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },
    ["Honor March"] = {
        description = "Boosts attack speed.",
        category = "March",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        tier = "III",
        BRD = 99,
        main_job_only = true,
        master_level = true,
        notes = "Haste +18% (base). Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. Master Level ability. BRD-only (main job).",
    },

    --============================================================
    -- MADRIGALS (Accuracy)
    --============================================================

    ["Sword Madrigal"] = {
        description = "Boosts melee accuracy.",
        category = "Madrigal",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 11,
        notes = "Accuracy +10. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Blade Madrigal"] = {
        description = "Boosts melee accuracy.",
        category = "Madrigal",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 51,
        subjob_master_only = true,
        notes = "Accuracy +16. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (subjob master OK).",
    },

    --============================================================
    -- BALLADS (MP Regen)
    --============================================================

    ["Mage's Ballad"] = {
        description = "Restores MP.",
        category = "Ballad",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 25,
        notes = "MP +3/tick (every 3s). Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Mage's Ballad II"] = {
        description = "Restores MP.",
        category = "Ballad",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 55,
        subjob_master_only = true,
        notes = "MP +5/tick (every 3s). Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (subjob master OK).",
    },
    ["Mage's Ballad III"] = {
        description = "Restores MP.",
        category = "Ballad",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "III",
        BRD = 85,
        main_job_only = true,
        notes = "MP +7/tick (every 3s). Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- MINNES (Defense)
    --============================================================

    ["Knight's Minne"] = {
        description = "Boosts defense.",
        category = "Minne",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 1,
        notes = "Defense +20. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Knight's Minne II"] = {
        description = "Boosts defense.",
        category = "Minne",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 21,
        notes = "Defense +32. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Knight's Minne III"] = {
        description = "Boosts defense.",
        category = "Minne",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "III",
        BRD = 41,
        notes = "Defense +44. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Knight's Minne IV"] = {
        description = "Boosts defense.",
        category = "Minne",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "IV",
        BRD = 61,
        main_job_only = true,
        notes = "Defense +56. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },
    ["Knight's Minne V"] = {
        description = "Boosts defense.",
        category = "Minne",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "V",
        BRD = 80,
        main_job_only = true,
        notes = "Defense +68. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- ETUDES (Stat Boosts - Single Target)
    --============================================================

    ["Enchanting Etude"] = {
        description = "Boosts charisma.",
        category = "Etude",
        element = "Light",
        magic_type = "Song",
        type = "single",
        stat = "CHR",
        BRD = 22,
        notes = "CHR +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Bewitching Etude"] = {
        description = "Boosts charisma.",
        category = "Etude",
        element = "Light",
        magic_type = "Song",
        type = "single",
        stat = "CHR",
        BRD = 62,
        main_job_only = true,
        notes = "CHR +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Spirited Etude"] = {
        description = "Boosts mind.",
        category = "Etude",
        element = "Water",
        magic_type = "Song",
        type = "single",
        stat = "MND",
        BRD = 24,
        notes = "MND +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Logical Etude"] = {
        description = "Boosts mind.",
        category = "Etude",
        element = "Water",
        magic_type = "Song",
        type = "single",
        stat = "MND",
        BRD = 64,
        main_job_only = true,
        notes = "MND +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Learned Etude"] = {
        description = "Boosts intelligence.",
        category = "Etude",
        element = "Ice",
        magic_type = "Song",
        type = "single",
        stat = "INT",
        BRD = 26,
        notes = "INT +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Sage Etude"] = {
        description = "Boosts intelligence.",
        category = "Etude",
        element = "Ice",
        magic_type = "Song",
        type = "single",
        stat = "INT",
        BRD = 66,
        main_job_only = true,
        notes = "INT +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Quick Etude"] = {
        description = "Boosts agility.",
        category = "Etude",
        element = "Wind",
        magic_type = "Song",
        type = "single",
        stat = "AGI",
        BRD = 28,
        notes = "AGI +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Swift Etude"] = {
        description = "Boosts agility.",
        category = "Etude",
        element = "Wind",
        magic_type = "Song",
        type = "single",
        stat = "AGI",
        BRD = 68,
        main_job_only = true,
        notes = "AGI +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Vivacious Etude"] = {
        description = "Boosts vitality.",
        category = "Etude",
        element = "Earth",
        magic_type = "Song",
        type = "single",
        stat = "VIT",
        BRD = 30,
        notes = "VIT +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Vital Etude"] = {
        description = "Boosts vitality.",
        category = "Etude",
        element = "Earth",
        magic_type = "Song",
        type = "single",
        stat = "VIT",
        BRD = 70,
        main_job_only = true,
        notes = "VIT +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Dextrous Etude"] = {
        description = "Boosts dexterity.",
        category = "Etude",
        element = "Lightning",
        magic_type = "Song",
        type = "single",
        stat = "DEX",
        BRD = 32,
        notes = "DEX +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Uncanny Etude"] = {
        description = "Boosts dexterity.",
        category = "Etude",
        element = "Lightning",
        magic_type = "Song",
        type = "single",
        stat = "DEX",
        BRD = 72,
        main_job_only = true,
        notes = "DEX +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Sinewy Etude"] = {
        description = "Boosts strength.",
        category = "Etude",
        element = "Fire",
        magic_type = "Song",
        type = "single",
        stat = "STR",
        BRD = 34,
        notes = "STR +4 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Herculean Etude"] = {
        description = "Boosts strength.",
        category = "Etude",
        element = "Fire",
        magic_type = "Song",
        type = "single",
        stat = "STR",
        BRD = 74,
        main_job_only = true,
        notes = "STR +8 (base). Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- CAROLS (Elemental Resistance)
    --============================================================

    ["Light Carol"] = {
        description = "Boosts light resist.",
        category = "Carol",
        element = "Dark",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Light",
        tier = "I",
        BRD = 36,
        notes = "Light resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Light Carol II"] = {
        description = "Boosts light resist.",
        category = "Carol",
        element = "Dark",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Light",
        tier = "II",
        BRD = 99,
        main_job_only = true,
        notes = "Light resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Dark Carol"] = {
        description = "Boosts dark resist.",
        category = "Carol",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Dark",
        tier = "I",
        BRD = 50,
        subjob_master_only = true,
        notes = "Dark resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (subjob master OK).",
    },
    ["Dark Carol II"] = {
        description = "Boosts dark resist.",
        category = "Carol",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Dark",
        tier = "II",
        BRD = 99,
        main_job_only = true,
        notes = "Dark resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Earth Carol"] = {
        description = "Boosts earth resist.",
        category = "Carol",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Earth",
        tier = "I",
        BRD = 38,
        notes = "Earth resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Earth Carol II"] = {
        description = "Boosts earth resist.",
        category = "Carol",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Earth",
        tier = "II",
        BRD = 81,
        main_job_only = true,
        notes = "Earth resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Water Carol"] = {
        description = "Boosts water resist.",
        category = "Carol",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Water",
        tier = "I",
        BRD = 40,
        notes = "Water resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Water Carol II"] = {
        description = "Boosts water resist.",
        category = "Carol",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Water",
        tier = "II",
        BRD = 84,
        main_job_only = true,
        notes = "Water resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Wind Carol"] = {
        description = "Boosts wind resist.",
        category = "Carol",
        element = "Ice",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Wind",
        tier = "I",
        BRD = 42,
        notes = "Wind resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Wind Carol II"] = {
        description = "Boosts wind resist.",
        category = "Carol",
        element = "Ice",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Wind",
        tier = "II",
        BRD = 87,
        main_job_only = true,
        notes = "Wind resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Fire Carol"] = {
        description = "Boosts fire resist.",
        category = "Carol",
        element = "Water",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Fire",
        tier = "I",
        BRD = 44,
        notes = "Fire resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Fire Carol II"] = {
        description = "Boosts fire resist.",
        category = "Carol",
        element = "Water",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Fire",
        tier = "II",
        BRD = 90,
        main_job_only = true,
        notes = "Fire resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Ice Carol"] = {
        description = "Boosts ice resist.",
        category = "Carol",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Ice",
        tier = "I",
        BRD = 46,
        notes = "Ice resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Ice Carol II"] = {
        description = "Boosts ice resist.",
        category = "Carol",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Ice",
        tier = "II",
        BRD = 93,
        main_job_only = true,
        notes = "Ice resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Lightning Carol"] = {
        description = "Boosts lightning resist.",
        category = "Carol",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Lightning",
        tier = "I",
        BRD = 48,
        notes = "Lightning resistance +20. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Lightning Carol II"] = {
        description = "Boosts lightning resist.",
        category = "Carol",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Lightning",
        tier = "II",
        BRD = 96,
        main_job_only = true,
        notes = "Lightning resistance +40. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- PRELUDE (Ranged Accuracy - Single Target)
    --============================================================

    ["Hunter's Prelude"] = {
        description = "Boosts ranged accuracy.",
        category = "Prelude",
        element = "Lightning",
        magic_type = "Song",
        type = "single",
        tier = "I",
        BRD = 31,
        notes = "Ranged Accuracy +8. Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Archer's Prelude"] = {
        description = "Boosts ranged accuracy.",
        category = "Prelude",
        element = "Lightning",
        magic_type = "Song",
        type = "single",
        tier = "II",
        BRD = 71,
        main_job_only = true,
        notes = "Ranged Accuracy +16. Single target. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- MAMBO (Evasion Boost)
    --============================================================

    ["Sheepfoe Mambo"] = {
        description = "Boosts evasion.",
        category = "Mambo",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 13,
        notes = "Evasion +8. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },
    ["Dragonfoe Mambo"] = {
        description = "Boosts evasion.",
        category = "Mambo",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 53,
        subjob_master_only = true,
        notes = "Evasion +16. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (subjob master OK).",
    },

    --============================================================
    -- SPECIAL BUFFS (Status Resistance & Utility)
    --============================================================

    ["Scop's Operetta"] = {
        description = "Boosts silence resist.",
        category = "Operetta",
        element = "Ice",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Silence",
        BRD = 19,
        notes = "Silence resistance +50. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },
    ["Puppet's Operetta"] = {
        description = "Boosts silence resist.",
        category = "Operetta",
        element = "Ice",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Silence",
        BRD = 69,
        main_job_only = true,
        notes = "Silence resistance +70. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Herb Pastoral"] = {
        description = "Boosts poison resist.",
        category = "Pastoral",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Poison",
        BRD = 9,
        notes = "Poison resistance +50. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },

    ["Fowl Aubade"] = {
        description = "Boosts sleep resist.",
        category = "Aubade",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Sleep",
        BRD = 33,
        notes = "Sleep resistance +50. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only.",
    },

    ["Goblin Gavotte"] = {
        description = "Boosts bind resist.",
        category = "Gavotte",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Bind",
        BRD = 49,
        notes = "Bind resistance +50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only.",
    },

    ["Gold Capriccio"] = {
        description = "Boosts petrification resist.",
        category = "Capriccio",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Petrification",
        BRD = 54,
        subjob_master_only = true,
        notes = "Petrification resistance +50. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (subjob master OK).",
    },

    ["Shining Fantasia"] = {
        description = "Boosts blindness resist.",
        category = "Fantasia",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Blindness",
        BRD = 56,
        subjob_master_only = true,
        notes = "Blindness resistance +50. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (subjob master OK).",
    },

    ["Sentinel's Scherzo"] = {
        description = "Grants damage absorption.",
        category = "Scherzo",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        effect = "Damage Mitigation (Stoneskin)",
        BRD = 82,
        main_job_only = true,
        notes = "Grants Stoneskin-like effect. Absorbs physical and magical damage (potency: Singing skill + CHR). Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    ["Goddess' Hymnus"] = {
        description = "Grants reraise.",
        category = "Hymnus",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        effect = "Reraise",
        BRD = 71,
        main_job_only = true,
        notes = "Grants Reraise I effect. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Warding Round"] = {
        description = "Boosts curse resist.",
        category = "Round",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_status = "Curse",
        BRD = 73,
        main_job_only = true,
        notes = "Curse resistance +50. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Foe Sirvente"] = {
        description = "Reduces enmity loss.",
        category = "Sirvente",
        element = "Light",
        magic_type = "Song",
        type = "single",
        effect = "Enmity Loss Reduction",
        BRD = 75,
        main_job_only = true,
        notes = "Reduces enmity decay from non-actions. Single target. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Adventurer's Dirge"] = {
        description = "Reduces enmity.",
        category = "Dirge",
        element = "Light",
        magic_type = "Song",
        type = "single",
        effect = "Enmity Down",
        BRD = 75,
        main_job_only = true,
        notes = "Reduces current enmity. Single target. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Aria of Passion"] = {
        description = "Boosts physical dmg limit.",
        category = "Aria",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        effect = "Physical Damage Limit+",
        BRD = 99,
        main_job_only = true,
        master_level = true,
        notes = "Raises physical damage limit. Duration: Singing skill. Master Level ability. Instrument: String (Harp/Lute) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- MAZURKA (Movement Speed)
    --============================================================

    ["Raptor Mazurka"] = {
        description = "Boosts movement speed.",
        category = "Mazurka",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        effect = "Movement Speed +25%",
        BRD = 37,
        notes = "Movement speed +25%. Duration: Singing skill. Overwritten by Chocobo Mazurka. Instrument: Wind (Flute/Piccolo) enhances duration. BRD-only.",
    },
    ["Chocobo Mazurka"] = {
        description = "Greatly boosts movement speed.",
        category = "Mazurka",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        effect = "Movement Speed +100%",
        BRD = 73,
        main_job_only = true,
        notes = "Movement speed +100% (Chocobo Jig equivalent). Duration: Singing skill. Overwrites Raptor Mazurka. Instrument: Wind (Flute/Piccolo) enhances duration. BRD-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SONG_BUFFS
