---============================================================================
--- DNC State Configuration - Job States & Modes
---============================================================================
--- Defines all DNC job states (Combat Modes, Weapon Sets, Step Management, etc.).
---
--- Features:
---   • HybridMode configuration (PDT/Normal)
---   • MainWeapon state with multiple weapon options
---   • Step Management (MainStep, AltStep, UseAltStep, CurrentStep)
---   • Climactic Flourish buff tracking
---   • Auto-trigger systems (ClimacticAuto, JumpAuto)
---   • CombatWeaponMode (TP bonus optimization modes)
---   • Keybind integration
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call DNCStates.configure() to initialize all states
---   • Call DNCStates.validate() to verify configuration (optional)
---
--- @file    config/dnc/DNC_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
--- @requires Mote-Include (state, M objects)
---============================================================================
local DNCStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all DNC states
--- Must be called from user_setup() after Mote-Include is loaded.
--- Defines all combat modes, weapon sets, step management, and auto-trigger states.
---
--- @return void
function DNCStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT'    - Physical Damage Taken -50% (safe mode)
    ---   • 'Normal' - Full offense (max DPS)
    --- Keybind: Alt+2 to cycle
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')  -- Default to PDT mode for safety

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Sub weapon automatically selected based on main weapon
    --- Keybind: Alt+1 to cycle
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Twashtar',  -- Relic dagger (best for DPS)
        'Mpu Gandring',  -- Relic dagger (best for DPS)
        'Demersal'       -- Demersal Degen (alternative)
    }
    state.MainWeapon:set('Mpu Gandring')  -- Default: No override

    --- SubWeaponOverride: Override sub weapon selection
    --- When set to 'Off', uses sub weapon from weapon set
    --- When set to 'Blurred', forces Blurred Knife +1 regardless of main weapon
    --- Keybind: Ctrl+1 to toggle
    state.SubWeaponOverride = M {
        ['description'] = 'Sub Override',
        'Off',      -- Use sub from weapon set (default behavior)
        'Blurred'   -- Force Blurred Knife +1
    }
    state.SubWeaponOverride:set('Off')  -- Default: No override

    -- ==========================================================================
    -- STEP MANAGEMENT SYSTEM
    -- ==========================================================================

    --- MainStep: Primary step ability
    --- Keybind: //gs c step (uses MainStep, then AltStep if UseAltStep=On)
    state.MainStep = M {
        ['description'] = 'Main Step',
        'Box Step',     -- Defense down (party benefit)
        'Quick Step',  -- Evasion down (DPS boost)
        'Feather Step', -- Critical hit rate
    }
    
    --- AltStep: Alternative step ability (for rotation)
    state.AltStep = M {
        ['description'] = 'Alt Step',
        'Quick Step',   -- Evasion down (alternative)
        'Box Step',    -- Defense down (default alt)
        'Feather Step', -- Critical hit rate
    }

    --- UseAltStep: Enable/disable alternate step rotation
    state.UseAltStep = M {
        ['description'] = 'Use Alt Step',
        'On',   -- Use both Main and Alt steps in rotation
        'Off'   -- Use only Main step
    }

    --- CurrentStep: Tracks which step to use next (Main or Alt)
    state.CurrentStep = M {
        ['description'] = 'Current Step',
        'Main',  -- Next step will be MainStep
        'Alt'    -- Next step will be AltStep
    }

    -- ==========================================================================
    -- FLOURISH BUFF TRACKING
    -- ==========================================================================

    --- Climactic Flourish: Buff active state
    --- Auto-updated by buff tracking system
    state.Buff['Climactic Flourish'] = buffactive['Climactic Flourish'] or false

    -- ==========================================================================
    -- AUTO-TRIGGER SYSTEMS
    -- ==========================================================================

    --- ClimacticAuto: Automatic Climactic Flourish trigger before WS
    --- Keybind: Alt+6 to toggle
    state.ClimacticAuto = M {
        ['description'] = 'Climactic Auto',
        'On',   -- Auto-trigger Climactic Flourish before configured WS
        'Off'   -- Manual Climactic Flourish only
    }
    state.ClimacticAuto:set('On')  -- Default: Auto-trigger enabled

    --- JumpAuto: Automatic Jump trigger before WS (DRG subjob)
    --- Keybind: Alt+7 to toggle
    state.JumpAuto = M {
        ['description'] = 'Jump Auto',
        'On',   -- Auto-trigger Jump before WS if TP < 1000 (DRG subjob only)
        'Off'   -- Manual Jump only
    }
    state.JumpAuto:set('on')  -- Default: Auto-trigger enabled

    -- ==========================================================================
    -- TP BONUS MODE (MOONSHADE EARRING LOGIC)
    -- ==========================================================================

    --- CombatWeaponMode: TP bonus optimization mode
    --- Determines which gear variant to use for weaponskills
    --- Auto-managed by WS system based on buffs/TP
    state.CombatWeaponMode = M {
        ['description'] = 'Combat Weapon Mode',
        'Normal',       -- No special buffs (standard WS gear)
        'TPBonus',      -- Use TP bonus gear (Moonshade Earring)
        'Clim',         -- Climactic Flourish active (Clim WS set)
        'ClimTPBonus'   -- Climactic + TP bonus (both optimizations)
    }

    -- ==========================================================================
    -- DANCE SELECTION (SABER DANCE / FAN DANCE)
    -- ==========================================================================

    --- Dance: Active dance selection
    --- Determines which dance to activate with //gs c dance command
    --- Keybind: Alt+8 to cycle
    state.Dance = M {
        ['description'] = 'Dance',
        'Saber Dance',  -- Offensive dance (+accuracy, +attack speed)
        'Fan Dance'     -- Defensive dance (+evasion)
    }
    state.Dance:set('Saber Dance')  -- Default: Saber Dance for DPS

    -- ==========================================================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ==========================================================================

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

--- Validate that states were configured correctly
--- Checks that all required states exist and have proper structure.
---
--- @return boolean success True if validation passed, false otherwise
--- @return string  message Validation message (success or error description)
function DNCStates.validate()
    -- Check HybridMode exists and has correct options
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end

    -- Check Step Management states
    if not state.MainStep then
        return false, "MainStep state not configured"
    end
    if not state.AltStep then
        return false, "AltStep state not configured"
    end
    if not state.UseAltStep then
        return false, "UseAltStep state not configured"
    end
    if not state.CurrentStep then
        return false, "CurrentStep state not configured"
    end

    -- Check Auto-Trigger states
    if not state.ClimacticAuto then
        return false, "ClimacticAuto state not configured"
    end
    if not state.JumpAuto then
        return false, "JumpAuto state not configured"
    end

    -- Check CombatWeaponMode
    if not state.CombatWeaponMode then
        return false, "CombatWeaponMode state not configured"
    end

    -- Check Dance state
    if not state.Dance then
        return false, "Dance state not configured"
    end

    -- Check SubWeaponOverride state
    if not state.SubWeaponOverride then
        return false, "SubWeaponOverride state not configured"
    end

    return true, "All DNC states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNCStates
