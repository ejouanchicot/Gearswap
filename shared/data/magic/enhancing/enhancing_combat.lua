---============================================================================
--- ENHANCING MAGIC DATABASE - Combat Enhancement Module
---============================================================================
--- Combat-focused enhancement spells (23 total)
---
--- Spike Spells:
---   - Damage reflection based on INT + MAB
---   - Equipment: Duelist's Tights (+INT boost for spike damage)
---
--- Enspells:
---   - Elemental weapon damage scales with Enhancing Magic skill (no known cap)
---   - Equipment: Crocea Mors (+500%), Vitiation Sword (+400%), Ayanmo Manopolas +2 (+17), Ghostfyre Cape (+5)
---
--- Phalanx:
---   - Damage reduction scales with Enhancing Magic skill (cap 500 = -35 damage)
---   - Equipment: Sakpata's Sword (+5), Futhark Bandeau (+4-7), Souveran pieces (+4-5)
---
--- Haste/Flurry/Temper:
---   - Fixed attack speed/multi-attack rates (no skill scaling)
---   - No specific gear for potency
---
--- @file enhancing_combat.lua
--- @author Tetsouo
--- @version 2.1 - Improved alignment - Standardized with spell_family
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-11-05
---============================================================================

local ENHANCING_COMBAT = {}

ENHANCING_COMBAT.spells = {

    --============================================================
    -- SPIKE SPELLS - INT/MAB based, gear for INT boost
    --============================================================

    ["Blaze Spikes"] = {
        description             = "Fire damage on hit",
        skill                   = "Enhancing Magic",
        spell_family            = "Spikes",
        target_type             = "single",
        element                 = "Fire",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        effect                  = "Fire damage on hit: INT/2 + MAB/10",
        BLM                     = 10,
        RDM                     = 20,
        SCH                     = 30,
        RUN                     = 45,
    },

    ["Ice Spikes"] = {
        description             = "Ice damage on hit, may paralyze",
        skill                   = "Enhancing Magic",
        spell_family            = "Spikes",
        target_type             = "single",
        element                 = "Ice",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        effect                  = "Ice damage on hit: INT/2 + MAB/10, chance to Paralyze",
        BLM                     = 20,
        RDM                     = 40,
        SCH                     = 50,
        RUN                     = 65,
    },

    ["Shock Spikes"] = {
        description             = "Thunder damage on hit, may stun",
        skill                   = "Enhancing Magic",
        spell_family            = "Spikes",
        target_type             = "single",
        element                 = "Thunder",
        magic_type              = "Black",
        enhancing_skill_affects = false,
        effect                  = "Thunder damage on hit: INT/2 + MAB/10, chance to Stun",
        BLM                     = 30,
        RDM                     = 60,
        SCH                     = 70,
        RUN                     = 85,
    },

    --============================================================
    -- ENSPELLS - Skill-based (no known cap)
    --============================================================

    ["Enaero"] = {
        description             = "Adds wind damage to melee attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "I",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Wind damage: 3 + floor(Enhancing skill / 100)",
        RDM                     = 20,
    },

    ["Enaero II"] = {
        description             = "Add Wind dmg, lower target Ice res",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "II",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Wind damage: 3 + floor(Enhancing skill / 100), Ice resist -10",
        RDM                     = 54,
    },

    ["Enblizzard"] = {
        description             = "Adds ice damage to melee attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "I",
        element                 = "Ice",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Ice damage: 3 + floor(Enhancing skill / 100)",
        RDM                     = 22,
    },

    ["Enblizzard II"] = {
        description             = "Add Ice dmg, lower target Fire res",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "II",
        element                 = "Ice",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Ice damage: 3 + floor(Enhancing skill / 100), Fire resist -10",
        RDM                     = 56,
        main_job_only           = true,
    },

    ["Enfire"] = {
        description             = "Adds fire damage to melee attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "I",
        element                 = "Fire",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Fire damage: 3 + floor(Enhancing skill / 100)",
        RDM                     = 24,
        main_job_only           = true,
    },

    ["Enfire II"] = {
        description             = "Add Fire dmg, lower target Water res",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "II",
        element                 = "Fire",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Fire damage: 3 + floor(Enhancing skill / 100), Water resist -10",
        RDM                     = 58,
        main_job_only           = true,
    },

    ["Enstone"] = {
        description             = "Adds earth damage to melee attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "I",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Earth damage: 3 + floor(Enhancing skill / 100)",
        RDM                     = 18,
    },

    ["Enstone II"] = {
        description             = "Add Earth dmg, lower target Wind res",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "II",
        element                 = "Earth",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Earth damage: 3 + floor(Enhancing skill / 100), Wind resist -10",
        RDM                     = 52,
    },

    ["Enthunder"] = {
        description             = "Adds lightning damage to melee attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "I",
        element                 = "Thunder",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Thunder damage: 3 + floor(Enhancing skill / 100)",
        RDM                     = 16,
        main_job_only           = true,
    },

    ["Enthunder II"] = {
        description             = "Add Thunder dmg, lower target Earth res",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "II",
        element                 = "Thunder",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Thunder damage: 3 + floor(Enhancing skill / 100), Earth resist -10",
        RDM                     = 50,
    },

    ["Enwater"] = {
        description             = "Adds water damage to melee attacks.",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "I",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Water damage: 3 + floor(Enhancing skill / 100)",
        RDM                     = 27,
        main_job_only           = true,
    },

    ["Enwater II"] = {
        description             = "Add Water dmg, lower target Thunder res",
        skill                   = "Enhancing Magic",
        spell_family            = "Enspell",
        target_type             = "single",
        tier                    = "II",
        element                 = "Water",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Water damage: 3 + floor(Enhancing skill / 100), Thunder resist -10",
        RDM                     = 60,
        main_job_only           = true,
    },

    --============================================================
    -- FLURRY FAMILY - Fixed ranged attack speed
    --============================================================

    ["Flurry"] = {
        description             = "Increases ranged attack speed.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "I",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = false,
        effect                  = "Ranged attack delay -15%",
        RDM                     = 48,
    },

    ["Flurry II"] = {
        description             = "Increases ranged attack speed.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "II",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = false,
        effect                  = "Ranged attack delay -30%",
        RDM                     = 96,
        main_job_only           = true,
    },

    --============================================================
    -- HASTE FAMILY - Fixed attack speed
    --============================================================

    ["Haste"] = {
        description             = "Increases attack speed.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "I",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = false,
        effect                  = "Magic Haste +15% (150/1024)",
        WHM                     = 40,
        RDM                     = 48,
    },

    ["Haste II"] = {
        description             = "Increases attack speed.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "II",
        element                 = "Wind",
        magic_type              = "White",
        enhancing_skill_affects = false,
        effect                  = "Magic Haste +30% (307/1024)",
        RDM                     = 96,
        main_job_only           = true,
    },

    --============================================================
    -- PHALANX FAMILY - Skill-based (cap 500 = -35 damage)
    --============================================================

    ["Phalanx"] = {
        description             = "Reduces physical and magical damage taken.",
        skill                   = "Enhancing Magic",
        spell_family            = "Phalanx",
        target_type             = "single",
        tier                    = "I",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Damage reduction: Skill-based, cap -35 @ 500 skill",
        RDM                     = 33,
        RUN                     = 68,
        PLD                     = 77,
    },

    ["Phalanx II"] = {
        description             = "Reduces physical and magical damage taken.",
        skill                   = "Enhancing Magic",
        spell_family            = "Phalanx",
        target_type             = "single",
        tier                    = "II",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Damage reduction: Skill-based, cap -35 @ 500 skill",
        RDM                     = 75,
        main_job_only           = true,
    },

    --============================================================
    -- TEMPER FAMILY - Fixed multi-attack rates
    --============================================================

    ["Temper"] = {
        description             = "Increases Double Attack rate.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "I",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Double Attack: Skill-based, 5% @ <360 skill, then floor((skill-300)/10)%",
        RDM                     = 95,
        RUN                     = 99,
    },

    ["Temper II"] = {
        description             = "Increases Triple Attack rate.",
        skill                   = "Enhancing Magic",
        spell_family            = nil,
        target_type             = "single",
        tier                    = "II",
        element                 = "Light",
        magic_type              = "White",
        enhancing_skill_affects = true,
        effect                  = "Triple Attack: floor((skill-300)/10)%, no cap",
        RDM                     = 99,
        main_job_only           = true,
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENHANCING_COMBAT
