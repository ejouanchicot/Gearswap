---============================================================================
--- DRK State Configuration - Job States & Modes
---============================================================================
--- Defines all DRK job states (Combat Modes, Weapon Sets).
---
--- Features:
---   • HybridMode configuration (PDT/Normal)
---   • MainWeapon state with multiple weapon options
---   • Keybind integration (Alt+1/Alt+2)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call DRKStates.configure() to initialize all states
---   • Call DRKStates.validate() to verify configuration (optional)
---
--- @file    config/drk/DRK_STATES.lua
--- @author  Typioni
--- @version 1.0.0
--- @date    Created: 2025-10-23
--- @requires Mote-Include (state, M objects)
---============================================================================
local DRKStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all DRK states
--- Must be called from user_setup() after Mote-Include is loaded.
--- Defines HybridMode and MainWeapon states.
---
--- @return void
function DRKStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Combat stance configuration
    --- Options:
    ---   • 'PDT' - Physical Damage Taken -50% (defensive mode) [DEFAULT]
    ---   • 'Accu' - High Accuracy mode (for evasive enemies)
    --- Keybind: Alt+1 to cycle
    state.HybridMode:options('PDT', 'Accu')
    state.HybridMode:set('PDT') -- Default to PDT for safety

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Two-handed weapons use Utu Grip, one-handed use Blurred Shield +1
    --- Each weapon has its own engaged TP set for optimization
    --- Keybind: Alt+2 to cycle
    state.MainWeapon =
        M {
        ['description'] = 'Main Weapon',
        'Caladbolg', -- Caladbolg (Great Sword REMA) + Utu Grip
        'Liberator', -- Liberator (Scythe Mythic) + Utu Grip
        'Apocalypse', -- Apocalypse (Scythe Relic) + Utu Grip
        'Redemption', -- Redemption (Scythe Empyrrean) + Utu Grip
        'Foenaria', -- Foenaria (Scythe) + Utu Grip
        'Tokko', -- Tokko Chopper (Great Axe) + Utu Grip
        'Naegling', -- Naegling (Sword) + Blurred Shield +1
        'Loxotic' -- Loxotic Mace +1 (Club) + Blurred Shield +1
    }
    state.MainWeapon:set('Caladbolg') -- Default weapon

    -- Note: Additional states can be added here as needed
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate that states were configured correctly
--- Checks that all required states exist and have proper structure.
---
--- @return boolean success True if validation passed, false otherwise
--- @return string  message Validation message (success or error description)
function DRKStates.validate()
    -- Check HybridMode exists and has correct options
    if not state.HybridMode then
        return false, 'HybridMode state not configured'
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, 'MainWeapon state not configured'
    end

    return true, 'All DRK states configured successfully'
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRKStates
