---============================================================================
--- RDM State Configuration - Centralized State Management
---============================================================================
--- Centralizes all RDM state definitions for consistency and maintainability.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal, CombatMode: weapon locking)
---   • Engaged modes (EngagedMode: DT/Acc/TP/Enspell - melee focus)
---   • Idle modes (IdleMode: Refresh/DT/Regen)
---   • Weapon selection (MainWeapon: Crocea Mors, SubWeapon: Colada)
---   • Enfeebling system (EnfeebleMode: Potency/Skill/Duration)
---   • Nuke system (NukeMode: FreeNuke/LowTierNuke/Accuracy)
---   • Spell selection (MainLight/Dark, SubLight/Dark, NukeTier)
---   • Buff system (Enspell, GainSpell, Barspell, BarAilment, Spike)
---   • Automation (RefreshMode, SaboteurMode)
---   • SCH subjob support (Storm - conditional)
---   • Default state values for optimal gameplay
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum DPS
---   • EngagedMode: DT/Acc/TP/Enspell (melee focus when engaged)
---   • IdleMode: Refresh/DT/Regen (idle gear focus)
---   • CombatMode: Off = free swapping, On = weapon slots locked
---   • EnfeebleMode: Potency/Skill/Duration (enfeebling magic focus)
---   • NukeMode: FreeNuke/LowTierNuke/Accuracy (elemental magic strategy)
---   • MainLightSpell: Fire/Aero/Thunder (primary light nuke)
---   • SubLightSpell: Fire/Aero/Thunder (secondary light nuke)
---   • MainDarkSpell: Blizzard/Stone/Water (primary dark nuke)
---   • SubDarkSpell: Blizzard/Stone/Water (secondary dark nuke)
---   • NukeTier: V/VI/IV/III/II/I (nuke tier selection)
---   • Enspell: Off/Enfire/Enblizzard/etc. (weapon enchantment)
---   • GainSpell: Gain-STR/DEX/VIT/etc. (stat buff cycling)
---   • Barspell: Barfira/Barblizzara/etc. (elemental resist buff)
---   • BarAilment: Baramnesia/Barparalysis/etc. (ailment resist buff)
---   • Spike: Blaze/Ice/Shock Spikes (damage reflection)
---   • RefreshMode: On/Off (auto-refresh on party members)
---   • SaboteurMode: On/Off (auto-Saboteur before enfeebles)
---   • Storm: Firestorm/Hailstorm/etc. (SCH subjob only - conditional)
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- @file    config/rdm/RDM_STATES.lua
--- @author  Kaories
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local RDMStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

function RDMStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('Normal')

    state.EngagedMode =
        M {
        ['description'] = 'Engaged Mode',
        'DT', -- Damage Taken reduction
        'Acc', -- Accuracy focus
        'TP', -- TP gain focus
        'Enspell' -- Enspell damage focus
    }
    state.EngagedMode:set('DT')

    state.IdleMode =
        M {
        ['description'] = 'Idle Mode',
        'Refresh', -- MP Refresh gear
        'DT' -- Damage Taken reduction
    }
    state.IdleMode:set('Refresh')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    state.MainWeapon =
        M {
        ['description'] = 'Main Weapon',
        'Naegling', -- Savage Blade weapon
        'Colada', -- Enspell shield
        'Daybreak' -- Magic nuke weapon
    }
    state.MainWeapon:set('Naegling')

    state.SubWeapon =
        M {
        ['description'] = 'Sub Weapon',
        'Ammurapi', -- Enfeebling sword
        'Genmei', -- Enfeebling sword
        'Malevolence' -- Enfeebling sword
    }
    state.SubWeapon:set('Genmei')

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
        'Duration' -- Duration+ gear
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
        'Fire',
        'Aero',
        'Thunder'
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
        'Blizzard',
        'Stone',
        'Water'
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
        'Enfire',
        'Enblizzard',
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
        'Gain-DEX',
        'Gain-VIT',
        'Gain-AGI',
        'Gain-INT',
        'Gain-MND',
        'Gain-CHR'
    }
    state.GainSpell:set('Gain-STR')

    state.Barspell =
        M {
        ['description'] = 'Bar Spell',
        'Barfire',
        'Barblizzard',
        'Baraero',
        'Barstone',
        'Barthunder',
        'Barwater'
    }
    state.Barspell:set('Barfire')

    state.BarAilment =
        M {
        ['description'] = 'Bar Ailment',
        'Baramnesia',
        'Barparalyze',
        'Barsilence',
        'Barpetrify',
        'Barpoison',
        'Barblind',
        'Barsleep',
        'Barvirus'
    }
    state.BarAilment:set('Baramnesia')

    state.Spike =
        M {
        ['description'] = 'Spike',
        'Blaze Spikes',
        'Ice Spikes',
        'Shock Spikes'
    }
    state.Spike:set('Blaze Spikes')

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

    -- ========================================
    -- CONDITIONAL STORM (SCH Subjob Only)
    -- ========================================

    -- Create Storm state if SCH subjob is active (handles reload + subjob change)
    RDMStates.configure_storm()
end

---============================================================================
--- CONDITIONAL STATE CONFIGURATION (SCH Subjob)
---============================================================================

--- Configure Storm state based on current subjob
--- Called during initial setup and subjob changes
--- @return void
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
