-- AbilityHelper: auto-triggers abilities (Divine Emblem, Majesty, Flourish) before WS/spells.

local AbilityHelper = {}

-- Load recast configuration for cooldown tolerance
local RECAST_CONFIG = _G.RECAST_CONFIG or {}

local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast < 1)  -- Fallback: 1 second tolerance
    end
end

-- Memoization cache for ability lookups.
-- res.job_abilities:with('en', name) is an O(N) scan over ~700 abilities.
-- Each ability name is queried multiple times per WS/precast cycle, so caching
-- the result eliminates the bulk of the cost. The resource DB never changes at
-- runtime, so we never need to invalidate.
local ability_cache = {}

local function get_ability_data(ability_name)
    local cached = ability_cache[ability_name]
    if cached ~= nil then
        return cached or nil  -- false sentinel for "looked up, not found"
    end
    local res = require('resources')
    local data = res.job_abilities:with('en', ability_name)
    ability_cache[ability_name] = data or false  -- store negative result too
    return data
end

function AbilityHelper.can_use_ability(ability_name)
    local player = windower.ffxi.get_player()
    if not player then return false end

    local ability_data = get_ability_data(ability_name)
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

function AbilityHelper.is_ability_ready(ability_name)
    local ability_data = get_ability_data(ability_name)
    if not ability_data then return false end

    local ability_recasts = windower.ffxi.get_ability_recasts()
    local recast_id = ability_data.recast_id or ability_data.id
    local cooldown = ability_recasts[recast_id] or 0
    return is_recast_ready(cooldown)
end

function AbilityHelper.is_buff_active(buff_name)
    return buffactive[buff_name] or false
end

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
