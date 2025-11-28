---============================================================================
--- Rune Manager - Rune Ability Management (RUN/RUN)
---============================================================================
--- Manages Rune ability usage based on state.RuneMode selection.
--- Provides intelligent automation for:
---   • Mode-based rune selection (Sulpor/Lux/etc.)
---   • Cooldown tracking and validation
---   • Professional message display
---
--- Features:
---   • Dynamic rune selection from state.RuneMode
---   • Automatic cooldown checking
---   • User-friendly error messages
---
--- @file    jobs/run/functions/logic/rune_manager.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-06
---============================================================================
local RuneManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

---============================================================================
--- RUNE EXECUTION
---============================================================================

--- Execute the currently selected rune from state.RuneMode
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

    -- Check cooldown (with fallback if RECAST_CONFIG not loaded)
    local is_on_cooldown = false
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        is_on_cooldown = RECAST_CONFIG.on_cooldown(recast)
    else
        -- Fallback: simple check (no tolerance)
        is_on_cooldown = (recast > 0)
    end

    if is_on_cooldown then
        -- Ability on cooldown - show cooldown message
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_ability_cooldown(selected_rune, recast, job_tag)
        return
    end

    -- Ability ready - execute rune (message handled by ability_message_handler)
    -- NOTE: Message display is handled by universal ability_message_handler system
    --       which loads RUN_JA_DATABASE and shows description (e.g., "Ignis Fire rune, resist ice")
    send_command('@input /ja "' .. selected_rune .. '" <me>')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RuneManager
