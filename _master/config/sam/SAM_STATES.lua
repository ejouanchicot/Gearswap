---============================================================================
--- SAM State Configuration - Job States & Modes
---============================================================================
--- Defines all SAM job states (Combat Modes, Weapon Sets, etc.)
---
--- Features:
---   • HybridMode configuration (PDT/Normal)
---   • MainWeapon state with multiple weapon options
---   • FastCast, AutoMedicine
---   • Keys are bound in SAM_KEYBINDS.lua (Ctrl+Numpad1 weapon, Ctrl+Numpad9 HybridMode)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call SAMStates.configure() to initialize all states
---
--- @file    config/sam/SAM_STATES.lua
--- @author  ejouanchicot
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
--- Defines HybridMode, OffenseMode, WeaponskillMode, MainWeapon, Stance,
--- FastCast and AutoMedicine.
function SAMStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT'    - Physical Damage Taken -50% (safe mode, default)
    ---   • 'Normal' - Full offense (max DPS)
    ---   • 'MDT'    - Magic damage taken down (sets.engaged.MDT)
    --- Keybind: Ctrl+Numpad9 to cycle
    state.HybridMode:options('PDT', 'Normal', 'MDT')
    state.HybridMode:set('PDT') -- Default to PDT for safety

    --- OffenseMode: accuracy level of the engaged set (sets.engaged.<value>,
    --- then .<value>.<HybridMode> when it exists, e.g. sets.engaged.Acc.PDT)
    ---   • 'Normal' / 'Mid' / 'Acc' - more accuracy at each step
    ---   • 'SuBlow' - Subtle Blow set (sets.engaged.SuBlow)
    --- A HybridMode other than Normal wins when the accuracy set has no
    --- variant for it (Mid + PDT -> sets.engaged.PDT).
    --- Keybind: Ctrl+Numpad2 to cycle
    state.OffenseMode:options('Normal', 'Mid', 'Acc', 'SuBlow')
    state.OffenseMode:set('Normal')

    --- WeaponskillMode: sets.precast.WS['<name>'].<value> when it exists
    --- (Tachi: Shoha .Mid / .Acc...), else the WS set itself.
    --- Keybind: Ctrl+Numpad3 to cycle
    state.WeaponskillMode:options('Normal', 'Mid', 'Acc')
    state.WeaponskillMode:set('Normal')

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Keybind: Ctrl+Numpad1 to cycle
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
    -- STANCE
    -- ==========================================================================

    --- Stance: the stance the automation keeps up (Hasso and Seigan cancel
    --- each other). Set by //gs c hasso / //gs c seigan and by any Hasso or
    --- Seigan used. Seigan: Third Eye is preceded by Seigan when it is down.
    --- Hasso: Third Eye goes out alone, Hasso is never replaced.
    state.Stance = M { ['description'] = 'Stance', 'Hasso', 'Seigan' }
    state.Stance:set('Hasso')

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
    state.FastCast:set('0')  -- Default: 0% (adjust based on your gear)

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

return SAMStates
