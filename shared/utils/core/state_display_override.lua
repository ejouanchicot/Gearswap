---  ═══════════════════════════════════════════════════════════════════════════
---   State Display Override - Conditional State Change Messages
---  ═══════════════════════════════════════════════════════════════════════════
---   Overrides Mote-Include's display_current_state() globally for all jobs.
---   Provides conditional behavior based on UI visibility:
---     • UI visible → Silent (no state change messages)
---     • UI hidden → Display Mote-Include default messages
---
---   This eliminates message spam when UI is showing state values visually.
---
---   @file    shared/utils/core/state_display_override.lua
---   @author  Tetsouo
---   @version 1.2 - Robustness improvements (nil protection + unused parameter convention)
---   @date    Created: 2025-11-10 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local StateDisplayOverride = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   MOTE-INCLUDE OVERRIDE
---  ═══════════════════════════════════════════════════════════════════════════

--- Override Mote-Include's display_current_state function
--- Called automatically by Mote-Include whenever a state changes (cycle, set, etc.)
---
--- @param new_current_state string New state value
--- @param state_name string Name of the state that changed
--- @param _old_state string Previous state value (unused)
function StateDisplayOverride.init()
    _G.display_current_state = function(new_current_state, state_name, _old_state)
        -- Check if UI is enabled and visible
        if _G.ui_display_config and _G.ui_display_config.enabled then
            -- UI visible → Silent mode (no messages needed)
            return
        end

        -- UI hidden → Display Mote-Include default message (with nil protection)
        add_to_chat(122, (state_name or 'State')..': '..(new_current_state or 'Unknown'))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return StateDisplayOverride
