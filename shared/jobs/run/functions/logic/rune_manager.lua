---  ═══════════════════════════════════════════════════════════════════════════
---   Rune Manager - Rune Ability Management (RUN)
---  ═══════════════════════════════════════════════════════════════════════════
---   Manages Rune ability usage based on state.RuneMode selection.
---   Provides intelligent automation for:
---   • Mode-based rune selection (Sulpor/Lux/etc.)
---   • Cooldown check before casting
---
---   Features:
---   • Dynamic rune selection from state.RuneMode
---   • Cooldown message instead of a cast when on recast
---
---   @file    shared/jobs/run/functions/logic/rune_manager.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════
local RuneManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')

-- is_on_cooldown resolved as global from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

---  ═══════════════════════════════════════════════════════════════════════════
---   RUNE EXECUTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Execute the currently selected rune from state.RuneMode
function RuneManager.execute_rune()
    if not state or not state.RuneMode then
        MessageFormatter.show_error("RuneMode state not available")
        return
    end

    local selected_rune = state.RuneMode.current or state.RuneMode.value
    if not selected_rune then
        MessageFormatter.show_error("No rune selected in RuneMode")
        return
    end

    -- Check if ability is available (not on cooldown)
    local res = require('resources')
    local ability_data = res.job_abilities:with('en', selected_rune)

    if not ability_data then
        MessageFormatter.show_error("Rune ability not found: " .. selected_rune)
        return
    end

    -- Check recast
    local recasts = windower.ffxi.get_ability_recasts()
    local recast_id = ability_data.recast_id
    local recast = recasts[recast_id] or 0

    if is_on_cooldown(recast) then
        -- Ability on cooldown - show cooldown message
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_ability_cooldown(selected_rune, recast, job_tag)
        return
    end

    -- No message here: ability_message_handler shows the rune description
    -- from RUN_JA_DATABASE when the ability is used.
    send_command('@input /ja "' .. selected_rune .. '" <me>')
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return RuneManager
