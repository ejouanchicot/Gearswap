---============================================================================
--- Cast Time - how long a spell will take with the precast set equipped
---============================================================================
--- Read from the gear itself: each piece's game description and the
--- augments written in the sets ('"Fast Cast"+5', 'Song spellcasting time
--- -10%'...), summed per spell. Rules (BG-Wiki, Fast Cast, Song
--- Spellcasting Time, Nightingale, Troubadour):
---   Fast Cast + casting time reductions of the spell's kind (song, cure,
---   elemental magic... or all spells) add up, capped at 80 %;
---   Red Mage Fast Cast trait: 10-30 % by level (job points not counted:
---   the estimate stays on the long side);
---   songs: x0.5 under Nightingale, x1.5 under Troubadour;
---   Celerity / Alacrity halve the next white / black magic.
--- Haste and Marches shorten the recast, never the cast.
--- Not counted: set bonuses, latent effects, "Quick Magic" procs.
---
--- Only pieces this character owns count: GearSwap skips the others and the
--- slot keeps what it wore.
---
--- CastTime.install_hook() (INIT_SYSTEMS) records the estimate of every
--- spell at the end of its precast in _G._precast_cast_time, for the
--- midcast watchdog and the BRD song queue.
---
--- @file    shared/utils/precast/cast_time.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local CastTime = {}

local CAP = 80
local RDM_TRAIT = {{89, 30}, {76, 25}, {55, 20}, {35, 15}, {15, 10}}
local SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear',
    'body', 'hands', 'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}

local res = nil
local by_name = nil

local function resources()
    if not res then
        local ok, r = pcall(require, 'resources')
        res = ok and r or {}
    end
    return res
end

--- Item id from its name (short or long), built once.
local function item_id(name)
    if not by_name then
        by_name = {}
        for id, item in pairs(resources().items or {}) do
            if item.en then by_name[item.en:lower()] = id end
            if item.enl then by_name[item.enl:lower()] = id end
        end
    end
    return by_name[name:lower()]
end

--- Does a "<subject> casting time -N%" apply to this spell? An empty subject
--- ("Spellcasting time -N%") means every spell.
--- @param subject string Lower-cased words just before "casting time"
--- @param spell table
local function applies(subject, spell)
    local name = (spell.english or ''):lower()
    local skill = (spell.skill or ''):lower()
    if subject:find('arts') then return false end
    if subject:find('grimoire') then
        -- Scholar's books: only the magic of the Arts that is up
        -- (Addendum hides Light/Dark Arts in buffactive)
        local light = buffactive['Light Arts'] or buffactive['Addendum: White']
        local dark = buffactive['Dark Arts'] or buffactive['Addendum: Black']
        return (light and spell.type == 'WhiteMagic') or (dark and spell.type == 'BlackMagic') or false
    end
    if subject:find('song') then return skill == 'singing' end
    if subject:find('cure') then return name:find('^cur') ~= nil end
    if subject:find('utsusemi') then return name:find('^utsusemi') ~= nil end
    if subject:find('stoneskin') then return name == 'stoneskin' end
    for _, kind in ipairs({'elemental', 'healing', 'enhancing', 'enfeebling', 'dark', 'divine', 'blue'}) do
        if subject:find(kind) then return skill:find('^' .. kind) ~= nil end
    end
    return subject:gsub('[%s"]', '') == ''
end

--- Fast Cast and casting time reductions in one text, in percent.
--- @param text string Description or augment
--- @param spell table
--- @return number
local function reduction_in(text, spell)
    local total = 0
    local lower = text:gsub('[Ss]et:.*', ''):lower()
    for fc in lower:gmatch('"fast cast"%s*%+%s*(%d+)') do total = total + tonumber(fc) end
    for pos, value in lower:gmatch('()casting time %-(%d+)%%') do
        local before = lower:sub(math.max(1, pos - 30), pos - 1):gsub('spell ?$', '')
        local subject = before:match('([%a":, ]*)$') or ''
        if applies(subject, spell) then total = total + tonumber(value) end
    end
    return total
end

--- Percent from one piece: its description plus its augments.
local function piece_reduction(piece, spell)
    local name = type(piece) == 'table' and piece.name or piece
    if type(name) ~= 'string' or name == '' or name == 'empty' then return 0 end
    local total = 0
    local id = item_id(name)
    local desc = id and resources().item_descriptions and resources().item_descriptions[id]
    if desc and desc.en then total = total + reduction_in(desc.en, spell) end
    if type(piece) == 'table' and type(piece.augments) == 'table' then
        for _, augment in ipairs(piece.augments) do total = total + reduction_in(augment, spell) end
    end
    return total
end

local function rdm_trait()
    local level = 0
    if player and player.main_job == 'RDM' then level = player.main_job_level or 0
    elseif player and player.sub_job == 'RDM' then level = player.sub_job_level or 0 end
    for _, step in ipairs(RDM_TRAIT) do
        if level >= step[1] then return step[2] end
    end
    return 0
end

--- Cast time of `spell` in `gear`.
--- @param spell table GearSwap spell (cast_time, skill, type, english)
--- @param gear table slot -> item name or {name, augments}
--- @return number seconds, number percent (reduction applied, capped)
function CastTime.estimate(spell, gear)
    local base = spell.cast_time or 0
    local percent = rdm_trait()
    for _, slot in ipairs(SLOTS) do
        if gear[slot] then percent = percent + piece_reduction(gear[slot], spell) end
    end
    percent = math.min(percent, CAP)
    local seconds = base * (1 - percent / 100)
    if spell.skill == 'Singing' then
        if buffactive['Nightingale'] then seconds = seconds * 0.5 end
        if buffactive['Troubadour'] then seconds = seconds * 1.5 end
    end
    if (buffactive['Celerity'] and spell.type == 'WhiteMagic')
        or (buffactive['Alacrity'] and spell.type == 'BlackMagic') then
        seconds = seconds * 0.5
    end
    return seconds, percent
end

-- Bags GearSwap equips from: inventory, wardrobes 1-8
local EQUIP_BAGS = {0, 8, 10, 11, 12, 13, 14, 15, 16}
local OWNED_TTL = 30

--- Item ids in the bags gear can be equipped from, re-read at most every
--- OWNED_TTL seconds.
local function owned()
    local cache = rawget(_G, '_cast_time_owned')
    if cache and os.clock() - cache.at < OWNED_TTL then return cache.ids end
    local ids = {}
    for _, bag in ipairs(EQUIP_BAGS) do
        local items = windower.ffxi.get_items(bag)
        for _, item in ipairs(items or {}) do
            if type(item) == 'table' and item.id and item.id > 0 then ids[item.id] = true end
        end
    end
    _G._cast_time_owned = {at = os.clock(), ids = ids}
    return ids
end

--- Item ids this character can equip from its bags (cached OWNED_TTL s).
--- @return table Set of item ids
function CastTime.owned_ids()
    return owned()
end

--- What the precast leaves on: the worn gear, with this precast's equips over
--- it where the piece is owned. GearSwap skips a piece that is not in the
--- bags, and the slot keeps what it wore.
local function precast_gear()
    local gear = {}
    for slot, name in pairs(player and player.equipment or {}) do gear[slot] = name end
    local have = owned()
    for slot, piece in pairs(gearswap and gearswap.equip_list or {}) do
        local name = type(piece) == 'table' and piece.name or piece
        local id = type(name) == 'string' and item_id(name)
        if id and have[id] then gear[slot] = piece end
    end
    return gear
end

--- Wrap cleanup_precast once per load: every spell's estimate goes to
--- _G._precast_cast_time. Called from INIT_SYSTEMS, after Mote.
function CastTime.install_hook()
    local orig = rawget(_G, 'cleanup_precast')
    if not orig or rawget(_G, '_cast_time_hook') == orig then return end
    local hook = function(spell, spellMap, eventArgs)
        orig(spell, spellMap, eventArgs)
        if spell and spell.action_type == 'Magic' and not (eventArgs and eventArgs.cancel) then
            local ok, seconds, percent = pcall(CastTime.estimate, spell, precast_gear())
            if ok then
                _G._precast_cast_time = {id = spell.id, name = spell.english, seconds = seconds, percent = percent}
            end
        end
    end
    _G.cleanup_precast = hook
    _G._cast_time_hook = hook
end

return CastTime
