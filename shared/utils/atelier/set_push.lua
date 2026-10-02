---============================================================================
--- Set Push - the Atelier page writes a set into the player's set file
---============================================================================
--- "Push to GearSwap" in the Atelier page (data/atelier.html, Sets tab) sends
--- the pieces of one set through the live door (atelier_live.lua):
---
---   POST /push?mode=preview   what would change, nothing written
---   POST /push?mode=write&hash=<h>  writes it, when the file is still the one
---                             the preview read
---   GET  /push_history        the pushes of this character, newest first
---   POST /push_undo?id=<n>    puts a file back as it was before a push
---   POST /delete?mode=preview|write&hash=<h>  a set and its versions taken out
---                             of the file (body: the set path); refused for the
---                             job's base sets and while another set reads it
---
--- Body (one line per slot, tab separated): the set path first, then
---   <slot> piece <name> [<augment> ...]   that copy
---   <slot> one <name>                     the only copy the player owns: its name is enough
---   <slot> empty                          nothing in the slot (GearSwap's `empty`)
---   <slot> inherit                        the line goes: the set takes its base's piece again
---
--- A piece the file already names through a variable (`feet = Nyame.feet_b`)
--- is written with that variable, read from how the file's other sets use it;
--- any other piece by its name and augments. The set is found in the job's set
--- folder (<Char>/<job>/sets/, shared/utils/atelier/set_writer.lua does the text).
--- A support tier version of a weaponskill set (.Group, .Solo) the file does not
--- write yet is written right under its base set, as a set_combine of it; a
--- weaponskill with no set yet (sets.precast.WS['X']) after the file's last
--- weaponskill set, as a set_combine of sets.precast.WS.
---
--- Before writing, the file is copied to <Char>/saved/backups/; every push is
--- noted in <Char>/saved/set_push_history.lua, and the set's entry leaves
--- <Char>/saved/set_overrides.lua (the file now holds those pieces).
---
--- @file    shared/utils/atelier/set_push.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local SetPush = {}

local SetWriter = require('shared/utils/atelier/set_writer')

local HISTORY_FILE = 'set_push_history.lua'
local HISTORY_MAX = 200

---============================================================================
--- FILES
---============================================================================

local function read(path)
    local f = path and io.open(path, 'rb')
    if not f then return nil end
    local text = f:read('*a')
    f:close()
    return text
end

local function write(path, text)
    local f = path and io.open(path, 'wb')
    if not f then return false end
    f:write(text)
    f:close()
    return true
end

local function data_dir()
    return windower.addon_path .. 'data/'
end

--- A path under data/ as the page shows it ('Tetsouo/war/sets/war_sets.lua').
local function relative(path)
    local root = data_dir()
    return path:sub(1, #root) == root and path:sub(#root + 1) or path
end

--- The job's set files: <job>_sets.lua first, then the other files of its folder.
local function set_files(job)
    local CharPaths = require('shared/utils/core/char_paths')
    local main = CharPaths.file('sets', job:lower() .. '_sets.lua', job)
    if not main then return {} end
    local out, dir = {main}, main:match('^(.*/)[^/]*$')
    for _, name in ipairs(dir and windower.get_dir(dir) or {}) do
        if name:match('%.lua$') and dir .. name ~= main then out[#out + 1] = dir .. name end
    end
    return out
end

--- The file defining a set, its text and the definition; or nil and why.
local function locate(job, path)
    for _, file in ipairs(set_files(job)) do
        local text = read(file)
        local def = text and SetWriter.find(text, path)
        if def then return file, text, def end
    end
    return nil, 'not_found'
end

---============================================================================
--- PIECES AS THE FILE WRITES THEM
---============================================================================

local function path_string(keys)
    local out = 'sets'
    for _, k in ipairs(keys) do
        out = k:match('^[%a_][%w_]*$') and (out .. '.' .. k) or (out .. '["' .. k:gsub('"', '\\"') .. '"]')
    end
    return out
end

local function node_of(keys)
    local node = rawget(_G, 'sets')
    for _, k in ipairs(keys) do
        node = type(node) == 'table' and rawget(node, k) or nil
    end
    return type(node) == 'table' and node or nil
end

--- The piece a loaded set holds in a slot, as the set file gave it (an override
--- of the page put back: SetOverrides.was).
local function loaded_piece(keys, slot)
    local ok, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
    local was = ok and SetOverrides.was and SetOverrides.was[path_string(keys)]
    if was and was[slot] ~= nil then return was[slot] or nil end
    local node = node_of(keys)
    if not node then return nil end
    for k, v in pairs(node) do
        if SetWriter.canon(k) == slot then return v end
    end
    return nil
end

local function piece_key(value)
    if type(value) == 'string' then return value .. '|' end
    if type(value) ~= 'table' or type(value.name) ~= 'string' then return nil end
    return value.name .. '|' .. table.concat(type(value.augments) == 'table' and value.augments or {}, '|')
end

local function note(by_copy, by_name, value, expr)
    local key = piece_key(value)
    if not key then return end
    if not by_copy[key] then by_copy[key] = expr end
    -- a piece written by its name alone is a string: Windower's string library refuses s.name
    local name = type(value) == 'table' and value.name or value
    if key:sub(-1) == '|' and not by_name[name] then by_name[name] = expr end
end

--- The pieces of the gear modules the file requires (`local Armor = require('.../armor')`),
--- through the names the file gives them (`local Nyame = Armor.Nyame` -> Nyame.feet_b).
local function module_pieces(text, by_copy, by_name)
    local modules = {}
    for name, mod in text:gmatch('local%s+([%a_][%w_]*)%s*=%s*require%s*%(?%s*[\'"]([^\'"]+)[\'"]') do
        local ok, m = pcall(require, mod)
        if ok and type(m) == 'table' then modules[name] = m end
    end
    local function scan(tbl, prefix)
        local keys = {}
        for k in pairs(tbl) do if type(k) == 'string' and k:match('^[%a_][%w_]*$') then keys[#keys + 1] = k end end
        table.sort(keys)
        for _, k in ipairs(keys) do
            local v = tbl[k]
            if type(v) == 'table' and type(v.name) == 'string' then note(by_copy, by_name, v, prefix .. '.' .. k) end
        end
    end
    for alias, root, field in text:gmatch('local%s+([%a_][%w_]*)%s*=%s*([%a_][%w_]*)%.([%a_][%w_]*)') do
        local t = modules[root] and modules[root][field]
        if type(t) == 'table' then scan(t, alias) end
    end
    for name, m in pairs(modules) do scan(m, name) end
end

--- What the file's sets write through a variable: {copy key = expr}, {name = expr} for those
--- without augments; then the pieces of its gear modules.
local function variables(text)
    local by_copy, by_name = {}, {}
    module_pieces(text, by_copy, by_name)
    local used_copy, used_name = {}, {}
    for _, def in ipairs(SetWriter.definitions(text)) do
        for _, e in ipairs(def.entries) do
            local expr = e.slot and text:sub(e.expr_from, e.expr_to)
            if expr and expr:match('^[%a_][%w_]*[%.%[][%w_%.%[%]\'"]*$') and expr ~= 'empty' then
                note(used_copy, used_name, loaded_piece(def.keys, e.slot), expr)
            end
        end
    end
    -- what the sets already write wins over the modules' other names for the same piece
    for k, v in pairs(used_copy) do by_copy[k] = v end
    for k, v in pairs(used_name) do by_name[k] = v end
    return by_copy, by_name
end

--- The request body as {path, slots = {slot = {kind, name, augs}}}.
local function parse_body(body)
    local lines = {}
    for line in (body or ''):gmatch('[^\r\n]+') do lines[#lines + 1] = line end
    local req = {path = lines[1], slots = {}}
    for i = 2, #lines do
        local f = {}
        for part in (lines[i] .. '\t'):gmatch('([^\t]*)\t') do f[#f + 1] = part end
        local slot = SetWriter.canon(f[1])
        if slot and f[2] then
            local augs = {}
            for j = 4, #f do if f[j] ~= '' then augs[#augs + 1] = f[j] end end
            req.slots[slot] = {kind = f[2], name = f[3], augs = augs}
        end
    end
    return req
end

--- {slot = expr | false} for SetWriter.edit.
local function changes_of(req, text)
    local by_copy, by_name = variables(text)
    local out = {}
    for slot, p in pairs(req.slots) do
        if p.kind == 'inherit' then out[slot] = false
        elseif p.kind == 'empty' then out[slot] = 'empty'
        elseif p.name and p.name ~= '' then
            local key = p.name .. '|' .. table.concat(p.augs, '|')
            out[slot] = by_copy[key] or (p.kind == 'one' and (by_name[p.name] or SetWriter.literal(p.name)))
                or SetWriter.literal(p.name, p.augs)
        end
    end
    return out
end

-- Versions a push may write when the file has none yet, under the set they are built on:
-- the support tiers of a weaponskill set (shared/utils/party/support_tier.lua)
local NEW_VERSIONS = {Group = true, Solo = true}

--- Whether a weaponskill of that name exists (the game's resources; unknown when they cannot be read).
local function known_ws(name)
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    if not (resources and resources.weapon_skills) then return true end
    for _, ws in pairs(resources.weapon_skills) do
        if type(ws) == 'table' and ws.english == name then return true end
    end
    return false
end

--- A set the file does not write yet that a push may create: a version (.Group, .Solo) under
--- its set, or a weaponskill's set under sets.precast.WS (written after the last weaponskill set
--- of that file). The file, its text, the base's definition, the new name and the definition to
--- write after; or nil.
local function locate_base(job, keys)
    local name, base_keys, last_of_group = keys[#keys], {}, false
    for i = 1, #keys - 1 do base_keys[i] = keys[i] end
    if #keys == 3 and keys[1] == 'precast' and keys[2] == 'WS' then
        if not known_ws(name) then return nil end
        last_of_group = true
    elseif not (NEW_VERSIONS[name] and #keys > 1) then
        return nil
    end
    for _, file in ipairs(set_files(job)) do
        local text = read(file)
        local def = text and SetWriter.find_keys(text, base_keys)
        if def then
            local group = last_of_group and SetWriter.family(text, base_keys)
            return file, text, def, name, group and group[#group] or nil
        end
    end
    return nil
end

--- The file with the set changed, or with the version written when the file has none yet.
--- @return string|nil abs, string text|why, string out, table done, table def (before), table keys
local function rewrite(job, req)
    local keys = SetWriter.path_keys(req.path)
    local abs, text, def = locate(job, req.path)
    if abs then
        local out, done = SetWriter.edit(text, def, changes_of(req, text))
        return abs, text, out, done, def, keys
    end
    local babs, btext, base, name, after = locate_base(job, keys)
    if not babs then return nil, text end
    local out, done = SetWriter.create(btext, base, name, changes_of(req, btext), after)
    return babs, btext, out, done, nil, keys
end

--- The change asked, worked out: {file, abs, text, out, before, after, changes, hash} or nil and why.
local function prepare(job, body)
    local req = parse_body(body)
    if not (req.path and SetWriter.path_keys(req.path)) then return nil, 'path' end
    local abs, text, out, done, def, keys = rewrite(job, req)
    if not abs then return nil, text end
    local def_after = SetWriter.find_keys(out, keys)
    return {path = req.path, file = relative(abs), abs = abs, text = text, out = out, changes = done,
        before = def and SetWriter.block(text, def) or '', created = def == nil or nil, after = def_after and SetWriter.block(out, def_after) or '',
        hash = SetWriter.hash(text)}
end

---============================================================================
--- HISTORY
---============================================================================

local function history_path()
    return require('shared/utils/core/char_paths').writable('saved', HISTORY_FILE)
end

local function read_history()
    local path = history_path()
    local ok, list = pcall(dofile, path)
    return (ok and type(list) == 'table') and list or {}
end

local function lua_value(v, indent)
    if type(v) == 'string' then return string.format('%q', v) end
    if type(v) ~= 'table' then return tostring(v) end
    local parts, inner = {}, indent .. '    '
    for _, x in ipairs(v) do parts[#parts + 1] = inner .. lua_value(x, inner) .. ',' end
    local keys = {}
    for k in pairs(v) do if type(k) == 'string' then keys[#keys + 1] = k end end
    table.sort(keys)
    for _, k in ipairs(keys) do parts[#parts + 1] = inner .. k .. ' = ' .. lua_value(v[k], inner) .. ',' end
    if #parts == 0 then return '{}' end
    return '{\n' .. table.concat(parts, '\n') .. '\n' .. indent .. '}'
end

local function write_history(list)
    while #list > HISTORY_MAX do table.remove(list, 1) end
    return write(history_path(), '-- Sets pushed from the Atelier page into the set files (shared/utils/atelier/set_push.lua).\n'
        .. '-- Each push: the file, its copy before the push (saved/backups/), what changed.\nreturn ' .. lua_value(list, '') .. '\n')
end

--- The set's entry leaves <Char>/saved/set_overrides.lua: the set file holds those pieces now.
local function drop_override(job, path)
    local ok, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
    local data = ok and SetOverrides.read()
    if not (data and data[job] and data[job][path]) then return end
    data[job][path] = nil
    if next(data[job]) == nil then data[job] = nil end
    local file = require('shared/utils/core/char_paths').writable('saved', 'set_overrides.lua')
    write(file, '-- Pieces changed in the Atelier page (data/atelier.html, Sets tab), laid over the set files\n'
        .. '-- (shared/utils/atelier/set_overrides.lua). Delete this file to go back to your set files.\n'
        .. "-- 'empty' = nothing in the slot.\nreturn " .. lua_value(data, '') .. '\n')
end

--- The file copied to saved/backups/ (named after the history entry, so two changes in
--- the same second keep their own copy), then written.
--- @return string|nil backup path, string|nil why
local function backup_and_write(p, id)
    local name = p.abs:match('([^/]+)%.lua$') or 'sets'
    local backup = require('shared/utils/core/char_paths').writable('saved',
        'backups/' .. name .. '_' .. os.date('%Y%m%d-%H%M%S') .. '_' .. id .. '.lua')
    if not (backup and write(backup, p.text)) then return nil, 'backup' end
    if not write(p.abs, p.out) then return nil, 'write' end
    return backup
end

---============================================================================
--- PUBLIC
---============================================================================

--- What a push would change (nothing written).
--- @param job string Job code
--- @param body string Request body (see the header)
--- @return table {ok, file, hash, before, after, changes} or {error}
function SetPush.preview(job, body)
    local p, why = prepare(job, body)
    if not p then return {error = why} end
    return {ok = true, file = p.file, hash = p.hash, before = p.before, after = p.after, changes = p.changes, created = p.created}
end

--- Write the set into its file, when the file is still the one the preview read.
--- @return table {ok, entry} or {error}
function SetPush.write(job, body, hash)
    local p, why = prepare(job, body)
    if not p then return {error = why} end
    if p.hash ~= hash then return {error = 'changed'} end
    if #p.changes == 0 and not p.created then return {error = 'nothing'} end
    local list = read_history()
    local id = ((list[#list] or {}).id or 0) + 1
    local backup, err = backup_and_write(p, id)
    if not backup then return {error = err} end
    local entry = {id = id, at = os.date('%Y-%m-%d %H:%M'), job = job, path = p.path,
        file = p.file, backup = relative(backup), hash_before = p.hash, hash_after = SetWriter.hash(p.out), changes = p.changes}
    list[#list + 1] = entry
    write_history(list)
    drop_override(job, p.path)
    return {ok = true, entry = entry}
end

---============================================================================
--- DELETE
---============================================================================

-- Sets a job cannot do without: Mote builds idle, engaged, precast and the
-- weaponskills on them, so the page never deletes them
local PROTECTED = {['precast.WS'] = true, ['precast.FC'] = true, ['precast.JA'] = true,
    ['precast.RA'] = true, ['midcast.RA'] = true}

--- The sets of a file that read a set or one under it, outside the lines going away: their
--- paths (a read outside any set: its line).
local function readers(text, keys)
    local defs, out, seen = SetWriter.definitions(text), {}, {}
    for _, use in ipairs(SetWriter.uses(text, keys)) do
        local name
        for _, def in ipairs(defs) do
            if use.at >= def.line_from and use.at <= def.close then name = path_string(def.keys) end
        end
        if not name then
            local _, n = text:sub(1, use.at):gsub('\n', '')
            name = 'line ' .. (n + 1)
        end
        if not seen[name] then seen[name] = true; out[#out + 1] = name end
    end
    return out
end

--- The deletion asked, worked out: {path, file, abs, text, out, before, removed, hash}, or nil,
--- why and (for 'used') the sets still reading it.
local function prepare_delete(job, path)
    local keys = SetWriter.path_keys(path or '')
    if not keys then return nil, 'path' end
    if #keys == 1 or PROTECTED[table.concat(keys, '.')] then return nil, 'protected' end
    local abs, text = locate(job, path)
    if not abs then return nil, text end
    local family = SetWriter.family(text, keys)
    local out, before = SetWriter.remove(text, family)
    local users = {}
    for _, file in ipairs(set_files(job)) do
        for _, name in ipairs(readers(file == abs and out or (read(file) or ''), keys)) do users[#users + 1] = name end
    end
    if #users > 0 then return nil, 'used', users end
    local removed = {}
    for i, def in ipairs(family) do removed[i] = path_string(def.keys) end
    return {path = path, file = relative(abs), abs = abs, text = text, out = out, before = before,
        removed = removed, hash = SetWriter.hash(text)}
end

--- What deleting a set would take out of its file (nothing written).
--- @param job string Job code
--- @param path string Set path
--- @return table {ok, file, hash, before, removed} or {error, users}
function SetPush.delete_preview(job, path)
    local p, why, users = prepare_delete(job, path)
    if not p then return {error = why, users = users} end
    return {ok = true, file = p.file, hash = p.hash, before = p.before, removed = p.removed}
end

--- Delete a set and its versions from its file, when the file is still the one the preview read.
--- @return table {ok, entry} or {error}
function SetPush.delete(job, path, hash)
    local p, why, users = prepare_delete(job, path)
    if not p then return {error = why, users = users} end
    if p.hash ~= hash then return {error = 'changed'} end
    local list = read_history()
    local id = ((list[#list] or {}).id or 0) + 1
    local backup, err = backup_and_write(p, id)
    if not backup then return {error = err} end
    local entry = {id = id, at = os.date('%Y-%m-%d %H:%M'), job = job, path = p.path,
        file = p.file, backup = relative(backup), hash_before = p.hash, hash_after = SetWriter.hash(p.out), deleted = p.removed}
    list[#list + 1] = entry
    write_history(list)
    for _, removed in ipairs(p.removed) do drop_override(job, removed) end
    return {ok = true, entry = entry}
end

--- The pushes, newest first; `undoable` when the file is still as that push left it.
--- @return table
function SetPush.history()
    local list, hashes, out = read_history(), {}, {}
    for i = #list, 1, -1 do
        local e = list[i]
        if hashes[e.file] == nil then hashes[e.file] = SetWriter.hash(read(data_dir() .. e.file) or '') end
        e.undoable = not e.undone and hashes[e.file] == e.hash_after
        out[#out + 1] = e
    end
    return out
end

--- Put a file back as it was before a push.
--- @param id number History entry
--- @return table {ok} or {error}
function SetPush.undo(id)
    local list = read_history()
    for _, e in ipairs(list) do
        if e.id == id then
            if e.undone then return {error = 'undone'} end
            local abs = data_dir() .. e.file
            if SetWriter.hash(read(abs) or '') ~= e.hash_after then return {error = 'changed'} end
            local before = read(data_dir() .. e.backup)
            if not before then return {error = 'backup'} end
            if not write(abs, before) then return {error = 'write'} end
            e.undone = os.date('%Y-%m-%d %H:%M')
            write_history(list)
            return {ok = true}
        end
    end
    return {error = 'id'}
end

return SetPush
