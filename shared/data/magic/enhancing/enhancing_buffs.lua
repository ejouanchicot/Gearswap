---============================================================================
--- ENHANCING MAGIC DATABASE - Buff Spells Module
---============================================================================
--- Defensive and regeneration buffs (32 total)
---
--- Aquaveil:
---   - Prevents spell interruption based on Enhancing Magic skill
---   - Breakpoints: <300 (1 int), 301-500 (2 int), 501+ (3 int)
---   - Equipment: Amalric Coif +1 (+2), Regal Cuffs (+2), Shedir Seraweels (+1)
---
--- Protect/Shell:
---   - Fixed defense/magic defense values per tier (no skill scaling)
---   - No specific gear for potency
---
--- Refresh:
---   - Fixed MP/tick per tier (no skill scaling)
---   - Equipment: Lethargy Fuseau (+1-4 MP/tick), Amalric Coif (+1-2 MP/tick), Gishdubar Sash (+20s duration)
---
--- Regen:
---   - Base HP/tick + equipment bonuses (no skill scaling for potency)
---   - Equipment: Arbatel Bonnet, various armor pieces with Regen potency+
---
--- @file enhancing_buffs.lua
--- @author Tetsouo
--- @version 2.0 - Standardized with spell_family
--- @date Created: 2025-10-30 | Updated: 2025-11-05
---============================================================================

local ENHANCING_BUFFS = {}

ENHANCING_BUFFS.spells = {

    --============================================================
    -- AQUAVEIL - Skill-based (breakpoints 301/501)
    --============================================================
    ["Aquaveil"] = {
        description = "Reduces the chance of spell interruption.",
        skill = "Enhancing Magic",
        spell_family = "Aquaveil",
        target_type = "single",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = true,
        WHM = 10,
        RDM = 12,
        SCH = 13,
        RUN = 15,
    },

    --============================================================
    -- UTILITY BUFFS - No specific gear
    --============================================================
    ["Auspice"] = {
        description = "Increases accuracy and adds additional effect: Light damage to melee attacks.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 55,
    },

    --============================================================
    -- PROTECT FAMILY (Single) - Fixed defense values
    --============================================================
    ["Protect"] = {
        description = "Increases defense.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 7,
        RDM = 7,
        PLD = 10,
        SCH = 10,
        RUN = 20,
    },

    ["Protect II"] = {
        description = "Increases defense.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 27,
        RDM = 27,
        PLD = 30,
        SCH = 30,
        RUN = 40,
    },

    ["Protect III"] = {
        description = "Increases defense.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "III",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 47,
        RDM = 47,
        PLD = 50,
        SCH = 50,
        RUN = 60,
    },

    ["Protect IV"] = {
        description = "Increases defense.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "IV",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 63,
        RDM = 63,
        PLD = 70,
        SCH = 70,
        RUN = 80,
    },

    ["Protect V"] = {
        description = "Increases defense.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "V",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 76,
        RDM = 77,
        PLD = 90,
        SCH = 80,
    },

    --============================================================
    -- PROTECTRA FAMILY (AoE) - Fixed defense values
    --============================================================
    ["Protectra"] = {
        description = "Increases defense for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 7,
    },

    ["Protectra II"] = {
        description = "Increases defense for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 27,
    },

    ["Protectra III"] = {
        description = "Increases defense for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "III",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 47,
    },

    ["Protectra IV"] = {
        description = "Increases defense for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "IV",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 63,
    },

    ["Protectra V"] = {
        description = "Increases defense for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "V",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 75,
    },

    --============================================================
    -- REFRESH FAMILY - Fixed MP/tick, gear for potency
    --============================================================
    ["Refresh"] = {
        description = "Gradually restores target's MP.",
        skill = "Enhancing Magic",
        spell_family = "Refresh",
        target_type = "single",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "MP +3/tick",
        RDM = 41,
        SCH = 41,
        BRD = 52,
    },

    ["Refresh II"] = {
        description = "Gradually restores target's MP.",
        skill = "Enhancing Magic",
        spell_family = "Refresh",
        target_type = "single",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "MP +6/tick",
        RDM = 76,
        SCH = 76,
    },

    ["Refresh III"] = {
        description = "Gradually restores target's MP.",
        skill = "Enhancing Magic",
        spell_family = "Refresh",
        target_type = "single",
        tier = "III",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "MP +9/tick",
        RDM = 99,
        main_job_only = true,
    },

    --============================================================
    -- REGEN FAMILY - HP/tick + gear bonuses
    --============================================================
    ["Regen"] = {
        description = "Gradually restores target's HP.",
        skill = "Enhancing Magic",
        spell_family = "Regen",
        target_type = "single",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "HP +5/tick",
        SCH = 18,
        WHM = 21,
        RDM = 21,
        RUN = 23,
    },

    ["Regen II"] = {
        description = "Gradually restores target's HP.",
        skill = "Enhancing Magic",
        spell_family = "Regen",
        target_type = "single",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "HP +12/tick",
        SCH = 37,
        WHM = 44,
        RUN = 48,
        RDM = 76,
    },

    ["Regen III"] = {
        description = "Gradually restores target's HP.",
        skill = "Enhancing Magic",
        spell_family = "Regen",
        target_type = "single",
        tier = "III",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "HP +20/tick",
        SCH = 59,
        WHM = 66,
        RUN = 70,
    },

    ["Regen IV"] = {
        description = "Gradually restores target's HP.",
        skill = "Enhancing Magic",
        spell_family = "Regen",
        target_type = "single",
        tier = "IV",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "HP +30/tick",
        SCH = 79,
        WHM = 86,
        RUN = 99,
    },

    ["Regen V"] = {
        description = "Gradually restores target's HP.",
        skill = "Enhancing Magic",
        spell_family = "Regen",
        target_type = "single",
        tier = "V",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        effect = "HP +40/tick",
        SCH = 99,
        main_job_only = true,
    },

    --============================================================
    -- SHELL FAMILY (Single) - Fixed magic defense values
    --============================================================
    ["Shell"] = {
        description = "Reduces magic damage taken.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 17,
        RDM = 17,
        PLD = 20,
        SCH = 20,
        RUN = 10,
    },

    ["Shell II"] = {
        description = "Reduces magic damage taken.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 37,
        RDM = 37,
        PLD = 40,
        SCH = 40,
        RUN = 30,
    },

    ["Shell III"] = {
        description = "Reduces magic damage taken.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "III",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 57,
        RDM = 57,
        PLD = 60,
        SCH = 60,
        RUN = 50,
    },

    ["Shell IV"] = {
        description = "Reduces magic damage taken.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "IV",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 68,
        RDM = 68,
        PLD = 80,
        SCH = 71,
        RUN = 70,
    },

    ["Shell V"] = {
        description = "Reduces magic damage taken.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "single",
        tier = "V",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 76,
        RDM = 87,
        SCH = 90,
        RUN = 90,
    },

    --============================================================
    -- SHELLRA FAMILY (AoE) - Fixed magic defense values
    --============================================================
    ["Shellra"] = {
        description = "Reduces magic damage taken for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "I",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 17,
    },

    ["Shellra II"] = {
        description = "Reduces magic damage taken for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "II",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 37,
    },

    ["Shellra III"] = {
        description = "Reduces magic damage taken for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "III",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 57,
    },

    ["Shellra IV"] = {
        description = "Reduces magic damage taken for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "IV",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 68,
    },

    ["Shellra V"] = {
        description = "Reduces magic damage taken for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = nil,
        target_type = "aoe",
        tier = "V",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 75,
    },
}

return ENHANCING_BUFFS
