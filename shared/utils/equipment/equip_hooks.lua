---============================================================================
--- Equip Hooks - systems that adjust each set just before GearSwap equips it
---============================================================================
--- GearSwap's equip() is wrapped once per job load; each set passed to it goes
--- through the registered hooks in order, then on to GearSwap. A hook gets a
--- set and returns the set to use (the same one, or a copy: the sets written
--- by the player are never changed).
---
--- Order (by the `order` number, lowest first):
---    5  impact_lock.lua      Impact's cloak kept on through the cast
---   10  duplicate_gear.lua   which copy of a doubled item each side takes
---   20  hp_priority.lua      equip order by the HP each piece gains
---
--- @file shared/utils/equipment/equip_hooks.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local EquipHooks = {}

local HOOKS_KEY = '_equip_hooks'
local WRAPPER_KEY = '_equip_hooks_wrapper'

--- The hooks of this load, sorted by order.
local function hooks()
    return rawget(_G, HOOKS_KEY) or {}
end

--- Add (or replace, by name) a hook and make sure equip() is wrapped.
--- @param name string Hook name
--- @param order number Lower runs first
--- @param fn function(set) -> set
function EquipHooks.add(name, order, fn)
    local list = {}
    for _, h in ipairs(hooks()) do
        if h.name ~= name then list[#list + 1] = h end
    end
    list[#list + 1] = { name = name, order = order, fn = fn }
    table.sort(list, function(a, b) return a.order < b.order end)
    _G[HOOKS_KEY] = list
    EquipHooks.install()
end

--- Remove a hook (a system turned off for this job).
--- @param name string
function EquipHooks.remove(name)
    local list = {}
    for _, h in ipairs(hooks()) do
        if h.name ~= name then list[#list + 1] = h end
    end
    _G[HOOKS_KEY] = list
end

--- Wrap GearSwap's equip() once per load (the job's _G is new at each load).
function EquipHooks.install()
    local wrapper = rawget(_G, WRAPPER_KEY)
    if wrapper and rawget(_G, 'equip') == wrapper then return end
    local raw_equip = rawget(_G, 'equip')
    if type(raw_equip) ~= 'function' then return end
    wrapper = function(...)
        local list = hooks()
        if #list == 0 then return raw_equip(...) end
        local n = select('#', ...)
        local args = { ... }
        for i = 1, n do
            if type(args[i]) == 'table' then
                for _, h in ipairs(list) do
                    local ok, out = pcall(h.fn, args[i])
                    if ok and type(out) == 'table' then args[i] = out end
                end
            end
        end
        return raw_equip((table.unpack or unpack)(args, 1, n))
    end
    _G[WRAPPER_KEY] = wrapper
    _G.equip = wrapper
end

return EquipHooks
