---============================================================================
--- Log Keeper - the journals never grow without end
---============================================================================
--- Two rules, so that a year of play does not leave gigabytes of logs:
---   - a journal written line after line (logs/craft/synth.log, logs/rolls/...,
---     atelier/bag_moves.log) is moved to <name>.old.log once it passes
---     MAX_BYTES, one old copy kept (CharPaths.log does it the first time a
---     load writes there; the trace keeps its own, larger rule: trace_log.lua,
---     and the dated files are never cut: LogKeeper.rotates);
---   - in the folders of one file a day or a run (logs/fights, logs/enhtest,
---     logs/sortie: the SortieLog addon's), the files dated more than KEEP_DAYS
---     ago are deleted, once a session (from INIT_SYSTEMS, a moment after a load).
---
--- @file shared/utils/core/log_keeper.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-24
---============================================================================

local LogKeeper = {}

LogKeeper.MAX_BYTES = 2 * 1024 * 1024
LogKeeper.KEEP_DAYS = 60
-- The folders under <Character>/logs/ that hold one file a day or a run, named from its date (2026-10-13_hits.log)
LogKeeper.DATED = {'fights', 'enhtest', 'sortie'}

-- A LOGS line in the trace (//gs c trace), so a move or a prune can be seen to have run
local function trace(fmt, ...)
    local text = fmt:format(...)
    pcall(function() require('shared/utils/debug/trace_log').log('LOGS', '%s', text) end)
end

--- Move a journal to <name>.old.log once it passes MAX_BYTES (the old copy before it is deleted).
--- @param path string|nil The journal's full path
--- @return boolean True when it was moved
function LogKeeper.rotate(path)
    if type(path) ~= 'string' then return false end
    local file = io.open(path, 'rb')
    if not file then return false end
    local size = file:seek('end') or 0
    file:close()
    if size < LogKeeper.MAX_BYTES then return false end
    local old = path:gsub('%.log$', '') .. '.old.log'
    os.remove(old)
    local moved = os.rename(path, old) ~= nil
    trace('%s (%d KB) %s', path, math.floor(size / 1024), moved and 'moved to its .old.log' or 'not moved (held open?)')
    return moved
end

--- Whether CharPaths.log rotates a topic's journals: not the trace (its own 10 MB rule: trace_log.lua), not the
--- dated folders (a day's or a run's file: cut in two it would lose a boss's raw lines; KEEP_DAYS rules them)
--- @param topic string
--- @return boolean
function LogKeeper.rotates(topic)
    if topic == 'trace' then return false end
    for _, t in ipairs(LogKeeper.DATED) do if t == topic then return false end end
    return true
end

--- The time of the date a file's name starts with (2026-10-13...), or nil.
--- @param name string
--- @return number|nil
local function dated(name)
    local y, m, d = name:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)')
    if not y then return nil end
    return os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12})
end

--- Delete the dated files older than KEEP_DAYS in a character's dated log folders.
--- @param char string The character's folder name
--- @param now number|nil The time to count from (os.time() when nil)
--- @return number How many files were deleted
function LogKeeper.prune(char, now)
    if type(char) ~= 'string' or char == '' then return 0 end
    local limit, gone, seen = (now or os.time()) - LogKeeper.KEEP_DAYS * 86400, 0, 0
    local base = windower.addon_path .. 'data/' .. char .. '/logs/'
    for _, topic in ipairs(LogKeeper.DATED) do
        for _, name in ipairs(windower.get_dir(base .. topic) or {}) do
            local at = dated(name)
            if at then seen = seen + 1 end
            if at and at < limit and os.remove(base .. topic .. '/' .. name) then gone = gone + 1 end
        end
    end
    trace('prune %s: %d dated file(s) seen, %d older than %d days deleted', char, seen, gone, LogKeeper.KEEP_DAYS)
    return gone
end

--- Prune once a session for this character (the flag lives on windower, which outlives the loads).
--- @param char string The character's folder name
function LogKeeper.prune_once(char)
    windower._logs_pruned = windower._logs_pruned or {}
    if not char or windower._logs_pruned[char] then return end
    windower._logs_pruned[char] = true
    LogKeeper.prune(char)
end

return LogKeeper
