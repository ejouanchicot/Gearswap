---============================================================================
--- PLD State Configuration - Job States & Modes
---============================================================================
--- Defines all PLD job states (Combat Modes, Weapon Sets, XP Mode, Rune Mode).
---
--- Features:
---   • HybridMode configuration (PDT/MDT)
---   • MainWeapon state with multiple weapon options
---   • XP Mode for Phalanx optimization (SIRD vs Potency)
---   • RuneMode for RUN subjob (Ignis/Gelus/Flabra/Tellus/Sulpor/Unda/Lux/Tenebrae)
---   • Keybind integration (Alt+1/Alt+2/Alt+3/Alt+4/Alt+5)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call PLDStates.configure() to initialize all states
---   • Call PLDStates.validate() to verify configuration (optional)
---
--- @file    config/pld/PLD_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
--- @requires Mote-Include (state, M objects)
---============================================================================
local PLDStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all PLD states
--- Must be called from user_setup() after Mote-Include is loaded.
---
--- @return void
function PLDStates.configure()
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
        'Burtgang', -- Relic sword (ultimate tank weapon)
        'BurtgangKC', -- Burtgang + Kraken Club (DNC subjob multi-attack)
        'Naegling', -- Savage Blade sword
        'Shining', -- Shining One (Great Sword)
        'Malevo' -- Malevolence (Club)
    }

    --- XP Mode: Phalanx optimization (RDM subjob)
    --- Options:
    ---   • 'On'  - Phalanx with SIRD (Spell Interruption Rate Down) - for XP/low level
    ---   • 'Off' - Phalanx with Potency (enhancing skill/duration) - for endgame
    --- Keybind: Alt+4 to cycle (RDM subjob only)
    state.Xp =
        M {
        ['description'] = 'Xp',
        'Off', -- Potency Phalanx (default)
        'On' -- SIRD Phalanx
    }

    --- RuneMode: Rune selection (RUN subjob)
    --- Keybind: Alt+5 to cycle (RUN subjob only)
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
function PLDStates.validate()
    -- Check HybridMode exists and has correct options
    if not state.HybridMode then
        return false, 'HybridMode state not configured'
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, 'MainWeapon state not configured'
    end


    -- Check XP mode exists
    if not state.Xp then
        return false, 'Xp state not configured'
    end

    -- Check RuneMode exists
    if not state.RuneMode then
        return false, 'RuneMode state not configured'
    end

    return true, 'All PLD states configured successfully'
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDStates
