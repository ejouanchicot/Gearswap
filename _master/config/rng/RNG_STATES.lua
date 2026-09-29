---============================================================================
--- RNG State Configuration - Centralized State Management
---============================================================================
--- Ranger modes. Mote's own states, with their values set here:
---   • RangedMode       ranged attack gear: sets.precast.RA[RangedMode] and
---                      sets.midcast.RA[RangedMode] (Acc). Mote also uses it
---                      as the WS mode of Archery / Marksmanship weaponskills
---                      when WeaponskillMode is Normal and has that value
---   • OffenseMode      melee engaged set: sets.engaged[OffenseMode] (Acc)
---   • HybridMode       DT = sets.engaged[...].DT / sets.idle.DT
---                      (logic/set_builder.lua)
---   • WeaponskillMode  sets.precast.WS[name][WeaponskillMode] (Acc)
--- The job's weapons: each value is sets[value], or the plain weapon when
--- config/WEAPON_CONFIG.lua turns equip_without_set on. 'Free' has no set:
--- the item worn stays.
---   • RangeWeapon      the bow / gun / crossbow; its set also gives the
---                      ammo: sets['Fomalhaut'] = {range = "Fomalhaut",
---                      ammo = "Chrono Bullet"}
---   • MainWeapon       main hand
---   • SubWeapon        off hand. RNG has no Dual Wield of its own: an
---                      off-hand weapon is only held with /NIN or /DNC,
---                      otherwise sets.SingleWield's sub replaces it
---
--- Examples:
---   state.RangeWeapon = M { ['description'] = 'Range Weapon', 'Free', 'Gastraphetes', 'Fomalhaut' }
---   state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free', 'Naegling' }
---   state.RangedMode:options('Normal', 'Acc', 'HighAcc')   -- add a mode
---   state.HybridMode:set('DT')                               -- start in DT
---
--- @file    config/rng/RNG_STATES.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local RNGStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all RNG states (called from user_setup in the entry file)
function RNGStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.RangedMode:options('Normal', 'Acc')
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT')
    state.WeaponskillMode:options('Normal', 'Acc')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Gastraphetes', ...}. Each value is
    -- sets[value] in rng_sets.lua, or the plain weapon with equip_without_set.
    state.RangeWeapon = M { ['description'] = 'Range Weapon', 'Free' }
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

return RNGStates
