---============================================================================
--- ENHANCING MAGIC DATABASE - Bar-Spells Module
---============================================================================
--- Bar-element and Bar-status spells (28 total)
---
--- Bar-Element Spells:
---   - Resistance scales with Enhancing Magic skill (cap 500 = +150 resistance)
---   - Formula: 40 + skill/5 (below 300), 25 + skill/4 (above 300)
---   - Equipment: Piety Pantaloons +3 (+36), Cleric's +2 (+25), Shedir Seraweels (+15)
---
--- Bar-Status Spells:
---   - Fixed resistance (no skill scaling)
---   - Single: +30 resistance | AoE: +20 resistance
---   - Equipment: Sroda Necklace (+20 bonus to AoE bar-status)
---
--- @file enhancing_bars.lua
--- @author Tetsouo
--- @version 2.0 - Standardized with spell_family
--- @date Created: 2025-10-30 | Updated: 2025-11-05
---============================================================================

local ENHANCING_BARS = {}

ENHANCING_BARS.spells = {

    --============================================================
    -- BAR-ELEMENT SPELLS (AoE) - Skill-based (cap 500 = +150)
    --============================================================
    ["Baraera"] = {
        description = "Increases wind resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "aoe",
        element = "Ice",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Wind resist: Skill-based, cap +150 @ 500 skill (AoE)",
        WHM = 13,
    },

    ["Barblizzara"] = {
        description = "Increases ice resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "aoe",
        element = "Fire",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Ice resist: Skill-based, cap +150 @ 500 skill (AoE)",
        WHM = 21,
    },

    ["Barfira"] = {
        description = "Increases fire resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "aoe",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Fire resist: Skill-based, cap +150 @ 500 skill (AoE)",
        WHM = 17,
    },

    ["Barstonra"] = {
        description = "Increases earth resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "aoe",
        element = "Wind",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Earth resist: Skill-based, cap +150 @ 500 skill (AoE)",
        WHM = 5,
    },

    ["Barthundra"] = {
        description = "Increases lightning resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "aoe",
        element = "Earth",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Thunder resist: Skill-based, cap +150 @ 500 skill (AoE)",
        WHM = 25,
    },

    ["Barwatera"] = {
        description = "Increases water resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "aoe",
        element = "Thunder",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Water resist: Skill-based, cap +150 @ 500 skill (AoE)",
        WHM = 9,
    },

    --============================================================
    -- BAR-ELEMENT SPELLS (Single) - Skill-based (cap 500 = +150)
    --============================================================
    ["Baraero"] = {
        description = "Increases wind resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "single",
        element = "Ice",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Wind resist: Skill-based, cap +150 @ 500 skill",
        RUN = 12,
        RDM = 13,
    },

    ["Barblizzard"] = {
        description = "Increases ice resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "single",
        element = "Fire",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Ice resist: Skill-based, cap +150 @ 500 skill",
        RUN = 20,
        RDM = 21,
    },

    ["Barfire"] = {
        description = "Increases fire resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "single",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Fire resist: Skill-based, cap +150 @ 500 skill",
        RUN = 16,
        RDM = 17,
    },

    ["Barstone"] = {
        description = "Increases earth resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "single",
        element = "Wind",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Earth resist: Skill-based, cap +150 @ 500 skill",
        RUN = 4,
        RDM = 5,
    },

    ["Barthunder"] = {
        description = "Increases lightning resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "single",
        element = "Earth",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Thunder resist: Skill-based, cap +150 @ 500 skill",
        RUN = 24,
        RDM = 25,
    },

    ["Barwater"] = {
        description = "Increases water resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarElement",
        target_type = "single",
        element = "Thunder",
        magic_type = "White",
        enhancing_skill_affects = true,
        effect = "Water resist: Skill-based, cap +150 @ 500 skill",
        RUN = 8,
        RDM = 9,
    },

    --============================================================
    -- BAR-STATUS SPELLS (AoE) - Fixed +20 resistance
    --============================================================
    ["Baramnesra"] = {
        description = "Increases amnesia resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 78,
    },

    ["Barblindra"] = {
        description = "Increases blind resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 18,
    },

    ["Barparalyzra"] = {
        description = "Increases paralysis resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Fire",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 12,
    },

    ["Barpetra"] = {
        description = "Increases petrification resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Wind",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 43,
    },

    ["Barpoisonra"] = {
        description = "Increases poison resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Thunder",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 10,
    },

    ["Barsilencera"] = {
        description = "Increases silence resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Ice",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 23,
    },

    ["Barsleepra"] = {
        description = "Increases sleep resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 7,
    },

    ["Barvira"] = {
        description = "Increases disease resistance for party members within area of effect.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "aoe",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = false,
        WHM = 39,
    },

    --============================================================
    -- BAR-STATUS SPELLS (Single) - Fixed +30 resistance
    --============================================================
    ["Baramnesia"] = {
        description = "Increases amnesia resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 76,
        RDM = 78,
    },

    ["Barblind"] = {
        description = "Increases blind resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 17,
        RDM = 18,
    },

    ["Barparalyze"] = {
        description = "Increases paralysis resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Fire",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 11,
        RDM = 12,
    },

    ["Barpetrify"] = {
        description = "Increases petrification resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Wind",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 42,
        RDM = 43,
    },

    ["Barpoison"] = {
        description = "Increases poison resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Thunder",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 9,
        RDM = 10,
    },

    ["Barsilence"] = {
        description = "Increases silence resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Ice",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 22,
        RDM = 23,
    },

    ["Barsleep"] = {
        description = "Increases sleep resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Light",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 6,
        RDM = 7,
    },

    ["Barvirus"] = {
        description = "Increases disease resistance.",
        skill = "Enhancing Magic",
        spell_family = "BarAilment",
        target_type = "single",
        element = "Water",
        magic_type = "White",
        enhancing_skill_affects = false,
        RUN = 38,
        RDM = 39,
    },
}

return ENHANCING_BARS
