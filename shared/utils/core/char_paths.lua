---============================================================================
--- Character Paths - where each file of a character folder lives
---============================================================================
--- One place that knows the layout of data/<Character>/, so no module
--- builds a path by hand.
---
--- Layout since 2026-09-30:
---   <Char>/<Char>_<JOB>.lua      one-line entry (GearSwap needs this name)
---   <Char>/common/               settings for the whole character
---       alt/                     the dual-box alt's own commands (*_ALT_CUSTOM)
---       sets/                    gear shared by jobs (rings.lua...), craft and
---                                fishing sets
---   <Char>/<job>/                settings of one job
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
    alt    = {'common/alt/%s', 'config/alt/%s'},
    craft  = {'common/%s', 'common/craft/%s', 'config/craft/%s'},
    gear   = {'common/sets/%s', 'common/craft/%s', 'common/%s', 'sets/common/%s', 'sets/%s'},
    job    = {'%j/%s', 'config/%j/%s'},
    sets   = {'%j/sets/%s', '%j/%s', 'sets/%j/%s', 'sets/%s'},
    saved  = {'saved/%s', 'config/%s', '%s'},
}

--- Old place of a file that exists nowhere yet, per kind (the path the code
--- used before 2026-09-30).
local LEGACY_DEFAULT = {
    common = 'config/%s', alt = 'config/alt/%s', job = 'config/%j/%s', sets = 'sets/%s',
    craft = 'config/craft/%s', gear = 'sets/%s',
}
local ROOT_SAVED = {['temp_binds.lua'] = true, ['trace.log'] = true, ['trace.old.log'] = true,
    ['trace.on'] = true, ['atelier.on'] = true}

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
--- @param kind string common | alt | craft (CRAFT_REFILL) | gear (common/sets/:
---   shared gear, craft sets) | job | sets (a job's gear) | saved
--- @param file string File name (with .lua for files, without for modules)
--- @param job string|nil Job code, for job and sets
--- @return table
local function candidates(kind, file, job)
    local out = {}
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
