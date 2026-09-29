---  ═══════════════════════════════════════════════════════════════════════════
---   MNK Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle: BaseSetBuilder.select_idle_base (sets.idle.Town / sets.Adoulin on
---   top in a city, else sets.idle[HybridMode] when defined, else Mote's
---   base), Mote's defense / Kiting layers, MainWeapon, then sets.MoveSpeed
---   while moving outside a city.
---
---   Engaged: sets.engaged, then [OffenseMode] when that level has it, then
---   [HybridMode] (DT, Counter) from that level, else from sets.engaged. On
---   top: the buff layers (logic/buff_layers.lua: Counterstance, Footwork,
---   Impetus, Hundred Fists), Mote's defense / Kiting layers (Mote laid them
---   on its own pick, replaced here), MainWeapon.
---
---   Monk has no off hand (Martial Arts, no Dual Wield): only MainWeapon.
---
---   @file    shared/jobs/mnk/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
local BuffLayers = require('shared/jobs/mnk/functions/logic/buff_layers')

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Mote's defense (sets.defense) and Kiting (sets.Kiting) layers.
--- @param result table
--- @return table
local function mote_layers(result)
    if apply_defense then result = apply_defense(result) end
    if apply_kiting then result = apply_kiting(result) end
    return result
end

--- Mote layers, then the MainWeapon set.
--- @param result table
--- @return table
local function finish(result)
    result = mote_layers(result)
    return BaseSetBuilder.lay_weapon(result, 'main', state.MainWeapon and state.MainWeapon.current)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED
---  ═══════════════════════════════════════════════════════════════════════════

--- The engaged base (see header).
--- @param base_set table What Mote built
--- @return table set, string path (for the trace)
function SetBuilder.select_engaged_base(base_set)
    local group = sets.engaged
    if type(group) ~= 'table' then return base_set, 'Mote' end
    local node, path = group, 'sets.engaged'
    local mode = state.OffenseMode and state.OffenseMode.current
    if mode and type(group[mode]) == 'table' then
        node, path = group[mode], path .. '.' .. mode
    end
    local hybrid = state.HybridMode and state.HybridMode.current
    if hybrid and hybrid ~= 'Normal' then
        if type(node[hybrid]) == 'table' then
            return node[hybrid], path .. '.' .. hybrid
        elseif type(group[hybrid]) == 'table' then
            return group[hybrid], 'sets.engaged.' .. hybrid
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
    local laid
    result, laid = BuffLayers.lay_engaged(result)
    result = finish(result)
    require('shared/utils/debug/trace_log').log('ENGAGED', '%s, on top: %s', path,
        #laid > 0 and table.concat(laid, ', ') or 'nothing')
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
    result = finish(result)
    if not in_town then
        result = BaseSetBuilder.apply_movement(result)
    end
    return result
end

return SetBuilder
