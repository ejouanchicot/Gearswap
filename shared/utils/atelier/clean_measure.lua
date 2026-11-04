---============================================================================
--- Clean Measure - the character's stats as measured without boosts
---============================================================================
--- The Atelier's export takes the stats the game sends (collect_char, through measured_char, in
--- atelier_export_char.lua) and the page computes every set from them. Measured
--- under buffs that change them and that the page does not take out (Abyssea's
--- Atmas, its Max HP / MP and STR to CHR boosts, Weakness), every set showed
--- ~6000 HP (Tetsouo PLD/RUN in Abyssea, 2026-11-02). Abyssea is told by
--- Visitant or an Atma: its STR to CHR boosts share their buff ids (119-125)
--- with RDM's Gain- and WHM's Boost- spells, which must not freeze the measure.
---
--- The last measure taken without them is kept for each job / subjob / level in
--- <Char>/saved/clean_measure.lua and given in place of a boosted one: its
--- stats, max HP / MP, Attack, Defense and the gear and buffs up then. The rest
--- of the measure (merits, skills, levels) stays the current one, and the gear
--- worn now goes as worn_now (the page's "set from what I wear"). With no clean
--- measure kept yet, the boosted one goes as it is.
---
--- @file    shared/utils/atelier/clean_measure.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-03
---============================================================================

local CleanMeasure = {}

local FILE = 'clean_measure.lua'

-- Weakness, Visitant, Atma (res/buffs.lua)
local BOOSTS = {[1] = true, [285] = true, [287] = true}

-- the fields of a measure these buffs change
local STAT_FIELDS = {'at', 'max_hp', 'max_mp', 'attack', 'defense', 'base', 'add', 'worn', 'buffs'}

local function file_path()
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    return ok and CharPaths.writable and CharPaths.writable('saved', FILE) or nil
end

-- the kept measures, read once per character (windower.* outlives the reloads)
local function kept_measures()
    local name = player and player.name or '?'
    local cache = windower._clean_measures
    if not (cache and cache.char == name) then
        -- (no path, no read: in Lua 5.1 dofile(nil) reads the standard input)
        local path = file_path()
        local ok, all = false, nil
        if path then ok, all = pcall(dofile, path) end
        cache = {char = name, all = ok and type(all) == 'table' and all or {}, text = {}}
        windower._clean_measures = cache
    end
    return cache
end

-- Written under another name, then renamed (as item_icons.lua): a write stopped half way leaves the former file,
-- never an empty one. True when written
local function save(cache)
    local path = file_path()
    local f = path and io.open(path .. '.tmp', 'w')
    if not f then return false end
    local Writer = require('shared/utils/ui/ui_config_writer')
    local written = pcall(function()
        f:write('-- The last stats measured without Abyssea\'s boosts, by job, subjob and level (shared/utils/atelier/clean_measure.lua).\n')
        f:write('-- Written by the game: the Atelier export uses them while such boosts are up.\n')
        f:write('return ' .. Writer.to_lua(cache.all) .. '\n')
    end)
    f:close()
    if not written then os.remove(path .. '.tmp') return false end
    os.remove(path)
    return os.rename(path .. '.tmp', path) and true or false
end

-- a copy: the export changes the measure it gets (atelier_export.lua drops the worn pieces' ids), and the kept one
-- lives on windower across the reloads
local function copy(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for k, v in pairs(value) do out[k] = copy(v) end
    return out
end

local function boosted(buffs)
    for _, id in ipairs(buffs or {}) do
        if BOOSTS[id] then return true end
    end
    return false
end

--- A clean measure is kept (written only when it changed); a boosted one takes the kept stats of its job / subjob at
--- its level (a level sync measures lower stats: one kept at 99 is not taken for it, nor it for 99).
--- @param char table the measure built by collect_char (atelier_export_char.lua)
--- @param job string the main job
--- @return table the measure to export
function CleanMeasure.apply(char, job)
    local cache = kept_measures()
    local key = tostring(job) .. '_' .. tostring(char.sub or '') .. '_' .. tostring(char.main_level or '')
    if not boosted(char.buffs) then
        local kept = {}
        for _, field in ipairs(STAT_FIELDS) do kept[field] = copy(char[field]) end
        cache.all[key] = kept
        -- written again only when the stats change: not for the date, which moves at each measure, nor for the gear
        -- or the buffs alone (the page asks a measure at each stats packet: a file each swap, else)
        local stats = {}
        for _, field in ipairs(STAT_FIELDS) do
            if field ~= 'at' and field ~= 'worn' and field ~= 'buffs' then stats[field] = kept[field] end
        end
        local same = require('shared/utils/ui/ui_config_writer').to_lua(stats)
        -- (kept as written only once it is: a write that failed is tried again at the next measure)
        if cache.text[key] ~= same then
            local ok, done = pcall(save, cache)
            if ok and done then cache.text[key] = same end
        end
        return char
    end
    local kept = cache.all[key]
    if not kept then return char end
    char.worn_now = char.worn
    for _, field in ipairs(STAT_FIELDS) do char[field] = copy(kept[field]) end
    char.boost_kept = true
    return char
end

_G.CleanMeasure = CleanMeasure
return CleanMeasure
