---============================================================================
--- BLU State Configuration - Gabvanstronger
---============================================================================
--- His BLU.lua user_setup, value for value.
---
--- His states -> ours:
---   • OffenseMode Normal/Capped/DT/Subtle Blow/Acc/Refresh -> same (Mote's
---     OffenseMode, read by logic/set_builder.lua as Mote read it: sets.engaged
---     [.SW][OffenseMode]). Capped has no set: it wears sets.engaged.
---   • WeaponskillMode Normal/Capped/Acc -> same. Acc now finds his Acc set
---     (renamed from .acc); Capped has no set. As with Mote, WeaponskillMode
---     Normal takes the OffenseMode's name when it is a WS mode too (OffenseMode
---     Acc -> WS Acc).
---   • CastingMode Normal/Resistant -> same (Magical.Resistant)
---   • IdleMode Normal/Evasion/DT/Regain -> same
---   • WeaponSet / SubSet -> MainWeapon / SubWeapon, same values and order
---   • RangedSet Normal/Pull, CP -> modes of config/blu/BLU_CUSTOM.lua
---   • WeaponLock -> Combat Mode (config/combat_mode.lua, Shift+F9)
---   • Aftermath closed/opened (his Expiacion window) -> not a state: the
---     option blu_expiacion_window of config/AUTO_ABILITIES.lua
---
--- @file    config/blu/BLU_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26 (Gabvanstronger values)
---============================================================================

local BLUStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all BLU states (called from user_setup in the entry file)
function BLUStates.configure()
    -- ========================================
    -- MOTE MODES (his options)
    -- ========================================
    state.OffenseMode:options('Normal', 'Capped', 'DT', 'Subtle Blow', 'Acc', 'Refresh')
    state.WeaponskillMode:options('Normal', 'Capped', 'Acc')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'Evasion', 'DT', 'Regain')

    -- ========================================
    -- WEAPON SELECTION (his WeaponSet / SubSet)
    -- ========================================
    -- Plain weapons (equip_without_set); 'Free' keeps the weapon worn
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Tizona', 'Naegling', 'Maxentius', 'Sequence', 'Extinction', 'Free'
    }
    state.SubWeapon = M {
        ['description'] = 'Sub Weapon',
        "Sakpata's Sword", 'Zantetsuken', 'Thibron', 'Tanmogayi +1', 'Nihility', 'Free'
    }

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
