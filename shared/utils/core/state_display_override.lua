---============================================================================
--- State Display Override - Conditional State Change Messages
---============================================================================
--- Overrides Mote-Include's display_current_state() globally for all jobs.
--- Provides conditional behavior based on UI visibility:
---   • UI visible → Silent (no state change messages)
---   • UI hidden → Display Mote-Include default messages
---
--- This eliminates message spam when UI is showing state values visually.
---
--- @file    shared/utils/core/state_display_override.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-11-10
---============================================================================

local StateDisplayOverride = {}

---============================================================================
--- MOTE-INCLUDE OVERRIDE
---============================================================================

--- Override Mote-Include's display_current_state function
--- Called automatically by Mote-Include whenever a state changes (cycle, set, etc.)
---
--- @param new_current_state string New state value
--- @param state_name string Name of the state that changed
--- @param old_state string Previous state value
function StateDisplayOverride.init()
    _G.display_current_state = function(new_current_state, state_name, old_state)
        -- Check if UI is enabled and visible
        if _G.ui_display_config and _G.ui_display_config.enabled then
            -- UI visible → Silent mode (no messages needed)
            return
        end

        -- UI hidden → Display Mote-Include default message
        add_to_chat(122, state_name..': '..new_current_state)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return StateDisplayOverride
