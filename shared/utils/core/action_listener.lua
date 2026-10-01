---============================================================================
--- Action Listener - the action packets, as the server sent them
---============================================================================
--- Every module that reads action packets (0x028) subscribes here instead of
--- registering its own 'action' event. One raw 'incoming chunk' listener per
--- load parses the packet once, from `original`, and hands the same table
--- (windower.packets.parse_action) to each subscriber.
---
--- Why `original`: Battlemod rebuilds 0x028 for the chat
--- (addons/battlemod/parse_action_packet.lua). It sets to 0 the message of
--- what its filters hide, and folds the targets of one action into one line,
--- so a module reading the rebuilt packet could see a message 0 or fewer
--- targets than the action reached.
---
---   ActionListener.on('key', function(act) ... end)   subscribe (same key replaces)
---   ActionListener.off('key')                          unsubscribe
---
--- Subscribers live for the load, like any GearSwap event: each load
--- subscribes again. Each one is called in a pcall: one error does not stop
--- the others.
---
--- @file    shared/utils/core/action_listener.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-01
---============================================================================

local ActionListener = {}

--- key -> function, and the keys in subscription order. On the sandbox _G:
--- one list per load, even when this file runs twice in a load (before
--- module_cache.lua is installed).
local function registry()
    local r = rawget(_G, '_action_listener_subs')
    if not r then
        r = {fns = {}, order = {}}
        _G._action_listener_subs = r
    end
    return r
end

local function dispatch(original)
    local ok, act = pcall(windower.packets.parse_action, original)
    if not ok or type(act) ~= 'table' then return end
    local r = registry()
    for _, key in ipairs(r.order) do
        local fn = r.fns[key]
        if fn then pcall(fn, act) end
    end
end

local function listen()
    if rawget(_G, '_action_listener_id') then return end
    _G._action_listener_id = windower.raw_register_event('incoming chunk', function(id, original)
        if id == 0x028 then dispatch(original) end
    end)
end

--- Subscribe to the action packets of this load.
--- @param key string Name of the subscriber; subscribing again replaces it
--- @param fn function Called with the parsed packet (actor_id, category, param, targets)
function ActionListener.on(key, fn)
    if type(fn) ~= 'function' then return end
    local r = registry()
    if not r.fns[key] then r.order[#r.order + 1] = key end
    r.fns[key] = fn
    listen()
end

--- Unsubscribe.
--- @param key string Name given to on()
function ActionListener.off(key)
    local r = registry()
    if not r.fns[key] then return end
    r.fns[key] = nil
    for i, k in ipairs(r.order) do
        if k == key then table.remove(r.order, i) break end
    end
end

return ActionListener
