---  ═══════════════════════════════════════════════════════════════════════════
---   NIN Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle, in this order:
---     1. base: sets.idle.Town / sets.Adoulin on top of the idle in a city,
---        else sets.idle[HybridMode] (sets.idle.DT), else Mote's base
---        (BaseSetBuilder.select_idle_base);
---     2. Mote's defense / Kiting layers, MainWeapon, SubWeapon;
---     3. outside a city, while moving: sets.MoveSpeed.Night from dusk to
---        dawn (17:00-7:00 Vana'diel time, when defined), else sets.MoveSpeed.
---   Engaged: sets.engaged, then [OffenseMode] when that level has it, then
---   .DT under HybridMode DT, from that level or else from sets.engaged;
---   then one layer per buff up, in this order: sets.buff.Yonin,
---   sets.buff.Innin, sets.buff.Sange, sets.buff.Issekigan; then Mote's
---   defense / Kiting layers and the weapons.
---   The Dual Wield tier pieces (sets.DW.*) go on after this, from the
---   shared dual_wield.lua.
---
---   @file    shared/jobs/nin/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

--- Buffs whose set goes on top of the engaged set, in this order. Each one
--- is also in LifecycleManager's GEAR_BUFFS, so gaining or losing it
--- rebuilds the set.
SetBuilder.ENGAGED_BUFFS = {'Yonin', 'Innin', 'Sange', 'Issekigan'}

--- Dusk to dawn in Vana'diel minutes: from 17:00, until 7:00.
local DUSK, DAWN = 17 * 60, 7 * 60

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

--- @return boolean True under HybridMode DT
local function hybrid_dt()
    return state.HybridMode ~= nil and state.HybridMode.current == 'DT'
end

--- Is it dusk to dawn (17:00-7:00) in Vana'diel? world.time is in minutes.
--- @return boolean
function SetBuilder.is_night()
    local minutes = world and tonumber(world.time)
    if not minutes then return false end
    return minutes >= DUSK or minutes < DAWN
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT
---  ═══════════════════════════════════════════════════════════════════════════

--- Movement speed while moving: the night set from dusk to dawn when it
--- exists, else the shared sets.MoveSpeed (BaseSetBuilder.apply_movement).
--- @param result table
--- @return table
function SetBuilder.apply_movement(result)
    local night = sets.MoveSpeed and sets.MoveSpeed.Night
    local moving = state.Moving and state.Moving.value == 'true'
    if moving and type(night) == 'table' and SetBuilder.is_night() then
        return set_combine(result, night)
    end
    return BaseSetBuilder.apply_movement(result)
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
    result = BaseSetBuilder.lay_weapons(mote_layers(result))
    if not in_town then
        result = SetBuilder.apply_movement(result)
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

--- The buff layers (ENGAGED_BUFFS) of the buffs up.
--- @param result table
--- @return table set, table names laid (for the trace)
function SetBuilder.lay_buff_layers(result)
    local laid = {}
    local buff_sets = sets.buff or {}
    for _, name in ipairs(SetBuilder.ENGAGED_BUFFS) do
        if buffactive and buffactive[name] and type(buff_sets[name]) == 'table' then
            result = set_combine(result, buff_sets[name])
            laid[#laid + 1] = 'sets.buff.' .. name
        end
    end
    return result, laid
end

--- Build the engaged set.
--- @param base_set table Engaged set from Mote
--- @return table
function SetBuilder.build_engaged_set(base_set)
    if not base_set then return {} end
    local result, path = SetBuilder.select_engaged_base(base_set)
    local laid
    result, laid = SetBuilder.lay_buff_layers(result)
    result = BaseSetBuilder.lay_weapons(mote_layers(result))
    require('shared/utils/debug/trace_log').log('ENGAGED', '%s, on top: %s', path,
        #laid > 0 and table.concat(laid, ', ') or 'nothing')
    return result
end

return SetBuilder
