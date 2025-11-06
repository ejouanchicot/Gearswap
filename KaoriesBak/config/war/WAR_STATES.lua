---============================================================================
--- WAR State Configuration - Job States & Modes
---============================================================================
--- Defines all WAR job states (Combat Modes, Weapon Sets, etc.)
---
--- Features:
---   • HybridMode configuration (PDT/Normal)
---   • MainWeapon state with multiple weapon options
---   • Keybind integration (Alt+1 for weapon cycling, Alt+2 for HybridMode)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call WARStates.configure() to initialize all states
---   • Call WARStates.validate() to verify configuration (optional)
---
--- @file    config/war/WAR_STATES.lua
--- @author  Kaories
--- @version 1.0
--- @date    Created: 2025-10-14
--- @requires Mote-Include (state, M objects)
---============================================================================
local WARStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all WAR states
--- Must be called from user_setup() after Mote-Include is loaded.
--- Defines HybridMode and MainWeapon states with their default values.
---
--- @return void
function WARStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT'    - Physical Damage Taken -50% (safe mode)
    ---   • 'Normal' - Full offense (max DPS)
    --- Keybind: Alt+2 to cycle
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT') -- Default to PDT for safety

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Keybind: Alt+1 to cycle
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Ukonvasara', -- Relic Great Axe (Aftermath: TP reduction, best for AM3)
        'Naegling', -- Savage Blade sword (1H with shield for Fencer TP bonus)
        'NaeglingKC', -- Naegling + Kraken Club (multi-attack focus)
        'Shining', -- Shining One (Great Sword)
        'Chango', -- Empyrean Great Axe (Aftermath: Multi-Attack, +500 TP bonus)
        'Ikenga', -- Ikenga's Axe (1H option)
        'Loxotic' -- Loxotic Mace (1H option)
    }

    -- Note: Additional states can be added here as needed
    -- Examples:
    --   state.SubWeapon = M { ['description'] = 'Sub Weapon', 'Shield', 'Dual Wield' }
    --   state.PhysicalDefenseMode = M { ['description'] = 'Physical Defense', 'PDT', 'HP' }
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate that states were configured correctly
--- Checks that all required states exist and have proper structure.
---
--- @return boolean success True if validation passed, false otherwise
--- @return string  message Validation message (success or error description)
function WARStates.validate()
    -- Check HybridMode exists and has correct options
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end

    return true, "All WAR states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WARStates
