---============================================================================
--- SAM Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- @file SAM_PRECAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local CooldownChecker = require('shared/utils/precast/cooldown_checker')
local AbilityHelper = require('shared/utils/precast/ability_helper')

-- Load precast guard for debuff blocking
local precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
if not precast_guard_success then
    PrecastGuard = nil
end

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- WS Validator (universal WS range + validity validation)
local _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

-- SAM TP configuration (TP bonus gear thresholds)
local SAMTPConfig = _G.SAMTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- Load weaponskill manager
include('shared/utils/weaponskill/weaponskill_manager.lua')

if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
end

---============================================================================
--- SAM-SPECIFIC HELPERS
---============================================================================

--- Module-level variable to track Seigan cast attempts
local seigan_cast_attempted = false

--- Auto-cast Seigan before Third Eye if Seigan not active
--- @param spell table Spell data
--- @param eventArgs table Event arguments
local function try_seigan_before_third_eye(spell, eventArgs)
    if spell.english ~= 'Third Eye' then
        return false
    end

    -- If Seigan not active, cast it first
    if not buffactive.Seigan then
        if not seigan_cast_attempted then
            eventArgs.cancel = true
            seigan_cast_attempted = true
            send_command('input /ja Seigan <me>')
            send_command('@wait 1;input /ja "Third Eye" <me>')
            MessageFormatter.show_auto_ability('Seigan', 'Third Eye', 'SAM')
            return true
        else
            seigan_cast_attempted = false
        end
    end

    return false
end

--- Auto-cast Third Eye before weaponskills if available
--- @param spell table Spell data
--- @param eventArgs table Event arguments
local function try_third_eye_ws(spell, eventArgs)
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Check if Third Eye is available
    if not buffactive['Third Eye'] then
        local abilities = windower.ffxi.get_abilities()
        local ability_recasts = windower.ffxi.get_ability_recasts()

        if abilities and abilities.job_abilities then
            for _, ability_id in ipairs(abilities.job_abilities) do
                local res_ability = res.job_abilities[ability_id]
                if res_ability and res_ability.en == 'Third Eye' then
                    local recast = ability_recasts[ability_id] or 0
                    if recast == 0 then
                        -- Third Eye ready, cast it before WS
                        eventArgs.cancel = true
                        send_command('input /ja "Third Eye" <me>; wait 1.5; input /ws "' .. spell.name .. '" ' .. spell.target.raw)
                        MessageFormatter.show_auto_ability('Third Eye', spell.name, 'SAM')
                        return true
                    end
                end
            end
        end
    end

    return false
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

function job_precast(spell, action, spellMap, eventArgs)
    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Universal cooldown check
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: SAM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end
    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (universal - all weapon types)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' and WS_DB[spell.english] then            -- Check if enough TP before displaying WS message
            local current_tp = player and player.vitals and player.vitals.tp or 0
            if current_tp >= 1000 then
                -- Display WS message with current TP
                MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, nil)  -- TP displayed by TPBonusHandler after gear equip
            else
                -- Not enough TP - display error
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
            end
    end


    -- THIRD: Auto-cast Seigan before Third Eye
    if try_seigan_before_third_eye(spell, eventArgs) then
        return
    end

    -- FOURTH: Third Eye auto-cast before WS
    if try_third_eye_ws(spell, eventArgs) then
        return
    end

    -- FIFTH: WeaponSkill validation (Universal via WSValidator)
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- SIXTH: TP Bonus Gear Optimization (Universal via TPBonusHandler)
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, SAMTPConfig)
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    -- Apply TP bonus gear and display final TP (Universal via TPBonusHandler)
    if TPBonusHandler then
        TPBonusHandler.apply_and_display(spell, SAMTPConfig)
    end

    -- SAM-specific buff gear overrides
    if spell.type == 'WeaponSkill' then
        -- Apply Sekkanoki buff gear
        if state and state.Buff and state.Buff.Sekkanoki and sets.buff and sets.buff.Sekkanoki then
            equip(sets.buff.Sekkanoki)
        end

        -- Apply Meikyo Shisui buff gear
        if state and state.Buff and state.Buff['Meikyo Shisui'] and sets.buff and sets.buff['Meikyo Shisui'] then
            equip(sets.buff['Meikyo Shisui'])
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

local SAM_PRECAST = {}
SAM_PRECAST.job_precast = job_precast
SAM_PRECAST.job_post_precast = job_post_precast

return SAM_PRECAST
