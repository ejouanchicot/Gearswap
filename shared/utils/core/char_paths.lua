---============================================================================
--- Character Paths - where each file of a character folder lives
---============================================================================
--- One place that knows the layout of data/<Character>/, so no module
--- builds a path by hand.
---
--- Layout since 2026-09-30:
---   <Char>/<Char>_<JOB>.lua      one-line entry (GearSwap needs this name)
---   <Char>/common/               settings for the whole character, by theme
---       display/                 HUD, colours, region, lockstyle delay
---       keys/                    common keys, Combat Mode / Treasure Mode keys
---       dualbox/                 dual-box settings; alt/ = the alt's own commands
---       inventory/               refill, craft, wardrobe organizer
---       combat/                  automatic abilities, recasts, Dual Wield, belt,
---                                weapons, Sneak / Invisible
---       sets/                    gear shared by jobs (rings.lua...), craft and
---                                fishing sets
---   <Char>/<job>/                one job, by theme (job_group below)
---       display/                 <JOB>_HUD, _LOCKSTYLE, _MACROBOOK
---       keys/                    <JOB>_KEYBINDS, _STATES, _CUSTOM
---       combat/                  <JOB>_TP_CONFIG, _WS_CONFIG and the job's own
---                                settings (songs, Saboteur, cures, pets...)
---       inventory/               <JOB>_REFILL
---       sets/                    its gear: <job>_sets.lua, armor.lua...
---   <Char>/saved/                files the game writes (window positions,
---                                dual-box role, HUD settings, traces...)
---
--- Older layouts, still read: config/<FILE>, config/<job>/, config/alt/,
--- config/craft/, sets/<job>_sets.lua, sets/<job>/, files at the root of the
--- character folder, and the first form of this layout (sets and gear files
--- next to the settings, common/craft/). Every lookup tries the new place first, then the old
--- ones, so a character that was not moved (a frozen clone) keeps working.
--- A file that exists nowhere yet is created where that character's layout
--- puts it: its new place once the folder has common/, else the old place, so
--- a folder that was not moved never gets new folders.
---
--- @file    shared/utils/core/char_paths.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local CharPaths = {}

--- Places of each kind of file, relative to the character folder, newest
--- first. %s is the file name, %j the job in lower case.
local LAYOUT = {
    common = {'common/%s', 'config/%s'},
    alt    = {'common/dualbox/alt/%s', 'common/alt/%s', 'config/alt/%s'},
    craft  = {'common/inventory/%s', 'common/%s', 'common/craft/%s', 'config/craft/%s'},
    gear   = {'common/sets/%s', 'common/craft/%s', 'common/%s', 'sets/common/%s', 'sets/%s'},
    job    = {'%j/%s', 'config/%j/%s'},
    sets   = {'%j/sets/%s', '%j/%s', 'sets/%j/%s', 'sets/%s'},
    saved  = {'saved/%s', 'config/%s', '%s'},
}

--- Theme folder of each character setting in common/. A file not listed
--- here stays at the root of common/.
local COMMON_GROUPS = {
    ['UI_CONFIG.lua'] = 'display', ['UI_COLOR_CONFIG.lua'] = 'display',
    ['REGION_CONFIG.lua'] = 'display', ['LOCKSTYLE_CONFIG.lua'] = 'display',
    ['COMMON_KEYBINDS.lua'] = 'keys', ['combat_mode.lua'] = 'keys', ['treasure_mode.lua'] = 'keys',
    ['DUALBOX_CONFIG.lua'] = 'dualbox',
    ['REFILL_CONFIG.lua'] = 'inventory', ['CRAFT_CONFIG.lua'] = 'inventory',
    ['CRAFT_REFILL.lua'] = 'inventory', ['WARDROBE_CONFIG.lua'] = 'inventory',
    ['AUTO_ABILITIES.lua'] = 'combat', ['RECAST_CONFIG.lua'] = 'combat', ['DW_CONFIG.lua'] = 'combat',
    ['ELEMENTAL_BELT.lua'] = 'combat', ['WEAPON_CONFIG.lua'] = 'combat', ['STEALTH_CONFIG.lua'] = 'combat',
}
CharPaths.COMMON_GROUPS = COMMON_GROUPS

--- Theme folder of a job settings file, from the end of its name.
local JOB_GROUP_SUFFIXES = {
    {'_HUD', 'display'}, {'_LOCKSTYLE', 'display'}, {'_MACROBOOK', 'display'},
    {'_KEYBINDS', 'keys'}, {'_STATES', 'keys'}, {'_CUSTOM', 'keys'},
    {'_REFILL', 'inventory'},
}

--- @param file string e.g. 'WAR_STATES.lua'
--- @return string|nil display | keys | inventory | combat; nil for a gear file
function CharPaths.job_group(file)
    if not file:match('^%u') then return nil end
    local base = file:gsub('%.lua$', '')
    for _, entry in ipairs(JOB_GROUP_SUFFIXES) do
        if base:sub(-#entry[1]) == entry[1] then return entry[2] end
    end
    return 'combat'
end

--- Old place of a file that exists nowhere yet, per kind (the path the code
--- used before 2026-09-30).
local LEGACY_DEFAULT = {
    common = 'config/%s', alt = 'config/alt/%s', job = 'config/%j/%s', sets = 'sets/%s',
    craft = 'config/craft/%s', gear = 'sets/%s',
}
local ROOT_SAVED = {['temp_binds.lua'] = true, ['trace.log'] = true, ['trace.old.log'] = true,
    ['trace.on'] = true, ['atelier.on'] = true, ['rolldebug.log'] = true}

--- Name of the character being played, or nil before the game knows it.
--- @return string|nil
function CharPaths.name()
    local p = windower.ffxi.get_player()
    if p and p.name then return p.name end
    return rawget(_G, 'player') and player.name or nil
end

local function data_dir()
    return windower.addon_path .. 'data/'
end

local function exists(path)
    if windower.file_exists then return windower.file_exists(path) end
    local f = io.open(path, 'r')
    if f then f:close() return true end
    return false
end

local function fill(pattern, file, job)
    return (pattern:gsub('%%j', (job or ''):lower()):gsub('%%s', function() return file end))
end

--- True when the character folder uses the layout of 2026-09-30.
local layout_cache = {}
local function new_layout(char)
    if layout_cache[char] == nil then
        local dir = data_dir() .. char .. '/common'
        layout_cache[char] = (windower.dir_exists and windower.dir_exists(dir)) and true or false
    end
    return layout_cache[char]
end

--- Where a file that exists nowhere yet goes, for a folder in the old layout.
local function legacy_default(kind, file, job)
    if kind == 'saved' then return ROOT_SAVED[file] and file or ('config/' .. file) end
    return LEGACY_DEFAULT[kind] and fill(LEGACY_DEFAULT[kind], file, job) or nil
end

--- Candidate paths of one file, relative to the character folder.
--- @param kind string common (its theme folder from COMMON_GROUPS) | alt | craft (CRAFT_REFILL) | gear (common/sets/:
---   shared gear, craft sets) | job | sets (a job's gear) | saved
--- @param file string File name (with .lua for files, without for modules)
--- @param job string|nil Job code, for job and sets
--- @return table
local function candidates(kind, file, job)
    local out = {}
    if kind == 'common' and COMMON_GROUPS[file] then
        out[1] = 'common/' .. COMMON_GROUPS[file] .. '/' .. file
    elseif kind == 'job' and CharPaths.job_group(file) then
        out[1] = (job or ''):lower() .. '/' .. CharPaths.job_group(file) .. '/' .. file
    end
    for _, pattern in ipairs(LAYOUT[kind] or {}) do
        out[#out + 1] = fill(pattern, file, job)
    end
    return out
end

--- Path of a file relative to the character folder: where it is, or where
--- it would be created.
--- @param kind string
--- @param file string File name with its extension
--- @param job string|nil
--- @param char string|nil Character (default: the one being played)
--- @return string|nil
function CharPaths.relative(kind, file, job, char)
    char = char or CharPaths.name()
    if not char then return nil end
    local list = candidates(kind, file, job)
    for _, rel in ipairs(list) do
        if exists(data_dir() .. char .. '/' .. rel) then return rel end
    end
    if new_layout(char) then return list[1] end
    return legacy_default(kind, file, job) or list[1]
end

--- Absolute path of a file: where it is, or where it would be created.
--- @param kind string
--- @param file string File name with its extension
--- @param job string|nil
--- @param char string|nil
--- @return string|nil
function CharPaths.file(kind, file, job, char)
    char = char or CharPaths.name()
    local rel = CharPaths.relative(kind, file, job, char)
    return rel and (data_dir() .. char .. '/' .. rel) or nil
end

--- require() name of a module: where it is, else its new place.
--- @param kind string
--- @param name string Module name without .lua
--- @param job string|nil
--- @param char string|nil
--- @return string|nil
function CharPaths.module(kind, name, job, char)
    char = char or CharPaths.name()
    local rel = CharPaths.relative(kind, name .. '.lua', job, char)
    return rel and (char .. '/' .. rel:gsub('%.lua$', '')) or nil
end

--- pcall(require) of a character module.
--- @return boolean ok, any module or error
function CharPaths.load(kind, name, job, char)
    local mod = CharPaths.module(kind, name, job, char)
    if not mod then return false, 'no character' end
    return pcall(require, mod)
end

--- require() of a character module that older folders may not have: nil
--- when the file is missing, the module otherwise (a broken file still errors).
--- @return any|nil
function CharPaths.optional(kind, name, job, char)
    local path = CharPaths.file(kind, name .. '.lua', job, char)
    if not (path and exists(path)) then return nil end
    return require(CharPaths.module(kind, name, job, char))
end

--- Create the folder of a file about to be written (one level: the file's
--- own folder, e.g. <Char>/saved/).
--- @param path string Absolute file path
function CharPaths.ensure_parent(path)
    local dir = path and path:match('^(.*)/[^/]*$')
    if dir and windower.dir_exists and not windower.dir_exists(dir) and windower.create_dir then
        windower.create_dir(dir)
    end
end

--- Absolute path of a file about to be written: where it already is, else
--- where the character's layout puts it. In the new layout its folder is
--- created (e.g. saved/); an old-layout folder is never given new folders.
--- @return string|nil
function CharPaths.writable(kind, file, job, char)
    char = char or CharPaths.name()
    local path = CharPaths.file(kind, file, job, char)
    if path and new_layout(char) then CharPaths.ensure_parent(path) end
    return path
end

--- require() name for a path written the old way ('config/war/WAR_LOCKSTYLE',
--- 'Tetsouo/config/war/WAR_LOCKSTYLE', 'config/COMMON_KEYBINDS'), found in
--- the current layout. Any other path comes back unchanged.
--- @param path string
--- @return string
function CharPaths.legacy_module(path)
    if type(path) ~= 'string' then return path end
    local rest = path:match('^config/(.+)$')
    local char = nil
    if not rest then char, rest = path:match('^([^/]+)/config/(.+)$') end
    if not rest then return path end
    local job, name = rest:match('^(%w+)/([%w_]+)$')
    if job then return CharPaths.module('job', name, job, char) or path end
    if rest:match('^[%w_]+$') then return CharPaths.module('common', rest, nil, char) or path end
    return path
end

_G.CharPaths = CharPaths

return CharPaths
