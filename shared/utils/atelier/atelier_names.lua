---============================================================================
--- Atelier Names - the sets' pieces under the game's own item name
---============================================================================
--- A set file may write an item's long name ("Pummeler's Mask +4") or another
--- case, which GearSwap accepts; the bags hold the short one ("Pumm. Mask +4"),
--- and the Atelier page tells the pieces you have by name. The export
--- (shared/utils/atelier/atelier_export.lua) gives each piece the game's name.
---
--- @file    shared/utils/atelier/atelier_names.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-03
---============================================================================

local AtelierNames = {}

--- Rename the pieces of every set to the game's item name (res.items .en).
--- @param set_list table The export's sets ({pieces = {slot = {name = ...}}})
--- @param icons table|nil Name as written -> item id (the export's collect_icons)
function AtelierNames.use_game_names(set_list, icons)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.items and icons) then return end
    for _, set in ipairs(set_list) do
        for _, p in pairs(set.pieces) do
            local info = icons[p.name] and res.items[icons[p.name]]
            if info and info.en and info.en ~= p.name then
                icons[info.en] = icons[p.name]
                p.name = info.en
            end
        end
    end
end

return AtelierNames
