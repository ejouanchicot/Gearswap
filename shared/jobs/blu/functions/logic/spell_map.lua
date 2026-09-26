---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Spell Map - Blue Magic spell -> gear category
---  ═══════════════════════════════════════════════════════════════════════════
---   Blue Magic gear follows what a spell scales with (STR, DEX, INT, magic
---   accuracy, skill...), not its name. The character's
---   config/blu/BLU_SPELL_MAP.lua lists, per category, the spells that wear
---   sets.midcast['Blue Magic'].<category>. Read once per load.
---
---   A spell listed under two categories keeps the first in alphabetical
---   order of category, and a warning names it: a Lua table has no order, so
---   without that rule the winner would change from one load to the next.
---
---   Unbridled spells (need Unbridled Learning or Wisdom) come from the
---   Blue Magic database (shared/data/magic/BLU_SPELL_DATABASE.lua).
---
---   @file    shared/jobs/blu/functions/logic/spell_map.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local BLUSpellMap = {}

local by_spell = nil
local blu_database = nil

--- Categories of the map, sorted: the order a duplicate is resolved in.
--- @param map table category -> list of spell names
--- @return table
local function sorted_categories(map)
    local categories = {}
    for category, spells in pairs(map) do
        if type(category) == 'string' and type(spells) == 'table' then
            categories[#categories + 1] = category
        end
    end
    table.sort(categories)
    return categories
end

--- Tell the player about spells listed twice (the first category is kept).
--- @param duplicates table List of "name (kept, dropped)" strings
local function warn_duplicates(duplicates)
    if #duplicates == 0 then return end
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then
        MessageFormatter.show_warning('BLU_SPELL_MAP: listed twice, first kept: ' .. table.concat(duplicates, ', '))
    end
end

--- Build spell -> category from the character's map.
local function build()
    by_spell = {}
    local ok, map = pcall(require, 'config/blu/BLU_SPELL_MAP')
    if not ok or type(map) ~= 'table' then
        local mf_ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if mf_ok and MessageFormatter then
            MessageFormatter.show_warning('BLU: config/blu/BLU_SPELL_MAP.lua not loaded, Blue Magic uses its base set')
        end
        return
    end
    local duplicates = {}
    for _, category in ipairs(sorted_categories(map)) do
        for _, name in ipairs(map[category]) do
            local kept = by_spell[name]
            if kept then
                duplicates[#duplicates + 1] = ('%s (%s, not %s)'):format(name, kept, category)
            else
                by_spell[name] = category
            end
        end
    end
    warn_duplicates(duplicates)
end

--- Gear category of a Blue Magic spell.
--- @param spell_name string English spell name
--- @return string|nil Category ('PhysicalDex', 'Magical', ...), nil when unlisted
function BLUSpellMap.category(spell_name)
    if not by_spell then build() end
    return spell_name and by_spell[spell_name] or nil
end

--- Whether a spell needs Unbridled Learning (or Wisdom) to be cast.
--- @param spell_name string English spell name
--- @return boolean
function BLUSpellMap.is_unbridled(spell_name)
    if blu_database == nil then
        local ok, db = pcall(require, 'shared/data/magic/BLU_SPELL_DATABASE')
        blu_database = ok and db or false
    end
    if not blu_database or not spell_name then return false end
    local data = blu_database.get_spell_data(spell_name)
    return data ~= nil and data.unbridled == true
end

return BLUSpellMap
