---============================================================================
--- BLM State Configuration - Centralized State Management
---============================================================================
--- Centralizes all BLM state definitions for consistency and maintainability.
--- This module configures job-specific states used throughout the BLM system.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal, CombatMode: weapon locking)
---   • Magic Burst mode (MagicBurstMode: On/Off)
---   • Weapon selection (MainWeapon: Staves, SubWeapon: Grips)
---   • Elemental nuke system (Light/Dark + Single/AOE + Tier selection)
---   • Death spell mode (DeathMode: On/Off)
---   • Default state values for optimal gameplay
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum MAB
---   • CombatMode: Off = free swapping, On = weapon slots locked
---   • MagicBurstMode: On = burst potency gear, Off = normal nuke gear
---   • MainWeapon: Elemental Staves (Hvergelmir, etc.)
---   • SubWeapon: Grips (Alber Strap, Enki Strap, etc.)
---   • MainLightSpell: Fire/Aero/Thunder (Light-based nukes)
---   • MainDarkSpell: Blizzard/Stone/Water (Dark-based nukes)
---   • SpellTier: VI/V/IV/III/II/I (nuke tier - BLM goes up to VI)
---   • MainLightAOE: Fira/Aera/Thundara (Light AOE spells)
---   • MainDarkAOE: Blizzara/Stonera/Watera (Dark AOE spells)
---   • AOETier: III/II/I (AOE spell tier)
---   • DeathMode: On = optimize for Death spell, Off = normal nukes
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- @file    config/blm/BLM_STATES.lua
--- @author  Kaories
--- @version 1.0
--- @date    Created: 2025-10-15
---============================================================================

local BLMStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all BLM states (called from user_setup in main file)
function BLMStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    -- HybridMode: PDT (Physical Damage Taken -50%) or Normal (Maximum MAB)
    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('Normal')  -- Default to Normal (BLM focuses on damage)

    -- CombatMode: Lock weapons when engaged (prevents swapping)
    state.CombatMode = M {
        ['description'] = 'Combat Mode',
        'Off',  -- Weapons can swap freely
        'On'    -- Weapons locked (main/sub/range/ammo)
    }
    state.CombatMode:set('Off')  -- Default to Off (free swapping)

    -- MagicBurstMode: Magic Burst optimization
    state.MagicBurstMode = M {
        ['description'] = 'Magic Burst Mode',
        'Off',  -- Normal nuke gear
        'On'    -- Magic Burst potency gear
    }
    state.MagicBurstMode:set('Off')  -- Default to Off

    -- DeathMode: Death spell optimization
    state.DeathMode = M {
        ['description'] = 'Death Mode',
        'Off',  -- Normal nukes
        'On'    -- Optimize for Death spell (HP-based damage)
    }
    state.DeathMode:set('Off')  -- Default to Off

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    -- MainWeapon: Primary weapon selection (elemental staves)
    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Hvergelmir'  -- REMA staff (best for BLM)
    }
    state.MainWeapon:set('Hvergelmir')  -- Default to Hvergelmir

    -- SubWeapon: Offhand weapon selection (grips)
    state.SubWeapon = M {
        ['description'] = 'Sub Weapon',
        'Alber Strap'  -- MAB grip
    }
    state.SubWeapon:set('Alber Strap')  -- Default to Alber Strap

    -- ========================================
    -- ELEMENTAL NUKE SYSTEM
    -- ========================================

    -- MainLightSpell: Light elemental spells (Fire/Wind/Thunder)
    state.MainLightSpell = M {
        ['description'] = 'Main Light',
        "Fire",
        "Aero",
        "Thunder"
    }
    state.MainLightSpell:set("Fire")  -- Default to Fire

    -- MainDarkSpell: Dark elemental spells (Ice/Earth/Water)
    state.MainDarkSpell = M {
        ['description'] = 'Main Dark',
        "Blizzard",
        "Stone",
        "Water"
    }
    state.MainDarkSpell:set("Blizzard")  -- Default to Blizzard

    -- SubLightSpell: Sub Light elemental spells (Thunder/Fire/Aero)
    state.SubLightSpell = M {
        ['description'] = 'Sub Light',
        "Thunder",
        "Fire",
        "Aero"
    }
    state.SubLightSpell:set("Thunder")  -- Default to Thunder (different from Main)

    -- SubDarkSpell: Sub Dark elemental spells (Water/Blizzard/Stone)
    state.SubDarkSpell = M {
        ['description'] = 'Sub Dark',
        "Water",
        "Blizzard",
        "Stone"
    }
    state.SubDarkSpell:set("Water")  -- Default to Water (different from Main)

    -- SpellTier: Nuke spell tier (VI/V/IV/III/II/I)
    -- Note: Tier "I" casts base spell (e.g., "Fire" not "Fire I")
    -- Note: BLM has access to tier VI spells
    state.SpellTier = M {
        ['description'] = 'Spell Tier',
        "VI",
        "V",
        "IV",
        "III",
        "II",
        "I"
    }
    state.SpellTier:set("VI")  -- Default to Tier VI (highest)

    -- MainLightAOE: Light AOE elemental spells (-ga versions)
    state.MainLightAOE = M {
        ['description'] = 'Light AOE',
        "Firaga",
        "Aeroga",
        "Thundaga"
    }
    state.MainLightAOE:set("Firaga")  -- Default to Firaga

    -- MainDarkAOE: Dark AOE elemental spells (-ga versions)
    state.MainDarkAOE = M {
        ['description'] = 'Dark AOE',
        "Blizzaga",
        "Stonega",
        "Waterga"
    }
    state.MainDarkAOE:set("Blizzaga")  -- Default to Blizzaga

    -- AOETier: AOE spell tier (Aja/III/II/I)
    -- Aja = highest tier (Firaja, Stoneja, etc.) - no numeral
    -- III/II/I = -ga spell tiers (Firaga III, Firaga II, Firaga I)
    -- Refinement chain: Firaja → Firaga III → Firaga II → Firaga I (handled by spell_refiner)
    state.AOETier = M {
        ['description'] = 'AOE Tier',
        "Aja",  -- Top tier: -ja spells (Firaja, Stoneja, etc.)
        "III",  -- High tier: -ga III spells
        "II",   -- Mid tier: -ga II spells
        "I"     -- Base tier: -ga I spells
    }
    state.AOETier:set("Aja")  -- Default to Aja (highest)

    -- ========================================
    -- STORM SPELLS (SCH SUBJOB)
    -- ========================================

    -- Storm: Storm spell selection (for SCH subjob)
    -- Note: Spell names must match FFXI resources exactly (all lowercase after first letter)
    state.Storm = M {
        ['description'] = 'Storm Spell',
        'Firestorm',
        'Sandstorm',
        'Thunderstorm',
        'Hailstorm',
        'Rainstorm',
        'Windstorm',
        'Voidstorm',
        'Aurorastorm'
    }
    state.Storm:set('Firestorm')  -- Default to Firestorm
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate all BLM states are configured correctly
--- @return boolean success True if all states valid
--- @return string message Validation result message
function BLMStates.validate()
    -- Check required states exist
    if not state.HybridMode then
        return false, "HybridMode state not configured"
    end
    if not state.CombatMode then
        return false, "CombatMode state not configured"
    end
    if not state.MagicBurstMode then
        return false, "MagicBurstMode state not configured"
    end
    if not state.DeathMode then
        return false, "DeathMode state not configured"
    end
    if not state.MainWeapon then
        return false, "MainWeapon state not configured"
    end
    if not state.SubWeapon then
        return false, "SubWeapon state not configured"
    end
    if not state.MainLightSpell then
        return false, "MainLightSpell state not configured"
    end
    if not state.MainDarkSpell then
        return false, "MainDarkSpell state not configured"
    end
    if not state.SpellTier then
        return false, "SpellTier state not configured"
    end
    if not state.MainLightAOE then
        return false, "MainLightAOE state not configured"
    end
    if not state.MainDarkAOE then
        return false, "MainDarkAOE state not configured"
    end
    if not state.AOETier then
        return false, "AOETier state not configured"
    end
    if not state.Storm then
        return false, "Storm state not configured"
    end

    return true, "All BLM states configured successfully"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLMStates
