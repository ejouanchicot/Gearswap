---============================================================================
--- PUP State Configuration - Centralized State Management
---============================================================================
--- Puppetmaster modes. Mote's own states, with their values set here:
---   • OffenseMode   engaged set: sets.engaged[OffenseMode] (Acc)
---   • HybridMode    DT = sets.engaged.DT / sets.idle.DT for the master
---                   (logic/set_builder.lua)
--- The job's weapon:
---   • MainWeapon    sets[value], or the plain weapon when
---                   config/WEAPON_CONFIG.lua turns equip_without_set on.
---                   'Free' has no set: the weapon worn stays.
--- The automaton:
---   • PetMode       the automaton's role, set by itself from its head
---                   (Harlequin = Melee, Valoredge = Tank, Sharpshot = Ranged,
---                   Stormwaker = Magic, Soulsoother = Heal, Spiritreaver =
---                   Nuke). Picks sets.idle.Pet.Engaged[PetMode] and
---                   sets.midcast.Pet.WeaponSkill[PetMode]. Cycling it by
---                   hand holds until the head changes or a new automaton
---                   comes out.
---   • PetWS         On: automaton weaponskill gear while it fights with
---                   enough TP (config/pup/PUP_TP_CONFIG.lua, pet_ws_tp).
---
--- Examples:
---   state.OffenseMode:options('Normal', 'Acc', 'MaxAcc')   -- add a mode
---   state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free', 'Xiucoatl' }
---   state.PetWS:set('Off')                                 -- start with it off
---
--- @file    config/pup/PUP_STATES.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-29
---============================================================================

local PUPStates = {}

--- Automaton roles, in the order the key cycles them
PUPStates.PET_MODES = {'Melee', 'Tank', 'Ranged', 'Magic', 'Heal', 'Nuke'}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all PUP states (called from user_setup in the entry file)
function PUPStates.configure()
    -- ========================================
    -- MOTE MODES
    -- ========================================
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================
    -- Add your weapons: {'Free', 'Xiucoatl', ...}. Each value is sets[value]
    -- in pup_sets.lua, or the plain weapon with equip_without_set.
    state.MainWeapon = M { ['description'] = 'Main Weapon', 'Free' }

    -- ========================================
    -- AUTOMATON
    -- ========================================
    state.PetMode = M { ['description'] = 'Pet Mode', unpack(PUPStates.PET_MODES) }
    state.PetWS = M { ['description'] = 'Pet WS', 'On', 'Off' }

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

return PUPStates
