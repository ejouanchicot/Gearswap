---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle, in this order:
---     1. master idle: sets.idle.DT under HybridMode DT (when defined), else
---        Mote's base (sets.idle, sets.idle.Town in a city...). Mote's own
---        walk goes into sets.idle.Pet while a pet is out: that pick is
---        replaced by sets.idle, the pet layer below takes its place;
---     2. town: sets.idle.Town / sets.Adoulin on top in a city
---        (BaseSetBuilder.select_idle_base_town);
---     3. pet layer: automaton out and fighting -> sets.idle.Pet.Engaged
---        [PetMode], else sets.idle.Pet.Engaged; out, not fighting ->
---        sets.idle.Pet; no automaton -> nothing;
---   Engaged: sets.engaged, or sets.engaged.Pet while the automaton fights
---   too (when defined); then [OffenseMode] when that level has it; then .DT
---   under HybridMode DT, from that level or else from the group.
---   Both, then: sets.buff.Overdrive while Overdrive is up, the automaton WS
---   set when due (logic/pet_ws.lua), Mote's defense / Kiting layers (Mote
---   laid them on its own pick, replaced here), MainWeapon, and for idle
---   sets.MoveSpeed while moving outside a city.
---
---   @file    shared/jobs/pup/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
local Automaton = require('shared/jobs/pup/functions/logic/automaton')
local PetWS = require('shared/jobs/pup/functions/logic/pet_ws')

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- @return boolean True under HybridMode DT
local function hybrid_dt()
    return state.HybridMode ~= nil and state.HybridMode.current == 'DT'
end

--- node[PetMode] when it is a table, else node itself.
--- @param node table
--- @return table set, string suffix (for the trace)
local function by_pet_mode(node)
    local mode = state.PetMode and state.PetMode.current
    if mode and type(node[mode]) == 'table' then
        return node[mode], '.' .. mode
    end
    return node, ''
end

--- Mote's defense (sets.defense) and Kiting (sets.Kiting) layers.
--- @param result table
--- @return table
local function mote_layers(result)
    if apply_defense then result = apply_defense(result) end
    if apply_kiting then result = apply_kiting(result) end
    return result
end

--- Overdrive and automaton WS sets on top.
--- @param result table
--- @return table set, table names laid (for the trace)
function SetBuilder.lay_pet_layers(result)
    local laid = {}
    if buffactive and buffactive['Overdrive'] and sets.buff and sets.buff.Overdrive then
        result = set_combine(result, sets.buff.Overdrive)
        laid[#laid + 1] = 'sets.buff.Overdrive'
    end
    local ws = sets.midcast and sets.midcast.Pet and sets.midcast.Pet.WeaponSkill
    if ws and PetWS.is_due() then
        local set, suffix = by_pet_mode(ws)
        result = set_combine(result, set)
        laid[#laid + 1] = 'sets.midcast.Pet.WeaponSkill' .. suffix
    end
    return result, laid
end

--- Lay the rest (Overdrive, pet WS, Mote layers, weapon) and trace.
--- @param result table
--- @param kind string 'IDLE' or 'ENGAGED'
--- @param path string Base set chosen
--- @return table
local function finish(result, kind, path)
    local laid
    result, laid = SetBuilder.lay_pet_layers(result)
    result = BaseSetBuilder.lay_weapons(mote_layers(result))
    require('shared/utils/debug/trace_log').log(kind, '%s, pet mode %s, on top: %s', path,
        tostring(state.PetMode and state.PetMode.current), #laid > 0 and table.concat(laid, ', ') or 'nothing')
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE
---  ═══════════════════════════════════════════════════════════════════════════

--- The master's idle base (see header, step 1).
--- @param base_set table What Mote built
--- @return table
function SetBuilder.master_idle(base_set)
    local idle = sets.idle
    if hybrid_dt() and idle and type(idle.DT) == 'table' then
        return idle.DT
    end
    local pet_node = idle and idle.Pet
    if pet_node and (base_set == pet_node or base_set == pet_node.Engaged) then
        return idle
    end
    return base_set
end

--- The pet layer (see header, step 3).
--- @return table|nil set, string path
function SetBuilder.pet_idle_layer()
    local node = sets.idle and sets.idle.Pet
    if not Automaton.is_out() then return nil, 'no automaton' end
    if not node then return nil, 'no sets.idle.Pet' end
    if Automaton.is_engaged() and type(node.Engaged) == 'table' then
        local set, suffix = by_pet_mode(node.Engaged)
        return set, 'sets.idle.Pet.Engaged' .. suffix
    end
    return node, 'sets.idle.Pet'
end

--- Build the idle set.
--- @param base_set table Idle set from Mote
--- @return table
function SetBuilder.build_idle_set(base_set)
    if not base_set then return {} end
    local result, in_town = BaseSetBuilder.select_idle_base_town(SetBuilder.master_idle(base_set))
    local pet_set, pet_path = SetBuilder.pet_idle_layer()
    if pet_set then
        result = set_combine(result, pet_set)
    end
    result = finish(result, 'IDLE', (in_town and 'town, ' or '') .. pet_path)
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
    local group, group_path = sets.engaged, 'sets.engaged'
    if not group then return base_set, 'Mote' end
    if type(group.Pet) == 'table' and Automaton.is_engaged() then
        group, group_path = group.Pet, 'sets.engaged.Pet'
    end
    local node, path = group, group_path
    local mode = state.OffenseMode and state.OffenseMode.current
    if mode and type(group[mode]) == 'table' then
        node, path = group[mode], group_path .. '.' .. mode
    end
    if hybrid_dt() then
        if type(node.DT) == 'table' then
            return node.DT, path .. '.DT'
        elseif type(group.DT) == 'table' then
            return group.DT, group_path .. '.DT'
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
