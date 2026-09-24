---  ═══════════════════════════════════════════════════════════════════════════
---   Step Manager - Step + Presto Management (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles step command with Presto integration and intelligent step alternation.
---
---   Features:
---   • Presto auto-trigger before Steps (if available and level 77+)
---   • Step alternation support (MainStep ↔ AltStep rotation)
---   • UseAltStep toggle (On = alternate, Off = MainStep only)
---   • CurrentStep state tracking (Main/Alt position in rotation)
---   • Intelligent recast checking (aborts if Step on cooldown)
---   • Cooldown message display (formatted with job tag)
---   • Automatic state toggling after each step
---
---   Usage:
---   • //gs c step - Execute step with Presto if available
---   • Ctrl+Numpad5 cycles UseAltStep - Enable/disable alternation
---   • Ctrl+Numpad3/4 cycle MainStep/AltStep - Change step abilities
---     (keys from config/dnc/DNC_KEYBINDS.lua)
---
---   @file    shared/jobs/dnc/functions/logic/step_manager.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

local StepManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- is_recast_ready / is_on_cooldown resolved as globals from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

---  ═══════════════════════════════════════════════════════════════════════════
---   STEP EXECUTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Execute step with Presto integration and alternation support
function StepManager.execute_step()
    local use_alternation = state.UseAltStep and state.UseAltStep.value == 'On'

    local step_name
    if use_alternation then
        if state.CurrentStep and state.CurrentStep.value == 'Alt' then
            step_name = state.AltStep.value
        else
            step_name = state.MainStep.value  -- Default: start with Main
        end
    else
        step_name = state.MainStep.value
    end

    -- Check step recast FIRST (Steps use ability recast_id 220)
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local step_recast = ability_recasts[220] or 0

    -- Step on cooldown: abort before Presto so it is not wasted
    if is_on_cooldown(step_recast) then
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_ability_cooldown(step_name, step_recast, job_tag)
        return
    end

    -- Step is ready, check Presto availability (recast_id 236)
    local presto_recast = ability_recasts[236] or 0
    local presto_available = is_recast_ready(presto_recast) and
                             not buffactive['Presto'] and
                             player.main_job_level >= 77

    -- Execute: Presto+Step if available, otherwise Step only
    if presto_available then
        -- Presto raises the step's tier, so the step is worth waiting for it -
        -- but it still fires if the game refuses the ability.
        local AbilityHelper = require('shared/utils/precast/ability_helper')
        send_command('input /ja "Presto" <me>')
        AbilityHelper.follow_up('Presto', 'input /ja "' .. step_name .. '" <t>', 1)
    else
        send_command('input /ja "' .. step_name .. '" <t>')
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return StepManager
