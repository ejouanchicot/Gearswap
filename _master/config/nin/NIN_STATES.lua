---============================================================================
--- NIN State Configuration - Centralized State Management
---============================================================================
--- Ninja modes. Mote's own states, with their values set here:
---   • OffenseMode      engaged set: sets.engaged[OffenseMode] (Acc)
---   • HybridMode       DT = sets.engaged.DT (or sets.engaged.Acc.DT) and,
---                      outside a city, sets.idle.DT (logic/set_builder.lua)
---   • WeaponskillMode  sets.precast.WS[name][WeaponskillMode] (Acc)
--- The job's own:
---   • MagicBurstMode   On = elemental ninjutsu (Katon..Doton) in
---                      sets.midcast.Ninjutsu.Elemental.MagicBurst when you
---                      defined it (logic/ninjutsu.lua)
--- And the job's weapons (Ninja dual wields by trait):
---   • MainWeapon / SubWeapon: sets[value], or the plain weapon when
---     config/WEAPON_CONFIG.lua turns equip_without_set on. 'Free' has no
---     set: the weapon worn stays.
---
--- Examples:
---   state.OffenseMode:options('Normal', 'Acc', 'MaxAcc')   -- add a mode
---   state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free', 'Heishi Shorinken' }
---   state.SubWeapon = M { ['description'] = 'Sub Weapon', 'Free', 'Kunimitsu' }
---   state.MagicBurstMode:set('On')                         -- start with it on
---
--- @file    config/nin/NIN_STATES.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local NINStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all NIN states (called from user_setup in the entry file)
function NINStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT')
    state.WeaponskillMode:options('Normal', 'Acc')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Heishi Shorinken', ...}. Each value is
    -- sets[value] in nin_sets.lua, or the plain weapon with equip_without_set.
    state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free' }
    state.SubWeapon = M { ['description'] = 'Sub Weapon', 'Free' }

    -- ========================================
    -- NINJUTSU
    -- ========================================
    state.MagicBurstMode = M { ['description'] = 'Magic Burst', 'Off', 'On' }

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

return NINStates
