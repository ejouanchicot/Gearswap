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
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, song announcements)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Cooldown checker (universal ability/spell recast validation)
local CooldownChecker = require('shared/utils/precast/cooldown_checker')

-- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
local precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
if not precast_guard_success then
    PrecastGuard = nil
end

-- Weaponskill manager (WS validation + range checking)
include('../shared/utils/weaponskill/weaponskill_manager.lua')

-- TP bonus calculator (Moonshade Earring automation)
include('../shared/utils/weaponskill/tp_bonus_calculator.lua')

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- WS Validator (universal WS range + validity validation)
local _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

-- Set MessageFormatter in WeaponSkillManager
if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
end

---============================================================================
--- DEPENDENCIES - BRD SPECIFIC
---============================================================================

-- Song refinement system (auto-downgrade debuff songs if on cooldown)
local SongRefinement = require('shared/jobs/brd/functions/logic/song_refinement')

-- Instrument lock configuration (Honor March, Aria of Passion)
local InstrumentLockConfig = require('shared/jobs/brd/functions/logic/instrument_lock_config')

-- BRD configuration
local BRDTPConfig = _G.BRDTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Called before any action (song, JA, spell, etc.)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
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

    -- AUTO-PIANISSIMO: If targeting a party member, auto-activate Pianissimo
    if spell.type == 'BardSong' and spell.target and spell.target.type == 'PLAYER' then
        if spell.target.id and spell.target.id ~= player.id then
            -- Targeting another player → use Pianissimo
            if not buffactive['Pianissimo'] then
                cancel_spell()
                send_command('input /ja "Pianissimo" <me>')
                send_command('wait 1; input /ma "' .. spell.english .. '" <t>')
                MessageFormatter.show_pianissimo_target(spell.target.name or 'Unknown')
                eventArgs.cancel = true
                return
            end
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
                -- Not targeting another player → check for Marcato
                local has_ni = buffactive['Nightingale'] or false
                local has_tr = buffactive['Troubadour'] or false
                local has_sv = buffactive['Soul Voice'] or false

                if has_ni and has_tr and not has_sv and not buffactive['Marcato'] then
                    -- Check if Marcato is available (not on cooldown)
                    local marcato_recast = windower.ffxi.get_ability_recasts()[48] or 0

                    if marcato_recast == 0 then
                        -- Marcato ready → use before target song
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
