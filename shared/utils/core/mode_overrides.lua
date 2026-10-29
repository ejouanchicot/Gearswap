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

--- Lay one scope's values; the names refused are added to `bad`.
local function lay(st, values, silent_missing, bad)
    for name, value in pairs(type(values) == 'table' and values or {}) do
        local mode = type(name) == 'string' and mode_of(st, name)
        if mode and type(value) == 'string' then
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
    lay(st, data.common, true, bad)
    lay(st, data[job], false, bad)
    if #bad > 0 then
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter and MessageFormatter.show_error then
            MessageFormatter.show_error('Atelier start values ignored (' .. FILE .. '): ' .. table.concat(bad, ', '))
        end
    end
end

--- The value each overridden mode had from its states file before the override (for the Atelier export).
--- @return table {Mode = value}
function ModeOverrides.file_values()
    return file_values
end

_G.ModeOverrides = ModeOverrides
return ModeOverrides
