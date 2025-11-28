---============================================================================
--- Spell Caster - BLM/WHM Spell Casting Logic with Level Validation
---============================================================================
--- Handles casting of warp/teleport spells with automatic level checking.
--- Extracted from monolithic cast_warp_spell() for modularity.
---
--- @file spell_caster.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')
local MessageCore = require('shared/utils/messages/message_core')

local SpellCaster = {}

---============================================================================
--- SPELL DEFINITIONS WITH LEVEL REQUIREMENTS
---============================================================================

-- BLM spells with level requirements
local BLM_SPELLS = {
    ['Warp'] = 17,
    ['Warp II'] = 40,
    ['Retrace'] = 55,
    ['Escape'] = 29
}

-- WHM spells with level requirements
local WHM_SPELLS = {
    ['Teleport-Holla'] = 36,
    ['Teleport-Dem'] = 36,
    ['Teleport-Mea'] = 36,
    ['Teleport-Yhoat'] = 38,
    ['Teleport-Altep'] = 38,
    ['Teleport-Vahzl'] = 42,
    ['Recall-Jugner'] = 53,
    ['Recall-Pashh'] = 53,
    ['Recall-Meriph'] = 53
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if player can cast a specific spell
--- @param spell_name string Spell name
--- @return boolean, string|nil Can cast, error reason if not
local function can_cast_spell(spell_name)
    if not player then
        return false, 'Player data not available'
    end

    local has_blm = player.main_job == 'BLM' or player.sub_job == 'BLM'
    local has_whm = player.main_job == 'WHM' or player.sub_job == 'WHM'

    -- Check if it's a BLM spell
    if BLM_SPELLS[spell_name] then
        if not has_blm then
            return false, 'Requires BLM main/sub'
        end

        local required_level = BLM_SPELLS[spell_name]
        local effective_level = player.main_job == 'BLM' and player.main_job_level or player.sub_job_level

        if effective_level < required_level then
            return false, 'Level too low (' .. effective_level .. '/' .. required_level .. ')'
        end

        return true
    end

    -- Check if it's a WHM spell
    if WHM_SPELLS[spell_name] then
        if not has_whm then
            return false, 'Requires WHM main/sub'
        end

        local required_level = WHM_SPELLS[spell_name]
        local effective_level = player.main_job == 'WHM' and player.main_job_level or player.sub_job_level

        if effective_level < required_level then
            return false, 'Level too low (' .. effective_level .. '/' .. required_level .. ')'
        end

        return true
    end

    return false, 'Unknown spell'
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Cast a warp spell if player meets requirements
--- @param spell_name string Spell name (e.g., 'Warp', 'Teleport-Holla')
--- @return boolean True if spell was cast
function SpellCaster.cast_spell(spell_name)
    if not player then
        MessageCore.error('[WARP] Player data not available')
        return false
    end

    local can_cast, error_reason = can_cast_spell(spell_name)

    if not can_cast then
        -- Check if player has the required job first
        local has_blm = player.main_job == 'BLM' or player.sub_job == 'BLM'
        local has_whm = player.main_job == 'WHM' or player.sub_job == 'WHM'

        -- Show appropriate error message
        if BLM_SPELLS[spell_name] then
            local required_level = BLM_SPELLS[spell_name]
            if not has_blm then
                MessageWarp.show_warp_requires_blm(spell_name, required_level)
            else
                local effective_level = player.main_job == 'BLM' and player.main_job_level or player.sub_job_level
                MessageWarp.show_warp_level_error(spell_name, required_level, effective_level or 0)
            end
        elseif WHM_SPELLS[spell_name] then
            local required_level = WHM_SPELLS[spell_name]
            if not has_whm then
                MessageWarp.show_tele_requires_whm(spell_name, required_level)
            else
                local effective_level = player.main_job == 'WHM' and player.main_job_level or player.sub_job_level
                MessageWarp.show_tele_level_error(spell_name, required_level, effective_level or 0)
            end
        else
            MessageWarp.show_spell_cannot_cast(error_reason)
        end
        return false
    end

    -- Cast the spell
    if BLM_SPELLS[spell_name] then
        MessageWarp.show_warp_casting(spell_name)
    else
        MessageWarp.show_tele_casting(spell_name)
    end

    windower.chat.input('/ma "' .. spell_name .. '" <me>')
    return true
end

--- Check if player can cast a spell (without casting)
--- @param spell_name string Spell name
--- @return boolean True if player can cast
function SpellCaster.can_cast(spell_name)
    local can_cast, _ = can_cast_spell(spell_name)
    return can_cast
end

--- Get required level for a spell
--- @param spell_name string Spell name
--- @return number|nil Required level, or nil if unknown spell
function SpellCaster.get_required_level(spell_name)
    return BLM_SPELLS[spell_name] or WHM_SPELLS[spell_name]
end

--- Check if spell is a BLM spell
--- @param spell_name string Spell name
--- @return boolean True if BLM spell
function SpellCaster.is_blm_spell(spell_name)
    return BLM_SPELLS[spell_name] ~= nil
end

--- Check if spell is a WHM spell
--- @param spell_name string Spell name
--- @return boolean True if WHM spell
function SpellCaster.is_whm_spell(spell_name)
    return WHM_SPELLS[spell_name] ~= nil
end

return SpellCaster
