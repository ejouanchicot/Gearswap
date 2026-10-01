---============================================================================
--- Fishing Equipment Set
---============================================================================
--- Read by //gs c fish when _common/inventory/CRAFT_CONFIG.lua says
--- fish_file = 'fishing' (the default).
---
---   //gs c fish      -> equip this set (slots locked while you fish)
---   //gs c uncraft   -> back to the job's gear
---
--- How to fill it: write the item name between the quotes, e.g.
---     range = "Item Name",
--- A slot left "" is not touched.
---
--- @file    _common/sets/fishing_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

return {
    description = 'Fishing',
    gear = {
        range      = "",
        ammo       = "",
        head       = "",
        body       = "",
        hands      = "",
        legs       = "",
        feet       = "",
        neck       = "",
        waist      = "",
        left_ear   = "",
        right_ear  = "",
        left_ring  = "",
        right_ring = "",
        back       = "",
    },
}
