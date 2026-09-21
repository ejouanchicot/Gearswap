---============================================================================
--- PLD State Configuration - Job States & Modes
---============================================================================
--- Defines all PLD job states (Combat Modes, Weapon Sets, XP Mode, Rune Mode).
---
--- Features:
---   • HybridMode configuration (PDT/MDT/Sortie, or DPS/Tanking/Hoxne under /SCH)
---   • MainWeapon state (full list, Burtgang/Naegling in Sortie,
---     Excalibur/Naegling under /SCH)
---   • XP Mode for Phalanx optimization (SIRD vs Potency)
---   • RuneMode for RUN subjob (Ignis/Gelus/Flabra/Tellus/Sulpor/Unda/Lux/Tenebrae)
---   • SneakInviAOE for SCH subjob (Accession on Sneak/Invisible)
---   • Keybind integration (Ctrl+Numpad binds in PLD_KEYBINDS.lua)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call PLDStates.configure() to initialize all states
---   • Call PLDStates.validate() to verify configuration (optional)
---
--- @file    config/pld/PLD_STATES.lua
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

---============================================================================
--- COMBAT MODE OPTIONS
---============================================================================

--- The three stances every subjob but SCH gets.
local STANDARD_HYBRID_OPTIONS = {'PDT', 'MDT', 'Sortie'}

--- PLD/SCH is played for Sortie and nothing else, so it drops the general
--- PDT/MDT/Sortie split for the stances that content asks for: hold hate,
--- feed weaponskills, or carry the Hoxne Ampulla.
--- DPS and Hoxne each own their engaged build: the Ampulla's charge supplies
--- the Double Attack that DPS has to buy with gear. Hoxne also freezes the
--- ammo slot (logic/ampulla_lock.lua), the Ampulla being swapped out by the
--- next set the moment it is equipped otherwise.
local SCH_HYBRID_OPTIONS = {'DPS', 'Tanking', 'Hoxne'}

--- Under /SCH the stance and the weapon are separate choices: the stance
--- picks the set, the ammo and the lock, MainWeapon picks what is in hand.
--- Burtgang is not on this list - the Tanking stance holds it outright, that
--- weapon being what makes it the hate stance (SetBuilder decides), so cycling
--- here never lands on it by accident.
--- SetBuilder pairs each weapon with its shield: Excalibur and Naegling take
--- Duban, Burtgang takes Aegis.
local SCH_WEAPON_OPTIONS = {
    'Excalibur', 'Naegling'
}

--- Which lists the states hold: 'sch', 'sortie', 'standard', or nil when
--- configure() has created the states without applying a profile yet.
local active_profile = nil

--- Whether the current subjob is the Sortie-only Scholar setup
--- @return boolean True when the subjob is SCH
local function is_sch()
    return player ~= nil and player.sub_job == 'SCH'
end

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
    --- Options outside /SCH:
    ---   • 'PDT' - Physical Damage Taken -50% (default for physical enemies)
    ---   • 'MDT' - Magic Damage Taken -50% (for magical enemies)
    ---   • 'Sortie' - Mitigation + TP build (sets.engaged.TP / sets.idle.MDT),
    ---              and sets.EnmityMax replaces sets.FullEnmity
    --- Options under /SCH (Sortie-only setup):
    ---   • 'Tanking' - Burtgang + Aegis, sets.engaged.MDT,
    ---              and sets.EnmityMax replaces sets.FullEnmity
    ---   • 'DPS'     - sets.engaged.DPS (TP build), weapon from MainWeapon
    ---   • 'Hoxne'   - sets.engaged.Hoxne, weapon from MainWeapon, ammo
    ---              frozen on Hoxne Ampulla so nothing swaps the charge away
    --- Keybind: Ctrl+Numpad9 to cycle
    if is_sch() then
        state.HybridMode:options(table.unpack(SCH_HYBRID_OPTIONS))
        state.HybridMode:set('Tanking') -- Hold hate first, TP once it sticks
    else
        state.HybridMode:options(table.unpack(STANDARD_HYBRID_OPTIONS))
        state.HybridMode:set('PDT') -- Default to PDT
    end

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Options and their order come from WEAPON_OPTIONS / SORTIE_WEAPON_OPTIONS
    --- / SCH_WEAPON_OPTIONS, reapplied by apply_hybrid_profile().
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
    --- Keybind: Ctrl+Numpad2 to cycle (held On, and unbound, under /SCH)
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
    --- Held On and unbound under /SCH: covering the party is the only reason
    --- this setup takes Scholar, so the single-target path has no caller.
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

    -- Rune list and Phalanx default follow the subjob and the combat mode, not
    -- the other way round. configure() runs again on every reload, so clearing
    -- the marker here is what lets a subjob change reinstall its profile.
    active_profile = nil
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

--- Which profile the states should hold right now.
--- The subjob decides first: /SCH is the Sortie-only setup and has its own
--- stances, so the PDT/MDT/Sortie question never reaches it.
--- @param mode string HybridMode value
--- @return string 'sch', 'sortie' or 'standard'
local function profile_for(mode)
    if is_sch() then
        return 'sch'
    end
    return (mode == 'Sortie') and 'sortie' or 'standard'
end

--- Install the option lists and forced toggles a profile owns.
--- @param profile string 'sch', 'sortie' or 'standard'
--- @return void
local function install_profile(profile)
    if profile == 'sch' then
        reshape(state.MainWeapon, SCH_WEAPON_OPTIONS)
        state.PhalanxSIRD:set('On')
        state.SneakInviAOE:set('On')
        return
    end

    if profile == 'sortie' then
        reshape(state.RuneMode, SORTIE_RUNE_OPTIONS)
        reshape(state.MainWeapon, SORTIE_WEAPON_OPTIONS)
        state.PhalanxSIRD:set('On')
        return
    end

    reshape(state.RuneMode, RUNE_OPTIONS)
    reshape(state.MainWeapon, WEAPON_OPTIONS)
    state.PhalanxSIRD:set('Off')
end

--- Reshape the states that depend on the subjob and on HybridMode.
---
--- Sortie is a fixed rotation: five runes and two weapons are ever wanted
--- there, and Phalanx is cast under fire, so SIRD is the default rather than
--- potency. Any other mode restores the full lists and potency Phalanx.
---
--- /SCH is that same content with its own stances, so it holds Phalanx SIRD
--- and the Accession sneak/invi on for good, and offers the two weapons its
--- DPS and Hoxne stances swing (the Tanking stance brings its own).
---
--- Installing a profile is skipped while it is already the one in place:
--- PDT <-> MDT keeps every choice, the Phalanx SIRD toggle included. When the
--- lists do change, the weapon and rune in use are kept if the new list has
--- them; a weapon the new list lacks falls back to its first entry.
---
--- @param mode string HybridMode value ('PDT'/'MDT'/'Sortie', or 'DPS'/'Tanking'/'Hoxne')
--- @return void
function PLDStates.apply_hybrid_profile(mode)
    if not (state.RuneMode and state.PhalanxSIRD and state.MainWeapon and state.SneakInviAOE) then
        return
    end

    local profile = profile_for(mode)
    if profile ~= active_profile then
        active_profile = profile
        install_profile(profile)
    end

end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate that states were configured correctly
--- Checks that all required states exist and have proper structure.
---
--- @return boolean success True if validation passed, false otherwise
--- @return string  message Validation message (success or error description)
function PLDStates.validate()
    -- Check HybridMode exists and has correct options
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
