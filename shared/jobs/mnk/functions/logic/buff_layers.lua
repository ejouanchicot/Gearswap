---  ═══════════════════════════════════════════════════════════════════════════
---   MNK Buff Layers - Monk buff sets laid on top of engaged and weaponskills
---  ═══════════════════════════════════════════════════════════════════════════
---   Engaged: for each buff up, in ENGAGED order (later wins a shared slot),
---   sets.buff[buff], or its [HybridMode] child when that is a table
---   (sets.buff.Impetus.DT = what Impetus puts on under Hybrid Mode DT).
---
---   Weaponskills: for each WS rule whose buff is up and whose list names
---   the weaponskill (no list = every weaponskill): sets.buff[buff], then
---   sets.precast.WS[name][buff]. Both are layers laid on Mote's WS set.
---     Impetus   every weaponskill (the Bhikku Cyclas Impetus bonus is
---               critical hit damage and accuracy per consecutive hit)
---     Footwork  Dragon Kick and Tornado Kick only (Footwork's boosts
---               apply to those two)
---
---   @file    shared/jobs/mnk/functions/logic/buff_layers.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local BuffLayers = {}

--- Engaged layers, in the order they go on
BuffLayers.ENGAGED = {'Counterstance', 'Footwork', 'Impetus', 'Hundred Fists'}

--- Weaponskill layers: buff, and the weaponskills it applies to (nil = all)
BuffLayers.WS = {
    {buff = 'Impetus'},
    {buff = 'Footwork', ws = {['Dragon Kick'] = true, ['Tornado Kick'] = true}},
}

--- @param buff string
--- @return boolean
local function is_up(buff)
    return buffactive ~= nil and buffactive[buff] ~= nil and buffactive[buff] ~= false
end

--- sets.buff[buff], or its HybridMode child when that is a table.
--- @param buff string
--- @return table|nil set, string path
function BuffLayers.engaged_layer(buff)
    local node = sets.buff and sets.buff[buff]
    if type(node) ~= 'table' then return nil end
    local path = "sets.buff['" .. buff .. "']"
    local mode = state.HybridMode and state.HybridMode.current
    if mode and type(node[mode]) == 'table' then
        return node[mode], path .. '.' .. mode
    end
    return node, path
end

--- Lay the engaged buff layers of the buffs that are up.
--- @param result table Engaged set so far
--- @return table set, table names laid
function BuffLayers.lay_engaged(result)
    local laid = {}
    for _, buff in ipairs(BuffLayers.ENGAGED) do
        if is_up(buff) then
            local set, path = BuffLayers.engaged_layer(buff)
            if set then
                result = set_combine(result, set)
                laid[#laid + 1] = path
            end
        end
    end
    return result, laid
end

--- The weaponskill layers for `ws_name`, in the order they go on.
--- @param ws_name string Weaponskill name (spell.english)
--- @return table List of {set = table, path = string}
function BuffLayers.ws_layers(ws_name)
    local out = {}
    local named = sets.precast and sets.precast.WS and sets.precast.WS[ws_name]
    for _, rule in ipairs(BuffLayers.WS) do
        if is_up(rule.buff) and (rule.ws == nil or rule.ws[ws_name]) then
            local generic = sets.buff and sets.buff[rule.buff]
            if type(generic) == 'table' then
                out[#out + 1] = {set = generic, path = 'sets.buff.' .. rule.buff}
            end
            if type(named) == 'table' and type(named[rule.buff]) == 'table' then
                out[#out + 1] = {set = named[rule.buff], path = "sets.precast.WS['" .. ws_name .. "']." .. rule.buff}
            end
        end
    end
    return out
end

--- Equip the weaponskill layers (job_post_precast, after Mote's WS set).
--- @param spell table Spell from GearSwap
--- @return table names laid
function BuffLayers.equip_ws(spell)
    local laid = {}
    if not spell or spell.type ~= 'WeaponSkill' then return laid end
    for _, layer in ipairs(BuffLayers.ws_layers(spell.english)) do
        equip(layer.set)
        laid[#laid + 1] = layer.path
    end
    return laid
end

return BuffLayers
