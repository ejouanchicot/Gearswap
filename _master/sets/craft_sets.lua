---============================================================================
--- Craft Equipment Sets
---============================================================================
--- Read by //gs c craft when config/CRAFT_CONFIG.lua says
--- craft_file = 'craft'. To keep one file per craft, copy this one as
--- sets/<craft>_sets.lua (goldsmithing_sets.lua, woodworking_sets.lua...)
--- and name it in craft_file.
---
---   //gs c craft           -> default variant (hq)
---   //gs c craft nq        -> NQ variant
---   //gs c craft success   -> success-rate variant
---   //gs c craft wood      -> HQ with the Woodworking neck piece, for a
---                             recipe that also needs Woodworking skill
---                             (same for smith, gold, cloth, leather, bone,
---                             alchemy, cook: see SUB_CRAFTS)
---   //gs c uncraft         -> back to the job's gear
---
--- How to fill it: write the item name between the quotes, e.g.
---     body = "Item Name",
--- A slot left "" is not touched.
---   1. SHARED: the pieces worn for every variant (your craft's neck piece
---      goes in neck).
---   2. HQ / NQ / SUCCESS: the piece that makes the difference (usually the
---      ring).
---   3. SUB_CRAFTS: the neck piece of each other craft you use.
---   4. //gs c craft to test: the chat says how many slots were equipped.
---
--- @file    sets/craft_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

---============================================================================
--- PIECES WORN IN EVERY VARIANT
---============================================================================
local SHARED = {
    main      = "",
    sub       = "",
    head      = "",
    body      = "",
    hands     = "",
    neck      = "",
    waist     = "",
    left_ring = "",
}

--- The pieces of the three main variants
local HQ      = { right_ring = "" }
local NQ      = { right_ring = "" }
local SUCCESS = { right_ring = "" }

--- One variant per sub-craft: HQ, with that craft's neck piece. Remove the
--- line of your own craft if you like; an empty neck keeps SHARED's.
local SUB_CRAFTS = {
    { key = 'wood',    name = 'Woodworking',  aliases = { 'woodworking', 'carpenter' },  neck = "" },
    { key = 'smith',   name = 'Smithing',     aliases = { 'smithing', 'blacksmith' },    neck = "" },
    { key = 'gold',    name = 'Goldsmithing', aliases = { 'goldsmithing', 'goldsmith' }, neck = "" },
    { key = 'cloth',   name = 'Clothcraft',   aliases = { 'clothcraft', 'weaver' },      neck = "" },
    { key = 'leather', name = 'Leathercraft', aliases = { 'leathercraft', 'tanner' },    neck = "" },
    { key = 'bone',    name = 'Bonecraft',    aliases = { 'bonecraft', 'boneworker' },   neck = "" },
    { key = 'alchemy', name = 'Alchemy',      aliases = { 'alch', 'alchemist' },         neck = "" },
    { key = 'cook',    name = 'Cooking',      aliases = { 'cooking', 'culinarian' },     neck = "" },
}

--- Merge pieces left to right, skipping the slots left "".
--- @return table Gear set
local function set_with(...)
    local set = {}
    for _, pieces in ipairs({...}) do
        for slot, item in pairs(pieces) do
            if item ~= "" then set[slot] = item end
        end
    end
    return set
end

---============================================================================
--- VARIANTS
---============================================================================

local variants = {
    hq      = { description = 'Craft HQ',      aliases = { 'hq' },      gear = set_with(SHARED, HQ) },
    nq      = { description = 'Craft NQ',      aliases = { 'nq' },      gear = set_with(SHARED, NQ) },
    success = { description = 'Craft Success', aliases = { 'success' }, gear = set_with(SHARED, SUCCESS) },
}

for _, craft in ipairs(SUB_CRAFTS) do
    variants[craft.key] = {
        description = 'Craft HQ - ' .. craft.name .. ' sub',
        aliases     = craft.aliases,
        gear        = set_with(SHARED, HQ, { neck = craft.neck }),
    }
end

return {
    -- Variant used by //gs c craft with no word after it
    default  = 'hq',
    variants = variants,
}
