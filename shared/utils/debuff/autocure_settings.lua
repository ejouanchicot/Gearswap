---============================================================================
--- Auto Cure Settings - the shared defaults with the character's own choices
---============================================================================
--- shared/config/DEBUFF_AUTOCURE_CONFIG.lua holds the defaults (replaced by
--- every update). A character's _common/combat/AUTO_MEDICINE_CONFIG.lua overrides
--- them key by key: which debuffs are cured, the state Auto Medicine starts
--- in. The items come from one place for Auto Medicine and //gs c cleanse:
--- the `items` of _common/combat/CLEANSE_CONFIG.lua (silence, paralysis),
--- else the defaults of shared/data/debuffs/DEBUFF_REMOVAL.lua. An item is
--- its name; its id is looked up in the game data.
---
--- @file shared/utils/debuff/autocure_settings.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local AutoCureSettings = {}

--- Used when the shared file cannot be read.
local FALLBACK = {
    test_mode = false, test_debuff = 'Berserk',
    auto_cure_silence = true, auto_cure_paralysis = true,
    silence_cure_items = { { name = 'Echo Drops', id = 4151 }, { name = 'Remedy', id = 4155 } },
    paralysis_cure_items = { { name = 'Remedy', id = 4155 } },
    auto_cure_poison = false, auto_cure_blind = false, debug = false,
}

local ITEM_LISTS = { 'silence_cure_items', 'paralysis_cure_items' }

--- Ids of the items the shared lists already name, by lowercase name: a
--- default item given by name never depends on the game data.
--- @param base table Shared settings
--- @return table
local function known_ids(base)
    local ids = {}
    for _, src in ipairs({ base, FALLBACK }) do
        for _, key in ipairs(ITEM_LISTS) do
            for _, item in ipairs(type(src[key]) == 'table' and src[key] or {}) do
                if type(item) == 'table' and item.name and item.id then ids[item.name:lower()] = item.id end
            end
        end
    end
    return ids
end

--- An item list with every entry as {name, id} (names looked up once).
local function normalise(list, ids)
    local out = {}
    for _, entry in ipairs(type(list) == 'table' and list or {}) do
        local item = type(entry) == 'string' and { name = entry } or entry
        if type(item) == 'table' and type(item.name) == 'string' then
            if not item.id then
                local id = ids[item.name:lower()]
                if not id then
                    local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
                    local found = ok and res and res.items and res.items:with('en', item.name)
                    id = found and found.id
                end
                item = { name = item.name, id = id }
            end
            if item.id then out[#out + 1] = item end
        end
    end
    return out
end

--- The items of a debuff from CLEANSE_CONFIG.lua / DEBUFF_REMOVAL.lua, or
--- nil when they cannot be read (the shared defaults stay then).
--- @param key string 'silence' or 'paralysis'
--- @return table|nil names
local function cleanse_items(key)
    local ok, names = pcall(function()
        local Methods = require('shared/utils/debuff/cleanse_methods')
        for _, entry in ipairs(require('shared/data/debuffs/DEBUFF_REMOVAL')) do
            if entry.key == key then return Methods.items_for(entry, Methods.settings()) end
        end
    end)
    return (ok and type(names) == 'table') and names or nil
end

local CLEANSE_KEYS = { silence_cure_items = 'silence', paralysis_cure_items = 'paralysis' }

--- The settings: shared defaults, the character's file over them, the items
--- from CLEANSE_CONFIG.lua.
--- @return table
function AutoCureSettings.load()
    local ok, base = pcall(require, 'shared/config/DEBUFF_AUTOCURE_CONFIG')
    base = (ok and type(base) == 'table') and base or FALLBACK
    local ok_u, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'AUTO_MEDICINE_CONFIG')
    end)
    local merged = {}
    for k, v in pairs(base) do merged[k] = v end
    for k, v in pairs((ok_u and type(user) == 'table') and user or {}) do merged[k] = v end
    for list_key, debuff in pairs(CLEANSE_KEYS) do
        merged[list_key] = cleanse_items(debuff) or merged[list_key]
    end
    local ids = known_ids(base)
    for _, key in ipairs(ITEM_LISTS) do merged[key] = normalise(merged[key], ids) end
    return merged
end

return AutoCureSettings
