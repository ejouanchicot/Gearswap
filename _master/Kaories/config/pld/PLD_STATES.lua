---============================================================================
--- PLD State Configuration - Job States & Modes
---============================================================================
--- Defines all PLD job states (Combat Modes, Weapon Sets, XP Mode, Rune Mode).
---
--- Features:
---   • HybridMode configuration (PDT/MDT/Sortie)
---   • MainWeapon state (full list, or Burtgang/Naegling in Sortie)
---   • XP Mode for Phalanx optimization (SIRD vs Potency)
---   • RuneMode for RUN subjob (Ignis/Gelus/Flabra/Tellus/Sulpor/Unda/Lux/Tenebrae)
---   • SneakInviAOE for SCH subjob (Accession on Sneak/Invisible)
---   • Keybind integration (Ctrl+Numpad binds in PLD_KEYBINDS.lua)
---   • validate() helper (not called anywhere today)
---
--- Usage:
---   • Loaded in user_setup(), which Mote-Include runs during its own init
---   • Call PLDStates.configure() to initialize all states
---   • Call PLDStates.validate() to verify configuration (optional)
---
--- @file    Kaories/config/pld/PLD_STATES.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
--- @requires Mote-Include (state, M objects)
---============================================================================
local PLDStates = {}

---============================================================================
--- RUNE OPTIONS
---============================================================================

--- Every rune, in cycle order.
--- Ignis (fire, resists ice)      Gelus (ice, resists wind)
--- Flabra (wind, resists earth)   Tellus (earth, resists lightning)
--- Sulpor (lightning, res. water) Unda (water, resists fire)
--- Lux (light, resists dark)      Tenebrae (dark, resists light)
local RUNE_OPTIONS = {
    'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda', 'Lux', 'Tenebrae'
}

--- The only runes Sortie ever asks for, in the order they are wanted.
local SORTIE_RUNE_OPTIONS = {
    'Ignis', 'Tenebrae', 'Sulpor', 'Flabra', 'Unda'
}

---============================================================================
--- WEAPON OPTIONS
---============================================================================

--- Every weapon set, in cycle order.
--- Burtgang (relic, enmity tank)   KC (Kraken Club, multi-attack)
--- BurtgangKC (PLD/DNC combo)      Naegling (Savage Blade)
--- Shining (Shining One, polearm)  Malevo (Malevolence, club)
local WEAPON_OPTIONS = {
    'Burtgang', 'KC', 'BurtgangKC', 'Naegling', 'Shining', 'Malevo'
}

--- Sortie runs on two weapons only. Their shields are picked by SetBuilder
--- from the weapon itself (Burtgang > Aegis, Naegling > Blurred Shield +1),
--- so no Sortie set has to carry a sub slot.
local SORTIE_WEAPON_OPTIONS = {
    'Burtgang', 'Naegling'
}

--- Which lists the states hold: true = Sortie, false = standard, nil = none
--- applied since configure() created the states.
local sortie_profile = nil

--- Replace a mode's options, keeping its current value when the new list has it.
--- Modes' options() resets the mode to its first entry, and for MainWeapon that
--- is a weapon swap, which costs TP.
--- @param mode_state table Mote mode (M{})
--- @param options table New options, in cycle order
--- @return void
local function reshape(mode_state, options)
    local current = mode_state.value
    mode_state:options(table.unpack(options))
    if current and mode_state:contains(current) then
        mode_state:set(current)
    end
end

---============================================================================
--- STATE CONFIGURATION
---============================================================================

--- Configure all PLD states
--- Must be called from user_setup() after Mote-Include is loaded.
---
--- @return void
function PLDStates.configure()
    -- ==========================================================================
    -- COMBAT MODES
    -- ==========================================================================

    --- HybridMode: Defensive stance configuration
    --- Options:
    ---   • 'PDT' - Physical Damage Taken -50% (default for physical enemies)
    ---   • 'MDT' - Magic Damage Taken -50% (for magical enemies)
    ---   • 'Sortie' - Mitigation + TP build (sets.engaged.TP / sets.idle.MDT),
    ---              and sets.EnmityMax replaces sets.FullEnmity
    --- Keybind: Ctrl+Numpad9 to cycle
    state.HybridMode:options('PDT', 'MDT', 'Sortie')
    state.HybridMode:set('PDT') -- Default to PDT

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Options and their order come from WEAPON_OPTIONS / SORTIE_WEAPON_OPTIONS,
    --- reapplied by apply_hybrid_profile() whenever HybridMode changes.
    --- Keybind: Ctrl+Numpad1 to cycle
    state.MainWeapon =
        M {
        ['description'] = 'Main Weapon',
        table.unpack(WEAPON_OPTIONS)
    }

    --- XP Mode: Phalanx optimization (RDM subjob)
    --- Options:
    ---   • 'On'  - Phalanx with SIRD (Spell Interruption Rate Down) - for XP/low level
    ---   • 'Off' - Phalanx with Potency (enhancing skill/duration) - for endgame
    --- Keybind: Ctrl+Numpad4 to cycle (RDM subjob only)
    state.Xp =
        M {
        ['description'] = 'Xp',
        'Off', -- Potency Phalanx (default)
        'On' -- SIRD Phalanx
    }

    --- PhalanxSIRD: Force SIRD Phalanx set regardless of XP mode
    --- Options:
    ---   • 'Off' - Use normal Phalanx routing (Potency or XP-based)
    ---   • 'On'  - Force SIRD Phalanx set (Spell Interruption Rate Down)
    --- Keybind: Ctrl+Numpad2 to cycle
    state.PhalanxSIRD =
        M {
        ['description'] = 'Phalanx SIRD',
        'Off', -- Normal routing (default)
        'On' -- Force SIRD set
    }

    --- RuneMode: Rune selection (RUN subjob)
    --- Options and their order come from RUNE_OPTIONS / SORTIE_RUNE_OPTIONS,
    --- reapplied by apply_hybrid_profile() whenever HybridMode changes.
    --- Keybind: Ctrl+Numpad3 to cycle (RUN subjob only)
    state.RuneMode =
        M {
        ['description'] = 'Rune Mode',
        table.unpack(RUNE_OPTIONS)
    }

    -- ==========================================================================
    -- SCH SUBJOB
    -- ==========================================================================

    --- SneakInviAOE: whether //gs c aoe sneak and //gs c aoe invi spend a stratagem
    --- charge on Accession to cover the party (SCH subjob).
    ---   • 'On'  - Light Arts + Accession, cast on self
    ---   • 'Off' - no stratagem, cast on a single target (<stal>)
    state.SneakInviAOE =
        M {
        ['description'] = 'Sneak/Invi AOE',
        'On',
        'Off'
    }

    -- ==========================================================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ==========================================================================

    --- FastCast: Fast Cast % for watchdog timeout calculation
    --- Set this to your total Fast Cast % from gear/traits
    --- Formula: adjusted_cast = base_cast × (1 - FC%/100)
    --- Cap: 80% maximum (FFXI mechanics)
    state.FastCast = M {
        ['description'] = 'Fast Cast %',
        0, 10, 20, 30, 40, 50, 60, 70, 80
    }
    state.FastCast:set(80)  -- Default: 80% (PLD needs FC for SIRD build)

    -- Rune list and Phalanx default follow the combat mode, not the other way
    -- round: cold load starts on PDT, so this installs the standard profile.
    sortie_profile = nil
    PLDStates.apply_hybrid_profile(state.HybridMode.value)

    -- Universal toggle, created here rather than centrally: the keybind HUD
    -- renders from user_setup() and caches what it reads, so a state added
    -- afterwards shows as N/A until something forces a redraw.
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if ok and AutoMedicine then
        AutoMedicine.init(state, M)
    end
end

---============================================================================
--- HYBRIDMODE PROFILE
---============================================================================

--- Reshape the states that depend on HybridMode.
---
--- Sortie is a fixed rotation: five runes and two weapons are ever wanted
--- there, and Phalanx is cast under fire, so SIRD is the default rather than
--- potency. Any other mode restores the full lists and potency Phalanx.
---
--- Only a move into or out of Sortie changes anything: PDT <-> MDT keeps every
--- choice, the Phalanx SIRD toggle included. When the lists do change, the
--- weapon and rune in use are kept if the new list has them; a weapon the
--- Sortie list lacks falls back to its first entry.
---
--- @param mode string HybridMode value ('PDT', 'MDT', 'Sortie')
--- @return void
function PLDStates.apply_hybrid_profile(mode)
    if not (state.RuneMode and state.PhalanxSIRD and state.MainWeapon) then
        return
    end

    local sortie = (mode == 'Sortie')
    if sortie == sortie_profile then
        return
    end
    sortie_profile = sortie

    if sortie then
        reshape(state.RuneMode, SORTIE_RUNE_OPTIONS)
        reshape(state.MainWeapon, SORTIE_WEAPON_OPTIONS)
        state.PhalanxSIRD:set('On')
    else
        reshape(state.RuneMode, RUNE_OPTIONS)
        reshape(state.MainWeapon, WEAPON_OPTIONS)
        state.PhalanxSIRD:set('Off')
    end
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate that states were configured correctly
--- Checks that HybridMode, MainWeapon, Xp, RuneMode and SneakInviAOE exist.
---
--- @return boolean success True if validation passed, false otherwise
--- @return string  message Validation message (success or error description)
function PLDStates.validate()
    -- Check HybridMode exists
    if not state.HybridMode then
        return false, 'HybridMode state not configured'
    end

    -- Check MainWeapon exists
    if not state.MainWeapon then
        return false, 'MainWeapon state not configured'
    end

    -- Check XP mode exists
    if not state.Xp then
        return false, 'Xp state not configured'
    end

    -- Check RuneMode exists
    if not state.RuneMode then
        return false, 'RuneMode state not configured'
    end

    if not state.SneakInviAOE then
        return false, 'SneakInviAOE state not configured'
    end

    return true, 'All PLD states configured successfully'
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make globally available: the shared state-change hook reaches the profile
-- through _G, the character path of this file being unknown to shared/.
_G.PLDStates = PLDStates

return PLDStates
