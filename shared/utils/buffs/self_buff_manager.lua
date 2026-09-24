---  ═══════════════════════════════════════════════════════════════════════════
---   Self Buff Manager - Queued self-buffing from a list
---  ═══════════════════════════════════════════════════════════════════════════
---   Factory shared by every job that offers a `//gs c buff` command. A job
---   supplies its list of spells and job abilities; this module decides what
---   is worth using and sends the actions in order.
---
---   An entry is skipped when its buff is already up, when it is still on
---   recast, when it was used seconds ago (double press), or when the current
---   job and subjob cannot use it at all — the same list therefore behaves
---   correctly across subjob changes.
---
---   @file    shared/utils/buffs/self_buff_manager.lua
---   @author  Tetsouo
---   @version 1.1 - Job abilities alongside spells
---   @date    Created: 2026-09-17
---  ═══════════════════════════════════════════════════════════════════════════

local SelfBuffManager = {}

local MessageBuffs = require('shared/utils/messages/formatters/magic/message_buffs')
local MessageFormatter = require('shared/utils/messages/message_formatter')

--- Minimum seconds between two uses of the same entry, so a double press
--- does not queue the same buff twice.
local CAST_COOLDOWN = 2.0

--- Seconds the queue waits after an action before sending the next one,
--- unless the entry names its own delay.
local DEFAULT_DELAY = 6

---  ═══════════════════════════════════════════════════════════════════════════
---   ENTRY RESOLUTION
---  ═══════════════════════════════════════════════════════════════════════════

--- Job id of a job abbreviation ('PLD' -> 7)
--- @param res table Windower resources
--- @param job_abbrev string|nil Job abbreviation
--- @return number|nil Job id
local function job_id(res, job_abbrev)
    if not job_abbrev then
        return nil
    end

    local job = res.jobs:with('ens', job_abbrev)

    return job and job.id
end

--- Resolve a list entry against the resources.
---
--- The buff name comes from the action's status effect rather than its name:
--- they differ often enough (Enlight II grants Enlight, Crusade grants Enmity
--- Boost) that deriving it is safer than repeating it in every job list.
--- @param entry table { spell = string } or { ability = string }, plus optional buff and delay
--- (delay = seconds the queue waits after this action)
--- @param res table Windower resources
--- @return table|nil { name, buff, delay, is_ability, command, recast_id, id, levels }
local function resolve_entry(entry, res)
    local is_ability = entry.ability ~= nil
    local name = entry.ability or entry.spell
    local data = is_ability and res.job_abilities:with('en', name) or res.spells:with('en', name)

    if not data then
        return nil
    end

    local status = data.status and res.buffs[data.status]

    return {
        name = name,
        buff = entry.buff or (status and status.en),
        delay = entry.delay or DEFAULT_DELAY,
        is_ability = is_ability,
        command = is_ability and '/ja' or '/ma',
        recast_id = data.recast_id or data.id,
        id = data.id,
        levels = data.levels or {}
    }
end

--- The job abilities the current job and subjob grant, as a set of ids.
--- Absorbs both API shapes: a list of ids, or a map keyed by id.
--- @return table Set of ability ids
local function available_abilities()
    local ok, abilities = pcall(windower.ffxi.get_abilities)
    if not ok or type(abilities) ~= 'table' or type(abilities.job_abilities) ~= 'table' then
        return {}
    end

    local ids = {}
    for key, value in pairs(abilities.job_abilities) do
        ids[(type(value) == 'number') and value or key] = true
    end

    return ids
end

--- Whether the current job and subjob can use this entry.
---
--- Abilities are read from the game, which already accounts for job and level.
--- Spells are checked by hand: a known spell listed for the main job is
--- castable, the scroll could not have been learned otherwise, while the
--- subjob is capped and its own requirement is compared to the subjob level.
--- @param item table From resolve_entry
--- @param ctx table { known, abilities, main_id, sub_id, sub_level }
--- @return boolean
local function is_usable(item, ctx)
    if item.is_ability then
        return ctx.abilities[item.id] == true
    end

    if not ctx.known[item.id] then
        return false
    end

    if ctx.main_id and item.levels[ctx.main_id] then
        return true
    end

    return ctx.sub_id ~= nil and item.levels[ctx.sub_id] ~= nil and item.levels[ctx.sub_id] <= ctx.sub_level
end

---  ═══════════════════════════════════════════════════════════════════════════
---   FACTORY
---  ═══════════════════════════════════════════════════════════════════════════

--- Build a buff manager for one job
--- @param config table {
---   buffs = table             List of { spell = string } or { ability = string },
---                             each with optional buff and delay,
---   action_type = string|nil  Label for the status display (default 'Magic')
--- }
--- @return table Manager exposing buff_self()
function SelfBuffManager.create(config)
    local manager = {}
    local last_use_times = {}

    --- The entries worth using now, each with the delay it waits for.
    --- The wait comes from the entries actually queued, not from the list: an
    --- entry the subjob does not grant costs no time at all.
    --- @param items table Resolved entries
    --- @param recasts table { spells = table, abilities = table }
    --- @param now number os.clock()
    --- @return table List of { item, delay }
    local function queue_ready(items, recasts, now)
        local ready = {}
        local total_delay = 0

        for _, item in ipairs(items) do
            local timers = item.is_ability and recasts.abilities or recasts.spells
            local on_recast = (timers[item.recast_id] or 0) > 0
            local spammed = last_use_times[item.name] and (now - last_use_times[item.name]) < CAST_COOLDOWN

            if not (buffactive[item.buff] or on_recast or spammed) then
                local previous = ready[#ready]
                if previous then
                    total_delay = total_delay + previous.item.delay
                end
                ready[#ready + 1] = { item = item, delay = total_delay }
            end
        end

        return ready
    end

    --- Send the queue, each action waiting out the ones before it
    --- @param ready table From queue_ready
    --- @param now number os.clock(), recorded for the anti-spam window
    local function send_queue(ready, now)
        for _, entry in ipairs(ready) do
            local action = 'input ' .. entry.item.command .. ' "' .. entry.item.name .. '" <me>'

            send_command(entry.delay > 0 and ('wait ' .. entry.delay .. '; ' .. action) or action)
            last_use_times[entry.item.name] = now
        end
    end

    --- Report the buffs already up, so a no-op press is not silent
    --- @param items table Resolved entries
    --- @return boolean True when something was displayed
    local function show_active(items)
        local status_data = {}

        for _, item in ipairs(items) do
            if buffactive[item.buff] then
                status_data[#status_data + 1] = { name = item.name, status = 'active' }
            end
        end

        if #status_data == 0 then
            return false
        end

        MessageBuffs.show_buff_status(status_data, config.action_type or 'Magic')

        return true
    end

    --- The entries of the list this job and subjob can use right now
    --- @param res table Windower resources
    --- @return table Resolved entries, in list order
    local function usable_entries(res)
        local ctx = {
            known = windower.ffxi.get_spells() or {},
            abilities = available_abilities(),
            main_id = job_id(res, player.main_job),
            sub_id = job_id(res, player.sub_job),
            sub_level = player.sub_job_level or 0
        }

        local items = {}
        for _, entry in ipairs(config.buffs) do
            local item = resolve_entry(entry, res)
            if item and item.buff and is_usable(item, ctx) then
                items[#items + 1] = item
            end
        end

        return items
    end

    --- Use every buff of the list that is missing and available
    --- @return boolean True when actions were queued or a status was displayed
    function manager.buff_self()
        -- os.clock, not os.time: os.time only counts whole seconds, too coarse
        -- for the CAST_COOLDOWN anti-spam window.
        local now = os.clock()
        local recasts = {
            spells = windower.ffxi.get_spell_recasts(),
            abilities = windower.ffxi.get_ability_recasts()
        }

        if type(recasts.spells) ~= 'table' or type(recasts.abilities) ~= 'table' then
            MessageFormatter.show_error('Recast timers unavailable')
            return false
        end

        local res = _G.res or windower.res or require('resources')
        if not res then
            MessageFormatter.show_error('Resources unavailable')
            return false
        end

        local items = usable_entries(res)
        local ready = queue_ready(items, recasts, now)

        if #ready > 0 then
            send_queue(ready, now)
            return true
        end

        return show_active(items)
    end

    return manager
end

return SelfBuffManager
