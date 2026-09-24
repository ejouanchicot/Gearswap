---============================================================================
--- Temp Binds - //gs c tb, keys made on the fly for a repetitive task
---============================================================================
---   //gs c tb ^f1 dia2 vampire leech          bind a key (^f1 / ctrl+f1 / cf1)
---   //gs c tb dia2 t                           no key: the first free one is used
---   //gs c tb force ^f1 ...                    even over a key already in use
---   //gs c tb list                             what is bound
---   //gs c tb del ctrl+f1                      unbind one
---   //gs c tb clear                            unbind all
---   //gs c tb help                             full help
---
--- The key is bound to `gs c tb run <key>`, and the real command is built at
--- each press: that is when a name is looked up, so the target can move,
--- die and respawn.
---
--- Kept in <Character>/temp_binds.lua, not in memory: //lua r gearswap
--- wipes GearSwap's memory but not Windower's binds, and `clear` must still
--- find them. They are meant to last until the game closes: the file
--- records os.clock() (time counted from the game process start), which
--- starts from zero again when the game restarts - a smaller value on load means a new
--- game session, whose Windower binds are already gone, so the file is
--- emptied.
---
--- @file    shared/utils/keybinds/temp_binds.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local TempBinds = {}

local Parse = require('shared/utils/keybinds/temp_binds_parse')

local Msg = nil
local function msg()
    if not Msg then
        local ok, m = pcall(require, 'shared/utils/messages/formatters/system/message_tempbind')
        Msg = ok and m or nil
    end
    return Msg
end

--- Keys Mote-Globals.lua binds on every job (its whole F9-F12 block is kept
--- free, including the few combinations it leaves unbound), and Windower's
--- init.txt paste.
local RESERVED = {
    ['f9'] = 'Mote', ['f10'] = 'Mote', ['f11'] = 'Mote', ['f12'] = 'Mote',
    ['^f9'] = 'Mote', ['^f10'] = 'Mote', ['^f11'] = 'Mote', ['^f12'] = 'Mote',
    ['!f9'] = 'Mote', ['!f10'] = 'Mote', ['!f11'] = 'Mote', ['!f12'] = 'Mote',
    ['@f9'] = 'Mote', ['@f10'] = 'Mote', ['@f11'] = 'Mote', ['@f12'] = 'Mote',
    ['^-'] = 'Mote', ['^='] = 'Mote', ['^v'] = 'Windower paste',
}

---============================================================================
--- STORAGE
---============================================================================

local function file_path()
    if not (player and player.name) then return nil end
    return ('%sdata/%s/temp_binds.lua'):format(windower.addon_path, player.name)
end

--- {key = command} for this game session.
--- @return table
local function load_binds()
    local path = file_path()
    local file = path and io.open(path, 'r')
    if not file then return {} end
    file:close()
    local ok, data = pcall(dofile, path)
    if not ok or type(data) ~= 'table' or type(data.binds) ~= 'table' then return {} end
    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok_t and Trace then
        Trace.log('TB', 'load: saved clock %s now %s -> %s', data.clock, os.clock(),
            (tonumber(data.clock) or 0) > os.clock() and 'restart detected, list emptied' or 'same session')
    end
    if (tonumber(data.clock) or 0) > os.clock() then return {} end -- game restarted
    return data.binds
end

--- Write the binds back, stamped with this session's clock.
--- @param binds table
local function save_binds(binds)
    local path = file_path()
    local file = path and io.open(path, 'w')
    if not file then return end
    local lines = {'-- Written by //gs c tb. Emptied when the game restarts.', 'return {',
        ('    clock = %s,'):format(os.clock()), '    binds = {'}
    local keys = {}
    for key in pairs(binds) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
        lines[#lines + 1] = ('        [%q] = %q,'):format(key, binds[key])
    end
    lines[#lines + 1] = '    },'
    lines[#lines + 1] = '}'
    file:write(table.concat(lines, '\n'), '\n')
    file:close()
end

---============================================================================
--- CHECKS
---============================================================================

--- What already uses `key`: the job's own keys, Mote's, Windower's.
--- @param key string
--- @return string|nil
local function taken_by(key)
    if RESERVED[key] then return RESERVED[key] end
    local job = player and player.main_job
    local module = job and rawget(_G, job .. 'Keybinds')
    if type(module) ~= 'table' then return nil end
    local ok, active = pcall(module.get_active_binds or function() return module.binds end)
    for _, bind in ipairs(ok and active or {}) do
        if bind.key == key then return job .. ' ' .. tostring(bind.desc) end
    end
    return nil
end

---============================================================================
--- SUBCOMMANDS
---============================================================================

--- Keys tried, in order, when no key is given.
local AUTO_KEYS = {'^f1', '^f2', '^f3', '^f4', '^f5', '^f6', '^f7', '^f8',
                   '!f1', '!f2', '!f3', '!f4', '!f5', '!f6', '!f7', '!f8'}

--- First key of AUTO_KEYS used by nothing: job, Mote, or another tb.
--- @return string|nil
local function free_key()
    local binds = load_binds()
    for _, key in ipairs(AUTO_KEYS) do
        if not binds[key] and not taken_by(key) then return key end
    end
    return nil
end

local function add(words, force)
    local key = Parse.key(words[1])
    if key then
        table.remove(words, 1)
    elseif Parse.looks_like_key(words[1]) then
        return msg() and msg().show_usage('unknown key ' .. tostring(words[1]))
    else
        key = free_key()
        if not key then return msg() and msg().show_usage('no free key left (Ctrl/Alt+F1-F8)') end
    end
    local owner = taken_by(key)
    if owner and not force then return msg() and msg().show_taken(Parse.show_key(key), owner) end
    local command, err = Parse.command(words)
    if not command then return msg() and msg().show_usage(err) end
    local binds = load_binds()
    binds[key] = command
    save_binds(binds)
    send_command('bind ' .. key .. ' gs c tb run ' .. key)
    if msg() then msg().show_added(Parse.show_key(key), Parse.show_command(command)) end
end

local function run(key)
    local command = key and load_binds()[key]
    if not command then return msg() and msg().show_unknown(Parse.show_key(key or '?')) end
    local ready, missing = Parse.resolve(command)
    if not ready then return msg() and msg().show_not_found(missing) end
    send_command(ready)
end

local function remove(text)
    local key = Parse.key(text)
    local binds = load_binds()
    if not key or not binds[key] then return msg() and msg().show_unknown(text or '?') end
    binds[key] = nil
    save_binds(binds)
    send_command('unbind ' .. key)
    if msg() then msg().show_removed(Parse.show_key(key)) end
end

local function clear()
    local binds, n = load_binds(), 0
    for key in pairs(binds) do
        send_command('unbind ' .. key)
        n = n + 1
    end
    save_binds({})
    if msg() then msg().show_cleared(n) end
end

local function list()
    local rows = {}
    for key, command in pairs(load_binds()) do
        rows[#rows + 1] = {key = Parse.show_key(key), command = Parse.show_command(command)}
    end
    table.sort(rows, function(a, b) return a.key < b.key end)
    if msg() then msg().show_list(rows) end
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Handle //gs c tb ...
--- @param args table Words after "tb"
--- @return boolean handled
function TempBinds.handle(args)
    local words = {}
    for i, w in ipairs(args or {}) do words[i] = w end
    local sub = words[1] and words[1]:lower()
    if not sub then
        if msg() then msg().show_usage() end
    elseif sub == 'help' or sub == '?' then
        if msg() then msg().show_help() end
    elseif sub == 'list' then list()
    elseif sub == 'clear' then clear()
    elseif sub == 'del' then remove(words[2])
    elseif sub == 'run' then run(words[2])
    elseif sub == 'force' then table.remove(words, 1); add(words, true)
    else add(words, false) end
    return true
end

_G.TempBinds = TempBinds

return TempBinds
