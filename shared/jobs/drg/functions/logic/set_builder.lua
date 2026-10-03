---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle, in this order:
---     1. base: Mote's pick, except that Mote's own walk goes into
---        sets.idle.Pet while a pet is out: that pick is replaced by
---        sets.idle, the wyvern layer (step 3) takes its place;
---     2. BaseSetBuilder.select_idle_base: sets.idle.Town / sets.Adoulin on
---        top in a city, else sets.idle[HybridMode] (sets.idle.DT) when
---        defined;
---     3. outside a city, wyvern out: sets.idle.Pet on top (its .DT child
---        under HybridMode DT when defined);
---     4. Mote's defense / Kiting layers, MainWeapon / SubWeapon, and
---        sets.MoveSpeed while moving outside a city.
---   Engaged: sets.engaged, then [OffenseMode] when that level has it, then
---   .DT under HybridMode DT, from that level or else from sets.engaged;
---   sets.buff['Spirit Surge'] on top while Spirit Surge is up; Mote's
---   defense / Kiting layers; MainWeapon / SubWeapon.
---
---   @file    shared/jobs/drg/functions/logic/set_builder.lua
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

--- @return boolean True while the wyvern (any pet) is out
function SetBuilder.wyvern_out()
    return pet ~= nil and pet.isvalid == true
end

--- Mote's defense (sets.defense) and Kiting (sets.Kiting) layers: Mote laid
--- them on its own pick, which is replaced here.
--- @param result table
--- @return table
local function mote_layers(result)
    if apply_defense then result = apply_defense(result) end
    if apply_kiting then result = apply_kiting(result) end
    return result
end

--- Lay the Mote layers and the weapons, then trace.
--- @param result table
--- @param kind string 'IDLE' or 'ENGAGED'
--- @param path string What was chosen
--- @return table
local function finish(result, kind, path)
    result = BaseSetBuilder.lay_weapons(mote_layers(result))
    require('shared/utils/debug/trace_log').log(kind, '%s', path)
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE
---  ═══════════════════════════════════════════════════════════════════════════

--- The idle base under the town / HybridMode choice (see header, step 1).
--- @param base_set table What Mote built
--- @return table
function SetBuilder.master_idle(base_set)
    local pet_node = sets.idle and sets.idle.Pet
    if pet_node and (base_set == pet_node or base_set == pet_node.Engaged) then
        return sets.idle
    end
    return base_set
end

--- The wyvern layer (see header, step 3).
--- @return table|nil set, string path
function SetBuilder.wyvern_idle_layer()
    local node = sets.idle and sets.idle.Pet
    if not SetBuilder.wyvern_out() then return nil, 'no wyvern' end
    if type(node) ~= 'table' then return nil, 'no sets.idle.Pet' end
    if hybrid_dt() and type(node.DT) == 'table' then
        return node.DT, 'sets.idle.Pet.DT'
    end
    return node, 'sets.idle.Pet'
end

--- Build the idle set.
--- @param base_set table Idle set from Mote
--- @return table
function SetBuilder.build_idle_set(base_set)
    if not base_set then return {} end
    local result, in_town = BaseSetBuilder.select_idle_base(SetBuilder.master_idle(base_set))
    if in_town then
        return finish(result, 'IDLE', 'town')
    end
    local layer, path = SetBuilder.wyvern_idle_layer()
    if layer then
        result = set_combine(result, layer)
    end
    result = finish(result, 'IDLE', path)
    return BaseSetBuilder.apply_movement(result)
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

--- sets.buff['Spirit Surge'] on top while the buff is up.
--- @param result table
--- @return table set, boolean laid
function SetBuilder.lay_spirit_surge(result)
    local surge = sets.buff and sets.buff['Spirit Surge']
    if surge and buffactive and buffactive['Spirit Surge'] then
        return set_combine(result, surge), true
    end
    return result, false
end

--- Build the engaged set.
--- @param base_set table Engaged set from Mote
--- @return table
function SetBuilder.build_engaged_set(base_set)
    if not base_set then return {} end
    local result, path = SetBuilder.select_engaged_base(base_set)
    -- the party support's version of it (.Solo, .Group: shared/utils/party/support_tier.lua)
    result = require('shared/utils/party/support_tier').engaged(result)
    local surged
    result, surged = SetBuilder.lay_spirit_surge(result)
    return finish(result, 'ENGAGED', surged and (path .. ' + Spirit Surge') or path)
end

return SetBuilder
