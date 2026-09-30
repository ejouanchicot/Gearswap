---============================================================================
--- Cleanse Methods - the debuffs on this character and what can take them off
---============================================================================
--- Everything is read from the game at the moment of the key press:
---   debuffs   the buff ids on the character (not buffactive, which lags
---             inside a scheduled function), matched against
---             shared/data/debuffs/DEBUFF_REMOVAL.lua
---   spells    learned, main or sub level, MP, recast, not silenced; a
---             Scholar needs Addendum: White up
---   items     in the inventory (items are used from there)
--- Settings: shared defaults, the character's _common/combat/CLEANSE_CONFIG.lua
--- over them (order, items, spells on / off, partner, Doom tries).
---
--- @file shared/utils/debuff/cleanse_methods.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local CleanseMethods = {}

local DEFAULTS = {
    use_spells = true,
    ask_partner = true,
    partner_wait = 5,
    doom_tries = 5,
    skip = {},
    first = {},
    items = {},
}

-- The spells this module casts, from res/spells.lua (ids, MP, cast time,
-- level per job id: 3 WHM, 5 RDM, 7 PLD, 20 SCH).
local SPELLS = {
    ['Poisona']  = {id = 14,  mp = 8,  cast = 1,   levels = {[3] = 6,  [20] = 10}},
    ['Paralyna'] = {id = 15,  mp = 12, cast = 1,   levels = {[3] = 9,  [20] = 12}},
    ['Blindna']  = {id = 16,  mp = 16, cast = 1,   levels = {[3] = 14, [20] = 17}},
    ['Silena']   = {id = 17,  mp = 24, cast = 1,   levels = {[3] = 19, [20] = 22}},
    ['Stona']    = {id = 18,  mp = 40, cast = 1,   levels = {[3] = 39, [20] = 50}},
    ['Viruna']   = {id = 19,  mp = 48, cast = 1,   levels = {[3] = 34, [20] = 46}},
    ['Cursna']   = {id = 20,  mp = 30, cast = 1,   levels = {[3] = 29, [20] = 32}},
    ['Erase']    = {id = 143, mp = 18, cast = 2.5, levels = {[3] = 32, [20] = 39}},
    ['Cure']     = {id = 1,   mp = 8,  cast = 2,   levels = {[3] = 1,  [5] = 3, [7] = 5, [20] = 5}},
}
CleanseMethods.SPELLS = SPELLS

-- Item ids from res/items.lua; any other item named in the settings is
-- looked up in the game data once.
local ITEM_IDS = {
    ['Echo Drops'] = 4151, ['Remedy'] = 4155, ['Eye Drops'] = 4150,
    ['Antidote'] = 4148, ['Holy Water'] = 4154, ['Panacea'] = 4149,
}
local ITEM_CAST = 1

local SCH = 20
local ADDENDUM_WHITE = 401
-- Silence, Mute, Omerta: no spell at all
local NO_SPELLS = {[6] = true, [29] = true, [262] = true}

---============================================================================
--- SETTINGS
---============================================================================

--- Shared defaults with the character's CLEANSE_CONFIG.lua over them.
--- @return table
function CleanseMethods.settings()
    local ok, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'CLEANSE_CONFIG')
    end)
    local merged = {}
    for k, v in pairs(DEFAULTS) do merged[k] = v end
    for k, v in pairs((ok and type(user) == 'table') and user or {}) do merged[k] = v end
    return merged
end

--- The debuff list in the order of removal: `first` in front, `skip` out.
--- @param settings table
--- @return table list of DEBUFF_REMOVAL entries
local function ordered(settings)
    local all = require('shared/data/debuffs/DEBUFF_REMOVAL')
    local skip, by_key, out, placed = {}, {}, {}, {}
    for _, key in ipairs(settings.skip or {}) do skip[key] = true end
    for _, entry in ipairs(all) do by_key[entry.key] = entry end
    for _, key in ipairs(settings.first or {}) do
        if by_key[key] and not skip[key] and not placed[key] then
            out[#out + 1] = by_key[key]; placed[key] = true
        end
    end
    for _, entry in ipairs(all) do
        if not skip[entry.key] and not placed[entry.key] then out[#out + 1] = entry end
    end
    return out
end

--- The items for a debuff: the settings' list for it (or `erasable` for
--- the Erase ones), else the default.
--- @param entry table DEBUFF_REMOVAL entry
--- @param settings table
--- @return table names
function CleanseMethods.items_for(entry, settings)
    local items = settings.items or {}
    if type(items[entry.key]) == 'table' then return items[entry.key] end
    if entry.spell == 'Erase' and type(items.erasable) == 'table' then return items.erasable end
    return entry.items or {}
end

---============================================================================
--- WHAT IS ON THIS CHARACTER
---============================================================================

local function buff_ids()
    local me = windower.ffxi.get_player()
    local ids = {}
    for _, id in ipairs(me and me.buffs or {}) do ids[id] = true end
    return ids
end

--- Whether one of the debuff's ids is on the character now.
--- @param entry table
--- @return boolean
function CleanseMethods.is_up(entry)
    local ids = buff_ids()
    for _, id in ipairs(entry.ids) do
        if ids[id] then return true end
    end
    return false
end

--- The debuffs on this character, in the order of removal.
--- @param settings table
--- @return table list of DEBUFF_REMOVAL entries
function CleanseMethods.active(settings)
    local ids = buff_ids()
    local out = {}
    for _, entry in ipairs(ordered(settings)) do
        for _, id in ipairs(entry.ids) do
            if ids[id] then out[#out + 1] = entry; break end
        end
    end
    return out
end

---============================================================================
--- ITEMS
---============================================================================

local function item_id(name)
    if ITEM_IDS[name] then return ITEM_IDS[name] end
    local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
    local found = ok and res and res.items and res.items:with('en', name)
    ITEM_IDS[name] = found and found.id or false
    return ITEM_IDS[name]
end

--- Count of an item in the inventory.
--- @param name string
--- @return number
function CleanseMethods.item_count(name)
    local id = item_id(name)
    if not id then return 0 end
    local total = 0
    for _, slot in ipairs(windower.ffxi.get_items(0) or {}) do
        if type(slot) == 'table' and slot.id == id then total = total + (slot.count or 0) end
    end
    return total
end

--- The first item of the list this character has.
--- @param names table
--- @return table|nil {name, id}
function CleanseMethods.first_item(names)
    for _, name in ipairs(names or {}) do
        if CleanseMethods.item_count(name) > 0 then return {name = name, id = item_id(name)} end
    end
    return nil
end

--- Seconds an item or a spell takes.
--- @param name string
--- @return number
function CleanseMethods.cast_time(name)
    return SPELLS[name] and SPELLS[name].cast or ITEM_CAST
end

---============================================================================
--- SPELLS
---============================================================================

--- The job that reaches the spell's level (main first), or nil.
local function job_for(spell, p)
    local main = spell.levels[p.main_job_id]
    if main and main <= (p.main_job_level or 0) then return p.main_job_id end
    local sub = p.sub_job_id and spell.levels[p.sub_job_id]
    if sub and sub <= (p.sub_job_level or 0) then return p.sub_job_id end
    return nil
end

--- Whether this character can cast `name` now.
--- @param name string
--- @return boolean
function CleanseMethods.can_cast(name)
    local spell = SPELLS[name]
    local p = windower.ffxi.get_player()
    if not (spell and p) then return false end
    local job = job_for(spell, p)
    if not job then return false end
    local learned = windower.ffxi.get_spells() or {}
    if not learned[spell.id] then return false end
    if spell.mp > ((p.vitals and p.vitals.mp) or 0) then return false end
    local recasts = windower.ffxi.get_spell_recasts() or {}
    if (recasts[spell.id] or 0) > 0 then return false end
    local ids = buff_ids()
    for id in pairs(NO_SPELLS) do
        if ids[id] then return false end
    end
    -- A Scholar's -na spells and Erase need Addendum: White
    if job == SCH and name ~= 'Cure' and not ids[ADDENDUM_WHITE] then return false end
    return true
end

--- Whether a partner with these jobs may have the spell (its MP, recast
--- and Addendum are its own business: it answers only if it can).
--- @param spell_name string
--- @param job string|nil Main job (e.g. 'WHM')
--- @param subjob string|nil
--- @return boolean
function CleanseMethods.partner_may_cast(spell_name, job, subjob)
    local spell = SPELLS[spell_name]
    if not spell then return false end
    if not job then return true end
    local JOB_IDS = {WHM = 3, RDM = 5, PLD = 7, SCH = 20}
    if JOB_IDS[job] and spell.levels[JOB_IDS[job]] then return true end
    -- A subjob is level 49 or more at level 99
    local sub_level = subjob and JOB_IDS[subjob] and spell.levels[JOB_IDS[subjob]]
    return sub_level ~= nil and sub_level <= 49 and subjob ~= 'SCH'
end

return CleanseMethods
