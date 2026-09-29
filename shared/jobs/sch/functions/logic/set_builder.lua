---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle, in this order:
---     1. base: sets.idle.Town / sets.Adoulin on top of the idle in a city,
---        else sets.idle[HybridMode] (sets.idle.DT) when it exists, else
---        Mote's pick (BaseSetBuilder.select_idle_base);
---     2. sets.buff.Sublimation while Sublimation is charging
---        ("Sublimation: Activated"): the pieces that drain more HP for more
---        MP must stay on the whole time it charges;
---     3. Mote's defense / Kiting layers (Mote laid them on its own pick,
---        replaced here), then MainWeapon / SubWeapon;
---     4. sets.MoveSpeed while moving outside a city.
---   Engaged: sets.engaged, then [OffenseMode] when that level has it, then
---   .DT under HybridMode DT (from that level, else from sets.engaged);
---   then Mote's layers and the weapons.
---
---   @file    shared/jobs/sch/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

--- Buff shown while Sublimation charges (res/buffs.lua id 187).
local SUBLIMATION_CHARGING = 'Sublimation: Activated'

--- Mote's defense (sets.defense) and Kiting (sets.Kiting) layers.
--- @param result table
--- @return table
local function mote_layers(result)
    if apply_defense then result = apply_defense(result) end
    if apply_kiting then result = apply_kiting(result) end
    return result
end

--- Trace line (//gs c trace on).
local function trace(kind, fmt, ...)
    require('shared/utils/debug/trace_log').log(kind, fmt, ...)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE
---  ═══════════════════════════════════════════════════════════════════════════

--- The Sublimation layer (see header, step 2).
--- @return table|nil
function SetBuilder.sublimation_layer()
    if not (buffactive and buffactive[SUBLIMATION_CHARGING]) then return nil end
    local set = sets.buff and sets.buff.Sublimation
    return type(set) == 'table' and set or nil
end

--- Build the idle set.
--- @param base_set table Idle set from Mote
--- @return table
function SetBuilder.build_idle_set(base_set)
    if not base_set then return {} end
    local result, in_town = BaseSetBuilder.select_idle_base(base_set)
    local sublimation = SetBuilder.sublimation_layer()
    if sublimation then
        result = set_combine(result, sublimation)
    end
    result = BaseSetBuilder.lay_weapons(mote_layers(result))
    if not in_town then
        result = BaseSetBuilder.apply_movement(result)
    end
    trace('IDLE', 'town %s, hybrid %s, sublimation %s', tostring(in_town),
        tostring(state.HybridMode and state.HybridMode.current), sublimation and 'on' or 'off')
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED
---  ═══════════════════════════════════════════════════════════════════════════

--- The engaged base (see header).
--- @param base_set table What Mote built
--- @return table set, string path
function SetBuilder.select_engaged_base(base_set)
    local group = sets.engaged
    if type(group) ~= 'table' then return base_set, 'Mote' end
    local node, path = group, 'sets.engaged'
    local mode = state.OffenseMode and state.OffenseMode.current
    if mode and type(group[mode]) == 'table' then
        node, path = group[mode], path .. '.' .. mode
    end
    if state.HybridMode and state.HybridMode.current == 'DT' then
        if type(node.DT) == 'table' then
            return node.DT, path .. '.DT'
        elseif type(group.DT) == 'table' then
            return group.DT, 'sets.engaged.DT'
        end
    end
    return node, path
end

--- Build the engaged set.
--- @param base_set table Engaged set from Mote
--- @return table
function SetBuilder.build_engaged_set(base_set)
    if not base_set then return {} end
    local result, path = SetBuilder.select_engaged_base(base_set)
    trace('ENGAGED', '%s', path)
    return BaseSetBuilder.lay_weapons(mote_layers(result))
end

return SetBuilder
