---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Engaged Module - Combat Set Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   DT/Enspell/Refresh/TP modes, dual wield detection, weapon overlay.
---
---   @file    PLD_ENGAGED.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil
local MessageFormatter = nil

function customize_melee_set(meleeSet)
    -- DEBUG: Trace customize_melee_set call
    local debug_start
    if _G.UPDATE_DEBUG then
        if not MessageFormatter then MessageFormatter = require('shared/utils/messages/message_formatter') end
        debug_start = os.clock()
        MessageFormatter.show_debug('PLD', string.format('[UPDATE_DEBUG] 4. customize_melee_set CALLED | t=%.3f', debug_start))
    end

    -- Lazy load SetBuilder on first engage
    if not SetBuilder then
        SetBuilder = require('shared/jobs/pld/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    local result = SetBuilder.build_engaged_set(meleeSet)

    -- DEBUG: Trace customize_melee_set end
    if _G.UPDATE_DEBUG and debug_start then
        local debug_end = os.clock()
        MessageFormatter.show_debug('PLD', string.format('[UPDATE_DEBUG] 5. customize_melee_set DONE | took=%.3fms', (debug_end - debug_start) * 1000))
    end

    return result
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set
