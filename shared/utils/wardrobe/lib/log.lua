---============================================================================
--- Wardrobe Organizer - Debug Log
---============================================================================
--- Appends to <Character>/logs/wardrobe/wardrobe_debug.log when Config.DEBUG_LOG
--- is true (one file for every character in data/ before 2026-10-07: two boxes
--- overwrote each other's; Config.LOG_PATH is where it goes with no character).
--- Truncates the file at the start of each run via dlog_clear().
---
--- Also provides bag_name(bag_id) used for human-readable log lines.
---
--- @file shared/utils/wardrobe/lib/log.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-05-01
---============================================================================

local Config = require('shared/utils/wardrobe/lib/config')

local Log = {}

--- The character's log file, else the shared one.
local function log_path()
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').log('wardrobe', 'wardrobe_debug.log')
    end)
    return ok and path or Config.LOG_PATH
end

--- Append one line to the debug log file (no-op if DEBUG_LOG is false).
--- @param line any Text to log (passed through tostring)
function Log.dlog(line)
    if not Config.DEBUG_LOG then
        return
    end
    local f = io.open(log_path(), 'a')
    if f then
        f:write(os.date('[%H:%M:%S] ') .. tostring(line) .. '\n')
        f:close()
    end
end

--- Truncate the debug log file (called at the start of a fresh run).
function Log.dlog_clear()
    local f = io.open(log_path(), 'w')
    if f then
        f:close()
    end
end

--- Convert a bag id to its human-readable label (W1..W8, inv, Sack...).
--- Falls back to 'b<id>' for unknown bag ids.
--- @param b number Bag id
--- @return string Label
function Log.bag_name(b)
    return Config.BAG_LABELS[b] or ('b' .. tostring(b))
end

return Log
