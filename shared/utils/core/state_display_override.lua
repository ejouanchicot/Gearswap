---  ═══════════════════════════════════════════════════════════════════════════
---   State Display Override - Conditional State Change Messages
---  ═══════════════════════════════════════════════════════════════════════════
---   Replaces Mote-Include's display_current_state() for all jobs (installed
---   by INIT_SYSTEMS at +0.5 s). Mote calls it with no arguments, only from
---   `gs c update user` (F12) - Mote-SelfCommands.lua:256.
---     • HUD enabled in the settings (_G.ui_display_config.enabled) → silent
---     • HUD disabled → one show_state_display line. Since Mote passes no
---       arguments, that line always reads "State: Unknown" (see
---       docs/dev/systems/ui-overlay.md, Known issues).
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

--- Install the replacement _G.display_current_state. The replacement keeps a
--- (new_current_state, state_name, _old_state) signature, but Mote's only
--- caller passes nothing, so both are nil and the 'State' / 'Unknown'
--- fallbacks are what gets shown.
function StateDisplayOverride.init()
    _G.display_current_state = function(new_current_state, state_name, _old_state)
        -- The settings flag, not whether the HUD is actually shown right now
        if _G.ui_display_config and _G.ui_display_config.enabled then
            return
        end

        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_state_display(state_name or 'State', new_current_state or 'Unknown')
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return StateDisplayOverride
