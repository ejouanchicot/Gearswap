---============================================================================
--- WHM State Configuration - Job States & Modes
---============================================================================
--- Defines all WHM job states (Combat Modes, Casting Modes, Idle Modes).
---
--- Features:
---   • OffenseMode configuration (None/Melee ON) - weapon locking
---   • CastingMode configuration (Normal/Resistant) - spell accuracy
---   • IdleMode configuration (PDT/Refresh) - defensive idle
---   • CureMode, AfflatusMode, CureAutoTier, CombatMode, FastCast, AutoMedicine
---   • Keybind integration (see WHM_KEYBINDS.lua)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call WHMStates.configure() to initialize all states
---
--- @file    config/whm/WHM_STATES.lua
--- @author  ejouanchicot
--- @version 1.0.0
--- @date    Created: 2025-10-21
--- @requires Mote-Include (state, M objects)
---============================================================================
local WHMStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all WHM states
--- Must be called from user_setup() after Mote-Include is loaded.
--- Defines OffenseMode, CastingMode, IdleMode and the WHM-specific states.
function WHMStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- OffenseMode: Melee engagement configuration
    --- Options:
    ---   • 'None' - No melee, focus on healing/casting (default)
    ---   • 'Melee ON' - Enable melee mode (locks weapons)
    --- Keybind: none in WHM_KEYBINDS.lua
    --- Note: When Melee ON, main/sub/range are locked to prevent accidental swaps
    state.OffenseMode:options('None', 'Melee ON')
    state.OffenseMode:set('None') -- Default: healing/casting focus

    --- CastingMode: Spell accuracy configuration
    --- Options:
    ---   • 'Normal' - Standard casting gear (default, white in UI)
    ---   • 'Resistant' - Magic accuracy focused gear (for resistant enemies, green in UI)
    --- Keybind: Ctrl+Numpad6 to cycle
    state.CastingMode:options('Normal', 'Resistant')
    state.CastingMode:set('Normal') -- Default: standard casting (white)

    --- IdleMode: Idle/defensive stance configuration
    --- Options:
    ---   • 'PDT' - Physical Damage Taken reduction (defensive idle, default)
    ---   • 'Refresh' - MP recovery priority (for safe areas)
    --- Keybind: Ctrl+Numpad1 to cycle
    --- Default: PDT for safety
    state.IdleMode:options('PDT', 'Refresh')
    state.IdleMode:set('PDT') -- Default: defensive idle

    -- ==========================================================================
    -- WHM-SPECIFIC STATES
    -- ==========================================================================

    --- CureMode: Cure spell optimization mode
    --- Options:
    ---   • 'Potency' - Maximum cure potency (default, for safe casting)
    ---   • 'SIRD' - Spell Interruption Rate Down (for casting under attack)
    --- Keybind: Ctrl+Numpad3 to cycle
    --- Note: UI updates handled by job_state_change in WHM_COMMANDS.lua
    state.CureMode = M('Potency', 'Cure Mode')
    state.CureMode:options('Potency', 'SIRD')
    state.CureMode:set('Potency') -- Default: max cure potency

    --- AfflatusMode: Afflatus stance selection
    --- Options:
    ---   • 'Solace' - Cure focus (Stoneskin on Cure, Bar-spell MDB, Sacrifice 7 effects)
    ---   • 'Misery' - Damage focus (Cura boost, Banish boost, Esuna 2 effects, Auspice Enlight)
    --- Keybind: Ctrl+Numpad5 to cycle
    --- Command: //gs c afflatus (auto-casts current stance)
    --- Note: Solace gear (Ebers Bliaut +3) equipped in midcast for Cure/Barspell bonuses
    state.AfflatusMode = M('Solace', 'Afflatus Mode')
    state.AfflatusMode:options('Solace', 'Misery')
    state.AfflatusMode:set('Solace') -- Default: Cure focus

    --- CureAutoTier: Automatic Cure tier selection
    --- Options:
    ---   • 'On' - Auto-downgrade Cure tier based on target HP missing (MP efficient, default)
    ---   • 'Off' - Always use the Cure tier you manually selected (for Stoneskin farming)
    --- Keybind: Ctrl+Numpad4 to cycle
    --- Note: When Off, casting Cure VI on low HP target still gives small Stoneskin (HP healed based)
    state.CureAutoTier = M('On', 'Cure Auto-Tier')
    state.CureAutoTier:options('On', 'Off')
    state.CureAutoTier:set('On') -- Default: MP efficient auto-tier

    --- CombatMode: Weapon lock configuration
    --- Options:
    ---   • 'Off' - Weapons can swap freely (default, for casting builds)
    ---   • 'On' - Weapons locked (main/sub/range/ammo stay equipped during combat)
    --- Keybind: Ctrl+Numpad2 to cycle
    --- Note: When On, prevents accidental weapon swaps during melee combat
    state.CombatMode = M {
        ['description'] = 'Combat Mode',
        'Off', -- Weapons can swap freely
        'On'   -- Weapons locked (main/sub/range/ammo)
    }
    state.CombatMode:set('Off')

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
    state.FastCast:set('80')  -- Default: 80% (WHM has high FC)

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

return WHMStates
