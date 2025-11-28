---============================================================================
--- BRD Precast Module - Precast Action Handling & Fast Cast Optimization
---============================================================================
--- Handles all precast actions for Bard job:
---   • Fast Cast optimization (cap 80%)
---   • Song precast (Casting Time reduction)
---   • Job ability precast (Soul Voice, Nightingale, Troubadour, Pianissimo)
---   • Honor March protection system (Marsyas lock)
---   • Song refinement (auto-downgrade debuff songs on cooldown)
---   • Security layers (debuff guard, cooldown check)
---
--- @file    BRD_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-13
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================
-- All modules are loaded on first action (job_precast call)
-- This reduces startup time from ~234ms to ~1ms

local MessageFormatter = nil
local MessagePrecast = nil
local CooldownChecker = nil
local PrecastGuard = nil
local TPBonusHandler = nil
local WSValidator = nil
local SongRefinement = nil
local InstrumentLockConfig = nil
local JA_DB = nil
local WS_DB = nil

local BRDTPConfig = _G.BRDTPConfig or {}

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    -- Load universal systems
    MessageFormatter = require('shared/utils/messages/message_formatter')
    MessagePrecast = require('shared/utils/messages/formatters/magic/message_precast')
    CooldownChecker = require('shared/utils/precast/cooldown_checker')

    local precast_guard_success
    precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
    if not precast_guard_success then
        PrecastGuard = nil
    end

    include('../shared/utils/weaponskill/weaponskill_manager.lua')
    include('../shared/utils/weaponskill/tp_bonus_calculator.lua')

    local _
    _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')
    _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

    if WeaponSkillManager and MessageFormatter then
        WeaponSkillManager.MessageFormatter = MessageFormatter
    end

    -- Load BRD-specific systems
    SongRefinement = require('shared/jobs/brd/functions/logic/song_refinement')
    InstrumentLockConfig = require('shared/jobs/brd/functions/logic/instrument_lock_config')
    JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')
    WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

    modules_loaded = true
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Called before any action (song, JA, spell, etc.)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first action (saves ~150ms at startup)
    ensure_modules_loaded()

    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked, exit immediately
    end

    -- SECOND: Song refinement (auto-downgrade debuff songs if on cooldown)
    if spell.type == 'BardSong' then
        if SongRefinement.refine_song(spell, eventArgs) then
            return -- Song was refined/cancelled, exit
        end
    end

    -- AUTO-PIANISSIMO
    -- If targeting another PC (not self, not charmed), auto-activate Pianissimo
    if spell.type == 'BardSong' then
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

    -- AUTO-MARCATO: Configurable song (state.MarcatoSong) with Nitro and not using Pianissimo
    if spell.type == 'BardSong' and state and state.MarcatoSong then
        local marcato_enabled = state.MarcatoSong.value ~= 'Off'
        local target_song = nil

        if state.MarcatoSong.value == 'HonorMarch' then
            target_song = 'Honor March'
        elseif state.MarcatoSong.value == 'AriaPassion' then
            target_song = 'Aria of Passion'
        end

        if marcato_enabled and target_song and spell.english == target_song then
            if spell.target.type ~= 'PLAYER' or spell.target.id == player.id then
                -- Not targeting another player >> check for Marcato
                local has_ni = buffactive['Nightingale'] or false
                local has_tr = buffactive['Troubadour'] or false
                local has_sv = buffactive['Soul Voice'] or false

                if has_ni and has_tr and not has_sv and not buffactive['Marcato'] then
                    -- Check if Marcato is available (not on cooldown)
                    local marcato_recast = windower.ffxi.get_ability_recasts()[48] or 0

                    if marcato_recast == 0 then
                        -- Marcato ready >> use before target song
                        cancel_spell()
                        send_command('input /ja "Marcato" <me>')
                        send_command('wait 2; input /ma "' .. target_song .. '" <me>')
                        MessageFormatter.show_marcato_honor_march(target_song)
                        eventArgs.cancel = true
                        return
                    end
                    -- If Marcato on cooldown: just cast song without it (no message spam)
                end
            end
        end
    end

    -- THIRD: Universal cooldown check
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if action was cancelled
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- DISABLED: BRD Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end
    -- WeaponSkill validation
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- BRD-specific TP Bonus gear optimization for weaponskills
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, BRDTPConfig)
    end

    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (with description + final TP including Moonshade)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' then
        local current_tp = player and player.vitals and player.vitals.tp or 0

        if current_tp >= 1000 then
            -- Check if WS is in database
            if WS_DB and WS_DB[spell.english] then
                -- Calculate final TP (includes Moonshade bonus if equipped)
                local final_tp = current_tp

                -- Try to get final TP with Moonshade bonus
                if TPBonusCalculator and TPBonusCalculator.get_final_tp then
                    local weapon_name = player.equipment and player.equipment.main or nil
                    local sub_weapon = player.equipment and player.equipment.sub or nil
                    local tp_gear = _G.temp_tp_bonus_gear

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, BRDTPConfig, weapon_name, buffactive, sub_weapon)
                    if success then
                        final_tp = result
                    end
                end

                    end
        else
            -- Not enough TP - display error
            MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
        end
    end


    -- CRITICAL: Instrument Lock Protection System
    -- Some songs (Honor March, Aria of Passion) require specific instruments
    -- that MUST stay equipped throughout the entire cast or the song fails
    if spell.type == 'BardSong' and InstrumentLockConfig.requires_lock(spell.english) then
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
end

--- Apply final gear adjustments before equipping
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Apply TP bonus gear (Moonshade) without message (already displayed in precast with final TP)
    if spell.type == 'WeaponSkill' then
        local tp_gear = _G.temp_tp_bonus_gear
        if tp_gear then
            equip(tp_gear)
            _G.temp_tp_bonus_gear = nil
        end
    end

    -- Nightingale active - even faster cast time for songs
    if buffactive['Nightingale'] and spell.skill == 'Singing' then
    -- Keep precast gear as-is (instant cast with Nightingale + Fast Cast cap)
    end

    -- ==========================================================================
    -- DEBUG: PRECAST SET DISPLAY (Universal System)
    -- ==========================================================================
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

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export to global scope for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export module
local BRD_PRECAST = {}
BRD_PRECAST.job_precast = job_precast
BRD_PRECAST.job_post_precast = job_post_precast

return BRD_PRECAST
