---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Spell Map - Blue Magic spell -> gear category
---  ═══════════════════════════════════════════════════════════════════════════
---   Blue Magic gear follows what a spell scales with (STR, DEX, INT, magic
---   accuracy, skill...), not its name. The character's
---   blu/combat/BLU_SPELL_MAP.lua lists, per category, the spells that wear
---   sets.midcast['Blue Magic'].<category>. Read once per load.
---
---   A spell listed under two categories keeps the first in alphabetical
---   order of category, and a warning names it: a Lua table has no order, so
---   without that rule the winner would change from one load to the next.
---
---   A spell the map does not list takes the broad category of the Blue
---   Magic database (shared/data/magic/BLU_SPELL_DATABASE.lua): Physical,
---   Magical, Buff, Breath, Healing, and Debuff as MagicAccuracy. The map
---   stays the source for the stat (PhysicalStr, MagicalMnd...), which the
---   database does not hold. The database also says which spells need
---   Unbridled Learning or Wisdom.
---
---   @file    shared/jobs/blu/functions/logic/spell_map.lua
---   @author  ejouanchicot
---   @version 1.1
---   @date    Created: 2026-09-26 | Updated: 2026-09-27
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
    local ok, map = require('shared/utils/core/char_paths').load('job', 'BLU_SPELL_MAP', 'BLU')
    if not ok or type(map) ~= 'table' then
        -- said to a BLU only: the Atelier export reads this map on every job (shared/utils/atelier/
        -- atelier_families.lua), and a character who plays no BLU has none
        local mf_ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if mf_ok and MessageFormatter and player and player.main_job == 'BLU' then
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

-- Database categories that are not map category names
local DATABASE_CATEGORY = {
    Debuff = 'MagicAccuracy',
}

--- The database entry of a spell, or nil (database loaded once).
--- @param spell_name string English spell name
--- @return table|nil
local function database_entry(spell_name)
    if blu_database == nil then
        local ok, db = pcall(require, 'shared/data/magic/BLU_SPELL_DATABASE')
        blu_database = ok and db or false
    end
    if not blu_database or not spell_name then return nil end
    return blu_database.get_spell_data(spell_name)
end

--- Gear category of a Blue Magic spell: the map's, else the database's.
--- @param spell_name string English spell name
--- @return string|nil Category ('PhysicalDex', 'Magical', ...), nil when unknown
function BLUSpellMap.category(spell_name)
    if not by_spell then build() end
    if not spell_name then return nil end
    if by_spell[spell_name] then return by_spell[spell_name] end
    local data = database_entry(spell_name)
    local category = data and data.category
    return category and (DATABASE_CATEGORY[category] or category) or nil
end

--- Whether a spell needs Unbridled Learning (or Wisdom) to be cast.
--- @param spell_name string English spell name
--- @return boolean
function BLUSpellMap.is_unbridled(spell_name)
    local data = database_entry(spell_name)
    return data ~= nil and data.unbridled == true
end

return BLUSpellMap
