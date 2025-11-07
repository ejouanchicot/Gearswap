---============================================================================
--- ENHANCING MAGIC DATABASE - Utility & Travel Module
---============================================================================
--- Utility, stat buffs, and travel spells (41 total)
---
--- Stoneskin:
---   - Damage absorption scales with MND + Enhancing Magic skill (cap 540 with 0 MND)
---   - Equipment: Earthcry Mantle (+10), Stone Gorget (+7), Siegel Sash (+20)
---
--- Gain Spells:
---   - Fixed stat bonus (+8 base stat)
---   - Duration scales with Enhancing Magic skill (cap 500 = 300 seconds)
---   - Equipment: Duration gear (Telchine set, Estoqueur's Houseaux +2)
---
--- Boost Spells:
---   - WHM party version of Gain spells (AoE)
---   - Fixed stat bonus (+25 base stat)
---   - Duration scales with Enhancing Magic skill
---
--- @file enhancing_utility.lua
--- @author Tetsouo
--- @version 2.1 - Improved alignment - Standardized with spell_family
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-11-05
---============================================================================

local ENHANCING_UTILITY = {}

ENHANCING_UTILITY.spells = {

    --============================================================
    -- SCHOLAR-SPECIFIC SPELLS - No specific gear
    --============================================================

    ["Adloquium"] = {
        description             = "+Max HP, +MDEF, reduce interrupt",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        SCH                     = 88,
    },

    ["Animus Augeo"] = {
        description             = "Increases pet's TP generation speed.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Dark",
        magic_type              = "White",
        enhancing_skill_affects = true,
        SCH                     = 85,
        main_job_only           = true,
    },

    ["Animus Minuo"] = {
        description             = "Reduces pet's enmity generation.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        SCH                     = 85,
    },

    --============================================================
    -- UTILITY SPELLS - No specific gear (except Stoneskin)
    --============================================================

    ["Blink"] = {
        description             = "Creates shadow copies that each absorb one physical attack.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        WHM                     = 19,
        RDM                     = 23,
        SCH                     = 30,
        RUN                     = 35,
    },

    ["Crusade"] = {
        description             = "Increases enmity gain.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Dark",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Enmity +30",
        duration                = "5 minutes",
        PLD                     = 88,
        RUN                     = 88,
        main_job_only           = true,
        notes                   = "Overwrites Animus Augeo. Does not stack."
    },

    ["Deodorize"] = {
        description             = "Reduces chance of being detected by scent-tracking monsters.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        WHM                     = 15,
        RDM                     = 15,
        SCH                     = 15,
    },

    ["Embrava"] = {
        description             = "Increases magic accuracy and grants haste effect.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        SCH                     = 5,
        main_job_only           = true,
    },

    ["Erase"] = {
        description             = "Removes one detrimental status effect from target.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 32,
        SCH                     = 39,
    },

    ["Foil"] = {
        description             = "Prevents one dispel effect when hit by physical attack.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        RUN                     = 58,
    },

    ["Inundation"] = {
        description             = "Reduces target's magic evasion.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        RDM                     = 64,
        main_job_only           = true,
    },

    ["Invisible"] = {
        description             = "Reduces chance of being detected by sight-tracking monsters.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        WHM                     = 25,
        RDM                     = 25,
        SCH                     = 25,
    },

    ["Klimaform"] = {
        description             = "+Elemental magic potency in weather",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Dark",
        magic_type              = "White",
        enhancing_skill_affects = true,
        GEO                     = 35,
        SCH                     = 68,
    },

    ["Reprisal"] = {
        description             = "Reflects damage back to attacker when you parry.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        PLD                     = 61,
        main_job_only           = true,
    },

    ["Sneak"] = {
        description             = "Reduces chance of being detected by sound-tracking monsters.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        WHM                     = 20,
        RDM                     = 20,
        SCH                     = 20,
    },

    ["Stoneskin"] = {
        description             = "Absorbs damage from physical and magical attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Stoneskin",
        target_type             = "single",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        WHM                     = 28,
        RDM                     = 34,
        SCH                     = 44,
        RUN                     = 55,
    },

    --============================================================
    -- BOOST SPELLS (Party Stat Enhancement - AoE)
    --============================================================

    ["Boost-AGI"] = {
        description             = "Increases Agility for party members within area of effect.",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "AGI +25 (AoE)",
        WHM                     = 90,
    },

    ["Boost-CHR"] = {
        description             = "Increases Charisma for party members within area of effect.",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "CHR +25 (AoE)",
        WHM                     = 87,
        main_job_only           = true,
    },

    ["Boost-DEX"] = {
        description             = "Increases Dexterity for party members within area of effect.",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Thunder",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "DEX +25 (AoE)",
        WHM                     = 99,
        main_job_only           = true,
    },

    ["Boost-INT"] = {
        description             = "Party AoE: +Intelligence",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Ice",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "INT +25 (AoE)",
        WHM                     = 96,
        main_job_only           = true,
    },

    ["Boost-MND"] = {
        description             = "Increases Mind for party members within area of effect.",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "MND +25 (AoE)",
        WHM                     = 84,
        main_job_only           = true,
    },

    ["Boost-STR"] = {
        description             = "Increases Strength for party members within area of effect.",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Fire",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "STR +25 (AoE)",
        WHM                     = 93,
        main_job_only           = true,
    },

    ["Boost-VIT"] = {
        description             = "Increases Vitality for party members within area of effect.",
        skill                   = "Enhancing Magic",
        spell_family            = "Boost",
        target_type             = "aoe",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "VIT +25 (AoE)",
        WHM                     = 81,
        main_job_only           = true,
    },

    --============================================================
    -- GAIN SPELLS (Self Stat Enhancement)
    --============================================================

    ["Gain-AGI"] = {
        description             = "Increases Agility.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "AGI +8",
        RDM                     = 90,
        main_job_only           = true,
    },

    ["Gain-CHR"] = {
        description             = "Increases Charisma.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "CHR +8",
        RDM                     = 87,
        main_job_only           = true,
    },

    ["Gain-DEX"] = {
        description             = "Increases Dexterity.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Thunder",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "DEX +8",
        RDM                     = 99,
        main_job_only           = true,
    },

    ["Gain-INT"] = {
        description             = "Increases Intelligence.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Ice",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "INT +8",
        RDM                     = 96,
        main_job_only           = true,
    },

    ["Gain-MND"] = {
        description             = "Increases Mind.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "MND +8",
        RDM                     = 84,
        main_job_only           = true,
    },

    ["Gain-STR"] = {
        description             = "Increases Strength.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Fire",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "STR +8",
        RDM                     = 93,
        main_job_only           = true,
    },

    ["Gain-VIT"] = {
        description             = "Increases Vitality.",
        skill                   = "Enhancing Magic",
        spell_family            = "Gain",
        target_type             = "single",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "VIT +8",
        RDM                     = 81,
        main_job_only           = true,
    },

    --============================================================
    -- RECALL SPELLS (Teleport to Past - AoE) - No gear
    --============================================================

    ["Recall-Jugner"] = {
        description             = "Warp party to Jugner [S] HP",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 53,
        main_job_only           = true,
    },

    ["Recall-Meriph"] = {
        description             = "Warp party to Meriphataud HP",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 53,
        main_job_only           = true,
    },

    ["Recall-Pashh"] = {
        description             = "Warp party to Pashhow HP",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 53,
        main_job_only           = true,
    },

    --============================================================
    -- TELEPORT SPELLS (Crag Teleports - AoE) - No gear
    --============================================================

    ["Escape"] = {
        description             = "Warp party to dungeon entrance",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Dark",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        BLM                     = 29,
        main_job_only           = true,
    },

    ["Retrace"] = {
        description             = "Returns you to last visited location.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Dark",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        BLM                     = 55,
    },

    ["Teleport-Altep"] = {
        description             = "Warp party to Crag of Holla",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 38,
        main_job_only           = true,
    },

    ["Teleport-Dem"] = {
        description             = "Warp party to Crag of Dem",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 36,
    },

    ["Teleport-Holla"] = {
        description             = "Warp party to Crag of Holla",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 36,
        main_job_only           = true,
    },

    ["Teleport-Mea"] = {
        description             = "Warp party to Crag of Mea",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 36,
        main_job_only           = true,
    },

    ["Teleport-Vahzl"] = {
        description             = "Warp party to Crag of Vahzl",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 42,
        main_job_only           = true,
    },

    ["Teleport-Yhoat"] = {
        description             = "Warp party to Crag of Yhoat",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "aoe",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = false,
        WHM                     = 38,
        main_job_only           = true,
    },

    --============================================================
    -- WARP SPELLS (Home Point Teleport) - No gear
    --============================================================

    ["Warp"] = {
        description             = "Returns you to your current Home Point.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        element                 = "Dark",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        BLM                     = 17,
        main_job_only           = true,
    },

    ["Warp II"] = {
        description             = "Leader to HP, party to yours",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "II",
        element                 = "Dark",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        BLM                     = 40,
        main_job_only           = true,
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENHANCING_UTILITY
