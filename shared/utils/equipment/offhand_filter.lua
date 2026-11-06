---============================================================================
--- Off-hand Filter - SubWeapon offers only shields when the subjob gives no Dual Wield
---============================================================================
--- A job loads with its SubWeapon mode as the states file and the Atelier left
--- it. When the character cannot hold two weapons (main job without Dual Wield,
--- subjob not /NIN 10+ or /DNC 20+: weapon_resolver.lua can_dual_wield), the
--- mode keeps only the values that are no weapon (shields, grips, names the
--- game does not know): the HUD and the cycle key show only those. A list with
--- no shield is left whole (sets.SingleWield swaps the weapon when equipping).
--- With Dual Wield the whole list stays.
---
--- The value chosen on each side ("two weapons" / "one weapon") is kept for the
--- session on `windower` (it outlives the reload a subjob change makes): taken
--- each time SubWeapon changes (the job's job_state_change, wrapped here: a key,
--- //gs c cycle, //gs c set), given back at the next load when the list holds
--- it. Not taken at the subjob change itself: Mote runs user_setup again before
--- job_sub_job_change, so the mode is back at its start value by then. A relog
--- starts from the start values again. Each step is written to the trace (LOAD).
--- SPEC: notes/docs-perso/subweapon-selon-sub-2026-11-06/SPEC.md
---
--- Applied once per job load by INIT_SYSTEMS.lua, after init_gear_sets (a
--- value names a weapon set, sets.Kraken = {sub = 'Kraken Club'}, built there).
---
--- @file    shared/utils/equipment/offhand_filter.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-06
---============================================================================

local OffhandFilter = {}

local MODE = 'SubWeapon'


-- The whole list of the mode filtered in this load, for the Atelier export (atelier_export.lua collect_modes)
local full_lists = {}

--- The SubWeapon mode of the job loaded, when it is a list.
local function sub_mode()
    local st = rawget(_G, 'state')
    local mode = type(st) == 'table' and rawget(st, MODE)
    local track = type(mode) == 'table' and rawget(mode, '_track')
    return track and track._class == 'mode' and track._type == 'list' and mode or nil
end

--- The item a SubWeapon value puts in the off hand: its weapon set's sub (sets.Kraken), else the value itself.
local function item_of(value)
    local set = rawget(_G, 'sets') and sets[value]
    local sub = type(set) == 'table' and set.sub
    if type(sub) == 'table' then sub = sub.name end
    return type(sub) == 'string' and sub or value
end

--- The session's memory of the choices, by character and job: {['Tetsouo/BRD'] = {dw = 'Kraken', single = 'Genmei'}}
local function memory()
    windower._offhand_pick = windower._offhand_pick or {}
    return windower._offhand_pick
end

--- Draw the HUD again: it outlives the reload and was drawn with the values from before the filter (the player,
--- 2026-11-06: "Kraken" shown till the first key press). Now, and once more a moment later, should the HUD of this
--- load attach after INIT_SYSTEMS.
local function redraw_hud()
    local function update()
        local ok, UI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ok and UI and UI.update then pcall(UI.update) end
    end
    update()
    if coroutine and coroutine.schedule then coroutine.schedule(update, 1.0) end
end

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('LOAD', fmt, (table.unpack or unpack)(args)) end)
end

local function key(job)
    return tostring(player and player.name or '?') .. '/' .. tostring(job)
end

--- Lay the mode's values again (Mote's options()), its current value kept when it is still there.
local function relist(mode, list)
    local current = tostring(mode.current)
    if not pcall(mode.options, mode, (table.unpack or unpack)(list)) then return false end
    for _, v in ipairs(list) do
        if v == current then pcall(mode.set, mode, current) break end
    end
    return true
end

--- Filter the SubWeapon mode for the subjob held, then give back the value last chosen on this side.
--- @param job string Main job ("BRD")
function OffhandFilter.apply(job)
    for k in pairs(full_lists) do full_lists[k] = nil end
    local mode = sub_mode()
    if not mode then return end
    local before = tostring(mode.current)
    local WR = require('shared/utils/equipment/weapon_resolver')
    local side = WR.can_dual_wield() and 'dw' or 'single'
    local list = {}
    for _, v in ipairs(mode) do list[#list + 1] = v end
    local shown = list
    if side == 'single' then
        local keep, shield = {}, false
        for _, v in ipairs(list) do
            local dual = WR.is_offhand_weapon(item_of(v))
            if dual ~= true then keep[#keep + 1] = v end
            if dual == false then shield = true end
        end
        if shield and #keep < #list and relist(mode, keep) then
            full_lists[MODE] = list
            shown = keep
        end
    end
    local pick = (memory()[key(job)] or {})[side]
    for _, v in ipairs(shown) do
        if v == pick then pcall(mode.set, mode, pick) break end
    end
    trace('offhand %s side=%s list={%s} kept={%s} pick=%s now=%s', tostring(job), side, table.concat(list, ','),
        table.concat(shown, ','), tostring(pick), tostring(mode.current))
    -- (the job's functions, which define job_state_change, are included after INIT_SYSTEMS: wrapped once they are there)
    if coroutine and coroutine.schedule then coroutine.schedule(function() OffhandFilter.watch(job) end, 1.0)
    else OffhandFilter.watch(job) end
    if full_lists[MODE] or tostring(mode.current) ~= before then redraw_hud() end
end

--- Keep the SubWeapon value now held, on the side the subjob held gives.
--- @param job string Main job
function OffhandFilter.remember(job)
    local mode = sub_mode()
    if not (mode and job) then return end
    local side = require('shared/utils/equipment/weapon_resolver').can_dual_wield() and 'dw' or 'single'
    local mine = memory()[key(job)] or {}
    mine[side] = tostring(mode.current)
    memory()[key(job)] = mine
    trace('offhand %s kept %s=%s', tostring(job), side, mine[side])
end

--- Wrap the job's job_state_change (once per load: the job file defines it again each load, after INIT_SYSTEMS) so a
--- SubWeapon change is kept at once.
--- @param job string Main job
function OffhandFilter.watch(job)
    local original = rawget(_G, 'job_state_change')
    if type(original) == 'function' and rawget(_G, '_offhand_wrapped') == original then return end
    local wrapped = function(field, new_value, old_value)
        if type(original) == 'function' then original(field, new_value, old_value) end
        local mode = sub_mode()
        if mode and (field == MODE or field == rawget(mode, 'description') or field == mode.description) then
            OffhandFilter.remember(job)
        end
    end
    _G.job_state_change = wrapped
    _G._offhand_wrapped = wrapped
end

--- The whole list of a mode this load filtered, or nil (the Atelier export sends the whole list).
--- @param name string Mode name
--- @return table|nil
function OffhandFilter.full_values(name)
    return full_lists[name]
end

_G.OffhandFilter = OffhandFilter
return OffhandFilter
