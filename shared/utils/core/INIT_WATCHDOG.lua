---============================================================================
--- Watchdog Auto-Initialization
---============================================================================
--- Auto-loads and starts the midcast watchdog on GearSwap load.
--- Include this file in your character main file to enable watchdog protection.
---
--- Usage in character file (e.g., Tetsouo_WAR.lua):
---   include('shared/utils/core/INIT_WATCHDOG.lua')
---
--- @file INIT_WATCHDOG.lua
--- @author Tetsouo
--- @version 3.0 - Simplified (no global hooks)
--- @date Created: 2025-10-25
---============================================================================

-- Load the watchdog system
local success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')

if not success then
    add_to_chat(167, '[Watchdog] Failed to load: ' .. tostring(MidcastWatchdog))
    return
end

-- Store in global for command access
_G.MidcastWatchdog = MidcastWatchdog

-- Delay watchdog start to avoid load conflicts
-- Start after GearSwap is fully initialized
coroutine.schedule(function()
    MidcastWatchdog.start()
    -- Silent init - no message displayed
end, 2.0)  -- 2 second delay
