---============================================================================
--- SONG DATABASE - Debuff Songs Module (BRD Enemy Weakening)
---============================================================================
--- Songs that debuff and damage enemies (32 total)
---
--- @file song_debuffs.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local SONG_DEBUFFS = {}

SONG_DEBUFFS.spells = {

    --============================================================
    -- REQUIEMS (Sonic Damage)
    --============================================================

    ["Foe Requiem"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 7,
        notes = "Sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Foe Requiem II"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 17,
        notes = "Enhanced sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Foe Requiem III"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "III",
        BRD = 37,
        notes = "Enhanced sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Foe Requiem IV"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "IV",
        BRD = 47,
        notes = "Enhanced sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Foe Requiem V"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "V",
        BRD = 57,
        subjob_master_only = true,
        notes = "Enhanced sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob master OK).",
    },

    ["Foe Requiem VI"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "VI",
        BRD = 67,
        main_job_only = true,
        notes = "Enhanced sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Foe Requiem VII"] = {
        description = "Deals damage.",
        category = "Requiem",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "VII",
        BRD = 76,
        main_job_only = true,
        notes = "Highest sonic damage to enemies (damage: Singing skill + CHR). Duration: 90s base + Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- THRENODIES (Elemental Resistance Down)
    --============================================================

    ["Light Threnody"] = {
        description = "Lowers resistance against Light.",
        category = "Threnody",
        element = "Dark",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Light",
        tier = "I",
        BRD = 10,
        notes = "Light resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Light Threnody II"] = {
        description = "Lowers resistance against Light.",
        category = "Threnody",
        element = "Dark",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Light",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Light resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Dark Threnody"] = {
        description = "Lowers resistance against Dark.",
        category = "Threnody",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Dark",
        tier = "I",
        BRD = 12,
        notes = "Dark resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Dark Threnody II"] = {
        description = "Lowers resistance against Dark.",
        category = "Threnody",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Dark",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Dark resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Earth Threnody"] = {
        description = "Lowers resistance against Earth.",
        category = "Threnody",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Earth",
        tier = "I",
        BRD = 14,
        notes = "Earth resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Earth Threnody II"] = {
        description = "Lowers resistance against Earth.",
        category = "Threnody",
        element = "Wind",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Earth",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Earth resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Water Threnody"] = {
        description = "Lowers resistance against Water.",
        category = "Threnody",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Water",
        tier = "I",
        BRD = 16,
        notes = "Water resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Water Threnody II"] = {
        description = "Lowers resistance against Water.",
        category = "Threnody",
        element = "Lightning",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Water",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Water resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Wind Threnody"] = {
        description = "Lowers resistance against Wind.",
        category = "Threnody",
        element = "Ice",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Wind",
        tier = "I",
        BRD = 18,
        notes = "Wind resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Wind Threnody II"] = {
        description = "Lowers resistance against Wind.",
        category = "Threnody",
        element = "Ice",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Wind",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Wind resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Fire Threnody"] = {
        description = "Lowers resistance against Fire.",
        category = "Threnody",
        element = "Water",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Fire",
        tier = "I",
        BRD = 20,
        notes = "Fire resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Fire Threnody II"] = {
        description = "Lowers resistance against Fire.",
        category = "Threnody",
        element = "Water",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Fire",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Fire resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Ice Threnody"] = {
        description = "Lowers resistance against Ice.",
        category = "Threnody",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Ice",
        tier = "I",
        BRD = 22,
        notes = "Ice resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Ice Threnody II"] = {
        description = "Lowers resistance against Ice.",
        category = "Threnody",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Ice",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Ice resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    ["Lightning Threnody"] = {
        description = "Lowers resistance against Lightning.",
        category = "Threnody",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Lightning",
        tier = "I",
        BRD = 24,
        notes = "Lightning resistance -50. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Lightning Threnody II"] = {
        description = "Lowers resistance against Lightning.",
        category = "Threnody",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        resist_element = "Lightning",
        tier = "II",
        BRD = 99,
        job_points = true,
        notes = "Lightning resistance -75. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. Job Point ability (BRD).",
    },

    --============================================================
    -- LULLABIES (Sleep)
    --============================================================

    ["Foe Lullaby"] = {
        description = "Puts an enemy to sleep.",
        category = "Lullaby",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 16,
        notes = "Inflicts Sleep on single enemy. Duration: 60s base + Singing skill. Success rate: Singing skill + CHR vs Sleep resistance. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Foe Lullaby II"] = {
        description = "Puts an enemy to sleep.",
        category = "Lullaby",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 83,
        main_job_only = true,
        notes = "Inflicts enhanced Sleep on single enemy. Duration: 60s base + Singing skill. Success rate: Singing skill + CHR vs Sleep resistance. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Horde Lullaby"] = {
        description = "Puts enemies to sleep.",
        category = "Lullaby",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 27,
        notes = "Inflicts Sleep on multiple enemies (wider AoE than Foe Lullaby). Duration: 60s base + Singing skill. Success rate: Singing skill + CHR vs Sleep resistance. Instrument: Wind (Flute/Piccolo) enhances potency. BRD (subjob OK).",
    },

    ["Horde Lullaby II"] = {
        description = "Puts enemies to sleep.",
        category = "Lullaby",
        element = "Light",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 92,
        main_job_only = true,
        notes = "Inflicts enhanced Sleep on multiple enemies (wider AoE). Duration: 60s base + Singing skill. Success rate: Singing skill + CHR vs Sleep resistance. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    --============================================================
    -- ELEGIES (Attack Speed Down)
    --============================================================

    ["Battlefield Elegy"] = {
        description = "Lowers attack speed.",
        category = "Elegy",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "I",
        BRD = 39,
        notes = "Slow effect: Attack speed -25%. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob OK).",
    },

    ["Carnage Elegy"] = {
        description = "Lowers attack speed.",
        category = "Elegy",
        element = "Earth",
        magic_type = "Song",
        type = "aoe",
        tier = "II",
        BRD = 59,
        subjob_master_only = true,
        notes = "Enhanced Slow effect: Attack speed -50%. Duration: Singing skill. Instrument: String (Harp/Lute) enhances potency. BRD (subjob master OK).",
    },

    --============================================================
    -- SPECIAL DEBUFFS
    --============================================================

    ["Magic Finale"] = {
        description = "Removes one beneficial magic effect from an enemy.",
        category = "Special",
        element = "Light",
        magic_type = "Song",
        type = "single",
        effect = "Dispel",
        BRD = 33,
        notes = "Dispels one beneficial effect from enemy (similar to Dispel spell). Success rate: Singing skill + CHR. Single target. Instrument: String (Harp/Lute) enhances success rate. BRD (subjob OK).",
    },

    ["Maiden's Virelai"] = {
        description = "Charms an enemy.",
        category = "Special",
        element = "Light",
        magic_type = "Song",
        type = "single",
        effect = "Charm",
        BRD = 75,
        main_job_only = true,
        notes = "Inflicts Charm status (enemy becomes temporary ally). Duration: 90s base + Singing skill. Success rate: Singing skill + CHR vs Charm resistance. Single target. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

    ["Pining Nocturne"] = {
        description = "Lowers magic accuracy, Raises cast time.",
        category = "Nocturne",
        element = "Fire",
        magic_type = "Song",
        type = "aoe",
        effect = "Magic Accuracy Down + Cast Time Up",
        BRD = 95,
        main_job_only = true,
        notes = "Magic Accuracy -50, Cast Time +100%. Duration: Singing skill. Instrument: Wind (Flute/Piccolo) enhances potency. BRD-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SONG_DEBUFFS
