---============================================================================
--- Item Index - name lookups over the game's item list, built once
---============================================================================
--- The game knows ~23,500 items. GearSwap has the list loaded already
--- (require('resources') returns its table), but a lookup by name means a
--- walk over all of it: 20 to 30 ms each offline, more in game. Four modules
--- used to build their own index on first use, again after every job load
--- (a module local dies with the sandbox): WeaponResolver twice, the quiver
--- manager and the refill item resolver.
---
--- One walk now builds the three lookups they need, kept on `windower`: the
--- item list never changes during a session, so the walk happens once per
--- `lua load gearswap`, not once per job load and per module.
---   ItemIndex.id(name)          item id for a name (short or log form, name
---                               fields en / enl / name / name_log, any case;
---                               the first item met keeps a shared name)
---   ItemIndex.is_weapon(name)   exact short name of an item in the Weapon
---                               category (grips included)
---   ItemIndex.dual_wields(name) true for a weapon with a combat skill, false
---                               for any other known item (shield, grip...),
---                               nil for an unknown name; short or log form,
---                               any case
---
--- @file    shared/utils/equipment/item_index.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local ItemIndex = {}

local NAME_FIELDS = {'en', 'enl', 'name', 'name_log'}

--- One walk over the item list, or nil when the list is not available.
local function build()
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.items) then return nil end
    local ids, weapons, dual = {}, {}, {}
    for id, item in pairs(res.items) do
        if item then
            for _, field in ipairs(NAME_FIELDS) do
                local v = item[field]
                if type(v) == 'string' then
                    local key = v:lower()
                    if not ids[key] then ids[key] = id end
                end
            end
            if item.category == 'Weapon' and item.en then weapons[item.en] = true end
            local wields = item.category == 'Weapon' and (item.skill or 0) > 0
            for _, n in ipairs({item.en, item.enl}) do
                if type(n) == 'string' then
                    local key = n:lower()
                    dual[key] = dual[key] or wields
                end
            end
        end
    end
    return {ids = ids, weapons = weapons, dual = dual}
end

--- The lookups, built on first use and kept for the session.
local function index()
    local cached = windower._item_index
    if cached then return cached end
    cached = build()
    if cached then windower._item_index = cached end
    return cached
end

--- @param name string|nil
--- @return number|nil Item id
function ItemIndex.id(name)
    if type(name) ~= 'string' then return nil end
    local idx = index()
    return idx and idx.ids[name:lower()]
end

--- @param name string|nil
--- @return boolean
function ItemIndex.is_weapon(name)
    local idx = index()
    return idx ~= nil and idx.weapons[name] == true
end

--- @param name string|nil
--- @return boolean|nil
function ItemIndex.dual_wields(name)
    if type(name) ~= 'string' or name == '' then return nil end
    local idx = index()
    return idx and idx.dual[name:lower()]
end

return ItemIndex
