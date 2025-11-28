---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all idle state logic for Red Mage job:
---   - Idle set selection based on IdleMode (DT, Refresh, Regain, Evasion)
---   - Movement speed optimization
---   - Town gear management
---   - Dynamic weapon application to idle sets
---
---   @file    shared/jobs/pld/functions/PLD_IDLE.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Apply weapon sets, mode selection, and movement gear to all idle configurations
--- @param idleSet table The idle set to customize
--- @return table Modified idle set with current weapon, mode, and movement gear
function customize_idle_set(idleSet)
    -- DEBUG: Trace customize_idle_set call
    local debug_start
    if _G.UPDATE_DEBUG then
        debug_start = os.clock()
        add_to_chat(207, string.format('[UPDATE_DEBUG] 4. customize_idle_set CALLED | t=%.3f', debug_start))
    end

    -- Lazy load SetBuilder on first idle
    if not SetBuilder then
        SetBuilder = require('shared/jobs/pld/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    local result = SetBuilder.build_idle_set(idleSet)

    -- DEBUG: Trace customize_idle_set end
    if _G.UPDATE_DEBUG and debug_start then
        local debug_end = os.clock()
        add_to_chat(207, string.format('[UPDATE_DEBUG] 5. customize_idle_set DONE | took=%.3fms', (debug_end - debug_start) * 1000))
    end

    return result
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set
