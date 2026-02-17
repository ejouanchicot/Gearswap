---============================================================================
--- THF State Configuration - Centralized State Management
---============================================================================
--- Centralizes all THF state definitions for consistency and maintainability.
--- This module configures job-specific states used throughout the THF system.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal)
---   • Weapon selection (MainWeapon: 8 options, SubWeapon: 8 options)
---   • Abyssea proc system (AbyProc: On/Off, AbyWeapon: 7 weapon types)
---   • Treasure Hunter modes (TreasureMode: Tag/SATA/Full)
---   • Ranged weapon lock (RangeLock: On/Off for Exalted Crossbow + Acid Bolt)
---   • Default state values for optimal safety
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum DPS
---   • MainWeapon: Primary weapon selection (Vajra default - best DPS)
---   • SubWeapon: Offhand weapon selection (Centovente default - REMA dagger)
---   • AbyProc: Enable/disable Abyssea proc mode (false default)
---   • AbyWeapon: Weapon type for Abyssea procs (Sword default)
---   • TreasureMode: Tag = Quick TH tag, SATA = SA/TA combo, Full = Max TH gear
---   • RangeLock: Lock ranged weapons (Off default, enabled via //gs c range)
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- @file    config/thf/THF_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local THFStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all THF states (called from user_setup in main file)
function THFStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    -- HybridMode: PDT (Physical Damage Taken -50%) or Normal (Maximum DPS)
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')  -- Default to PDT for safety

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    -- MainWeapon: Primary weapon selection
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Vajra',        -- Relic dagger (best DPS)
        'TwashtarM',    -- Empyrean dagger (crit build)
        'Mpu Gandring', -- REMA dagger (DNC shared)
        'Tauret',       -- High accuracy dagger
        'Naegling',     -- Savage Blade sword
        'Malevolence',  -- Magic damage club
        'Dagger'        -- Generic dagger (for weapon sets)
    }
    state.MainWeapon:set('Vajra')  -- Default to Vajra (best DPS)

    -- SubWeapon: Offhand weapon selection
    state.SubWeapon = M {
        ['description'] = 'Sub Weapon',
        'Centovente',   -- REMA dagger offhand (best)
        'Tanmogayi',    -- High DPS sword offhand
        'Kraken',  -- High magic damage club offhand
    }
    state.SubWeapon:set('Centovente')  -- Default to Centovente (REMA)

    -- ========================================
    -- ABYSSEA PROC SYSTEM
    -- ========================================

    -- AbyProc: Enable/disable Abyssea proc mode (for /WAR subjob)
    state.AbyProc = M(false, 'Aby Proc')

    -- AbyWeapon: Weapon type for Abyssea procs
    state.AbyWeapon = M {
        ['description'] = 'Aby Weapon',
        'Dagger2',      -- Dagger
        'Sword',        -- Sword
        'Club',         -- Club
        'Great Sword',  -- Great Sword
        'Polearm',      -- Polearm
        'Staff',        -- Staff
        'Scythe'        -- Scythe
    }
    state.AbyWeapon:set('Sword')  -- Default to Sword

    -- ========================================
    -- TREASURE HUNTER SYSTEM
    -- ========================================

    -- TreasureMode: Treasure Hunter application strategy
    -- REQUIRED by UI_MANAGER.are_states_ready() for THF
    state.TreasureMode = M {
        ['description'] = 'Treasure Hunter Mode',
        'Tag',   -- Quick TH tag (minimal gear for speed)
        'SATA',  -- SA/TA combo with TH (balanced DPS + TH)
        'Full'   -- Maximum TH gear (full TH optimization)
    }
    state.TreasureMode:set('Tag')  -- Default to Tag (fastest)

    -- ========================================
    -- RANGED WEAPON LOCK
    -- ========================================

    -- RangeLock: Lock ranged weapons (Exalted Crossbow + Acid Bolt)
    -- Enabled via //gs c range command (auto-equip + lock + /ra)
    state.RangeLock = M(false, 'Range Lock')

    -- ========================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ========================================

    --- FastCast: Fast Cast % for watchdog timeout calculation
    --- Set this to your total Fast Cast % from gear/traits
    --- Formula: adjusted_cast = base_cast × (1 - FC%/100)
    --- Cap: 80% maximum (FFXI mechanics)
    state.FastCast = M {
        ['description'] = 'Fast Cast %',
        0, 10, 20, 30, 40, 50, 60, 70, 80
    }
    state.FastCast:set(0)  -- Default: 0% (adjust based on your gear)
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate all THF states are configured correctly
--- @return boolean success True if all states valid
--- @return string message Validation result message
function THFStates.validate()
    -- Check required states exist
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end
    if not state.SubWeapon then
        return false, "SubWeapon state not configured"
    end
    if not state.AbyProc then
        return false, "AbyProc state not configured"
    end
    if not state.AbyWeapon then
        return false, "AbyWeapon state not configured"
    end
    if not state.TreasureMode then
        return false, "TreasureMode state not configured"
    end
    if not state.RangeLock then
        return false, "RangeLock state not configured"
    end

    return true, "All THF states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return THFStates
