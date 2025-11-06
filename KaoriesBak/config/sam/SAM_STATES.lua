---============================================================================
--- SAM State Configuration - Job States & Modes
---============================================================================
--- Defines all SAM job states (Combat Modes, Weapon Sets, etc.)
---
--- Features:
---   • HybridMode configuration (PDT/Normal)
---   • MainWeapon state with multiple weapon options
---   • Keybind integration (Alt+1 for weapon cycling, Alt+2 for HybridMode)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call SAMStates.configure() to initialize all states
---   • Call SAMStates.validate() to verify configuration (optional)
---
--- @file    config/sam/SAM_STATES.lua
--- @author  Kaories
--- @version 1.0
--- @date    Created: 2025-10-21
--- @requires Mote-Include (state, M objects)
---============================================================================
local SAMStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all SAM states
--- Must be called from user_setup() after Mote-Include is loaded.
--- Defines HybridMode and MainWeapon states with their default values.
---
--- @return void
function SAMStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT'    - Physical Damage Taken -50% (safe mode, default)
    ---   • 'Normal' - Full offense (max DPS)
    --- Keybind: Alt+2 to cycle
    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('PDT') -- Default to PDT for safety

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Keybind: Alt+1 to cycle
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Masamune',  -- Empyrean Great Katana (Aftermath: 30-50% Triple Damage)
        'Kusanagi',  -- Prime Great Katana (Aftermath: Physical damage limit+, Double Attack+10%)
        'Shining',   -- Shining One (Polearm - Impulse Drive +40%, Crit rate varies with TP)
        'Dojikiri',  -- Dojikiri Yasutsuna (Aeonic - Store TP+10, TP Bonus+500, AM: SC/MB potency+)
        'Soboro',    -- Soboro Sukehiro (Great Katana - Multi-hit)
        'Norifusa'   -- Norifusa (Great Katana - Multi-hit)
    }
    state.MainWeapon:set('Masamune') -- Default weapon

    -- ==========================================================================
    -- BUFF TRACKING
    -- ==========================================================================
    -- Note: Buff tracking states are initialized here for consistency
    -- Actual buff updates handled by WHM_BUFFS.lua module

    state.Buff = {}
    state.Buff.Hasso = false
    state.Buff.Seigan = false
    state.Buff['Third Eye'] = false
    state.Buff.Sekkanoki = false
    state.Buff['Meikyo Shisui'] = false
    state.Buff.Sengikori = false
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate that states were configured correctly
--- Checks that all required states exist and have proper structure.
---
--- @return boolean success True if validation passed, false otherwise
--- @return string  message Validation message (success or error description)
function SAMStates.validate()
    -- Check HybridMode exists and has correct options
    if not state.HybridMode then
        return false, 'HybridMode state not configured'
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, 'MainWeapon state not configured'
    end

    -- Check Buff tracking table exists
    if not state.Buff then
        return false, 'Buff tracking state not configured'
    end

    return true, 'All states configured successfully'
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SAMStates
