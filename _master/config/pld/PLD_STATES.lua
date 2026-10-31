---============================================================================
--- PLD State Configuration - Job States & Modes
---============================================================================
--- Defines all PLD job states (Combat Modes, Weapon Sets, XP Mode, Rune Mode).
---
--- Features:
---   • HybridMode configuration (PDT/MDT, plus DPS/Tanking/Hoxne under /SCH and /RUN)
---   • MainWeapon state (full list, Excalibur/Naegling under /SCH and /RUN)
---   • XP Mode for Phalanx optimization (SIRD vs Potency)
---   • RuneMode for RUN subjob (Ignis/Gelus/Flabra/Tellus/Sulpor/Unda/Lux/Tenebrae)
---   • SneakInviAOE for SCH subjob (Accession on Sneak/Invisible)
---   • Keybind integration (Ctrl+Numpad binds in PLD_KEYBINDS.lua)
---   • Validation function to verify state configuration
---
--- Usage:
---   • Loaded in user_setup() after Mote-Include initializes
---   • Call PLDStates.configure() to initialize all states
---
--- @file    config/pld/PLD_STATES.lua
--- @author  ejouanchicot
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

--- Every weapon set, in cycle order: Burtgang first, the weapon a tank holds by default.
--- Burtgang (mythic, enmity tank)  Excalibur (relic, Knights of Round)
--- KC (Kraken Club, multi-attack)
--- BurtgangKC (PLD/DNC combo)      Naegling (Savage Blade)
--- Shining (Shining One, polearm)  Malevo (Malevolence, club)
local WEAPON_OPTIONS = {
    'Burtgang', 'Excalibur', 'KC', 'BurtgangKC', 'Naegling', 'Shining', 'Malevo'
}

---============================================================================
--- COMBAT MODE OPTIONS
---============================================================================

--- The stances every subjob but /SCH and /RUN (STANCE_SUBJOBS) gets: the tank ones (they fight in their idle
--- set) and DPS, the TP build (sets.engaged.DPS, Naegling or Excalibur). Tanking and Hoxne are played under
--- /RUN and /SCH only.
local STANDARD_HYBRID_OPTIONS = {'PDT', 'MDT', 'DPS'}

--- Subjobs played for Sortie and nothing else: they take the Sortie stances
--- (STANCE_SUB_OPTIONS), their weapon list and Phalanx SIRD, and the /SCH
--- weaponskill variants (sets.precast.WS.SCH, PLD_PRECAST.lua). What only one
--- of them has stays its own: Accession sneak/invi and Regen under /SCH, the
--- Sortie runes under /RUN.
local STANCE_SUBJOBS = {SCH = true, RUN = true}

--- Subjobs that offer the Regen state (sets.idleRegen over the idle): their keys in PLD_KEYBINDS.lua.
local REGEN_SUBJOBS = {SCH = true, RUN = true}

--- The Sortie stances of PLD/SCH and /RUN (DPS, Tanking, Hoxne), offered beside the classic PDT and MDT
--- (STANCE_SUB_OPTIONS below): hold hate, feed weaponskills, or carry the Hoxne Ampulla.
--- DPS and Hoxne each own their engaged build: the Ampulla's charge supplies
--- the Double Attack that DPS has to buy with gear. Hoxne also freezes the
--- ammo slot (shared/utils/equipment/ampulla_lock.lua), the Ampulla being swapped out by the
--- next set the moment it is equipped otherwise.
--- What /SCH and /RUN offer: the classic stances first (PDT, the default, and MDT, as on any subjob: weapons
--- from WEAPON_OPTIONS, the set's own shield), then the Sortie ones (Tanking: Burtgang + Aegis, DPS, Hoxne).
local STANCE_SUB_OPTIONS = {'PDT', 'MDT', 'DPS', 'Tanking', 'Hoxne'}

--- Whether a HybridMode value is one of the Sortie stances.
local SORTIE_STANCE = {DPS = true, Tanking = true, Hoxne = true}

--- Under /SCH the stance and the weapon are separate choices: the stance
--- picks the set, the ammo and the lock, MainWeapon picks what is in hand.
--- Burtgang is not on this list - the Tanking stance holds it outright, that
--- weapon being what makes it the hate stance (SetBuilder decides), so cycling
--- here never lands on it by accident.
--- SetBuilder pairs each weapon with its shield: Excalibur and Naegling take
--- Duban, Burtgang takes Aegis.
--- Naegling leads: it is what the setup opens on, Excalibur being the choice
--- you make when you want Knights of Round.
local SCH_WEAPON_OPTIONS = {
    'Naegling', 'Excalibur'
}

--- Which lists the states hold: 'sch', 'dps', 'standard', or nil when
--- configure() has created the states without applying a profile yet.
local active_profile = nil

--- Whether the current subjob is SCH (Accession, Regen)
--- @return boolean True when the subjob is SCH
local function is_sch()
    return player ~= nil and player.sub_job == 'SCH'
end

--- Whether the current subjob plays the Sortie stances (STANCE_SUBJOBS)
--- @return boolean
local function is_stance_sub()
    return player ~= nil and STANCE_SUBJOBS[player.sub_job] == true
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
    --- Options on every subjob:
    ---   • 'PDT' - fights and idles in sets.idle.PDT (default)
    ---   • 'MDT' - fights and idles in sets.idle.MDT
    ---   • 'DPS' - the TP build (sets.engaged.DPS), Naegling or Excalibur; idles in
    ---            the set its Idle Defense mode names (below)
    --- Options under /SCH and /RUN only (the Sortie setup; DPS there takes Phalanx SIRD):
    ---   • 'Tanking' - Burtgang + Aegis, fights and idles in sets.idle.MDT,
    ---              and sets.EnmityMax replaces sets.FullEnmity
    ---   • 'Hoxne'   - sets.engaged.Hoxne, weapon from MainWeapon, ammo
    ---              frozen on Hoxne Ampulla so nothing swaps the charge away
    --- Keybind: Ctrl+Numpad9 to cycle
    if is_stance_sub() then
        -- the classic stances and the Sortie ones (STANCE_SUB_OPTIONS), PDT first: Tanking is for Sortie only
        state.HybridMode:options(table.unpack(STANCE_SUB_OPTIONS))
        state.HybridMode:set('PDT')
    else
        state.HybridMode:options(table.unpack(STANDARD_HYBRID_OPTIONS))
        state.HybridMode:set('PDT') -- Default to PDT
    end

    --- IdleDefense: the idle set of the TP stances (DPS; Hoxne under /SCH and /RUN), whose
    --- engaged builds leave the standing defense to choose. The tank stances idle in
    --- their own set (PDT: sets.idle.PDT; MDT, Tanking: sets.idle.MDT).
    ---   • 'MDT' - sets.idle.MDT (default)
    ---   • 'PDT' - sets.idle.PDT
    --- Read by logic/set_builder.lua (IDLE_SET_BY_MODE). Keybind: Ctrl+Numpad8, shown
    --- in DPS and Hoxne only (PLD_KEYBINDS.lua); //gs c set IdleDefense PDT|MDT too.
    state.IdleDefense = M {['description'] = 'Idle Defense', 'MDT', 'PDT'}

    -- ==========================================================================
    -- WEAPON SETS
    -- ==========================================================================

    --- MainWeapon: Primary weapon selection
    --- Options and their order come from WEAPON_OPTIONS / SCH_WEAPON_OPTIONS,
    --- reapplied by apply_hybrid_profile().
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
    --- Keybind: Ctrl+Numpad2 to cycle (Ctrl+Numpad3 under /SCH, where it starts On)
    state.PhalanxSIRD =
        M {
        ['description'] = 'Phalanx SIRD',
        'Off', -- Normal routing (default)
        'On' -- Force SIRD set
    }

    --- Shield: the shield in the off hand, over the one the stance and weapon give
    --- (pld/combat/PLD_WEAPONS.lua shields). 'Auto' leaves it to them; a shield
    --- name forces it (a two-handed weapon keeps its grip). Keybind: Ctrl+Numpad0; also set by
    --- //gs c sortie <target> (SORTIE_CONFIG.lua states) or //gs c set Shield <name>.
    state.Shield =
        M {
        ['description'] = 'Shield',
        'Auto',
        'Duban',
        'Aegis',
        'Blurred Shield +1'
    }

    --- StanceWeapon: the weapon a stance that holds one puts in hand (Tanking:
    --- pld/combat/PLD_WEAPONS.lua stance_weapon), over that stance's own.
    --- 'Auto' leaves it to the stance. The weaponskill slots follow it. Keybind:
    --- Ctrl+Numpad1 in the Tanking stance (MainWeapon's key elsewhere); also set by
    --- //gs c sortie <target> (SORTIE_CONFIG.lua states) or //gs c set StanceWeapon <name>.
    state.StanceWeapon =
        M {
        ['description'] = 'Stance Weapon',
        'Auto',
        'Naegling',
        'Excalibur'
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

    --- Regen: lay sets.idleRegen over the idle set the stance already chose.
    --- Idle only, so it never costs anything in combat; the stance keeps every
    --- slot the Regen set leaves out.
    --- Key ^numpad2 under /SCH (PLD_KEYBINDS.lua), or a macro with
    --- //gs c set Regen On|Off. Shown in the HUD under /SCH and /RUN (^numpad7 there) - the
    --- other subjobs force it Off below rather than leave it On where the HUD does
    --- not show it.
    state.Regen =
        M {
        ['description'] = 'Regen',
        'Off',
        'On'
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
        '0', '10', '20', '30', '40', '50', '60', '70', '80'
    }
    state.FastCast:set('80')  -- Default: 80% (PLD needs FC for SIRD build)

    -- Rune list and Phalanx default follow the subjob and the combat mode, not
    -- the other way round. configure() runs again on every reload, so clearing
    -- the marker here is what lets a subjob change reinstall its profile.
    active_profile = nil
    PLDStates.apply_hybrid_profile(state.HybridMode.value)

    -- Weaponskill slots (state.WS1..WSn, n = PLDWSConfig.max_slots), built from the weapon in hand.
    -- Created here for the same reason AutoMedicine is: a state born after
    -- user_setup() is missing from the row structure the HUD lays out, and
    -- reads as N/A however live its value lookup is.
    --
    -- SetBuilder knows the stance overrides the weapon choice (Tanking holds
    -- Burtgang); it is pcall'd because this runs early, and the weapon choice
    -- alone is a good enough fallback - the first state change refreshes it.
    local ws_ok, WSSlots = pcall(require, 'shared/utils/weaponskill/ws_slots')
    if ws_ok and WSSlots and _G.PLDWSConfig then
        local sb_ok, SetBuilder = pcall(require, 'shared/jobs/pld/functions/logic/set_builder')
        local weapon = (sb_ok and SetBuilder and SetBuilder.current_weapon())
            or (state.MainWeapon and state.MainWeapon.value)
        WSSlots.rebuild(_G.PLDWSConfig.get(weapon), _G.PLDWSConfig.max_slots)
    end

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
--- The subjob decides first: under /SCH and /RUN (STANCE_SUBJOBS), the Sortie setup,
--- DPS, Tanking and Hoxne take the /SCH profile; on any other subjob DPS takes the dps one (the
--- same two weapons, nothing of the Sortie setup); PDT and MDT the standard one, as anywhere.
--- @param mode string HybridMode value
--- @return string 'sch', 'dps' or 'standard'
local function profile_for(mode)
    if is_stance_sub() and SORTIE_STANCE[mode] then
        return 'sch'
    end
    return mode == 'DPS' and 'dps' or 'standard'
end

--- Install the option lists and forced toggles a profile owns.
--- @param profile string 'sch', 'dps' or 'standard'
--- @param was string|nil The profile in place before (nil on a load)
--- @return void
local function install_profile(profile, was)
    if profile == 'sch' then
        reshape(state.MainWeapon, SCH_WEAPON_OPTIONS)

        -- reshape keeps whatever weapon was already selected when the new list
        -- has it, to spare the TP a swap costs. Entering the setup is not that
        -- case: the stance defaults have just been reset too, so the weapon
        -- opens on the same footing rather than carrying over the last job's.
        state.MainWeapon:set(SCH_WEAPON_OPTIONS[1])

        state.PhalanxSIRD:set('On')
        if is_sch() then
            state.SneakInviAOE:set('On')
        else
            -- /RUN: the Sortie runes (Regen stays as it is: /RUN has it too)
            reshape(state.RuneMode, SORTIE_RUNE_OPTIONS)
        end
        return
    end

    reshape(state.RuneMode, RUNE_OPTIONS)
    if profile == 'dps' then
        -- the TP build's two weapons, Naegling first (as entering the /SCH setup)
        reshape(state.MainWeapon, SCH_WEAPON_OPTIONS)
        state.MainWeapon:set(SCH_WEAPON_OPTIONS[1])
    else
        reshape(state.MainWeapon, WEAPON_OPTIONS)
        -- back from a TP stance (DPS, Hoxne) to a tank one: the tank's weapon again, Burtgang (the list's first),
        -- its TP lost rather than tanking with Naegling (the player's rule, 2026-10-31)
        if was == 'sch' or was == 'dps' then state.MainWeapon:set(WEAPON_OPTIONS[1]) end
    end
    state.PhalanxSIRD:set('Off')
    -- Not shown in the HUD outside /SCH and /RUN: turned Off there rather than left On unseen.
    if not (player and REGEN_SUBJOBS[player.sub_job]) then state.Regen:set('Off') end
end

--- Reshape the states that depend on the subjob and on HybridMode.
---
--- The Sortie stances of /SCH and /RUN (DPS, Tanking, Hoxne) are a fixed
--- rotation, Phalanx cast under fire: they hold Phalanx SIRD on, /SCH the
--- Accession sneak/invi and /RUN the five Sortie runes, and offer the two
--- weapons the DPS and Hoxne stances swing (the Tanking stance brings its own).
--- PDT and MDT restore the full lists and potency Phalanx.
---
--- Installing a profile is skipped while it is already the one in place:
--- PDT <-> MDT keeps every choice, the Phalanx SIRD toggle included. When the
--- lists do change, the weapon and rune in use are kept if the new list has
--- them; a weapon the new list lacks falls back to its first entry.
---
--- @param mode string HybridMode value ('PDT'/'MDT', or 'DPS'/'Tanking'/'Hoxne')
--- @return void
function PLDStates.apply_hybrid_profile(mode)
    if not (state.RuneMode and state.PhalanxSIRD and state.MainWeapon and state.SneakInviAOE
        and state.Regen) then
        return
    end

    local profile = profile_for(mode)
    if profile ~= active_profile then
        local was = active_profile
        active_profile = profile
        install_profile(profile, was)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

--- Whether the current subjob plays the Sortie stances (/SCH, /RUN): PLD_PRECAST
--- swaps in the sets.precast.WS.SCH weaponskill variants for those.
--- @return boolean
PLDStates.stance_subjob = function()
    return is_stance_sub() and state.HybridMode ~= nil and SORTIE_STANCE[state.HybridMode.value] == true
end

-- Make globally available: the shared state-change hook reaches the profile
-- through _G, the character path of this file being unknown to shared/.
_G.PLDStates = PLDStates

return PLDStates
