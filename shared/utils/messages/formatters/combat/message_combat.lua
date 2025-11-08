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
--- ELEMENT COLOR MAPPING
---============================================================================

--- Get color code for a spell element
--- @param element string Element name (Fire, Ice, Wind, etc.)
--- @return number|nil color_code FFXI color code for the element
local function get_element_color(element)
    if not element then return nil end

    local element_colors = {
        Fire = 2,
        Ice = 210,      -- Cyan - more visible than 30
        Wind = 14,
        Earth = 37,
        Thunder = 16,
        Lightning = 16,
        Water = 219,
        Light = 187,
        Dark = 200,
    }

    return element_colors[element]
end

--- Apply element color to spell name
--- @param spell_name string Spell name
--- @param element string|nil Element name
--- @return string colored_spell_name Spell name with color codes if element exists
local function apply_element_color(spell_name, element)
    if not element then
        return spell_name
    end

    local color_code = get_element_color(element)
    if not color_code then
        return spell_name
    end

    local gray_code = string.char(0x1F, 160)
    return string.char(0x1F, color_code) .. spell_name .. gray_code
end

--- Get color code for a target based on type
--- @param target_type string|nil Target type ("SELF", "PLAYER", "PC", "NPC", "MONSTER", etc.)
--- @return number color_code Color code for the target
local function get_target_color(target_type)
    if not target_type then
        -- Default: assume enemy if no type provided
        return 011  -- Pink/Rose - Enemy
    end

    local type_upper = target_type:upper()

    -- Player types (PC, PLAYER, SELF)
    if type_upper == "PLAYER" or type_upper == "PC" or type_upper == "SELF" then
        return 158  -- Green - Player
    end

    -- NPC types
    if type_upper == "NPC" then
        return 063  -- Pale yellow - NPC
    end

    -- Enemy/Monster types (MONSTER, ENEMY, MOB)
    -- Default to enemy for anything else
    return 011  -- Pink/Rose - Enemy
end

--- Apply target color to target name
--- @param target_name string Target name
--- @param target_type string|nil Target type
--- @return string colored_target Colored target name
local function apply_target_color(target_name, target_type)
    if not target_name then
        return target_name
    end

    local color_code = get_target_color(target_type)
    local gray_code = string.char(0x1F, 160)
    return string.char(0x1F, color_code) .. target_name .. gray_code
end

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

function MessageCombat.show_spell_activated(spell_name, description, target_name, spell_skill, spell_element, target_type)
    local job_tag = MessageCore.get_job_tag()

    -- Apply element color to spell name if element provided
    if spell_element then
        spell_name = apply_element_color(spell_name, spell_element)
    end

    -- Apply target color to target name if target provided
    if target_name and target_name ~= player.name then
        target_name = apply_target_color(target_name, target_type)
    end

    -- Detect spell type by skill
    local is_healing = spell_skill == 'Healing Magic'
    local is_enhancing = spell_skill == 'Enhancing Magic'
    local is_enfeebling = spell_skill == 'Enfeebling Magic'
    local is_divine = spell_skill == 'Divine Magic'
    local is_dark = spell_skill == 'Dark Magic'
    local is_blue = spell_skill == 'Blue Magic'

    local key
    if description and target_name and target_name ~= player.name then
        if is_healing then
            key = 'healing_spell_activated_full_target'
        elseif is_enhancing then
            key = 'enhancing_spell_activated_full_target'
        elseif is_enfeebling then
            key = 'enfeebling_spell_activated_full_target'
        elseif is_divine then
            key = 'divine_spell_activated_full_target'
        elseif is_dark then
            key = 'dark_spell_activated_full_target'
        elseif is_blue then
            key = 'blue_spell_activated_full_target'
        else
            key = 'spell_activated_full_target'
        end
    elseif description then
        if is_healing then
            key = 'healing_spell_activated_full'
        elseif is_enhancing then
            key = 'enhancing_spell_activated_full'
        elseif is_enfeebling then
            key = 'enfeebling_spell_activated_full'
        elseif is_divine then
            key = 'divine_spell_activated_full'
        elseif is_dark then
            key = 'dark_spell_activated_full'
        elseif is_blue then
            key = 'blue_spell_activated_full'
        else
            key = 'spell_activated_full'
        end
    elseif target_name and target_name ~= player.name then
        if is_healing then
            key = 'healing_spell_activated_target'
        elseif is_enhancing then
            key = 'enhancing_spell_activated_target'
        elseif is_enfeebling then
            key = 'enfeebling_spell_activated_target'
        elseif is_divine then
            key = 'divine_spell_activated_target'
        elseif is_dark then
            key = 'dark_spell_activated_target'
        elseif is_blue then
            key = 'blue_spell_activated_target'
        else
            key = 'spell_activated_target'
        end
    else
        if is_healing then
            key = 'healing_spell_activated'
        elseif is_enhancing then
            key = 'enhancing_spell_activated'
        elseif is_enfeebling then
            key = 'enfeebling_spell_activated'
        elseif is_divine then
            key = 'divine_spell_activated'
        elseif is_dark then
            key = 'dark_spell_activated'
        elseif is_blue then
            key = 'blue_spell_activated'
        else
            key = 'spell_activated'
        end
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
