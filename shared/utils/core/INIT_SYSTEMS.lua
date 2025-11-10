---============================================================================
--- Universal Systems Auto-Initialization Façade
---============================================================================
--- Loads all universal systems that should be active for ALL jobs/characters.
--- Include this file in each job's main file to enable all universal features.
---
--- Usage in character file (e.g., Tetsouo_WAR.lua, KAORIES_BRD.lua):
---   include('../shared/utils/core/INIT_SYSTEMS.lua')
---
--- Systems Initialized:
---   1. Midcast Watchdog (3.5s timeout protection)
---   2. Warp System (universal warp detection + IPC multi-boxing)
---   3. (Future systems can be added here)
---
--- @file INIT_SYSTEMS.lua
--- @author Tetsouo
--- @version 1.1 - Improved formatting - Universal Systems Façade
--- @date Created: 2025-10-28 | Updated: 2025-11-06
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageInit = require('shared/utils/messages/formatters/system/message_init')

---============================================================================
--- SYSTEM 1: MIDCAST WATCHDOG
---============================================================================

local watchdog_success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')

if watchdog_success and MidcastWatchdog then
    -- Store in global for command access
    _G.MidcastWatchdog = MidcastWatchdog

    -- Delay watchdog start to avoid load conflicts
    coroutine.schedule(function()
        MidcastWatchdog.start()
        -- Silent init - no message displayed
    end, 2.0)  -- 2 second delay
else
    MessageInit.show_module_load_failed('Watchdog', MidcastWatchdog)
end

---============================================================================
--- SYSTEM 2: WARP SYSTEM (with IPC Multi-Boxing Support)
---============================================================================

local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')

if warp_success and WarpInit then
    WarpInit.init()
else
    MessageInit.show_module_load_failed('Warp System', WarpInit)
end

---============================================================================
--- SYSTEM 3: AUTOMOVE (Movement Detection)
---============================================================================

-- Check if job wants to disable AutoMove (e.g., BST for performance)
if not _G.DISABLE_AUTOMOVE then
    -- AutoMove initializes automatically via include()
    -- Jobs must define: sets.MoveSpeed = { legs="..." }
    local automove_success = pcall(include, '../shared/utils/movement/automove.lua')

    if not automove_success then
        MessageInit.show_module_load_failed('AutoMove', 'include failed')
    end
else
    -- AutoMove disabled by job (custom movement system used)
    add_to_chat(8, '[INIT_SYSTEMS] AutoMove disabled by job request')
end

---============================================================================
--- SYSTEM 4: STATE DISPLAY OVERRIDE (Conditional State Messages)
---============================================================================

local state_display_success, StateDisplayOverride = pcall(require, 'shared/utils/core/state_display_override')

if state_display_success and StateDisplayOverride then
    StateDisplayOverride.init()
    -- Silent init - overrides Mote-Include's display_current_state globally
else
    MessageInit.show_module_load_failed('State Display Override', StateDisplayOverride)
end

---============================================================================
--- SYSTEM 5: FUTURE SYSTEMS
---============================================================================

-- Example template for adding new universal systems:
--
-- local system_success, SystemModule = pcall(require, 'shared/utils/path/to/system')
-- if system_success and SystemModule then
--     SystemModule.init()
-- else
--     MessageInit.show_module_load_failed('System', SystemModule)
-- end

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- Note: Individual system messages will show their initialization status above
