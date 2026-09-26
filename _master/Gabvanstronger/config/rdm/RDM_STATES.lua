---============================================================================
--- RDM State Configuration - Centralized State Management
---============================================================================
--- Centralizes all RDM state definitions for consistency and maintainability.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal, CombatMode: weapon locking)
---   • Engaged modes (EngagedMode: Store TP/Refresh DT/DT/Enspell/Subtle Blow)
---   • Idle modes (IdleMode: Refresh/DT/Regain/Regen)
---   • Weapon selection (MainWeapon: Sakpata's Sword...Nihility/Free, SubWeapon: shields, Daybreak, daggers)
---   • Enfeebling system (EnfeebleMode: Potency/Skill/Duration/Acc)
---   • Nuke system (NukeMode: FreeNuke/Magic Burst)
---   • Spell selection (MainLight/Dark, SubLight/Dark, NukeTier)
---   • Buff system (EnSpell, GainSpell, Barspell, BarAilment, Spike)
---   • Automation (SaboteurMode)
---   • SCH subjob support (Storm - conditional)
---   • Default state values for optimal gameplay
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum DPS
---   • EngagedMode: Store TP/Refresh DT/DT/Enspell/Subtle Blow (melee focus when engaged)
---   • IdleMode: Refresh/DT/Regain/Regen (idle gear focus)
---   • CombatMode: Off = free swapping, On = weapon slots locked
---   • EnfeebleMode: Potency/Skill/Duration/Acc (enfeebling magic focus)
---   • NukeMode: FreeNuke/Magic Burst (elemental magic strategy)
---   • MainLightSpell: Fire/Aero/Thunder (primary light nuke)
---   • SubLightSpell: Fire/Aero/Thunder (secondary light nuke)
---   • MainDarkSpell: Blizzard/Stone/Water (primary dark nuke)
---   • SubDarkSpell: Blizzard/Stone/Water (secondary dark nuke)
---   • NukeTier: V/IV/III/II/I (nuke tier selection)
---   • EnSpell: Enfire/Enblizzard/etc. (weapon enchantment)
---   • GainSpell: Gain-STR/DEX/VIT/etc. (stat buff cycling)
---   • Barspell: Barfire/Barblizzard/etc. (elemental resist buff)
---   • BarAilment: Baramnesia/Barparalyze/etc. (ailment resist buff)
---   • Spike: Blaze/Ice/Shock Spikes (damage reflection)
---   • SaboteurMode: On/Off (auto-Saboteur before enfeebles)
---   • EnfeebleTier: On/Off (tiered enfeeble on recast drops a tier, or is cancelled)
---   • Storm: Firestorm/Hailstorm/etc. (SCH subjob only - conditional)
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- Gabvanstronger: the template with his values and defaults (from his
--- Gabvanstronger/config/rdm/RDM_STATES.lua). Where his file left the
--- default commented out, the default here is the first value, as it was
--- for him.
---
--- @file    config/rdm/RDM_STATES.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2025-10-14 | Updated: 2026-09-25 (Gabvanstronger values)
---============================================================================

local RDMStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all RDM states
--- Must be called from user_setup() after Mote-Include is loaded.
function RDMStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('Normal')

    state.EngagedMode =
        M {
        ['description'] = 'Engaged Mode',
        'Store TP', -- TP gain focus
        'Refresh DT', -- Refresh while engaged, DT
        'DT', -- Damage Taken reduction
        'Enspell', -- Enspell damage focus
        'Subtle Blow' -- Subtle Blow focus
    }
    state.EngagedMode:set('Store TP')

    state.IdleMode =
        M {
        ['description'] = 'Idle Mode',
        'Refresh', -- MP Refresh gear
        'DT', -- Damage Taken reduction
        'Regain', -- Regain gear
        'Regen' -- HP Regen gear
    }
    state.IdleMode:set('Refresh')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    state.MainWeapon =
        M {
        ['description'] = 'Main Weapon',
        "Sakpata's Sword",
        'Excalibur',
        'Maxentius',
        'Naegling',
        'Murgleis',
        'Crocea Mors',
        'Tauret',
        'Aern Dagger',
        'Nihility',
        'Free' -- sets['Free']
    }
    state.MainWeapon:set("Sakpata's Sword")

    state.SubWeapon =
        M {
        ['description'] = 'Sub Weapon',
        "Archduke's Shield",
        'Sacro Bulwark',
        'Forfend +1',
        'Daybreak',
        "Bunzi's Rod",
        'Thibron',
        'Crepuscular Knife',
        "Gleti's Knife",
        'Qutrub Knife'
    }
    state.SubWeapon:set("Archduke's Shield")

    state.CombatMode =
        M {
        ['description'] = 'Combat Mode',
        'Off', -- Weapons can swap freely
        'On' -- Weapons locked (main/sub/range/ammo)
    }
    state.CombatMode:set('Off')

    -- ========================================
    -- MAGIC SYSTEMS
    -- ========================================

    state.EnfeebleMode =
        M {
        ['description'] = 'Enfeeble Mode',
        'Potency', -- Max potency (MND/INT)
        'Skill', -- Enfeebling Skill+
        'Duration', -- Duration+ gear
        'Acc' -- Magic accuracy
    }
    state.EnfeebleMode:set('Potency')

    state.NukeMode =
        M {
        ['description'] = 'Nuke Mode',
        'FreeNuke', -- High-tier nukes (default)
        'Magic Burst' -- Magic Burst focus
    }
    state.NukeMode:set('FreeNuke')

    state.MainLightSpell =
        M {
        ['description'] = 'Main Light Spell',
        'Fire',
        'Aero',
        'Thunder'
    }
    state.MainLightSpell:set('Fire')

    state.SubLightSpell =
        M {
        ['description'] = 'Sub Light Spell',
        'Thunder',
        'Aero',
        'Fire'
    }
    state.SubLightSpell:set('Thunder')

    state.MainDarkSpell =
        M {
        ['description'] = 'Main Dark Spell',
        'Blizzard',
        'Stone',
        'Water'
    }
    state.MainDarkSpell:set('Blizzard')

    state.SubDarkSpell =
        M {
        ['description'] = 'Sub Dark Spell',
        'Stone',
        'Water',
        'Blizzard'
    }
    state.SubDarkSpell:set('Stone')

    state.NukeTier =
        M {
        ['description'] = 'Nuke Tier',
        'V',
        'IV',
        'III',
        'II',
        'I'
    }
    state.NukeTier:set('V')

    -- ========================================
    -- BUFF SYSTEM
    -- ========================================

    state.EnSpell =
        M {
        ['description'] = 'Enspell',
        'Enblizzard',
        'Enfire',
        'Enaero',
        'Enstone',
        'Enthunder',
        'Enwater'
    }
    state.EnSpell:set('Enfire')

    state.GainSpell =
        M {
        ['description'] = 'Gain Spell',
        'Gain-STR',
        'Gain-MND',
        'Gain-INT',
        'Gain-DEX',
        'Gain-VIT',
        'Gain-AGI',
        'Gain-CHR'
    }
    state.GainSpell:set('Gain-STR')

    state.Barspell =
        M {
        ['description'] = 'Bar Spell',
        'Barblizzard',
        'Barfire',
        'Baraero',
        'Barstone',
        'Barthunder',
        'Barwater'
    }
    state.Barspell:set('Barthunder')

    state.BarAilment =
        M {
        ['description'] = 'Bar Ailment',
        'Barparalyze',
        'Baramnesia',
        'Barsilence',
        'Barpetrify',
        'Barpoison',
        'Barblind',
        'Barsleep',
        'Barvirus'
    }
    state.BarAilment:set('Barparalyze')

    state.Spike =
        M {
        ['description'] = 'Spike',
        'Shock Spikes',
        'Ice Spikes',
        'Blaze Spikes'
    }
    state.Spike:set('Shock Spikes')

    -- ========================================
    -- AUTOMATION
    -- ========================================

    state.SaboteurMode =
        M {
        ['description'] = 'Saboteur Mode',
        'Off', -- Manual Saboteur
        'On' -- Auto-Saboteur before enfeebles
    }
    state.SaboteurMode:set('Off')

    -- EnfeebleTier: On = a tiered enfeeble on recast drops to the next ready
    -- tier (Gravity II -> Gravity); Off = it is cancelled and the recast shown,
    -- so the tier stays the player's choice. Nukes drop either way.
    state.EnfeebleTier = M {['description'] = 'Enfeeble Tier', 'On', 'Off'}
    state.EnfeebleTier:set('On')

    -- ========================================
    -- CONDITIONAL STORM (SCH Subjob Only)
    -- ========================================

    -- Create Storm state if SCH subjob is active (handles reload + subjob change)
    RDMStates.configure_storm()

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
    state.FastCast:set('80')  -- Default: 80% (RDM has high FC)

    -- Universal toggle, created here rather than centrally: the keybind HUD
    -- renders from user_setup() and caches what it reads, so a state added
    -- afterwards shows as N/A until something forces a redraw.
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if ok and AutoMedicine then
        AutoMedicine.init(state, M)
    end
end

---============================================================================
--- CONDITIONAL STATE CONFIGURATION (SCH Subjob)
---============================================================================

--- Configure Storm state based on current subjob
--- Called during initial setup and subjob changes
function RDMStates.configure_storm()
    local current_subjob = player and player.sub_job or nil

    if current_subjob == 'SCH' and not state.Storm then
        -- Create Storm state for SCH subjob
        state.Storm = M {
            ['description'] = 'Storm',
            'Firestorm',
            'Hailstorm',
            'Windstorm',
            'Sandstorm',
            'Thunderstorm',
            'Rainstorm',
            'Aurorastorm',
            'Voidstorm'
        }
        state.Storm:set('Firestorm')
    elseif current_subjob ~= 'SCH' and state.Storm then
        -- Destroy Storm state when leaving SCH
        state.Storm = nil
    end
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate that states were configured correctly
--- @return boolean success True if every checked state exists
--- @return string  message Validation message (success or first missing state)
function RDMStates.validate()
    if not state.HybridMode then
        return false, 'HybridMode not configured'
    end
    if not state.EngagedMode then
        return false, 'EngagedMode not configured'
    end
    if not state.IdleMode then
        return false, 'IdleMode not configured'
    end
    if not state.MainWeapon then
        return false, 'MainWeapon not configured'
    end
    if not state.SubWeapon then
        return false, 'SubWeapon not configured'
    end
    if not state.CombatMode then
        return false, 'CombatMode not configured'
    end
    if not state.EnfeebleMode then
        return false, 'EnfeebleMode not configured'
    end
    if not state.NukeMode then
        return false, 'NukeMode not configured'
    end
    if not state.MainLightSpell then
        return false, 'MainLightSpell not configured'
    end
    if not state.SubLightSpell then
        return false, 'SubLightSpell not configured'
    end
    if not state.MainDarkSpell then
        return false, 'MainDarkSpell not configured'
    end
    if not state.SubDarkSpell then
        return false, 'SubDarkSpell not configured'
    end
    if not state.NukeTier then
        return false, 'NukeTier not configured'
    end
    if not state.EnSpell then
        return false, 'EnSpell not configured'
    end
    if not state.GainSpell then
        return false, 'GainSpell not configured'
    end
    if not state.Barspell then
        return false, 'Barspell not configured'
    end
    if not state.BarAilment then
        return false, 'BarAilment not configured'
    end
    if not state.Spike then
        return false, 'Spike not configured'
    end
    if not state.SaboteurMode then
        return false, 'SaboteurMode not configured'
    end
    return true, 'All RDM states configured successfully'
end

return RDMStates
