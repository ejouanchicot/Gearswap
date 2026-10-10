---============================================================================
--- Lockstyle Configuration - Centralized Lockstyle Timing Settings
---============================================================================
--- User-configurable settings for lockstyle application timing.
--- These delays are critical to prevent FFXI "Style lock mode disabled" errors.
---
--- FFXI enforces a cooldown on /lockstyleset commands. Through testing, 8 seconds
--- has been determined as the optimal delay that:
--- - Prevents "Style lock mode disabled" errors
--- - Allows rapid job switching without conflicts
--- - Provides enough time for DressUp addon management
---
--- Loaded by every job entry file (pcall require) and exposed as
--- _G.LockstyleConfig. Its one setting is initial_load_delay.
---
--- @file _common/display/LOCKSTYLE_CONFIG.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2025-10-03
---============================================================================
local LockstyleConfig = {}

---============================================================================
--- TIMING SETTINGS
---============================================================================

-- Initial load delay (when first loading job file or changing main job)
-- Read by every Tetsouo_<JOB>.lua entry file and by message_system.lua
-- Recommended: 8.0 seconds (tested and validated)
LockstyleConfig.initial_load_delay = 8.0

-- initial_load_delay is the only setting. There used to be job_change_delay
-- and cooldown here: nothing read them, so changing them did nothing
-- (removed 2026-09-29).

---============================================================================
--- NOTES
---============================================================================

-- Testing Results (2025-10-03):
-- - 5 seconds: Too short, causes "Style lock mode disabled" errors
-- - 7 seconds: Still too short for rapid job switching
-- - 8 seconds: Optimal - works even with rapid WAR >> PLD >> WAR switching
-- - 10+ seconds: Safe but unnecessarily slow

-- DressUp Addon Management:
-- Lockstyle application sequence with DressUp management on
-- (shared/utils/lockstyle/lockstyle_manager.lua, toggled by //gs c dressup):
--   1. Unload DressUp addon
--   2. Apply /lockstyleset command 0.3s later
--   3. Reload DressUp addon 3.0s after step 1

return LockstyleConfig
