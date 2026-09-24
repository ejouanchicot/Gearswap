---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Jump Manager - Intelligent Jump System for Sub-DRG
---  ═══════════════════════════════════════════════════════════════════════════
---   Centralized jump management for any job with DRG subjob (//gs c jump).
---   Handles Jump/High Jump rotation with TP-based decision making: the second
---   jump is considered 1.0s after the first, once its TP has landed.
---
---   @file    shared/utils/drg/DRG_JUMP_MANAGER.lua
---   @author  Tetsouo
---   @version 1.4 - Use centralized MessageCooldowns system (proper colors)
---   @date    Created: 2025-10-04 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')

local DRGJumpManager = {}

-- is_recast_ready resolved as global from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

--- Handle smart jump command with TP checking
--- Uses Jump first, High Jump as fallback
--- Chains jumps only if TP < 1000 after first jump
--- @return nil
function DRGJumpManager.execute_jump()
    if not player or player.sub_job ~= 'DRG' then
        MessageFormatter.show_error("Requires DRG subjob")
        return
    end

    -- In Odyssey Sheol Gaol the subjob is disabled: sub_job_level reads 0
    if not player.sub_job_level or player.sub_job_level == 0 then
        MessageFormatter.show_error("Subjob disabled (Odyssey Sheol Gaol)")
        return
    end

    if player.tp >= 1000 then
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_tp_ready(job_tag, 1000)
        return
    end

    local ability_recasts = windower.ffxi.get_ability_recasts()
    if not ability_recasts then return end

    local jump_recast = ability_recasts[158] or 0        -- Jump recast_id
    local high_jump_recast = ability_recasts[159] or 0   -- High Jump recast_id

    local first_jump, second_jump

    if is_recast_ready(jump_recast) then
        first_jump = "Jump"
        second_jump = "High Jump"
    elseif is_recast_ready(high_jump_recast) then
        first_jump = "High Jump"
        second_jump = "Jump"
    else
        local job_tag = MessageFormatter.get_job_tag()
        local messages = {
            { type = "cooldown", name = "Jump", value = jump_recast, action_type = "Ability" },
            { type = "cooldown", name = "High Jump", value = high_jump_recast, action_type = "Ability" }
        }
        MessageCooldowns.show_multi_status(messages, job_tag)
        return
    end

    send_command('input /ja "' .. first_jump .. '" <t>')

    -- 1.0s lets the first jump's animation finish and its TP register
    coroutine.schedule(function()
        if player and player.tp < 1000 then
            local recasts = windower.ffxi.get_ability_recasts()
            if not recasts then return end

            local second_jump_recast = (second_jump == "Jump") and (recasts[158] or 0) or (recasts[159] or 0)

            if is_recast_ready(second_jump_recast) then
                send_command('input /ja "' .. second_jump .. '" <t>')
            end
        end
        -- If TP ≥ 1000 after first jump, do nothing (stop chaining)
    end, 1.0)
end

return DRGJumpManager
