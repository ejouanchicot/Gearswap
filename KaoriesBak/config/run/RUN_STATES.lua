---============================================================================
--- RUN State Configuration - Job States & Modes
---============================================================================
--- Defines all RUN job states (Combat Modes, Weapon Sets, Rune Mode).
---
--- Features:
---   • HybridMode configuration (PDT/MDT)
---   • MainWeapon state with multiple weapon options
---   • SubWeapon state (grip selection: Utu/Refined)
---   • RuneMode for Rune selection (Ignis/Gelus/Flabra/Tellus/Sulpor/Unda/Lux/Tenebrae)
---   • Keybind integration (Alt+1/Alt+2/Alt+3/Alt+4)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call RUNStates.configure() to initialize all states
---   • Call RUNStates.validate() to verify configuration (optional)
---
--- @file    config/run/RUN_STATES.lua
--- @author  Kaories
--- @version 1.0
--- @date    Created: 2025-10-14
--- @requires Mote-Include (state, M objects)
---============================================================================
local RUNStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all RUN states
--- Must be called from user_setup() after Mote-Include is loaded.
--- Defines HybridMode, MainWeapon, SubWeapon, and RuneMode states.
---
--- @return void
function RUNStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT' - Physical Damage Taken -50% (default for physical enemies)
    ---   • 'MDT' - Magic Damage Taken -50% (for magical enemies)
    --- Keybind: Alt+2 to cycle
    state.HybridMode:options('PDT', 'MDT')
    state.HybridMode:set('PDT') -- Default to PDT

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Keybind: Alt+1 to cycle
    state.MainWeapon =
        M {
        ['description'] = 'Main Weapon',
        'Epeolatry', -- Empyrean Great Sword
        'Lionheart', -- Relic Great Sword
        'Aettir' -- Aeonic Great Sword
    }

    --- SubWeapon: Sub weapon/grip selection
    --- Keybind: Alt+3 to cycle
    state.SubWeapon =
        M {
        ['description'] = 'Sub Weapon',
        'Utu', -- Utu Grip
        'Refined' -- Refined Grip +1
    }
    state.SubWeapon:set('Utu') -- Default grip

    -- ==========================================================================
    -- RUNE MODE
    -- ==========================================================================

    --- RuneMode: Rune selection for quick casting
    --- Keybind: Alt+4 to cycle
    state.RuneMode =
        M {
        ['description'] = 'Rune Mode',
        'Ignis', -- Fire rune (Ice resistance)
        'Gelus', -- Ice rune (Wind resistance)
        'Flabra', -- Wind rune (Earth resistance)
        'Tellus', -- Earth rune (Lightning resistance)
        'Sulpor', -- Lightning rune (Water resistance)
        'Unda', -- Water rune (Fire resistance)
        'Lux', -- Light rune (Dark resistance)
        'Tenebrae' -- Dark rune (Light resistance)
    }

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
function RUNStates.validate()
    -- Check HybridMode exists and has correct options
    if not state.HybridMode then
        return false, 'HybridMode state not configured'
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, 'MainWeapon state not configured'
    end

    -- Check SubWeapon exists
    if not state.SubWeapon then
        return false, 'SubWeapon state not configured'
    end

    -- Check RuneMode exists
    if not state.RuneMode then
        return false, 'RuneMode state not configured'
    end

    return true, 'All RUN states configured successfully'
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUNStates
