---============================================================================
--- THF State Configuration - Gabvanstronger
---============================================================================
--- The template's THF states with the values of his THF.lua (user_setup) and
--- Mote-TreasureHunter.
---
--- His states -> ours:
---   • OffenseMode Normal / DT      -> HybridMode Normal / DT (our THF picks
---                                     sets.engaged[HybridMode])
---   • OffenseMode Abyssea          -> AbyProc (on/off) + AbyWeapon: his
---                                     Abyssea mode equipped the AbysseaSet
---                                     weapon pair on the plain engaged set
---   • IdleMode Normal/Refresh/Regain -> IdleMode, same values (Mote)
---   • RangedMode Normal / Acc      -> RangedMode, same values (Mote)
---   • WeaponSet / SubSet           -> MainWeapon / SubWeapon, same values
---   • AbysseaSet                   -> AbyWeapon (Dagger ... Staff, his order)
---   • TreasureMode None/Tag/SATA/Fulltime -> None/Tag/SATA/Full, default Full
---                                     (he set Fulltime); None = no TH gear
---   • WeaponLock                   -> Combat Mode (config/combat_mode.lua)
---   • RangedSet Ammo / Pull, CP    -> custom modes in THF_CUSTOM.lua
---   • WeaponskillMode Acc: not kept, his WS.Acc set was a copy of WS.
---
--- @file    config/thf/THF_STATES.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2025-10-14 | Updated: 2026-09-26 (Gabvanstronger values)
---============================================================================

local THFStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all THF states (called from user_setup in main file)
function THFStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    -- HybridMode: his OffenseMode (F9) Normal / DT
    state.HybridMode = M{['description']='Hybrid Mode', 'Normal', 'DT'}
    state.HybridMode:set('Normal')

    -- Mote's own modes, with his options
    state.IdleMode:options('Normal', 'Refresh', 'Regain')
    state.RangedMode:options('Normal', 'Acc')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    -- MainWeapon: his WeaponSet ('Free' = keep the weapon worn)
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Aeneas',
        'Kartika',
        'Tauret',
        'Naegling',
        'Norgish Dagger',
        'Free'
    }
    state.MainWeapon:set('Aeneas')

    -- SubWeapon: his SubSet ('Free' = keep the weapon worn)
    state.SubWeapon = M {
        ['description'] = 'Sub Weapon',
        'Fusetto +2',
        "Gleti's Knife",
        'Tanmogayi +1',
        'Ternion Dagger +1',
        'Qutrub Knife',
        'Free'
    }
    state.SubWeapon:set('Fusetto +2')

    -- ========================================
    -- ABYSSEA PROC SYSTEM
    -- ========================================

    -- AbyProc: his OffenseMode 'Abyssea' (weapon pair from AbyWeapon)
    state.AbyProc = M(false, 'Aby Proc')

    -- AbyWeapon: his AbysseaSet, same order (sets.<value> in thf_sets.lua)
    state.AbyWeapon = M {
        ['description'] = 'Aby Weapon',
        'Dagger',       -- Aern Dagger + Nihility
        'Sword',        -- Extinction + Nihility
        'Club',         -- Charm Wand + Nihility
        'Polearm',      -- Pitchfork +1
        'Scythe',       -- Hoe
        'Great Sword',  -- Lament
        'Staff'         -- Chatoyant Staff
    }
    state.AbyWeapon:set('Dagger')

    -- ========================================
    -- TREASURE HUNTER SYSTEM
    -- ========================================

    -- TreasureMode: Mote-TreasureHunter's values ('Full' = his 'Fulltime').
    -- 'None' is no value our THF code knows, so it wears no TH gear.
    -- REQUIRED: ui_lifecycle.are_states_ready() waits for it as THF's anchor state
    state.TreasureMode = M {
        ['description'] = 'Treasure Hunter Mode',
        'None',  -- Never TH gear
        'Tag',   -- TH gear until the mob is tagged
        'SATA',  -- Tag, plus TH on SA/TA and weaponskills
        'Full'   -- TH gear always
    }
    state.TreasureMode:set('Full')

    -- ========================================
    -- RANGED WEAPON LOCK
    -- ========================================

    -- RangeLock: Lock ranged weapons (set On by every /ra)
    state.RangeLock = M(false, 'Range Lock')

    -- ========================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ========================================

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
--- VALIDATION
---============================================================================

--- Validate all THF states are configured correctly
--- @return boolean success True if all states valid
--- @return string message Validation result message
function THFStates.validate()
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end
    if not state.SubWeapon then
        return false, "SubWeapon state not configured"
    end
    if not state.AbyProc then
        return false, "AbyProc state not configured"
    end
    if not state.AbyWeapon then
        return false, "AbyWeapon state not configured"
    end
    if not state.TreasureMode then
        return false, "TreasureMode state not configured"
    end
    if not state.RangeLock then
        return false, "RangeLock state not configured"
    end

    return true, "All THF states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return THFStates
