---============================================================================
--- Mode Overrides - start values chosen in the Atelier page, laid over the states files
---============================================================================
--- The Atelier page (data/atelier.html, "Modes & keys" tab) writes the start
--- value a player picks for a mode into <Char>/atelier/overrides/mode_overrides.lua.
--- The states files (<job>/keys/<JOB>_STATES.lua...) are never rewritten:
--- deleting that file brings every start value back.
---
--- Format of the file:
---   return {
---       common = { AutoMedicine = 'On' },     -- every job (the shared modes)
---       WHM    = { IdleMode = 'Refresh' },
---   }
--- Applied once per job load, when the job's keys are assembled
--- (shared/utils/keybinds/keybind_manager.lua create): every mode exists by
--- then (the states file, CombatMode, TreasureMode, JumpAuto, the CUSTOM
--- file's) and the HUD has not drawn yet. Like a states file's :set(), it
--- fires no state change. A value the mode does not hold is ignored and
--- named once in the chat; a common mode the job lacks is skipped silently.
---
--- @file shared/utils/core/mode_overrides.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-29
---============================================================================

local ModeOverrides = {}

local FILE = 'mode_overrides.lua'

-- The state tables already laid over (one per job load): a second create in the same load leaves the player's
-- cycling alone
local applied = setmetatable({}, {__mode = 'k'})

-- The value each overridden mode had from its file, for the Atelier export
local file_values = {}

--- The overrides file of the character, read now, or nil when there is none.
--- @return table|nil {common = {Mode = value}, <JOB> = {Mode = value}}
function ModeOverrides.read()
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    local path = ok and CharPaths and CharPaths.file('atelier', FILE)
    if not path then return nil end
    -- read as data, never run: the Atelier writes this file through the game's door (shared/utils/core/lua_data.lua)
    local f = io.open(path, 'rb')
    if not f then return nil end
    local text = f:read('*a')
    f:close()
    local data = require('shared/utils/core/lua_data').parse(text)
    return type(data) == 'table' and data or nil
end

--- A Mote mode of the state table, or nil
local function mode_of(st, name)
    local mode = rawget(st, name)
    local track = type(mode) == 'table' and rawget(mode, '_track')
    return track and track._class == 'mode' and track._type ~= 'string' and mode or nil
end

-- The values the Atelier added to each mode ('+Mode' entries) and took out of it ('-Mode'), for its export
local added_values, removed_values = {}, {}

--- A list mode's values made again (Mote's options()), its current value kept when it is still there, else the
--- first. Mote's options() alone goes back to the first.
--- @return boolean true when laid
local function relist(mode, list)
    local current = tostring(mode.current)
    if not pcall(mode.options, mode, (table.unpack or unpack)(list)) then return false end
    for _, v in ipairs(list) do
        if v == current then pcall(mode.set, mode, current) break end
    end
    return true
end

--- Add values at the end of a list mode, keeping its current value. A value the mode holds already is left where it is.
--- @return boolean true when laid
local function add_values(mode, name, values)
    if rawget(mode, '_track')._type ~= 'list' then return false end
    local list, have, added = {}, {}, 0
    for _, v in ipairs(mode) do list[#list + 1] = v; have[v] = true end
    for _, v in ipairs(values) do
        if type(v) == 'string' and not have[v] then list[#list + 1] = v; have[v] = true; added = added + 1 end
    end
    added_values[name] = values
    return added == 0 or relist(mode, list)
end

--- Take values out of a list mode (a weapon the player took out of a cycle in the Atelier). The current value goes
--- to the first left when it is taken out; the last value is never taken out (a mode holds one at least).
--- @return boolean true when laid
local function remove_values(mode, name, values)
    if rawget(mode, '_track')._type ~= 'list' then return false end
    local out, list = {}, {}
    for _, v in ipairs(values) do if type(v) == 'string' then out[v] = true end end
    for _, v in ipairs(mode) do if not out[v] then list[#list + 1] = v end end
    if #list == 0 then return false end
    removed_values[name] = values
    if #list == #mode then return true end
    return relist(mode, list)
end

--- Lay one scope's entries of one kind ('remove': '-Mode', 'add': '+Mode', 'start': a start value); the names
--- refused are added to `bad`. A weapon added to or taken out of a cycle in the Atelier:
--- notes/docs-perso/ajouter-arme-2026-11-01/SPEC.md.
local function lay(st, values, silent_missing, bad, kind)
    for name, value in pairs(type(values) == 'table' and values or {}) do
        local sign, base = nil, name
        if type(name) == 'string' then sign, base = name:match('^([%+%-])(.+)$') end
        base = base or name
        local entry = sign == '+' and 'add' or sign == '-' and 'remove' or 'start'
        local mode = type(base) == 'string' and mode_of(st, base)
        if entry ~= kind then
            -- another pass's entry
        elseif sign then
            local laid = mode and type(value) == 'table' and (sign == '+' and add_values or remove_values)(mode, base, value)
            if not laid and not (silent_missing and not mode) then bad[#bad + 1] = name end
        elseif mode and type(value) == 'string' then
            local before = tostring(mode.current)
            if pcall(mode.set, mode, value) then
                if file_values[name] == nil then file_values[name] = before end
            else
                bad[#bad + 1] = name .. ' = ' .. value
            end
        elseif not (silent_missing and not mode) then
            bad[#bad + 1] = tostring(name) .. ' = ' .. tostring(value)
        end
    end
end

--- Lay the character's start values over the job's modes, once per job load.
--- @param job string Job code ("WHM")
function ModeOverrides.apply(job)
    local st = rawget(_G, 'state')
    if type(st) ~= 'table' or applied[st] then return end
    applied[st] = true
    local data = ModeOverrides.read()
    if not data then return end
    local bad = {}
    -- the values taken out, then the ones added, then the start values (a start value may name a value added)
    for _, kind in ipairs({'remove', 'add', 'start'}) do
        lay(st, data.common, true, bad, kind)
        lay(st, data[job], false, bad, kind)
    end
    if #bad > 0 then
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter and MessageFormatter.show_error then
            MessageFormatter.show_error('Atelier start values ignored (' .. FILE .. '): ' .. table.concat(bad, ', '))
        end
    end
end

--- The values the Atelier added to each mode (for its export): {Mode = {value, ...}}
--- @return table
function ModeOverrides.added_values()
    return added_values
end

--- The values the Atelier took out of each mode: {Mode = {value, ...}}
--- @return table
function ModeOverrides.removed_values()
    return removed_values
end

--- The value each overridden mode had from its states file before the override (for the Atelier export).
--- @return table {Mode = value}
function ModeOverrides.file_values()
    return file_values
end

_G.ModeOverrides = ModeOverrides
return ModeOverrides
