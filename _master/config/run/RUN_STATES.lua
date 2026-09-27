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
---   • Keys are bound in RUN_KEYBINDS.lua (Ctrl+Numpad1/2/3/9)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call RUNStates.configure() to initialize all states
---
--- @file    config/run/RUN_STATES.lua
--- @author  ejouanchicot
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
--- Defines HybridMode, MainWeapon, SubWeapon, RuneMode, FastCast and AutoMedicine.
function RUNStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT' - Physical Damage Taken -50% (default for physical enemies)
    ---   • 'MDT' - Magic Damage Taken -50% (for magical enemies)
    --- Keybind: Ctrl+Numpad9 to cycle
    state.HybridMode:options('PDT', 'MDT')
    state.HybridMode:set('PDT') -- Default to PDT

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Keybind: Ctrl+Numpad1 to cycle
    state.MainWeapon =
        M {
        ['description'] = 'Main Weapon',
        'Epeolatry', -- Empyrean Great Sword
        'Lycurgos', -- Lycurgos (Great Axe, 2H - no grip)
        --'Loxotic' -- Loxotic Mace +1 (Club) + Blurred Shield +1
        --'Lionheart', -- Aeonic Great Sword
        --'Aettir' -- Oboro Great Sword
    }

    --- SubWeapon: Sub weapon/grip selection
    --- Keybind: Ctrl+Numpad2 to cycle
    state.SubWeapon =
        M {
        ['description'] = 'Sub Weapon',
        'Utu', -- Utu Grip
        'Refined' -- Refined Grip +1
    }
    state.SubWeapon:set('Refined') -- Default grip

    -- ==========================================================================
    -- RUNE MODE
    -- ==========================================================================

    --- RuneMode: Rune selection for quick casting
    --- Keybind: Ctrl+Numpad3 to cycle
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

    -- ==========================================================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ==========================================================================

    --- FastCast: Fast Cast % for watchdog timeout calculation
    --- Set this to your total Fast Cast % from gear/traits
    --- Formula: adjusted_cast = base_cast × (1 - FC%/100)
    --- Cap: 80% maximum (FFXI mechanics)
    state.FastCast = M {
        ['description'] = 'Fast Cast %',
        '0', '10', '20', '30', '40', '50', '60', '70', '80'
    }
    state.FastCast:set('30')  -- Default: 30% (RUN has moderate FC)

    -- Universal toggle, created here rather than centrally: the keybind HUD
    -- renders from user_setup() and caches what it reads, so a state added
    -- afterwards shows as N/A until something forces a redraw.
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if ok and AutoMedicine then
        AutoMedicine.init(state, M)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUNStates
