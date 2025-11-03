---============================================================================
--- COR State Configuration - Centralized State Management
---============================================================================
--- Centralizes all COR state definitions for consistency and maintainability.
--- This module configures job-specific states used throughout the COR system.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal)
---   • Weapon selection (MainWeapon: melee, RangeWeapon: ranged options)
---   • Quick Draw element selection (8 elements for Quick Draw shots)
---   • Phantom Roll configuration (MainRoll/SubRoll: 20 different rolls each)
---   • Luzaf's Ring mode (ON = 16y range, OFF = 8y range)
---   • Default state values for optimal gameplay
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum DPS
---   • MainWeapon: Primary melee weapon (Naegling default - Savage Blade)
---   • RangeWeapon: Ranged weapon selection (Anarchy default - best DPS)
---   • QuickDraw: Element selection for Quick Draw shots (Light default)
---   • LuzafRing: Roll range mode (ON = 16y Luzaf bonus, OFF = 8y standard)
---   • MainRoll: Primary Phantom Roll selection (Chaos default - Attack+)
---   • SubRoll: Secondary Phantom Roll selection (Samurai default - Store TP+)
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- @file    config/cor/COR_STATES.lua
--- @author  Typioni
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local CORStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all COR states (called from user_setup in main file)
function CORStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    -- HybridMode: PDT (Physical Damage Taken -50%) or Normal (Maximum DPS)
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')  -- Default to PDT for safety

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    -- MainWeapon: Primary melee weapon selection
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Naegling'      -- Savage Blade sword (best melee option)
    }
    state.MainWeapon:set('Naegling')  -- Default to Naegling

    -- RangeWeapon: Ranged weapon selection
    state.RangeWeapon = M {
        ['description'] = 'Range Weapon',
        'Anarchy',      -- REMA gun (best DPS)
        'Compensator'   -- High-tier gun (alternative)
    }
    state.RangeWeapon:set('Anarchy')  -- Default to Anarchy (best DPS)

    -- ========================================
    -- QUICK DRAW ELEMENT SELECTION
    -- ========================================

    -- QuickDraw: Element selection for Quick Draw shots
    state.QuickDraw = M {
        ['description'] = 'Quick Draw Element',
        'Light',        -- Light Shot (most versatile)
        'Fire',         -- Fire Shot
        'Ice',          -- Ice Shot
        'Wind',         -- Wind Shot
        'Earth',        -- Earth Shot
        'Thunder',      -- Thunder Shot
        'Water',        -- Water Shot
        'Dark'          -- Dark Shot
    }
    state.QuickDraw:set('Light')  -- Default to Light (most common)

    -- ========================================
    -- LUZAF'S RING MODE
    -- ========================================

    -- LuzafRing: Toggle Luzaf's Ring mode (affects roll range)
    -- ON = 16y range (with Luzaf's Ring bonus)
    -- OFF = 8y range (standard roll range)
    state.LuzafRing = M {
        ['description'] = 'Luzaf Ring',
        'ON',           -- 16y range (Luzaf's Ring equipped)
        'OFF'           -- 8y range (standard)
    }
    state.LuzafRing:set('ON')  -- Default to ON (16y range)

    -- ========================================
    -- PHANTOM ROLL SELECTION
    -- ========================================

    -- MainRoll: Primary Phantom Roll selection (most common rolls first)
    state.MainRoll = M {
        ['description'] = 'Main Roll',
        "Chaos Roll",        -- Attack+
        "Samurai Roll",      -- Store TP+
        "Hunter's Roll",     -- Accuracy+
        "Tactician's Roll",  -- Regain+
        "Allies' Roll",      -- Skillchain Damage+
        "Wizard's Roll",     -- MAB+
        "Warlock's Roll",    -- MACC+
        "Corsair's Roll",    -- Exp/CP+
        "Caster's Roll",     -- Fast Cast+
        "Courser's Roll",    -- Snapshot+
        "Blitzer's Roll",    -- Delay Reduction+
        "Fighter's Roll",    -- Double-Attack+
        "Rogue's Roll",      -- Crit Hit Rate+
        "Gallant's Roll",    -- PDT-
        "Evoker's Roll",     -- Refresh+
        "Bolter's Roll",     -- Movement Speed+
        "Miser's Roll",      -- Save TP+
        "Companion's Roll",  -- Pet Regain/Regen+
        "Avenger's Roll",    -- Counter Rate+
        "Naturalist's Roll"  -- Enh. Magic Duration+
    }
    state.MainRoll:set("Chaos Roll")  -- Default to Chaos (Attack+ - most used)

    -- SubRoll: Secondary Phantom Roll selection
    state.SubRoll = M {
        ['description'] = 'Sub Roll',
        "Samurai Roll",      -- Store TP+
        "Chaos Roll",        -- Attack+
        "Hunter's Roll",     -- Accuracy+
        "Tactician's Roll",  -- Regain+
        "Allies' Roll",      -- Skillchain Damage+
        "Wizard's Roll",     -- MAB+
        "Warlock's Roll",    -- MACC+
        "Corsair's Roll",    -- Exp/CP+
        "Caster's Roll",     -- Fast Cast+
        "Courser's Roll",    -- Snapshot+
        "Blitzer's Roll",    -- Delay Reduction+
        "Fighter's Roll",    -- Double-Attack+
        "Rogue's Roll",      -- Crit Hit Rate+
        "Gallant's Roll",    -- PDT-
        "Evoker's Roll",     -- Refresh+
        "Bolter's Roll",     -- Movement Speed+
        "Miser's Roll",      -- Save TP+
        "Companion's Roll",  -- Pet Regain/Regen+
        "Avenger's Roll",    -- Counter Rate+
        "Naturalist's Roll"  -- Enh. Magic Duration+
    }
    state.SubRoll:set("Samurai Roll")  -- Default to Samurai (Store TP+ - pairs well with Chaos)
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate all COR states are configured correctly
--- @return boolean success True if all states valid
--- @return string message Validation result message
function CORStates.validate()
    -- Check required states exist
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end
    if not state.RangeWeapon then
        return false, "RangeWeapon state not configured"
    end
    if not state.QuickDraw then
        return false, "QuickDraw state not configured"
    end
    if not state.LuzafRing then
        return false, "LuzafRing state not configured"
    end
    if not state.MainRoll then
        return false, "MainRoll state not configured"
    end
    if not state.SubRoll then
        return false, "SubRoll state not configured"
    end

    return true, "All COR states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return CORStates
