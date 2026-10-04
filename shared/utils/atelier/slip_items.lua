---============================================================================
--- Slip Items - the gear kept at the Porter Moogle, for the Atelier export
---============================================================================
--- The items stored in the Porter Moogle's storage slips (Windower's slips library:
--- the bits of each slip held in a bag), as {item id = 'Slip N'}.
---
--- Read when a job loads, the bags are not always there yet and the slips read
--- empty: the page then called every stored piece missing. The export waits for
--- them (bags_ready); the last list read, kept in <Char>/saved/slip_items.lua,
--- stands in only when they still cannot be read after that wait.
---
--- Used by shared/utils/atelier/atelier_export.lua (collect_items).
---
--- @file    shared/utils/atelier/slip_items.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-04
---============================================================================

local SlipItems = {}

local CACHE_FILE = 'slip_items.lua'

--- The slips read now: {item id = 'Slip N'}, empty when they cannot be read.
local function read_slips()
    local ok, slips = pcall(require, 'slips')
    if not (ok and slips and slips.get_player_items) then return {} end
    local ok_g, list = pcall(slips.get_player_items)
    if not ok_g or type(list) ~= 'table' then return {} end
    local out = {}
    for slip_id, ids in pairs(list) do
        local n = slips.get_slip_number_by_id and slips.get_slip_number_by_id(slip_id)
        for _, id in ipairs(ids or {}) do
            if type(id) == 'number' and id > 0 then out[id] = 'Slip ' .. tostring(n or slip_id) end
        end
    end
    return out
end

local function cache_path()
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    return ok and CharPaths.writable and CharPaths.writable('saved', CACHE_FILE) or nil
end

local function save(items)
    local path = cache_path()
    local f = path and io.open(path, 'w')
    if not f then return end
    f:write('-- The gear kept at the Porter Moogle, last read from the storage slips (shared/utils/atelier/slip_items.lua).\n')
    f:write('-- Written by the game: the Atelier export uses it while the slips cannot be read.\nreturn {\n')
    local ids = {}
    for id in pairs(items) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do f:write(('    [%d] = %q,\n'):format(id, items[id])) end
    f:write('}\n')
    f:close()
end

local function load()
    local path = cache_path()
    local ok, items = pcall(dofile, path)
    return ok and type(items) == 'table' and items or {}
end

--- Whether the bags and the slips in them are there to be read: the inventory has its size (it reads 0
--- until the game sent it after a load or a zone), and a slip held in a bag shows its contents.
--- @return boolean
function SlipItems.bags_ready()
    local ok, items = pcall(windower.ffxi.get_items)
    if not ok or type(items) ~= 'table' or type(items.inventory) ~= 'table' or (items.inventory.max or 0) == 0 then return false end
    local ok_s, slips = pcall(require, 'slips')
    if not (ok_s and slips and slips.storages and slips.default_storages) then return true end
    local held = false
    for _, bag in ipairs(slips.default_storages) do
        for _, item in ipairs(type(items[bag]) == 'table' and items[bag] or {}) do
            if type(item) == 'table' and slips.storages:contains(item.id) then held = true end
        end
    end
    return not held or next(read_slips()) ~= nil
end

--- The Porter Moogle's items: the slips read now when the bags are there (kept for later, an empty list
--- too: nothing stored), else the last list kept.
--- @return table {item id = 'Slip N'}
function SlipItems.get()
    if not SlipItems.bags_ready() then return load() end
    local items = read_slips()
    save(items)
    return items
end

return SlipItems
