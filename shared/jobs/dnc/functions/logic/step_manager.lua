---============================================================================
--- Step Manager - Step + Presto Management (Logic Module)
---============================================================================
--- Handles step command with Presto integration and intelligent step alternation.
---
--- Features:
---   • Presto auto-trigger before Steps (if available and level 77+)
---   • Step alternation support (MainStep ↔ AltStep rotation)
---   • UseAltStep toggle (On = alternate, Off = MainStep only)
---   • CurrentStep state tracking (Main/Alt position in rotation)
---   • Intelligent recast checking (aborts if Step on cooldown)
---   • Cooldown message display (formatted with job tag)
---   • Automatic state toggling after each step
---
--- Usage:
---   • //gs c step - Execute step with Presto if available
---   • Alt+5 toggle UseAltStep - Enable/disable alternation
---   • Alt+3/4 cycle MainStep/AltStep - Change step abilities
---
--- @file    jobs/dnc/functions/logic/step_manager.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local StepManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrappers for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast == 0)
    end
end

local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)
    end
end

---============================================================================
--- STEP EXECUTION
---============================================================================

--- Execute step with Presto integration and alternation support
function StepManager.execute_step()
    -- Check if alternating is enabled
    local use_alternation = state.UseAltStep and state.UseAltStep.value == 'On'

    -- Determine which step to use
    local step_name
    if use_alternation then
        -- Alternation enabled - use CurrentStep to track position
        -- CurrentStep = 'Main' (default) >> use MainStep first
        -- CurrentStep = 'Alt' >> use AltStep second
        if state.CurrentStep and state.CurrentStep.value == 'Alt' then
            step_name = state.AltStep.value
        else
            step_name = state.MainStep.value  -- Default: start with Main
        end
    else
        -- Alternation disabled - always use MainStep
        step_name = state.MainStep.value
    end

    -- Check step recast FIRST (Steps use ability recast_id 220)
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local step_recast = ability_recasts[220] or 0

    -- If step on cooldown, show recast and ABORT completely (don't launch anything)
    if is_on_cooldown(step_recast) then
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_ability_cooldown(step_name, step_recast, job_tag)
        return -- EXIT - don't launch Presto or Step
    end

    -- Step is ready, check Presto availability (recast_id 236)
    local presto_recast = ability_recasts[236] or 0
    local presto_available = is_recast_ready(presto_recast) and
                             not buffactive['Presto'] and
                             player.main_job_level >= 77

    -- Execute: Presto+Step if available, otherwise Step only
    if presto_available then
        send_command('input /ja "Presto" <me>; wait 1; input /ma "' .. step_name .. '" <t>')
    else
        send_command('input /ma "' .. step_name .. '" <t>')
    end

    -- Toggle CurrentStep for next step ONLY if alternation is enabled
    if use_alternation and state.CurrentStep then
        if state.CurrentStep.value == 'Main' then
            state.CurrentStep:set('Alt')
        else
            state.CurrentStep:set('Main')
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return StepManager
