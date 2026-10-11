---============================================================================
--- Atelier Configs - the character's settings files, as text, for the page
---============================================================================
--- The Atelier page shows every settings file a player can change: those of
--- the character (<Char>/_common/<theme>/) and those of the loaded job
--- (<Char>/<job>/<theme>/). The export (shared/utils/atelier/atelier_export.lua)
--- carries each file's text; the page reads the settings and the comment over
--- each one from it (atelier/app/js/modules.js), so a file explains itself
--- there the way it does in an editor. A setting changed in the page comes
--- back as the file's whole new text (write): the file is copied first and
--- the change goes into the page's history, where it can be undone
--- (shared/utils/atelier/set_push.lua write_file).
---
--- Left out: the equipment (sets/), and the job's keys, states, macro book and
--- lockstyle, which the page already shows in parts of their own.
---
--- @file    shared/utils/atelier/atelier_configs.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local AtelierConfigs = {}

-- shown by the page's Keys, Modes and Macro book parts
local SHOWN_ELSEWHERE = {'_KEYBINDS%.lua$', '_STATES%.lua$', '_LOCKSTYLE%.lua$', '_MACROBOOK%.lua$'}
-- a theme folder inside a theme folder (_common/dualbox/alt/)
local MAX_DEPTH = 2

local function read(path)
    local file = io.open(path, 'rb')   -- as it is on the disk: the page sends the file back whole
    if not file then return nil end
    local text = file:read('*a')
    file:close()
    return text
end

local function wanted(name)
    if not name:match('%.lua$') then return false end
    for _, pattern in ipairs(SHOWN_ELSEWHERE) do
        if name:match(pattern) then return false end
    end
    return true
end

--- Add the settings files of one folder, then of its sub-folders.
--- @param out table The list being filled
--- @param base string Absolute path of the character folder, with its last slash
--- @param rel string Folder under it ('_common', 'war/combat')
--- @param scope string 'common' or 'job'
--- @param depth number How deep under the scope's folder
local function add_folder(out, base, rel, scope, depth)
    local names = windower.get_dir(base .. rel) or {}
    table.sort(names)
    for _, name in ipairs(names) do
        local path = rel .. '/' .. name
        if wanted(name) then
            local text = read(base .. path)
            if text then
                out[#out + 1] = {file = path, scope = scope, group = depth > 0 and rel:match('^[^/]+/([^/]+)') or '', text = text,
                    hash = require('shared/utils/atelier/set_writer').hash(text)}
            end
        elseif not name:find('%.') and name ~= 'sets' and depth < MAX_DEPTH then
            add_folder(out, base, path, scope, depth + 1)
        end
    end
end

--- The settings files of a character and of one of its jobs.
--- @param char string Character name (its folder under data/)
--- @param job string Job (three letters)
--- @return table List of {file = path under the character folder, scope = 'common'|'job', group = theme folder,
---   text = content, hash = what write() asks back}
function AtelierConfigs.collect(char, job)
    local out = {}
    if not (char and job) then return out end
    local base = windower.addon_path .. 'data/' .. char .. '/'
    add_folder(out, base, '_common', 'common', 0)
    add_folder(out, base, job:lower(), 'job', 0)
    return out
end

--- Rewrite one settings file with the text the page made from it.
--- @param char string Character name
--- @param job string Job the page shows (its files are the ones that may be written, with the character's)
--- @param file string Path under the character folder, as collect() gave it
--- @param text string The file's new text
--- @param hash string Hash of the text the page started from (SetWriter.hash)
--- @param change table {slot = setting, before = old value, after = new value}, for the history
--- @return table {ok, entry} or {error}
function AtelierConfigs.write(char, job, file, text, hash, change)
    local known = false
    for _, f in ipairs(AtelierConfigs.collect(char, job)) do known = known or f.file == file end
    if not known then return {error = 'file'} end
    local abs = windower.addon_path .. 'data/' .. char .. '/' .. file
    local before = read(abs)
    if not before or require('shared/utils/atelier/set_writer').hash(before) ~= hash then return {error = 'changed'} end
    if text == before or text == '' then return {error = 'nothing'} end
    -- a file that no longer reads would break the next load: refused before anything is written
    local compile = rawget(_G, 'loadstring')
    if compile and not compile(text) then return {error = 'syntax'} end
    return require('shared/utils/atelier/set_push').write_file(abs, before, text,
        {job = job, path = (file:match('([^/]+)%.lua$') or file) .. '.' .. tostring(change.slot), config = true, changes = {change}})
end

return AtelierConfigs
