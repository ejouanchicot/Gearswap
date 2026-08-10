---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Precast Module - Precast Action Handling & Fast Cast Optimization
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for Bard job:
---   • Fast Cast optimization (cap 80%)
---   • Song precast (Casting Time reduction)
---   • Job ability precast (Soul Voice, Nightingale, Troubadour, Pianissimo)
---   • Honor March protection system (Marsyas lock)
---   • Song refinement (auto-downgrade debuff songs on cooldown)
---   • Security layers (debuff guard, cooldown check)
---
---   @file    BRD_PRECAST.lua
---   @author  Tetsouo
---   @version 2.0
---   @date    Created: 2025-10-13
---   @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════
-- All modules are loaded on first action (lazy loading)

local MessageFormatter = nil
local MessagePrecast = nil
local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local SongRefinement = nil
local InstrumentLockConfig = nil

local BRDTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    BRDTPConfig = _G.BRDTPConfig or {}

    -- Load universal systems
    local mf_ok, mf = pcall(require, 'shared/utils/messages/message_formatter')
    if not mf_ok then mf = nil end
    MessageFormatter = mf

    local mp_ok, mp = pcall(require, 'shared/utils/messages/formatters/magic/message_precast')
    if not mp_ok then mp = nil end
    MessagePrecast = mp

    local cc_ok, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    if not cc_ok then cc = nil end
    CooldownChecker = cc

    local pg_ok, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    if not pg_ok then pg = nil end
    PrecastGuard = pg

    local wph_ok, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    if not wph_ok then wph = nil end
    WSPrecastHandler = wph

    -- Load BRD-specific systems
    local sr_ok, sr = pcall(require, 'shared/jobs/brd/functions/logic/song_refinement')
    if not sr_ok then sr = nil end
    SongRefinement = sr

    local ilc_ok, ilc = pcall(require, 'shared/jobs/brd/functions/logic/instrument_lock_config')
    if not ilc_ok then ilc = nil end
    InstrumentLockConfig = ilc

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Extracted from job_precast: the `spell.type == 'BardSong'` branch.
local function job_precast_bardsong(spell, eventArgs)
    local target_name = nil

    -- Check if targeting another PC
    if spell.target and spell.target.name and spell.target.name ~= player.name then
        -- Verify it's a PC (not monster, not NPC, not charmed)
        if spell.target.spawn_type and (spell.target.spawn_type == 13 or spell.target.in_party or spell.target.in_alliance) then
            if not spell.target.charmed then
                target_name = spell.target.name
            end
        end
    end

    -- If targeting another player, add Pianissimo
    if target_name and not buffactive['Pianissimo'] then
        -- ANTI-LOOP: Use synchronous flag to prevent double-cast
        if _G.pianissimo_in_progress then
            return
        end

        _G.pianissimo_in_progress = true

        cancel_spell()
        send_command('input /ja "Pianissimo" <me>')
        send_command('wait 2; input /ma "' .. spell.english .. '" "' .. target_name .. '"')

        MessageFormatter.show_pianissimo_target(target_name)
        eventArgs.cancel = true
        return
    end
end

--- Extracted from job_precast: the `spell.type == 'BardSong' and InstrumentLockConfig.requires_l` branch.
local function job_precast_bardsong_2(spell)
    local instrument = InstrumentLockConfig.get_instrument(spell.english)

    -- Equip instrument immediately
    equip({range = instrument})

    -- Set global flags to protect instrument during cast
    _G.casting_locked_song = true
    _G.locked_song_name = spell.english
    _G.locked_instrument = instrument

    -- Display lock message
    MessageFormatter.show_instrument_locked(spell.english, instrument)
end

--- The song Marcato is configured to boost, if any.
--- @return string|nil Song name, nil when the mode is off or unrecognised
local function marcato_target_song()
    if not (state and state.MarcatoSong) or state.MarcatoSong.value == 'Off' then
        return nil
    end
    if state.MarcatoSong.value == 'HonorMarch' then
        return 'Honor March'
    elseif state.MarcatoSong.value == 'AriaPassion' then
        return 'Aria of Passion'
    end
    return nil
end

--- Slip Marcato in ahead of the configured song, when it is worth doing.
---
--- Only under Nightingale and Troubadour together, which is the window where
--- the extra potency is worth an ability charge. Soul Voice already maxes the
--- song, so Marcato on top of it is wasted. Targeting another player is the
--- Pianissimo path and takes the song as it is.
---
--- On success the original cast is cancelled and replaced by Marcato followed
--- by the song, which is why it reports whether it acted.
--- @return boolean True when the cast was replaced
local function try_marcato(spell, eventArgs)
    local target_song = marcato_target_song()
    if not target_song or spell.english ~= target_song then
        return false
    end

    -- Another player as target means Pianissimo, not Marcato.
    if spell.target.type == 'PLAYER' and spell.target.id ~= player.id then
        return false
    end

    local has_ni = buffactive['Nightingale'] or false
    local has_tr = buffactive['Troubadour'] or false
    local has_sv = buffactive['Soul Voice'] or false
    if not (has_ni and has_tr) or has_sv or buffactive['Marcato'] then
        return false
    end

    -- 48 is Marcato. On cooldown, cast the song plainly rather than nag.
    local marcato_recast = windower.ffxi.get_ability_recasts()[48] or 0
    if marcato_recast > 0 then
        return false
    end

    cancel_spell()
    send_command('input /ja "Marcato" <me>')
    send_command('wait 2; input /ma "' .. target_song .. '" <me>')
    MessageFormatter.show_marcato_honor_march(target_song)
    eventArgs.cancel = true
    return true
end

function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    if spell.type == 'BardSong' then
        -- Refinement runs BEFORE the cooldown check, and must keep doing so.
        -- A song on recast can be downgraded - Lullaby II to Lullaby I - but
        -- only if it is still alive to downgrade; checking the cooldown first
        -- cancels it outright and the downgrade never happens. This is the one
        -- documented departure from the standard precast order.
        if SongRefinement.refine_song(spell, eventArgs) then
            return
        end

        job_precast_bardsong(spell, eventArgs)

        if try_marcato(spell, eventArgs) then
            return
        end
    end

    if CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        return
    end

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BRDTPConfig) then
        return
    end

    -- Honor March and Aria of Passion need their instrument to stay on for the
    -- whole cast, or the song simply fails.
    if spell.type == 'BardSong' and InstrumentLockConfig.requires_lock(spell.english) then
        job_precast_bardsong_2(spell)
    end
end

---   Apply final gear adjustments before equipping
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- Nightingale active - even faster cast time for songs
    if buffactive['Nightingale'] and spell.skill == 'Singing' then
    -- Keep precast gear as-is (instant cast with Nightingale + Fast Cast cap)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- DEBUG: PRECAST SET DISPLAY (Universal System)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Mote-Include already handles FC fallback: spell.name > spell.skill > base
    -- We just add debug display to show which set was selected
    if _G.PrecastDebugState and spell.action_type == 'Magic' then
        local selected_set = nil
        local set_name = 'sets.precast.FC'

        -- Detect which set Mote-Include selected
        if spell.type == 'BardSong' and sets.precast.BardSong then
            selected_set = sets.precast.BardSong
            set_name = 'sets.precast.BardSong'
        elseif sets.precast.FC and sets.precast.FC[spell.name] then
            selected_set = sets.precast.FC[spell.name]
            set_name = 'sets.precast.FC.' .. spell.name
        elseif spell.skill and sets.precast.FC and sets.precast.FC[spell.skill] then
            selected_set = sets.precast.FC[spell.skill]
            set_name = 'sets.precast.FC[\'' .. spell.skill .. '\']'
        else
            selected_set = sets.precast.FC
            set_name = 'sets.precast.FC'
        end

        -- Show debug info
        MessagePrecast.show_debug_header(spell.name, spell.skill or 'Unknown')
        MessagePrecast.show_equipped_set(set_name)

        if selected_set then
            MessagePrecast.show_equipment(selected_set)
        end

        MessagePrecast.show_completion()
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}

