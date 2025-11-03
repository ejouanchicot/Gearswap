---============================================================================
--- Ability Helper - Auto-Ability Execution Functions
---============================================================================
--- Provides helper functions for auto-triggering abilities before spells/WS.
--- Used by PLD (Divine Emblem, Majesty) and DNC (Climactic Flourish) jobs.
---
--- @file utils/precast/ability_helper.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-05
---============================================================================

local AbilityHelper = {}

---============================================================================
--- ABILITY STATE CHECKING
---============================================================================

--- Check if ability is ready (not on cooldown)
--- @param ability_name string The ability name
--- @return boolean True if ready (cooldown < 1 second)
function AbilityHelper.is_ability_ready(ability_name)
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local res = require('resources')
    local ability_data = res.job_abilities:with('en', ability_name)
    if not ability_data then return false end

    local recast_id = ability_data.recast_id or ability_data.id
    local cooldown = ability_recasts[recast_id] or 0
    return cooldown < 1
end

--- Check if buff is active
--- @param buff_name string The buff name
--- @return boolean True if buff is active
function AbilityHelper.is_buff_active(buff_name)
    return buffactive[buff_name] or false
end

---============================================================================
--- AUTO-ABILITY EXECUTION
---============================================================================

--- Use ability before spell (simple version - no buff check)
--- @param spell table The spell object
--- @param eventArgs table Event arguments with handled flag
--- @param ability_name string The ability to use
--- @param wait_time number Wait time between ability and spell (default: 2)
function AbilityHelper.try_ability(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2

    -- Check if ability ready and buff not active
    if AbilityHelper.is_ability_ready(ability_name) and not AbilityHelper.is_buff_active(ability_name) then
        eventArgs.handled = true
        cancel_spell()
        send_command(string.format('input /ja "%s" <me>; wait %d; input /ma "%s" %s',
            ability_name, wait_time, spell.name, spell.target.id))
    end
end

--- Use ability before spell (smart version - checks if buff already active)
--- @param spell table The spell object
--- @param eventArgs table Event arguments with handled flag
--- @param ability_name string The ability to use
--- @param wait_time number Wait time between ability and spell (default: 2)
function AbilityHelper.try_ability_smart(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2

    -- If buff already active, don't bother checking recast
    if AbilityHelper.is_buff_active(ability_name) then
        return
    end

    -- Check if ability ready
    if AbilityHelper.is_ability_ready(ability_name) then
        eventArgs.handled = true
        cancel_spell()
        send_command(string.format('input /ja "%s" <me>; wait %d; input /ma "%s" %s',
            ability_name, wait_time, spell.name, spell.target.id))
    end
end

--- Use ability before weaponskill
--- @param spell table The weaponskill spell object
--- @param eventArgs table Event arguments with handled flag
--- @param ability_name string The ability to use
--- @param wait_time number Wait time between ability and WS (default: 2)
function AbilityHelper.try_ability_ws(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2

    -- Check if ability ready and buff not active
    if AbilityHelper.is_ability_ready(ability_name) and not AbilityHelper.is_buff_active(ability_name) then
        eventArgs.handled = true
        eventArgs.cancel = true  -- CRITICAL: Cancel current WS (will auto-recast after ability)
        cancel_spell()
        -- Set flag to suppress WS message on auto-recast (DNC Jump/Climactic system)
        _G.DNC_AUTO_WS_RECAST = true
        send_command(string.format('input /ja "%s" <me>; wait %d; input /ws "%s" <t>',
            ability_name, wait_time, spell.name))
    end
end

return AbilityHelper
