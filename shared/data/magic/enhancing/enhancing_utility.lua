---============================================================================
--- ENHANCING MAGIC DATABASE - Utility & Travel Module
---============================================================================
--- Utility, stat buffs, and travel spells (41 total)
---
--- Contents:
---   - Scholar-specific (3): Adloquium, Animus Augeo, Animus Minuo
---   - Utility spells (12): Blink, Crusade, Deodorize, Embrava, Erase, Foil, Inundation, Invisible, Klimaform, Reprisal, Sneak, Stoneskin
---   - Boost spells (7): Boost-STR, Boost-DEX, etc. (party AoE stat buffs)
---   - Gain spells (7): Gain-STR, Gain-DEX, etc. (self stat buffs)
---   - Recall spells (3): Recall-Jugner, Recall-Meriph, Recall-Pashh (AoE teleports to past)
---   - Teleport spells (8): Escape, Retrace, Teleport-Holla, etc. (crag teleports)
---   - Warp spells (2): Warp, Warp II (home point teleport)
---
--- @file enhancing_utility.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
---============================================================================

local ENHANCING_UTILITY = {}

ENHANCING_UTILITY.spells = {

    --============================================================
    -- SCHOLAR-SPECIFIC SPELLS
    --============================================================

    ["Adloquium"] = {
        description = "Boosts max HP, magic def, spell interruption.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        SCH = 88,
        notes = "Increases maximum HP, magic defense, and reduces spell interruption rate. Duration: Enhancing Magic skill. SCH-only.",
    },

    ["Animus Augeo"] = {
        description = "Boosts pet TP generation.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "White",
        type = "single",
        SCH = 85,
        main_job_only = true,
        notes = "Increases pet's TP generation speed. Duration: Enhancing Magic skill. SCH-only.",
    },

    ["Animus Minuo"] = {
        description = "Reduces pet enmity.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        SCH = 85,
        notes = "Reduces pet's enmity generation. Duration: Enhancing Magic skill. SCH-only.",
    },

    --============================================================
    -- UTILITY SPELLS
    --============================================================

    ["Blink"] = {
        description = "Creates shadow copies (3).",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        WHM = 19, RDM = 23, SCH = 30, RUN = 35,
        notes = "Creates 3 shadow images that each absorb one physical attack. Duration: Enhancing Magic skill. WHM/RDM/SCH/RUN.",
    },

    ["Crusade"] = {
        description = "Boosts accuracy & attack.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "White",
        type = "self",
        PLD = 88, RUN = 88,
        main_job_only = true,
        notes = "Increases accuracy and attack. Enhances combat effectiveness. Duration: Enhancing Magic skill. PLD/RUN-only.",
    },

    ["Deodorize"] = {
        description = "Prevents scent detection.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        WHM = 15, RDM = 15, SCH = 15,
        notes = "Reduces chance of being detected by scent-tracking monsters. Duration: Enhancing Magic skill. WHM/RDM/SCH.",
    },

    ["Embrava"] = {
        description = "Boosts magic acc & haste.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        SCH = 5,
        main_job_only = true,
        notes = "Increases magic accuracy and grants haste effect. Strong offensive support buff. Duration: Enhancing Magic skill. SCH-only.",
    },

    ["Erase"] = {
        description = "Removes 1 debuff.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "single",
        WHM = 32, SCH = 39,
        notes = "Removes one detrimental status effect from target. Essential cleansing spell. WHM/SCH.",
    },

    ["Foil"] = {
        description = "Prevents next dispel (phys).",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        RUN = 58,
        notes = "Prevents one dispel effect when hit by physical attack. Duration: Enhancing Magic skill. RUN-only.",
    },

    ["Inundation"] = {
        description = "Lowers magic evasion.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        RDM = 64,
        main_job_only = true,
        notes = "Reduces target's magic evasion. Enhances magic damage effectiveness. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Invisible"] = {
        description = "Prevents sight detection.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        WHM = 25, RDM = 25, SCH = 25,
        notes = "Reduces chance of being detected by sight-tracking monsters. Duration: Enhancing Magic skill. WHM/RDM/SCH.",
    },

    ["Klimaform"] = {
        description = "Boosts magic during weather.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "White",
        type = "self",
        GEO = 35, SCH = 68,
        notes = "Enhances elemental magic potency when matching weather is active. Duration: Enhancing Magic skill. GEO/SCH.",
    },

    ["Reprisal"] = {
        description = "Reflects dmg on parry.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        PLD = 61,
        main_job_only = true,
        notes = "Reflects damage back to attacker when you parry. Duration: Enhancing Magic skill. PLD-only.",
    },

    ["Sneak"] = {
        description = "Prevents sound detection.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "single",
        WHM = 20, RDM = 20, SCH = 20,
        notes = "Reduces chance of being detected by sound-tracking monsters. Duration: Enhancing Magic skill. WHM/RDM/SCH.",
    },

    ["Stoneskin"] = {
        description = "Absorbs physical/magic dmg.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "self",
        WHM = 28, RDM = 34, SCH = 44, RUN = 55,
        notes = "Absorbs fixed amount of damage from physical and magical attacks. Potency: Enhancing Magic skill + MND. WHM/RDM/SCH/RUN.",
    },

    --============================================================
    -- BOOST SPELLS (Party Stat Enhancement - AoE)
    --============================================================

    ["Boost-AGI"] = {
        description = "Boosts agility (AOE).",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "aoe",
        WHM = 90,
        notes = "Increases Agility for party members in range. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Boost-CHR"] = {
        description = "Boosts charisma (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 87,
        main_job_only = true,
        notes = "Increases Charisma for party members in range. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Boost-DEX"] = {
        description = "Boosts dexterity (AOE).",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "aoe",
        WHM = 99,
        main_job_only = true,
        notes = "Increases Dexterity for party members in range. Job Point ability (WHM).",
    },

    ["Boost-INT"] = {
        description = "Boosts intelligence (AOE).",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "aoe",
        WHM = 96,
        main_job_only = true,
        notes = "Increases Intelligence for party members in range. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Boost-MND"] = {
        description = "Boosts mind (AOE).",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "aoe",
        WHM = 84,
        main_job_only = true,
        notes = "Increases Mind for party members in range. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Boost-STR"] = {
        description = "Boosts strength (AOE).",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "aoe",
        WHM = 93,
        main_job_only = true,
        notes = "Increases Strength for party members in range. Duration: Enhancing Magic skill. WHM-only.",
    },

    ["Boost-VIT"] = {
        description = "Boosts vitality (AOE).",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "aoe",
        WHM = 81,
        main_job_only = true,
        notes = "Increases Vitality for party members in range. Duration: Enhancing Magic skill. WHM-only.",
    },

    --============================================================
    -- GAIN SPELLS (Self Stat Enhancement)
    --============================================================

    ["Gain-AGI"] = {
        description = "Boosts agility.",
        category = "Enhancing",
        element = "Wind",
        magic_type = "White",
        type = "self",
        RDM = 90,
        main_job_only = true,
        notes = "Increases your Agility. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Gain-CHR"] = {
        description = "Boosts charisma.",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "self",
        RDM = 87,
        main_job_only = true,
        notes = "Increases your Charisma. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Gain-DEX"] = {
        description = "Boosts dexterity.",
        category = "Enhancing",
        element = "Thunder",
        magic_type = "White",
        type = "self",
        RDM = 99,
        main_job_only = true,
        notes = "Increases your Dexterity. Job Point ability (RDM).",
    },

    ["Gain-INT"] = {
        description = "Boosts intelligence.",
        category = "Enhancing",
        element = "Ice",
        magic_type = "White",
        type = "self",
        RDM = 96,
        notes = "Increases your Intelligence. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Gain-MND"] = {
        description = "Boosts mind.",
        category = "Enhancing",
        element = "Water",
        magic_type = "White",
        type = "self",
        RDM = 84,
        main_job_only = true,
        notes = "Increases your Mind. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Gain-STR"] = {
        description = "Boosts strength.",
        category = "Enhancing",
        element = "Fire",
        magic_type = "White",
        type = "self",
        RDM = 93,
        main_job_only = true,
        notes = "Increases your Strength. Duration: Enhancing Magic skill. RDM-only.",
    },

    ["Gain-VIT"] = {
        description = "Boosts vitality.",
        category = "Enhancing",
        element = "Earth",
        magic_type = "White",
        type = "self",
        RDM = 81,
        main_job_only = true,
        notes = "Increases your Vitality. Duration: Enhancing Magic skill. RDM-only.",
    },

    --============================================================
    -- RECALL SPELLS (Teleport to Past - AoE)
    --============================================================

    ["Recall-Jugner"] = {
        description = "Teleports to Jugner (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 53,
        main_job_only = true,
        notes = "Transports party members to their homepoint in Jugner Forest [S]. Past era teleport. WHM-only.",
    },

    ["Recall-Meriph"] = {
        description = "Teleports to Meriph (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 53,
        main_job_only = true,
        notes = "Transports party members to their homepoint in Meriphataud Mountains [S]. Past era teleport. WHM-only.",
    },

    ["Recall-Pashh"] = {
        description = "Teleports to Pashh (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 53,
        main_job_only = true,
        notes = "Transports party members to their homepoint in Pashhow Marshlands [S]. Past era teleport. WHM-only.",
    },

    --============================================================
    -- TELEPORT SPELLS (Crag Teleports - AoE)
    --============================================================

    ["Escape"] = {
        description = "Teleports to dungeon entrance (AOE).",
        category = "Enhancing",
        element = "Dark",
        magic_type = "Black",
        type = "aoe",
        BLM = 29,
        main_job_only = true,
        notes = "Transports party to the entrance of current dungeon. Cannot be used in all areas. BLM-only.",
    },

    ["Retrace"] = {
        description = "Returns to last visited location.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "Black",
        type = "self",
        BLM = 55,
        notes = "Returns you to last visited location. Cannot be used in all areas. BLM-only.",
    },

    ["Teleport-Altep"] = {
        description = "Teleports to Altep (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 38,
        main_job_only = true,
        notes = "Transports party members to Crag of Holla (Western Altepa Desert). Requires Altep Gate Crystal. WHM-only.",
    },

    ["Teleport-Dem"] = {
        description = "Teleports to Dem (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 36,
        notes = "Transports party members to Crag of Dem (Konschtat Highlands). Requires Dem Gate Crystal. WHM-only.",
    },

    ["Teleport-Holla"] = {
        description = "Teleports to Holla (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 36,
        main_job_only = true,
        notes = "Transports party members to Crag of Holla (La Theine Plateau). Requires Holla Gate Crystal. WHM-only.",
    },

    ["Teleport-Mea"] = {
        description = "Teleports to Mea (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 36,
        main_job_only = true,
        notes = "Transports party members to Crag of Mea (Tahrongi Canyon). Requires Mea Gate Crystal. WHM-only.",
    },

    ["Teleport-Vahzl"] = {
        description = "Teleports to Vahzl (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 42,
        main_job_only = true,
        notes = "Transports party members to Crag of Vahzl (Xarcabard). Requires Vahzl Gate Crystal. WHM-only.",
    },

    ["Teleport-Yhoat"] = {
        description = "Teleports to Yhoat (AOE).",
        category = "Enhancing",
        element = "Light",
        magic_type = "White",
        type = "aoe",
        WHM = 38,
        main_job_only = true,
        notes = "Transports party members to Crag of Yhoat (Yhoator Jungle). Requires Yhoat Gate Crystal. WHM-only.",
    },

    --============================================================
    -- WARP SPELLS (Home Point Teleport)
    --============================================================

    ["Warp"] = {
        description = "Returns to home point.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "Black",
        type = "self",
        BLM = 17,
        main_job_only = true,
        notes = "Returns you to your current Home Point. Cannot be used in all areas. BLM-only.",
    },

    ["Warp II"] = {
        description = "Returns party to home points.",
        category = "Enhancing",
        element = "Dark",
        magic_type = "Black",
        type = "single",
        tier = "II",
        BLM = 40,
        main_job_only = true,
        notes = "Returns party leader to their Home Point, and party members to yours. Cannot be used in all areas. BLM-only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENHANCING_UTILITY
