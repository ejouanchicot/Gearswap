---============================================================================
--- Auto Cure Settings - the shared defaults with the character's own choices
---============================================================================
--- shared/config/DEBUFF_AUTOCURE_CONFIG.lua holds the defaults (replaced by
--- every update). A character's _common/combat/AUTOCURE_CONFIG.lua overrides
--- them key by key: which debuffs are cured, with which items, the state
--- Auto Medicine starts in. An item may be given by name only
--- ('Echo Drops'); its id is looked up in the game data.
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
    paralysis_cure_items = { { name = 'Remedy', id = 4155 }, { name = 'Panacea', id = 4145 } },
    auto_cure_poison = false, auto_cure_blind = false, debug = false,
}

local ITEM_LISTS = { 'silence_cure_items', 'paralysis_cure_items' }

--- An item list with every entry as {name, id} (names looked up once).
local function normalise(list)
    local out = {}
    for _, entry in ipairs(type(list) == 'table' and list or {}) do
        local item = type(entry) == 'string' and { name = entry } or entry
        if type(item) == 'table' and type(item.name) == 'string' then
            if not item.id then
                local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
                local found = ok and res and res.items and res.items:with('en', item.name)
                item = { name = item.name, id = found and found.id }
            end
            if item.id then out[#out + 1] = item end
        end
    end
    return out
end

--- The settings: shared defaults, the character's file over them.
--- @return table
function AutoCureSettings.load()
    local ok, base = pcall(require, 'shared/config/DEBUFF_AUTOCURE_CONFIG')
    base = (ok and type(base) == 'table') and base or FALLBACK
    local ok_u, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'AUTOCURE_CONFIG')
    end)
    local merged = {}
    for k, v in pairs(base) do merged[k] = v end
    for k, v in pairs((ok_u and type(user) == 'table') and user or {}) do merged[k] = v end
    for _, key in ipairs(ITEM_LISTS) do merged[key] = normalise(merged[key]) end
    return merged
end

return AutoCureSettings
