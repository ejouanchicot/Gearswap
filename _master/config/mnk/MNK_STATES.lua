---============================================================================
--- MNK State Configuration - Centralized State Management
---============================================================================
--- Monk modes. Mote's own states, with their values set here:
---   • OffenseMode      engaged set: sets.engaged[OffenseMode] (Acc)
---   • HybridMode       DT      = sets.engaged.DT (and sets.idle.DT)
---                      Counter = sets.engaged.Counter (counter gear);
---                      from the OffenseMode level when it has one
---                      (sets.engaged.Acc.DT), else from sets.engaged
---                      (logic/set_builder.lua)
---   • WeaponskillMode  sets.precast.WS[name][WeaponskillMode]; Mote also
---                      uses OffenseMode here when WeaponskillMode is Normal
---                      and has a value of that name
--- The job's weapon (Monk has no off hand: Martial Arts, no Dual Wield):
---   • MainWeapon       sets[value], or the plain weapon when
---                      config/WEAPON_CONFIG.lua turns equip_without_set on.
---                      'Free' has no set: the weapon worn stays.
---
--- Examples:
---   state.OffenseMode:options('Normal', 'Acc', 'MaxAcc')        -- add a mode
---   state.HybridMode:options('Normal', 'DT')                    -- no Counter
---   state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free', 'Godhands', 'Verethragna' }
---   state.HybridMode:set('DT')                                  -- start in DT
---
--- @file    config/mnk/MNK_STATES.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local MNKStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all MNK states (called from user_setup in the entry file)
function MNKStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT', 'Counter')
    state.WeaponskillMode:options('Normal', 'Acc')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Godhands', ...}. Each value is sets[value]
    -- in mnk_sets.lua, or the plain weapon with equip_without_set.
    state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free' }

    -- ========================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ========================================
    --- Fast Cast % for the midcast watchdog timeout (80% cap)
    state.FastCast = M {
        ['description'] = 'Fast Cast %',
        '0', '10', '20', '30', '40', '50', '60', '70', '80'
    }
    state.FastCast:set('0')

    -- Universal toggle, created here rather than centrally: the keybind HUD
    -- renders from user_setup() and caches what it reads, so a state added
    -- afterwards shows as N/A until something forces a redraw.
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if ok and AutoMedicine then
        AutoMedicine.init(state, M)
    end
end

return MNKStates
