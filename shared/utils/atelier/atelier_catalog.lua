---============================================================================
--- Atelier Catalog - every piece of gear in the game, for the Atelier page
---============================================================================
--- Writes data/atelier/catalog.js from Windower's resources (res/items.lua,
--- res/item_descriptions.lua): each equippable item with its slots, jobs,
--- level, item level, the game's description, whether it is Rare (one copy
--- a character: never two Moonlight-style rings of it) and Ex (no trade). The page loads it only when
--- "every item in the game" is ticked in the piece picker, and reads each
--- item's stats from the description the way it reads the pieces you own.
---
--- Rewritten only when the resources hold another number of items, or when
--- CATALOG_VERSION changes (the first line of the file holds both).
---
--- @file    shared/utils/atelier/atelier_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local AtelierCatalog = {}

local CATALOG_VERSION = 3
-- res.items flags: Rare (0x8000), Ex (0x4000, no trade between players)
local FLAG_RARE, FLAG_EX = 15, 14
-- res slot ids, named as the page names them
local SLOT_BY_ID = {[0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
    'ear1', 'ear2', 'ring1', 'ring2', 'back'}
local JOBS = {'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG',
    'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'}

--- Whether a res flag field (a set of ids, or the raw bitmask) holds an id.
local function has(field, id)
    if type(field) == 'number' then return math.floor(field / 2 ^ id) % 2 == 1 end
    return type(field) == 'table' and field[id] == true
end

--- The page's slot names an item fits, space separated, or nil for an item worn nowhere.
local function slots_of(info)
    local out = {}
    for id = 0, 15 do if has(info.slots, id) then out[#out + 1] = SLOT_BY_ID[id] end end
    return #out > 0 and table.concat(out, ' ') or nil
end

--- Gear only: fishing bait (skill 48) and pet food (ammo with damage but no skill) fit a slot too.
local function is_gear(info)
    return not (info.skill == 48 or (info.skill == 0 and (info.damage or 0) > 0))
end

local function jobs_of(info)
    local out = {}
    for id, job in ipairs(JOBS) do if has(info.jobs, id) then out[#out + 1] = job end end
    return table.concat(out, ' ')
end

--- The equippable items, sorted by id: {id, name, slots, jobs, level, item level, description, rare 1/0, ex 1/0}.
local function collect(res)
    local ids = {}
    for id, info in pairs(res.items) do
        if type(id) == 'number' and type(info) == 'table' and info.slots and info.en and is_gear(info) then
            ids[#ids + 1] = id
        end
    end
    table.sort(ids)
    local rows = {}
    for _, id in ipairs(ids) do
        local info = res.items[id]
        local slots = slots_of(info)
        local desc = res.item_descriptions and res.item_descriptions[id]
        if slots then
            rows[#rows + 1] = {id, info.en, slots, jobs_of(info), info.level or 0, info.item_level or 0, desc and desc.en or '',
                has(info.flags, FLAG_RARE) and 1 or 0, has(info.flags, FLAG_EX) and 1 or 0}
        end
    end
    return rows
end

--- The first line of the file: the version and how many items it was written from.
local function header(count)
    return ('// atelier catalog v%d n=%d'):format(CATALOG_VERSION, count)
end

local function first_line(path)
    local file = io.open(path, 'r')
    if not file then return nil end
    local line = file:read('*l')
    file:close()
    return line
end

--- Write the catalog when missing or stale.
--- @param path string Absolute path of catalog.js
--- @param json function The exporter's JSON encoder (shared/utils/atelier/atelier_export.lua)
--- @return boolean True when the file was (re)written
function AtelierCatalog.write_if_stale(path, json)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.items) then return false end
    local count = 0
    for _ in pairs(res.items) do count = count + 1 end
    if first_line(path) == header(count) then return false end
    local rows = collect(res)
    local parts = {}
    for i, row in ipairs(rows) do parts[i] = json(row) end
    local file = io.open(path, 'w')
    if not file then return false end
    file:write(header(count), '\n', 'window.ATELIER_CATALOG = {"v":', CATALOG_VERSION, ',"items":[\n',
        table.concat(parts, ',\n'), '\n]};\n')
    file:close()
    return true
end

return AtelierCatalog
