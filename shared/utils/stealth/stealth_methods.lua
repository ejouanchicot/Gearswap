---============================================================================
--- Stealth Methods - which ways this character has to get Sneak / Invisible
---============================================================================
--- Everything is read from the game at the moment of the key press:
---   Spectral Jig  in the job abilities of the current jobs, recast ready
---   spells        learned, main or sub level high enough, MP, recast ready
---   ninjutsu      same, plus a tool in the inventory
---   items         in the inventory
---
--- Ninja tools (BG-Wiki): Monomi: Ichi uses Sanjaku-Tenugui, Tonko: Ichi / Ni
--- use Shinobi-Tabi; Shikanofuda covers both.
---
--- @file shared/utils/stealth/stealth_methods.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local StealthMethods = {}

local SPECTRAL_JIG = 196          -- res.job_abilities id
local SPECTRAL_JIG_RECAST = 218   -- recast_id

--- Per buff: spell, ninjutsu (best first) and items (in order of use).
--- An item with `both` gives Sneak and Invisible.
StealthMethods.BY_BUFF = {
    sneak = {
        buff = 'Sneak',
        spell = 'Sneak',
        ninjutsu = {'Monomi: Ichi'},
        items = {{name = 'Silent Oil'}, {name = 'Evanessence', both = true}},
    },
    invi = {
        buff = 'Invisible',
        spell = 'Invisible',
        ninjutsu = {'Tonko: Ni', 'Tonko: Ichi'},
        items = {{name = 'Prism Powder'}, {name = 'Evanessence', both = true}},
    },
}

-- The few spells and items this module needs, copied from res/spells.lua and
-- res/items.lua: looking them up by name walked the whole game lists (976
-- spells, 23 555 items) several times per key press, and could load the
-- item list on the first one.
local SPELLS = {
    ['Sneak']        = {id = 137, mp = 12, cast = 3,   levels = {[3] = 20, [5] = 20, [20] = 20}},
    ['Invisible']    = {id = 136, mp = 15, cast = 3,   levels = {[3] = 25, [5] = 25, [20] = 25}},
    ['Monomi: Ichi'] = {id = 318, mp = 0,  cast = 1.5, levels = {[13] = 25}},
    ['Tonko: Ichi']  = {id = 353, mp = 0,  cast = 1.5, levels = {[13] = 9}},
    ['Tonko: Ni']    = {id = 354, mp = 0,  cast = 1.5, levels = {[13] = 34}},
}
local ITEMS = {
    ['Silent Oil'] = 4165, ['Prism Powder'] = 4164, ['Evanessence'] = 6699,
    ['Sanjaku-Tenugui'] = 2553, ['Shinobi-Tabi'] = 1194, ['Shikanofuda'] = 2972,
}
local ITEM_CAST = 1   -- the three items' cast time

local TOOLS = {
    ['Monomi: Ichi'] = {'Sanjaku-Tenugui', 'Shikanofuda'},
    ['Tonko: Ichi'] = {'Shinobi-Tabi', 'Shikanofuda'},
    ['Tonko: Ni'] = {'Shinobi-Tabi', 'Shikanofuda'},
}

--- Item counts of the inventory, read once and kept for a second: one key
--- press checks several items and tools.
local bag_cache = {time = -1, counts = {}}

local function counts()
    if os.clock() - bag_cache.time < 1 then return bag_cache.counts end
    local wanted = {}
    for _, id in pairs(ITEMS) do wanted[id] = true end
    local found = {}
    for _, slot in ipairs(windower.ffxi.get_items(0) or {}) do
        if type(slot) == 'table' and wanted[slot.id] then
            found[slot.id] = (found[slot.id] or 0) + (slot.count or 0)
        end
    end
    bag_cache.time, bag_cache.counts = os.clock(), found
    return found
end

--- Count of an item in the inventory (bag 0: items are used from there).
--- @param name string One of the items above
--- @return number
function StealthMethods.item_count(name)
    local id = ITEMS[name]
    return id and counts()[id] or 0
end

--- Cast time of one of the spells or items above, in seconds.
--- @param name string
--- @return number
function StealthMethods.cast_time(name)
    local spell = SPELLS[name]
    if spell then return spell.cast end
    return ITEMS[name] and ITEM_CAST or 0
end

--- Whether a job of this character reaches the spell's level.
local function level_ok(spell, p)
    local main = spell.levels[p.main_job_id]
    local sub = p.sub_job_id and spell.levels[p.sub_job_id]
    return (main ~= nil and main <= (p.main_job_level or 0))
        or (sub ~= nil and sub <= (p.sub_job_level or 0))
end

--- Whether this character can cast `name` now (learned, level, MP, recast,
--- ninja tool).
--- @param name string Spell or ninjutsu name
--- @return boolean
function StealthMethods.can_cast(name)
    local spell = SPELLS[name]
    local p = windower.ffxi.get_player()
    if not (spell and p) then return false end
    local learned = windower.ffxi.get_spells() or {}
    if not learned[spell.id] or not level_ok(spell, p) then return false end
    if spell.mp > ((p.vitals and p.vitals.mp) or 0) then return false end
    local recasts = windower.ffxi.get_spell_recasts() or {}
    if (recasts[spell.id] or 0) > 0 then return false end
    if not TOOLS[name] then return true end
    for _, tool in ipairs(TOOLS[name]) do
        if StealthMethods.item_count(tool) > 0 then return true end
    end
    return false
end

--- Whether Spectral Jig can be used now.
--- @return boolean
function StealthMethods.can_jig()
    local abilities = windower.ffxi.get_abilities() or {}
    local known = false
    for _, id in ipairs(abilities.job_abilities or {}) do
        if id == SPECTRAL_JIG then known = true break end
    end
    if not known then return false end
    local recasts = windower.ffxi.get_ability_recasts() or {}
    return (recasts[SPECTRAL_JIG_RECAST] or 0) == 0
end

--- This character's own best way for `kind` after Spectral Jig: its spell,
--- then ninjutsu, then items. Used by the key and by //gs c stealth check,
--- so the check shows what the key will do.
--- @param kind string 'sneak' or 'invi'
--- @return table|nil {how = 'ma'|'item', name, both}, nil when it has none
function StealthMethods.best_own(kind)
    local method = StealthMethods.BY_BUFF[kind]
    if StealthMethods.can_cast(method.spell) then return {how = 'ma', name = method.spell} end
    for _, spell in ipairs(method.ninjutsu) do
        if StealthMethods.can_cast(spell) then return {how = 'ma', name = spell} end
    end
    for _, item in ipairs(method.items) do
        if StealthMethods.item_count(item.name) > 0 then
            return {how = 'item', name = item.name, both = item.both}
        end
    end
    return nil
end

--- Whether this character knows the spell for `kind` at all (level and
--- learned), whatever its MP or recast: decides who answers a partner.
--- @param kind string 'sneak' or 'invi'
--- @return boolean
function StealthMethods.has_spell(kind)
    local spell = SPELLS[StealthMethods.BY_BUFF[kind].spell]
    local p = windower.ffxi.get_player()
    local learned = windower.ffxi.get_spells() or {}
    return p ~= nil and learned[spell.id] == true and level_ok(spell, p)
end

return StealthMethods
