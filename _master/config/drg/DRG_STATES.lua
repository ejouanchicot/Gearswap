---============================================================================
--- DRG State Configuration - Centralized State Management
---============================================================================
--- Dragoon modes. Mote's own states, with their values set here:
---   • OffenseMode      engaged set: sets.engaged[OffenseMode] (Acc)
---   • HybridMode       DT = sets.engaged.DT / sets.idle.DT (and
---                      sets.idle.Pet.DT while the wyvern is out)
---                      (logic/set_builder.lua)
---   • WeaponskillMode  sets.precast.WS[name][WeaponskillMode] (Acc); Mote
---                      also uses OffenseMode here when WeaponskillMode is
---                      Normal and has a value of that name
--- The job's weapons:
---   • MainWeapon       the polearm: sets[value], or the plain weapon when
---                      config/WEAPON_CONFIG.lua turns equip_without_set on.
---   • SubWeapon        the grip, the same way.
---   'Free' has no set: the weapon (or grip) worn stays.
---
--- Examples:
---   state.OffenseMode:options('Normal', 'Acc', 'MaxAcc')   -- add a mode
---   state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free', 'Trishula' }
---   state.SubWeapon = M { ['description'] = 'Sub Weapon', 'Free', 'Utu Grip' }
---
--- @file    config/drg/DRG_STATES.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local DRGStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all DRG states (called from user_setup in the entry file)
function DRGStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT')
    state.WeaponskillMode:options('Normal', 'Acc')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Trishula', ...}. Each value is sets[value]
    -- in drg_sets.lua, or the plain weapon with equip_without_set.
    state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free' }
    state.SubWeapon = M { ['description'] = 'Sub Weapon', 'Free' }

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

return DRGStates
