---============================================================================
--- GEO State Configuration - Centralized State Management
---============================================================================
--- Centralizes all GEO state definitions for consistency and maintainability.
--- This module configures job-specific states used throughout the GEO system.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal, CombatMode: weapon locking)
---   • Luopan modes (LuopanMode: DT/DPS pet focus)
---   • Weapon selection (MainWeapon: Idris, SubWeapon: Genmei Shield)
---   • Indicolure system (Self/Entrust mode + 27 Indi spells)
---   • Geocolure system (26 Geo spells for Luopan bubble)
---   • Elemental nuke system (Light/Dark + Single/AOE + Tier selection)
---   • Default state values for optimal gameplay
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum DPS
---   • CombatMode: Off = free swapping, On = weapon slots locked
---   • LuopanMode: DT = Luopan survival, DPS = damage optimization
---   • MainWeapon: Idris (REMA - best handbell)
---   • SubWeapon: Genmei Shield (PDT shield)
---   • IndicolureMode: Self = Indi on self, Entrust = Indi on party member
---   • MainIndi: Indicolure spell selection (buffs on self/party)
---   • MainGeo: Geocolure spell selection (Luopan bubble - mostly debuffs)
---   • MainLightSpell: Fire/Aero/Thunder (Light-based nukes)
---   • MainDarkSpell: Blizzard/Stone/Water (Dark-based nukes)
---   • SpellTier: V/IV/III/II/I (nuke tier)
---   • MainLightAOE: Fira/Aera/Thundara (Light AOE spells)
---   • MainDarkAOE: Blizzara/Stonera/Watera (Dark AOE spells)
---   • AOETier: III/II/I (AOE spell tier)
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- @file    config/geo/GEO_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local GEOStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all GEO states (called from user_setup in main file)
function GEOStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    -- HybridMode: PDT (Physical Damage Taken -50%) or Normal (Maximum DPS)
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')  -- Default to PDT for safety

    -- CombatMode: Lock weapons when engaged (prevents swapping)
    state.CombatMode = M {
        ['description'] = 'Combat Mode',
        'Off',  -- Weapons can swap freely
        'On'    -- Weapons locked (main/sub/range/ammo)
    }
    state.CombatMode:set('Off')  -- Default to Off (free swapping)

    -- LuopanMode: Engaged gear focus when Luopan is active
    state.LuopanMode = M {
        ['description'] = 'Luopan Mode',
        'DT',   -- Luopan survival (PDT/MDT gear)
        'DPS'   -- Damage optimization
    }
    state.LuopanMode:set('DT')  -- Default to DT (Luopan survival)

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    -- MainWeapon: Primary weapon selection (handbell)
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Idris'  -- REMA handbell (best for GEO)
    }
    state.MainWeapon:set('Idris')  -- Default to Idris

    -- SubWeapon: Offhand weapon selection (shield)
    state.SubWeapon = M {
        ['description'] = 'Sub Weapon',
        'Genmei Shield'  -- PDT shield
    }
    state.SubWeapon:set('Genmei Shield')  -- Default to Genmei Shield

    -- ========================================
    -- INDICOLURE SYSTEM
    -- ========================================

    -- IndicolureMode: Indi spell on self vs Entrust on party member
    state.IndicolureMode = M {
        ['description'] = 'Indicolure Mode',
        'Self',     -- Indi spell on self
        'Entrust'   -- Indi spell on party member (requires Entrust ability active)
    }
    state.IndicolureMode:set('Self')  -- Default to Self

    -- MainIndi: Primary Indi spell selection (most used first)
    state.MainIndi = M {
        ['description'] = 'Main Indi Spell',
        -- Most used buffs first
        "Indi-Haste",        -- Haste+ (most common)
        "Indi-Fury",         -- Attack+
        "Indi-Precision",    -- Accuracy+
        "Indi-Refresh",      -- Refresh+
        "Indi-Barrier",      -- Defense+
        "Indi-Acumen",       -- MAB+
        "Indi-Focus",        -- MACC+
        "Indi-Voidance",     -- Evasion+
        "Indi-Attunement",   -- MDB+
        "Indi-Regen",        -- Regen+
        -- Stats buffs
        "Indi-STR",          -- STR+
        "Indi-DEX",          -- DEX+
        "Indi-VIT",          -- VIT+
        "Indi-AGI",          -- AGI+
        "Indi-INT",          -- INT+
        "Indi-MND",          -- MND+
        "Indi-CHR",          -- CHR+
        -- Debuffs (offensive)
        "Indi-Frailty",      -- Attack-
        "Indi-Malaise",      -- MDB-
        "Indi-Torpor",       -- Evasion-
        "Indi-Slow",         -- Magic Haste-
        "Indi-Languor",      -- Magic Attack/Defense-
        "Indi-Paralysis",    -- Adds Paralysis
        "Indi-Vex",          -- Magic Evasion-
        "Indi-Wilt",         -- Magic Defense-
        "Indi-Slip",         -- Accuracy-
        "Indi-Fade",         -- Magic Accuracy-
        "Indi-Gravity",      -- Movement Speed-
        "Indi-Fend",         -- Physical Defense-
        "Indi-Poison"        -- Adds Poison
    }
    state.MainIndi:set("Indi-Haste")  -- Default to Haste (most common)

    -- ========================================
    -- GEOCOLURE SYSTEM
    -- ========================================

    -- MainGeo: Primary Geo spell selection (Luopan bubble - debuffs first)
    state.MainGeo = M {
        ['description'] = 'Main Geo Spell',
        -- Most used debuffs first
        "Geo-Frailty",       -- Attack- (most common)
        "Geo-Malaise",       -- MDB-
        "Geo-Torpor",        -- Evasion-
        "Geo-Slow",          -- Magic Haste-
        "Geo-Languor",       -- Magic Attack/Defense-
        "Geo-Paralysis",     -- Adds Paralysis
        "Geo-Vex",           -- Magic Evasion-
        "Geo-Wilt",          -- Physical Defense-
        "Geo-Slip",          -- Accuracy-
        "Geo-Fade",          -- Magic Accuracy-
        "Geo-Gravity",       -- Movement Speed-
        "Geo-Fend",          -- Physical Defense-
        "Geo-Poison",        -- Adds Poison
        -- Buffs (less common for Geo)
        "Geo-Haste",         -- Haste+
        "Geo-Fury",          -- Attack+
        "Geo-Precision",     -- Accuracy+
        "Geo-Barrier",       -- Defense+
        "Geo-Acumen",        -- MAB+
        "Geo-Focus",         -- MACC+
        "Geo-Voidance",      -- Evasion+
        "Geo-Attunement",    -- MDB+
        "Geo-Regen",         -- Regen+
        -- Stats buffs
        "Geo-STR",           -- STR+
        "Geo-DEX",           -- DEX+
        "Geo-VIT",           -- VIT+
        "Geo-AGI",           -- AGI+
        "Geo-INT",           -- INT+
        "Geo-MND"            -- MND+
    }
    state.MainGeo:set("Geo-Frailty")  -- Default to Frailty (Attack- debuff)

    -- ========================================
    -- ELEMENTAL NUKE SYSTEM
    -- ========================================

    -- MainLightSpell: Light elemental spells (Fire/Wind/Thunder)
    state.MainLightSpell = M {
        ['description'] = 'Light Spell',
        "Fire",
        "Aero",
        "Thunder"
    }
    state.MainLightSpell:set("Fire")  -- Default to Fire

    -- MainDarkSpell: Dark elemental spells (Ice/Earth/Water)
    state.MainDarkSpell = M {
        ['description'] = 'Dark Spell',
        "Blizzard",
        "Stone",
        "Water"
    }
    state.MainDarkSpell:set("Blizzard")  -- Default to Blizzard

    -- SpellTier: Nuke spell tier (V/IV/III/II/I)
    -- Note: Tier "I" casts base spell (e.g., "Fire" not "Fire I")
    state.SpellTier = M {
        ['description'] = 'Spell Tier',
        "V",
        "IV",
        "III",
        "II",
        "I"
    }
    state.SpellTier:set("V")  -- Default to Tier V (highest)

    -- MainLightAOE: Light AOE elemental spells (-ra versions)
    state.MainLightAOE = M {
        ['description'] = 'Light AOE',
        "Fira",
        "Aera",
        "Thundara"
    }
    state.MainLightAOE:set("Fira")  -- Default to Fira

    -- MainDarkAOE: Dark AOE elemental spells (-ra versions)
    state.MainDarkAOE = M {
        ['description'] = 'Dark AOE',
        "Blizzara",
        "Stonera",
        "Watera"
    }
    state.MainDarkAOE:set("Blizzara")  -- Default to Blizzara

    -- AOETier: AOE spell tier (III/II/I)
    -- Note: Tier "I" casts base AOE (e.g., "Fira" not "Fira I")
    state.AOETier = M {
        ['description'] = 'AOE Tier',
        "III",
        "II",
        "I"
    }
    state.AOETier:set("III")  -- Default to Tier III (highest AOE)
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate all GEO states are configured correctly
--- @return boolean success True if all states valid
--- @return string message Validation result message
function GEOStates.validate()
    -- Check required states exist
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end
    if not state.CombatMode then
        return false, "CombatMode state not configured"
    end
    if not state.LuopanMode then
        return false, "LuopanMode state not configured"
    end
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end
    if not state.SubWeapon then
        return false, "SubWeapon state not configured"
    end
    if not state.IndicolureMode then
        return false, "IndicolureMode state not configured"
    end
    if not state.MainIndi then
        return false, "MainIndi state not configured"
    end
    if not state.MainGeo then
        return false, "MainGeo state not configured"
    end
    if not state.MainLightSpell then
        return false, "MainLightSpell state not configured"
    end
    if not state.MainDarkSpell then
        return false, "MainDarkSpell state not configured"
    end
    if not state.SpellTier then
        return false, "SpellTier state not configured"
    end
    if not state.MainLightAOE then
        return false, "MainLightAOE state not configured"
    end
    if not state.MainDarkAOE then
        return false, "MainDarkAOE state not configured"
    end
    if not state.AOETier then
        return false, "AOETier state not configured"
    end

    return true, "All GEO states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return GEOStates
