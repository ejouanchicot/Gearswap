---  ═══════════════════════════════════════════════════════════════════════════
---   DebugLogger - Centralized Flag-Gated Debug Logging
---  ═══════════════════════════════════════════════════════════════════════════
---   Replaces the boilerplate
---     if _G.SOMEFLAG_DEBUG then
---         add_to_chat(207, string.format('[Tag] msg %d', x))
---     end
---   with a single line:
---     DebugLogger.logf_if('SOMEFLAG_DEBUG', 'Tag', 'msg %d', x)
---
---   Lazy-loads MessageFormatter only on first call - if the flag is never
---   enabled, MessageFormatter is never required (zero cost at module load).
---
---   Color matches MessageFormatter.show_debug (color 8 = gray) for visual
---   consistency with the entry-point and BLM/BRD midcast debug traces.
---
---   Public API:
---     • log(prefix, message)              always-on log (no flag check)
---     • logf(prefix, fmt, ...)            always-on log with string.format
---     • log_if(flag_key, prefix, msg)     no-op if _G[flag_key] is falsy
---     • logf_if(flag_key, prefix, fmt, ...) idem with string.format
---
---   Scope: intended for INTERNAL system traces (AutoMove, JCM, UI lifecycle)
---   that the user can toggle on/off via flag commands. NOT for user-visible
---   command output (which should call MessageFormatter directly).
---
---   @file    shared/utils/debug/debug_logger.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09
---  ═══════════════════════════════════════════════════════════════════════════

local DebugLogger = {}

-- Lazy-loaded MessageFormatter - cached after first use
local MessageFormatter = nil

local function get_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return MessageFormatter
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ALWAYS-ON LOGGING (operational events visible regardless of flags)
---  ═══════════════════════════════════════════════════════════════════════════

--- Log a debug message (no flag check).
--- @param prefix string Tag (e.g. 'AutoMove', 'JCM') - shown as "[prefix] message"
--- @param message string The message body
function DebugLogger.log(prefix, message)
    get_formatter().show_debug(prefix, message)
end

--- Log with string.format (avoids manual format on caller side).
--- @param prefix string Tag
--- @param fmt string Format string for string.format()
--- @param ... any Format arguments
function DebugLogger.logf(prefix, fmt, ...)
    get_formatter().show_debug(prefix, string.format(fmt, ...))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   FLAG-GATED LOGGING (no-op when flag is off)
---  ═══════════════════════════════════════════════════════════════════════════

--- Conditional log: no-op if _G[flag_key] is falsy.
--- @param flag_key string Global flag name (e.g. 'AUTOMOVE_DEBUG', 'JOBCHANGE_DEBUG')
--- @param prefix string Tag
--- @param message string The message body
function DebugLogger.log_if(flag_key, prefix, message)
    if not _G[flag_key] then return end
    get_formatter().show_debug(prefix, message)
end

--- Conditional log with string.format.
--- @param flag_key string Global flag name
--- @param prefix string Tag
--- @param fmt string Format string for string.format()
--- @param ... any Format arguments
function DebugLogger.logf_if(flag_key, prefix, fmt, ...)
    if not _G[flag_key] then return end
    get_formatter().show_debug(prefix, string.format(fmt, ...))
end

return DebugLogger
