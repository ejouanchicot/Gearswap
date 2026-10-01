---============================================================================
--- Uncurable Debuffs - a debuff the cure item did not take off
---============================================================================
--- An aura keeps its debuff on while you stand in it: the cure item is used
--- up and the debuff stays (or is back at once). Without a check, Auto
--- Medicine spent an item on every press. After each cure item this module
--- looks again once the item had time to act:
---   - the item was used up and the debuff is still there: the debuff is
---     marked uncurable (message once), no more item for it;
---   - the item was not used up (moving, interrupted): nothing marked, the
---     next press tries again.
--- The mark goes when the debuff is gone, or after GIVE_UP_AFTER seconds at
--- most. Marks live on `windower`, so they survive a job change.
---
--- @file shared/utils/debuff/uncurable_debuffs.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local UncurableDebuffs = {}

--- One line in //gs c trace (tag CURE): what each check decided.
local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('CURE', fmt, unpack(args)) end)
end

--- Seconds after the /item line before looking: the item animation is over
--- and a debuff it removed is gone.
local CHECK_AFTER = 4.0

--- Seconds between two looks while a debuff is marked.
local POLL_EVERY = 2.0

--- Seconds after which a mark is dropped even if the debuff never left, so
--- the next press tries an item again.
local GIVE_UP_AFTER = 60.0

--- @return table name (lowercase) -> {until_time}
local function marks()
    windower._uncurable_debuffs = windower._uncurable_debuffs or {}
    return windower._uncurable_debuffs
end

local ids_cache = {}

--- Buff ids carrying this name (paralysis: 4, and 566 from a geomancy aura).
--- @param name string Lowercase buff name
--- @return table id -> true
local function ids_of(name)
    if ids_cache[name] then return ids_cache[name] end
    local ids = {}
    local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
    if ok and res and res.buffs then
        for id, buff in pairs(res.buffs) do
            if type(buff) == 'table' and buff.en and buff.en:lower() == name then ids[id] = true end
        end
    end
    ids_cache[name] = ids
    return ids
end

--- Whether the debuff is on now. Read from the game: buffactive lags behind
--- inside a coroutine.
--- @param name string Lowercase buff name
--- @return boolean
local function debuff_up(name)
    local me = windower.ffxi.get_player()
    if not me or type(me.buffs) ~= 'table' then return false end
    local ids = ids_of(name)
    for _, id in ipairs(me.buffs) do
        if ids[id] then return true end
    end
    return false
end

--- How many of an item the inventory holds (/item only uses the inventory).
--- @param item_id number
--- @return number
local function count_in_inventory(item_id)
    local items = windower.ffxi.get_items()
    local bag = items and items.inventory
    if type(bag) ~= 'table' then return 0 end
    local total = 0
    for slot = 1, (items.max_inventory or 80) do
        local item = bag[slot]
        if type(item) == 'table' and item.id == item_id and item.count then
            total = total + item.count
        end
    end
    return total
end

--- Look every POLL_EVERY seconds; drop the mark once the debuff is gone or
--- GIVE_UP_AFTER has passed.
--- @param name string
local function poll(name)
    coroutine.schedule(function()
        local mark = marks()[name]
        if not mark then return end
        if not debuff_up(name) or os.clock() > mark.until_time then
            trace('%s: mark dropped (%s)', name, debuff_up(name) and 'time up' or 'debuff gone')
            marks()[name] = nil
            return
        end
        poll(name)
    end, POLL_EVERY)
end

--- Whether no item should be tried for this debuff now.
--- @param name string Lowercase debuff name ('silence', 'paralysis')
--- @return boolean
function UncurableDebuffs.is_marked(name)
    local mark = marks()[name]
    if not mark then return false end
    if os.clock() > mark.until_time then
        marks()[name] = nil
        return false
    end
    return true
end

--- Watch a cure item just sent: mark the debuff when the item was used up
--- and the debuff is still there.
--- @param name string Lowercase debuff name
--- @param item table {name, id} of the item sent
--- @param send_delay number Seconds before the /item line goes out
--- @param on_marked function|nil Called with (debuff name, item name) once marked
function UncurableDebuffs.watch(name, item, send_delay, on_marked)
    if not name or not item or not item.id then return end
    local before = count_in_inventory(item.id)
    coroutine.schedule(function()
        local after = count_in_inventory(item.id)
        if after >= before then
            trace('%s: %s not used up (%d -> %d), nothing marked', name, item.name, before, after)
            return
        end
        if not debuff_up(name) then
            trace('%s: %s used, debuff gone', name, item.name)
            return
        end
        trace('%s: %s used, debuff still on: marked uncurable for %ds', name, item.name, GIVE_UP_AFTER)
        marks()[name] = {until_time = os.clock() + GIVE_UP_AFTER}
        if on_marked then pcall(on_marked, name, item.name) end
        poll(name)
    end, (send_delay or 0) + CHECK_AFTER)
end

--- Active buff ids and their names, for //gs c am debuffs.
--- @return table list of {id, name}
function UncurableDebuffs.active_buffs()
    local me = windower.ffxi.get_player()
    local list = {}
    local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
    for _, id in ipairs(me and me.buffs or {}) do
        local buff = ok and res and res.buffs and res.buffs[id]
        list[#list + 1] = {id = id, name = buff and buff.en or '?'}
    end
    return list
end

--- The marked debuffs and the seconds left before a new try.
--- @return table list of {name, seconds}
function UncurableDebuffs.marked()
    local list = {}
    for name, mark in pairs(marks()) do
        list[#list + 1] = {name = name, seconds = math.max(0, math.floor(mark.until_time - os.clock()))}
    end
    return list
end

return UncurableDebuffs
