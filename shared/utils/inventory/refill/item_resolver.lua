---  ═══════════════════════════════════════════════════════════════════════════
---   Item Resolver - Lazy item name -> resource ID lookup
---  ═══════════════════════════════════════════════════════════════════════════
---   Looks names up in the session-wide item index (item_index.lua: one
---   walk over res.items per session, shared with the quiver manager and the
---   weapon resolver). Without an index, scanning all res.items for every
---   refill entry caused a multi-second freeze.
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
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from refill_manager.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local ItemResolver = {}

--- Resolve item name to resource ID via res.items.
--- @param item_name string The English item name (full or log form)
--- @return number|nil Item ID or nil if not found
function ItemResolver.resolve_item_id(item_name)
    -- Session-wide index (item_index.lua): one walk over the item list
    return require('shared/utils/equipment/item_index').id(item_name)
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
