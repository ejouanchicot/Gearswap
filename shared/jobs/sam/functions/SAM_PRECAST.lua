---============================================================================
--- SAM Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- @file SAM_PRECAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MessageFormatter = nil
local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local SAMTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    SAMTPConfig = _G.SAMTPConfig or {}

    modules_loaded = true
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
    ensure_modules_loaded()

    -- FIRST: Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Cooldown check
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

    -- SAM-SPECIFIC: Auto-cast Seigan before Third Eye
    if try_seigan_before_third_eye(spell, eventArgs) then
        return
    end

    -- SAM-SPECIFIC: Third Eye auto-cast before WS
    if try_third_eye_ws(spell, eventArgs) then
        return
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, SAMTPConfig) then
        return
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Apply TP gear via unified handler
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- SAM-SPECIFIC: Apply buff gear for WS
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
