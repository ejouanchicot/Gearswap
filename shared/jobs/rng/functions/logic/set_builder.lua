---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle: BaseSetBuilder.select_idle_base: in a city sets.idle.Town (or
---   sets.Adoulin) on top of the idle; elsewhere sets.idle[HybridMode]
---   (sets.idle.DT) when it exists, else Mote's base (sets.idle).
---   Engaged: sets.engaged, then [OffenseMode] when that level has it, then
---   .DT under HybridMode DT, from that level or else from sets.engaged.
---   Both, then: Mote's defense / Kiting layers (Mote laid them on its own
---   pick, which may be replaced here), the weapons (MainWeapon, SubWeapon,
---   RangeWeapon: sets[value] through WeaponResolver; an off-hand weapon
---   without Dual Wield becomes sets.SingleWield's sub), and for idle
---   sets.MoveSpeed while moving outside a city.
---   No Ranger buff changes these sets: the ranged buffs dress the shot
---   (logic/ranged.lua). Dual Wield tiers (sets.DW) and Treasure Hunter are
---   laid afterwards by the shared hooks.
---
---   @file    shared/jobs/rng/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- @return boolean True under HybridMode DT
local function hybrid_dt()
    return state.HybridMode ~= nil and state.HybridMode.current == 'DT'
end

--- Mote's defense (sets.defense) and Kiting (sets.Kiting) layers.
--- @param result table
--- @return table
local function mote_layers(result)
    if apply_defense then result = apply_defense(result) end
    if apply_kiting then result = apply_kiting(result) end
    return result
end

--- MainWeapon, SubWeapon, then RangeWeapon (whose set carries the ammo).
--- @param result table
--- @return table
function SetBuilder.apply_weapons(result)
    result = BaseSetBuilder.lay_weapons(result)
    return BaseSetBuilder.lay_weapon(result, 'range', state.RangeWeapon and state.RangeWeapon.current)
end

--- Mote layers, weapons, and a trace line.
--- @param result table
--- @param kind string 'IDLE' or 'ENGAGED'
--- @param path string Base set chosen
--- @return table
local function finish(result, kind, path)
    result = SetBuilder.apply_weapons(mote_layers(result))
    require('shared/utils/debug/trace_log').log(kind, '%s, range weapon %s', path,
        tostring(state.RangeWeapon and state.RangeWeapon.current))
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE
---  ═══════════════════════════════════════════════════════════════════════════

--- Build the idle set.
--- @param base_set table Idle set from Mote
--- @return table
function SetBuilder.build_idle_set(base_set)
    if not base_set then return {} end
    local result, in_town = BaseSetBuilder.select_idle_base(base_set)
    result = finish(result, 'IDLE', in_town and 'town' or 'field')
    if not in_town then
        result = BaseSetBuilder.apply_movement(result)
    end
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
    if hybrid_dt() then
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
    return finish(result, 'ENGAGED', path)
end

return SetBuilder
