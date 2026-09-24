---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Idle Module - Idle Set Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Mote idle hook for Paladin. Delegates to SetBuilder.build_idle_set
---   (town, weapon/shield, HybridMode set, Xp/Regen overlays, movement gear,
---   mode shield and ammo).
---
---   @file    shared/jobs/pld/functions/PLD_IDLE.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil
local MessageFormatter = nil

---   Build the idle set, with optional //gs c debugupdate timing trace
---   @param idleSet table The idle set Mote selected
---   @return table Idle set to wear
function customize_idle_set(idleSet)
    local debug_start
    if _G.UPDATE_DEBUG then
        if not MessageFormatter then MessageFormatter = require('shared/utils/messages/message_formatter') end
        debug_start = os.clock()
        MessageFormatter.show_debug('PLD', string.format('[UPDATE_DEBUG] 4. customize_idle_set CALLED | t=%.3f', debug_start))
    end

    if not SetBuilder then
        SetBuilder = require('shared/jobs/pld/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    local result = SetBuilder.build_idle_set(idleSet)

    if _G.UPDATE_DEBUG and debug_start then
        local debug_end = os.clock()
        MessageFormatter.show_debug('PLD', string.format('[UPDATE_DEBUG] 5. customize_idle_set DONE | took=%.3fms', (debug_end - debug_start) * 1000))
    end

    return result
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set
