---============================================================================
--- BLU State Configuration - Centralized State Management
---============================================================================
--- Blue Mage modes. Mote's own states, with their values set here:
---   • OffenseMode      engaged set: sets.engaged[OffenseMode], under .SW
---                      when single wielding (logic/set_builder.lua)
---   • WeaponskillMode  sets.precast.WS[name][WeaponskillMode]; Mote also
---                      uses OffenseMode here when WeaponskillMode is Normal
---                      and has a value of that name
---   • CastingMode      sets.midcast['Blue Magic'][category][CastingMode]
---   • IdleMode         sets.idle[IdleMode] (Normal = sets.idle)
--- And the job's weapons:
---   • MainWeapon / SubWeapon: sets[value], or the plain weapon when
---     config/WEAPON_CONFIG.lua turns equip_without_set on. 'Free' has no
---     set: the weapon worn stays.
---
--- @file    config/blu/BLU_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

local BLUStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all BLU states (called from user_setup in the entry file)
function BLUStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.OffenseMode:options('Normal', 'Acc', 'DT', 'Subtle Blow', 'Refresh')
    state.WeaponskillMode:options('Normal', 'Acc')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'Evasion', 'DT', 'Regain')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Naegling', ...}. Each value is sets[value]
    -- in blu_sets.lua, or the plain weapon with equip_without_set.
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

---============================================================================
--- VALIDATION
---============================================================================

--- Validate the BLU states
--- @return boolean success True if all states are configured
--- @return string message Validation result message
function BLUStates.validate()
    for _, name in ipairs({'OffenseMode', 'WeaponskillMode', 'CastingMode', 'IdleMode', 'MainWeapon', 'SubWeapon'}) do
        if not state[name] then
            return false, name .. ' state not configured'
        end
    end
    return true, 'All BLU states configured successfully'
end

return BLUStates
