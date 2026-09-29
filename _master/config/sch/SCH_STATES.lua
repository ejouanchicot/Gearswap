---============================================================================
--- SCH State Configuration - Centralized State Management
---============================================================================
--- Scholar modes. Mote's own states, with their values set here:
---   • OffenseMode     engaged set: sets.engaged[OffenseMode] (Acc)
---   • HybridMode      DT = sets.idle.DT outside a city, sets.engaged.DT
---                     (logic/set_builder.lua)
--- The job's weapons:
---   • MainWeapon / SubWeapon   sets[value], or the plain weapon when
---                     config/WEAPON_CONFIG.lua turns equip_without_set on.
---                     'Free' has no set: the weapon worn stays.
---   • CombatMode      On keeps main / sub / range where they are
---                     (shared/utils/core/combat_mode.lua)
--- Magic:
---   • MagicBurstMode  On: sets.midcast['Elemental Magic'].MagicBurst,
---                     sets.midcast.Helix.MagicBurst,
---                     sets.midcast.Kaustra.MagicBurst
---   • Element         element of //gs c nuke / helix / storm
---   • NukeTier        tier of //gs c nuke (I = the base spell: Fire)
---   • SneakInviAOE    On: //gs c aoe sneak / invi spend Accession to cover
---                     the party; Off: one target (<stal>)
---
--- Examples:
---   state.OffenseMode:options('Normal', 'Acc', 'MaxAcc')   -- add a mode
---   state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free', 'Musa' }
---   state.MagicBurstMode:set('On')                         -- start with it on
---
--- @file    config/sch/SCH_STATES.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local SCHStates = {}

--- Elements, in the order the key cycles them
SCHStates.ELEMENTS = {'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light', 'Dark'}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all SCH states (called from user_setup in the entry file)
function SCHStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Musa', ...}. Each value is sets[value]
    -- in sch_sets.lua, or the plain weapon with equip_without_set.
    state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free' }
    state.SubWeapon = M { ['description'] = 'Sub Weapon', 'Free' }

    state.CombatMode = M { ['description'] = 'Combat Mode', 'Off', 'On' }

    -- ========================================
    -- MAGIC
    -- ========================================
    state.MagicBurstMode = M { ['description'] = 'Magic Burst', 'Off', 'On' }
    state.Element = M { ['description'] = 'Element', unpack(SCHStates.ELEMENTS) }
    state.NukeTier = M { ['description'] = 'Nuke Tier', 'V', 'IV', 'III', 'II', 'I' }
    state.SneakInviAOE = M { ['description'] = 'Sneak/Invi AOE', 'On', 'Off' }

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

return SCHStates
