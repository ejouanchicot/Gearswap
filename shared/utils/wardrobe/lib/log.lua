---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Debug Log
---  ═══════════════════════════════════════════════════════════════════════════
---   Appends to <addon>/data/wardrobe_debug.log when Config.DEBUG_LOG is true.
---   Truncates the file at the start of each run via dlog_clear().
---
---   Also provides bag_name(bag_id) used for human-readable log lines.
---
---   @file shared/utils/wardrobe/lib/log.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')

local Log = {}

--- Append one line to the debug log file (no-op if DEBUG_LOG is false).
function Log.dlog(line)
    if not Config.DEBUG_LOG then
        return
    end
    local f = io.open(Config.LOG_PATH, 'a')
    if f then
        f:write(os.date('[%H:%M:%S] ') .. tostring(line) .. '\n')
        f:close()
    end
end

--- Truncate the debug log file (called at the start of a fresh run).
function Log.dlog_clear()
    local f = io.open(Config.LOG_PATH, 'w')
    if f then
        f:close()
    end
end

--- Convert a bag id to its human-readable label (W1, W2, W3..W8, inv).
--- Falls back to 'b<id>' for unknown bag ids.
function Log.bag_name(b)
    return Config.BAG_LABELS[b] or ('b' .. tostring(b))
end

return Log
