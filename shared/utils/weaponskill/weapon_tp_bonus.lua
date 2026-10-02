---============================================================================
--- Weapon TP Bonus - the TP Bonus a weapon gives, without a list to keep
---============================================================================
--- The TP rule (tp_bonus_calculator.lua) counts the weapon's TP Bonus before
--- choosing TP pieces. A job's TP config may list weapons (WAR: Chango +500):
--- that value wins, it is the player's word. Any other weapon is read:
---   - its description in the game resources ("TP Bonus +500" on a weapon
---     that always gives it);
---   - your copy as //gs c gearscan read it (<Char>/saved/gear_augments.lua):
---     its augments and the stats of its path rank (Ikenga's Axe R23: +200,
---     shared/data/equipment/PATH_RANK_GEAR.lua). A name whose copies differ
---     (`differ`) gives nothing from the scan: the copy held is not known.
--- Read once a weapon a load; after an upgrade, //gs c gearscan then a reload.
---
--- @file    shared/utils/weaponskill/weapon_tp_bonus.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local WeaponTP = {}

local cache, scan = {}, nil

--- The TP Bonus written in a list of text lines (TP Bonus +200, "TP Bonus"+500), added up.
local function from_lines(lines)
    local total = 0
    for _, line in ipairs(lines or {}) do
        for n in tostring(line):gmatch('TP Bonus"?%s*%+(%d+)') do total = total + tonumber(n) end
    end
    return total
end

--- The item's description in the game resources, as one line list: of the newest item of that name
--- (several stages share a name: Ukonvasara from level 75 to 119).
local function description(name)
    local res = rawget(_G, 'res')
    if not res then
        local ok, lib = pcall(require, 'resources')
        res = ok and lib or nil
    end
    if not (res and res.items and res.item_descriptions) then return {} end
    local lower, best = name:lower(), nil
    for id, item in pairs(res.items) do
        if type(item) == 'table' and item.category == 'Weapon' and ((item.en or ''):lower() == lower or (item.enl or ''):lower() == lower)
            and (not best or id > best) then best = id end
    end
    local d = best and res.item_descriptions[best]
    return {d and d.en or ''}
end

--- Your copy as the last gear scan read it, or nil.
local function scanned(name)
    if scan == nil then
        local ok, GearScan = pcall(require, 'shared/utils/equipment/gear_scan')
        scan = ok and GearScan.load() or {}
    end
    local entry = scan[name:lower()]
    return entry and not entry.differ and entry or nil
end

--- TP Bonus of a weapon: the job's TP config when it lists it, else the description plus your copy.
--- @param name string|nil Weapon name (main or sub)
--- @param tp_config table|nil Job TP config (get_weapon_bonus)
--- @return number
function WeaponTP.of(name, tp_config)
    if type(name) ~= 'string' or name == '' or name == 'empty' then return 0 end
    if tp_config and tp_config.get_weapon_bonus then
        local listed = tp_config.get_weapon_bonus(name)
        if listed and listed > 0 then return listed end
    end
    if cache[name] == nil then
        local copy = scanned(name)
        cache[name] = from_lines(description(name)) + (copy and (from_lines(copy.augments) + from_lines(copy.rank_stats)) or 0)
    end
    return cache[name]
end

return WeaponTP
