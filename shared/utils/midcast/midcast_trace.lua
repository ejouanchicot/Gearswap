---============================================================================
--- Midcast Trace - MidcastManager's choices, written to the trace log
---============================================================================
--- While //gs c trace is on, one line per midcast in <Character>/trace.log:
--- the spell, its target, the set path MidcastManager chose and its pieces,
--- or that the skill had no set at all. A no-op while the trace is off.
---
--- @file    shared/utils/midcast/midcast_trace.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local MidcastTrace = {}

local current = nil

-- Every name GearSwap accepts for a slot (statics.lua slot_map); sets write
-- left_ring / ring1 / lring interchangeably
local SLOT_NAMES = {
    range = {'range', 'ranged'},
    ear1 = {'ear1', 'left_ear', 'lear', 'learring'},
    ear2 = {'ear2', 'right_ear', 'rear', 'rearring'},
    ring1 = {'ring1', 'left_ring', 'lring'},
    ring2 = {'ring2', 'right_ring', 'rring'},
}

--- Name of the piece a set puts in a slot, whatever name the set uses.
--- @param set table
--- @param slot string Canonical slot ('ring1', 'head', ...)
--- @return string|nil
function MidcastTrace.item_name(set, slot)
    for _, key in ipairs(SLOT_NAMES[slot] or {slot}) do
        local item = set[key]
        local name = (type(item) == 'table' and item.name) or (type(item) == 'string' and item) or nil
        if name then return name end
    end
    return nil
end

local function trace()
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok and Trace and Trace.enabled and Trace.enabled() then return Trace end
    return nil
end

--- Remember the spell being resolved ("Cure IV on self").
--- @param spell table|nil
function MidcastTrace.begin(spell)
    local target = spell and spell.target and (spell.target.type == 'SELF' and 'self' or spell.target.name) or '?'
    current = spell and (tostring(spell.english) .. ' on ' .. tostring(target)) or nil
end

--- The set chosen and its pieces.
--- @param selected_set table
--- @param path string|nil
--- @param slots table Slot names, in display order
function MidcastTrace.selection(selected_set, path, slots)
    local Trace = trace()
    if not Trace then return end
    local pieces = {}
    for _, slot in ipairs(slots) do
        local name = MidcastTrace.item_name(selected_set, slot)
        if name then pieces[#pieces + 1] = slot .. '=' .. name end
    end
    Trace.log('MIDCAST', '%s -> %s | %s', tostring(current), tostring(path or 'Combined'), table.concat(pieces, ', '))
end

--- The skill had no set at all.
--- @param skill string
function MidcastTrace.no_set(skill)
    local Trace = trace()
    if Trace then Trace.log('MIDCAST', '%s -> no set for skill %s', tostring(current), tostring(skill)) end
end

return MidcastTrace
