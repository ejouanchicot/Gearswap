---============================================================================
--- Message Combat - Combat state and validation messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file utils/message_combat.lua
--- @author Tetsouo
--- @version 2.0
--- @date Updated: 2025-11-06
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local M = require('shared/utils/messages/api/messages')
local MessageCombat = {}

---============================================================================
--- RANGE & VALIDATION ERRORS
---============================================================================

function MessageCombat.show_range_error(ability, distance_info)
    M.send('COMBAT', 'range_error', {
        ability = ability,
        distance = distance_info
    })
end

function MessageCombat.show_ws_validation_error(ws_name, reason, detail, status_ailment, detail_color_code)
    local job_tag = MessageCore.get_job_tag()

    local key
    if status_ailment then
        key = 'ws_validation_error_status'
        M.send('COMBAT', key, {
            job = job_tag,
            ws_name = ws_name,
            reason = reason,
            status = status_ailment
        })
    elseif detail then
        key = 'ws_validation_error_detail'
        M.send('COMBAT', key, {
            job = job_tag,
            ws_name = ws_name,
            reason = reason,
            detail = detail
        })
    else
        key = 'ws_validation_error'
        M.send('COMBAT', key, {
            job = job_tag,
            ws_name = ws_name,
            reason = reason
        })
    end
end

function MessageCombat.show_target_error(action, reason)
    M.send('COMBAT', 'target_error', {
        action = action,
        reason = reason
    })
end

function MessageCombat.show_state_change(old_state, new_state)
    M.send('COMBAT', 'state_change', {
        old_state = old_state,
        new_state = new_state
    })
end

function MessageCombat.show_ability_tp_error(ability_name, current_tp, required_tp, job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()
    M.send('COMBAT', 'ability_tp_error', {
        job = job_tag,
        ability = ability_name,
        current_tp = tostring(current_tp),
        required_tp = tostring(required_tp)
    })
end

---============================================================================
--- WEAPONSKILL MESSAGES
---============================================================================

function MessageCombat.show_ws_tp(ws_name, total_tp)
    -- Select template based on TP threshold
    local key
    if total_tp >= 3000 then
        key = 'ws_tp_ultimate'
    elseif total_tp >= 2000 then
        key = 'ws_tp_enhanced'
    else
        key = 'ws_tp_normal'
    end

    M.send('COMBAT', key, {
        ws_name = ws_name,
        tp = tostring(total_tp)
    })
end

function MessageCombat.show_ws_activated(ws_name, description, total_tp)
    local job_tag = MessageCore.get_job_tag()

    local key
    if total_tp then
        if total_tp >= 3000 then
            key = 'ws_activated_ultimate'
        elseif total_tp >= 2000 then
            key = 'ws_activated_enhanced'
        else
            key = 'ws_activated_normal'
        end

        M.send('COMBAT', key, {
            job = job_tag,
            ws_name = ws_name,
            description = description,
            tp = tostring(total_tp)
        })
    else
        key = 'ws_activated_no_tp'
        M.send('COMBAT', key, {
            job = job_tag,
            ws_name = ws_name,
            description = description
        })
    end
end

---============================================================================
--- SPELL & ABILITY USAGE
---============================================================================

function MessageCombat.show_spell_cast(spell_name)
    local job_tag = MessageCore.get_job_tag()
    M.send('COMBAT', 'spell_cast', {
        job = job_tag,
        spell_name = spell_name
    })
end

function MessageCombat.show_ability_use(ability_name, job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()
    M.send('COMBAT', 'ability_use', {
        job = job_tag,
        ability_name = ability_name
    })
end

---============================================================================
--- WALTZ HEALING (DNC)
---============================================================================

function MessageCombat.show_waltz_heal(waltz_name, missing_hp, extra_ability, job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()

    local key
    if missing_hp then
        if extra_ability then
            key = 'waltz_heal_single_extra'
            M.send('COMBAT', key, {
                job = job_tag,
                hp = tostring(missing_hp),
                waltz_name = waltz_name,
                extra = extra_ability
            })
        else
            key = 'waltz_heal_single'
            M.send('COMBAT', key, {
                job = job_tag,
                hp = tostring(missing_hp),
                waltz_name = waltz_name
            })
        end
    else
        if extra_ability then
            key = 'waltz_heal_aoe_extra'
            M.send('COMBAT', key, {
                job = job_tag,
                waltz_name = waltz_name,
                extra = extra_ability
            })
        else
            key = 'waltz_heal_aoe'
            M.send('COMBAT', key, {
                job = job_tag,
                waltz_name = waltz_name
            })
        end
    end
end

---============================================================================
--- JUMP MESSAGES (DRG)
---============================================================================

function MessageCombat.show_jump_activated(jump_ability, description, job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()
    M.send('COMBAT', 'jump_activated', {
        job = job_tag,
        jump_ability = jump_ability,
        description = description
    })
end

function MessageCombat.show_jump_chaining(second_jump, description, job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()

    if description then
        M.send('COMBAT', 'jump_chaining_desc', {
            job = job_tag,
            second_jump = second_jump,
            description = description
        })
    else
        M.send('COMBAT', 'jump_chaining', {
            job = job_tag,
            second_jump = second_jump
        })
    end
end

function MessageCombat.show_jump_complete(job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()
    M.send('COMBAT', 'jump_complete', {
        job = job_tag
    })
end

function MessageCombat.show_jump_relaunch(ws_name, job_tag)
    job_tag = job_tag or MessageCore.get_job_tag()
    M.send('COMBAT', 'jump_relaunch', {
        job = job_tag,
        ws_name = ws_name
    })
end

---============================================================================
--- SPELL ACTIVATION (ALREADY MIGRATED)
---============================================================================

function MessageCombat.show_spell_activated(spell_name, description, target_name)
    local job_tag = MessageCore.get_job_tag()

    local key
    if description and target_name and target_name ~= player.name then
        key = 'spell_activated_full_target'
    elseif description then
        key = 'spell_activated_full'
    elseif target_name and target_name ~= player.name then
        key = 'spell_activated_target'
    else
        key = 'spell_activated'
    end

    local params = {
        job = job_tag,
        spell = spell_name
    }

    if description then
        params.description = description
    end

    if target_name and target_name ~= player.name then
        params.target = target_name
    end

    local success, message_length = M.send('MAGIC', key, params)
    return message_length or 0
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageCombat
