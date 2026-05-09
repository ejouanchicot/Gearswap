---  ═══════════════════════════════════════════════════════════════════════════
---   Item Resolver - Lazy item name -> resource ID lookup
---  ═══════════════════════════════════════════════════════════════════════════
---   Builds a name-to-id index from res.items on first call (one-time cost,
---   ~30k entries) and caches it for O(1) lookups thereafter. Without this
---   cache, scanning all res.items for every refill entry causes a
---   multi-second freeze.
---
---   Matches against ALL common name fields (en, enl, name, name_log) so
---   callers can use either the full form ("Red Curry Bun +1") or FFXI's
---   abbreviated log form ("R. Curry Bun +1") and still find the item.
---
---   Public API:
---     • resolve_item_id(item_name) -> number|nil
---     • resolve_variants(name) -> list of {name, id}
---
---   @file    shared/utils/inventory/refill/item_resolver.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from refill_manager.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local res = require('resources')

local ItemResolver = {}

-- Lazy-built name->id lookup table (populated once on first call)
local _name_to_id = nil

local function build_name_index()
    local idx = {}
    for id, item_data in pairs(res.items) do
        if item_data then
            for _, field in ipairs({'en', 'enl', 'name', 'name_log'}) do
                local v = item_data[field]
                if type(v) == 'string' then
                    local key = v:lower()
                    -- First match wins; later collisions ignored (rare anyway)
                    if not idx[key] then
                        idx[key] = id
                    end
                end
            end
        end
    end
    return idx
end

--- Resolve item name to resource ID via res.items.
--- @param item_name string The English item name (full or log form)
--- @return number|nil Item ID or nil if not found
function ItemResolver.resolve_item_id(item_name)
    if not _name_to_id then
        _name_to_id = build_name_index()
    end
    return _name_to_id[item_name:lower()]
end

--- Normalise an entry's name field into a list of {display_name, item_id} tuples,
--- preserving order (preferred variant first).
--- @param name string|table  e.g. 'Panacea' OR {'Squid Sushi +1', 'Squid Sushi'}
--- @return table list of {name=string, id=number} (only successfully resolved IDs)
function ItemResolver.resolve_variants(name)
    local names = (type(name) == 'table') and name or {name}
    local out = {}
    for _, n in ipairs(names) do
        local id = ItemResolver.resolve_item_id(n)
        if id then
            table.insert(out, {name = n, id = id})
        end
    end
    return out
end

return ItemResolver
