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
--- @file    config/LOCKSTYLE_CONFIG.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-03
---============================================================================
local LockstyleConfig = {}

---============================================================================
--- TIMING SETTINGS
---============================================================================

-- Initial load delay (when first loading job file or changing main job)
-- Read by every job entry file (Tetsouo_<JOB>.lua), which schedules
-- select_default_lockstyle() after this delay; also shown by message_system.lua
-- Recommended: 8.0 seconds (tested and validated)
LockstyleConfig.initial_load_delay = 8.0

-- Job change delay. Not read by any module at the moment (neither
-- job_change_manager.lua nor lockstyle_manager.lua uses it); kept for
-- compatibility with the entry files' fallback tables.
LockstyleConfig.job_change_delay = 8.0

-- Global lockstyle cooldown. Not read by any module at the moment; kept for
-- compatibility with the entry files' fallback tables.
LockstyleConfig.cooldown = 15.0

---============================================================================
--- NOTES
---============================================================================

-- Testing Results (2025-10-03):
-- - 5 seconds: Too short, causes "Style lock mode disabled" errors
-- - 7 seconds: Still too short for rapid job switching
-- - 8 seconds: Optimal - works even with rapid WAR >> PLD >> WAR switching
-- - 10+ seconds: Safe but unnecessarily slow

-- DressUp Addon Management:
-- Lockstyle application sequence with DressUp:
--   1. Unload DressUp addon
--   2. Apply /lockstyleset command (0.3s later)
--   3. Reload DressUp addon (3.0s after the unload)
-- Handled by shared/utils/lockstyle/lockstyle_manager.lua

return LockstyleConfig
