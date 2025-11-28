---============================================================================
--- Ability Helper - Auto-Ability Execution Functions
---============================================================================
--- Provides helper functions for auto-triggering abilities before spells/WS.
--- Used by PLD (Divine Emblem, Majesty) and DNC (Climactic Flourish) jobs.
--- Integrates with RECAST_CONFIG for centralized tolerance management.
---
--- VALIDATION SYSTEM:
---   • Checks player main job + level before triggering ability
---   • Prevents cross-job ability usage (e.g., RUN trying Divine Emblem)
---   • Validates level requirements (Divine Emblem = PLD 78)
---   • Fails silently if player doesn't have access to ability
---
--- @file utils/precast/ability_helper.lua
--- @author Tetsouo
--- @version 1.2
--- @date Created: 2025-10-05 | Updated: 2025-11-11 - Integrated RECAST_CONFIG
---============================================================================

local AbilityHelper = {}

-- Load recast configuration for cooldown tolerance
local RECAST_CONFIG = _G.RECAST_CONFIG or {}

---============================================================================
--- RECAST TOLERANCE HELPER
---============================================================================

--- Check if ability is ready (not on cooldown) using RECAST_CONFIG tolerance
--- @param recast number The recast time in seconds
--- @return boolean True if ready
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast < 1)  -- Fallback: 1 second tolerance
    end
end

---============================================================================
--- ABILITY STATE CHECKING
---============================================================================

--- Check if player can use ability (job + level validation)
--- @param ability_name string The ability name
--- @return boolean True if player has access to this ability
function AbilityHelper.can_use_ability(ability_name)
    local player = windower.ffxi.get_player()
    if not player then return false end

    local res = require('resources')
    local ability_data = res.job_abilities:with('en', ability_name)
    if not ability_data then return false end

    -- For abilities without levels table (merit/quest abilities like Climactic Flourish),
    -- we can't validate directly - assume player has it if they try to use it
    if not ability_data.levels then
        return true
    end

    -- Check if ability has levels defined for current job
    local main_job_id = player.main_job_id
    local main_job_level = player.main_job_level

    -- Check if this ability is available for player's main job
    local required_level = ability_data.levels[main_job_id]
    if not required_level then
        return false -- Job doesn't have this ability
    end

    -- Check level requirement
    if main_job_level < required_level then
        return false -- Level too low
    end

    return true
end

--- Check if ability is ready (not on cooldown)
--- Uses RECAST_CONFIG tolerance if available (default: 1.5s)
--- @param ability_name string The ability name
--- @return boolean True if ready
function AbilityHelper.is_ability_ready(ability_name)
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local res = require('resources')
    local ability_data = res.job_abilities:with('en', ability_name)
    if not ability_data then return false end

    local recast_id = ability_data.recast_id or ability_data.id
    local cooldown = ability_recasts[recast_id] or 0
    return is_recast_ready(cooldown)
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

    -- VALIDATION: Check if player can use this ability (job + level)
    if not AbilityHelper.can_use_ability(ability_name) then
        return -- Player doesn't have this ability, skip silently
    end

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

    -- VALIDATION: Check if player can use this ability (job + level)
    if not AbilityHelper.can_use_ability(ability_name) then
        return -- Player doesn't have this ability, skip silently
    end

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

    -- VALIDATION: Check if player can use this ability (job + level)
    if not AbilityHelper.can_use_ability(ability_name) then
        return -- Player doesn't have this ability, skip silently
    end

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
