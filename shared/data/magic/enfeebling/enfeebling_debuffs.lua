---============================================================================
--- ENFEEBLING MAGIC DATABASE - Debuff Spells Module
---============================================================================
--- Stat and performance debuff spells (17 total)
---
--- Contents:
---   - Paralyze family (2): Paralyze I/II (Interrupt actions)
---   - Slow family (2): Slow I/II (Delay between attacks)
---   - Blind family (2): Blind I/II (Accuracy down)
---   - Gravity family (2): Gravity I/II (Movement speed down)
---   - Red Magic (9): Distract I/II/III, Frazzle I/II/III, Addle I/II (RDM job spells)
---
--- @file enfeebling_debuffs.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local ENFEEBLING_DEBUFFS = {}

ENFEEBLING_DEBUFFS.spells = {

    ---========================================================================
    --- PARALYZE FAMILY - Ice Element (Status Effects)
    ---========================================================================
    --- Enfeebling Type: MACC (Tier I) / MND_POTENCY (Tier II)

    ["Paralyze"] = {
        description             = "Inflicts paralysis.",
        element                 = "Ice",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 6,
        WHM                     = 4,
        notes                   = "Chance to interrupt actions. Success rate: Magic Accuracy. RDM/WHM.",
    },

    ["Paralyze II"] = {
        description             = "Inflicts paralysis.",
        element                 = "Ice",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "mnd_potency",
        RDM                     = 75,
        notes                   = "Enhanced paralysis. Chance to interrupt actions. Potency: MND. RDM-only.",
    },

    ---========================================================================
    --- SLOW FAMILY - Earth Element (Attack Speed Down)
    ---========================================================================
    --- Enfeebling Type: MACC (Tier I) / MND_POTENCY (Tier II)

    ["Slow"] = {
        description             = "Slows attacks.",
        element                 = "Earth",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 13,
        WHM                     = 13,
        notes                   = "Reduces attack speed (~14% delay). Success rate: Magic Accuracy. RDM/WHM.",
    },

    ["Slow II"] = {
        description             = "Slows attacks.",
        element                 = "Earth",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "mnd_potency",
        RDM                     = 75,
        notes                   = "Enhanced slow. Reduces attack speed (~30% delay). Potency: MND. RDM-only.",
    },

    ---========================================================================
    --- BLIND FAMILY - Dark Element (Accuracy Down)
    ---========================================================================
    --- Enfeebling Type: MACC (Tier I) / INT_POTENCY (Blind II)

    ["Blind"] = {
        description             = "Lowers accuracy.",
        element                 = "Dark",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "single",
        enfeebling_type         = "macc",
        BLM                     = 4,
        RDM                     = 8,
        notes                   = "Reduces accuracy. Success rate: Magic Accuracy. BLM/RDM.",
    },

    ["Blind II"] = {
        description             = "Lowers accuracy.",
        element                 = "Dark",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "single",
        enfeebling_type         = "int_potency",
        RDM                     = 75,
        notes                   = "Enhanced blind. Reduces accuracy. Potency: INT. RDM-only.",
    },

    ---========================================================================
    --- GRAVITY FAMILY - Wind Element (Movement Speed Down)
    ---========================================================================
    --- Enfeebling Type: MACC (Tier I) / POTENCY (Gravity II)

    ["Gravity"] = {
        description             = "Lowers movement speed.",
        element                 = "Wind",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 21,
        notes                   = "Reduces movement speed (~50%). Success rate: Magic Accuracy. RDM-only.",
    },

    ["Gravity II"] = {
        description             = "Lowers movement speed.",
        element                 = "Wind",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "single",
        enfeebling_type         = "potency",
        RDM                     = 98,
        notes                   = "Enhanced gravity. Reduces movement speed (~75%). Potency scaling. RDM-only.",
    },

    ---========================================================================
    --- RED MAGIC - DISTRACT (Evasion Down)
    ---========================================================================
    --- Enfeebling Type: MACC (Tier I-II) / SKILL_MND_POTENCY (Tier III)

    ["Distract"] = {
        description             = "Lowers evasion.",
        element                 = "Ice",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 35,
        notes                   = "Reduces evasion. Success rate: Magic Accuracy. RDM-only.",
    },

    ["Distract II"] = {
        description             = "Lowers evasion.",
        element                 = "Ice",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 85,
        notes                   = "Enhanced evasion reduction. Success rate: Magic Accuracy. RDM-only.",
    },

    ["Distract III"] = {
        description             = "Lowers evasion.",
        element                 = "Ice",
        tier                    = "III",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "skill_mnd_potency",
        RDM                     = 99,
        notes                   = "Maximum evasion reduction. Potency: Skill + MND. Job Point ability (RDM).",
    },

    ---========================================================================
    --- RED MAGIC - FRAZZLE (Magic Evasion Down)
    ---========================================================================
    --- Enfeebling Type: MACC (Tier I-II) / SKILL_MND_POTENCY (Tier III)

    ["Frazzle"] = {
        description             = "Lowers magic evasion.",
        element                 = "Dark",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 42,
        notes                   = "Reduces magic evasion. Success rate: Magic Accuracy. RDM-only.",
    },

    ["Frazzle II"] = {
        description             = "Lowers magic evasion.",
        element                 = "Dark",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 92,
        notes                   = "Enhanced magic evasion reduction. Success rate: Magic Accuracy. RDM-only.",
    },

    ["Frazzle III"] = {
        description             = "Lowers magic evasion.",
        element                 = "Dark",
        tier                    = "III",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "skill_mnd_potency",
        RDM                     = 99,
        notes                   = "Maximum magic evasion reduction. Potency: Skill + MND. Job Point ability (RDM).",
    },

    ---========================================================================
    --- RED MAGIC - ADDLE (Magic Accuracy Down + Casting Time Up)
    ---========================================================================
    --- Enfeebling Type: MACC (Addle I) / MND_POTENCY (Addle II)

    ["Addle"] = {
        description             = "Lowers m.acc, raises cast time.",
        element                 = "Fire",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "macc",
        RDM                     = 83,
        WHM                     = 93,
        notes                   = "Reduces magic accuracy and increases casting time. Success rate: Magic Accuracy. RDM/WHM.",
    },

    ["Addle II"] = {
        description             = "Lowers m.acc, raises cast time.",
        element                 = "Fire",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Red",
        type                    = "single",
        enfeebling_type         = "mnd_potency",
        RDM                     = 99,
        notes                   = "Enhanced magic accuracy reduction and casting time increase. Potency: MND. Job Point ability (RDM).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENFEEBLING_DEBUFFS
