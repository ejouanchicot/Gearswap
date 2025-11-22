---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Jump Manager - Intelligent Jump System for Sub-DRG
---  ═══════════════════════════════════════════════════════════════════════════
---   Centralized jump management for any job with DRG subjob.
---   Handles Jump/High Jump rotation with TP-based decision making.
---
---   Performance: Optimized 0.8s animation delay (down from 1.5s)
---
---   @file    shared/utils/drg/DRG_JUMP_MANAGER.lua
---   @author  Tetsouo
---   @version 1.4 - Use centralized MessageCooldowns system (proper colors)
---   @date    Created: 2025-10-04 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')

local DRGJumpManager = {}

-- Load recast tolerance configuration
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrapper for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        -- Fallback: simple check (no tolerance)
        return (recast == 0)
    end
end

--- Handle smart jump command with TP checking
--- Uses Jump first, High Jump as fallback
--- Chains jumps only if TP < 1000 after first jump
function DRGJumpManager.execute_jump()
    -- Check if player has DRG subjob
    if not player or player.sub_job ~= 'DRG' then
        MessageFormatter.show_error("Requires DRG subjob")
        return
    end

    -- ODYSSEY FIX: Check if subjob is active (level > 0)
    -- In Odyssey Sheol Gaol, player.sub_job_level = 0 (subjob disabled)
    if not player.sub_job_level or player.sub_job_level == 0 then
        MessageFormatter.show_error("Subjob disabled (Odyssey Sheol Gaol)")
        return
    end

    -- Check initial TP - if already >=1000, don't jump
    if player.tp >= 1000 then
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_tp_ready(job_tag, 1000)
        return
    end

    local ability_recasts = windower.ffxi.get_ability_recasts()
    if not ability_recasts then return end

    local jump_recast = ability_recasts[158] or 0        -- Jump recast_id
    local high_jump_recast = ability_recasts[159] or 0   -- High Jump recast_id

    -- Determine which jump to use first
    local first_jump, second_jump

    if is_recast_ready(jump_recast) then
        -- Jump ready - use it first
        first_jump = "Jump"
        second_jump = "High Jump"
    elseif is_recast_ready(high_jump_recast) then
        -- Jump on cooldown, use High Jump first
        first_jump = "High Jump"
        second_jump = "Jump"
    else
        -- Both on cooldown - show grouped recasts using centralized system
        local job_tag = MessageFormatter.get_job_tag()
        local messages = {
            { type = "cooldown", name = "Jump", value = jump_recast, action_type = "Ability" },
            { type = "cooldown", name = "High Jump", value = high_jump_recast, action_type = "Ability" }
        }
        MessageCooldowns.show_multi_status(messages, job_tag)
        return
    end

    -- Execute first jump
    send_command('input /ja "' .. first_jump .. '" <t>')

    -- Schedule TP check after first jump (1.0s delay - allows first jump animation to complete)
    coroutine.schedule(function()
        -- Re-check TP after first jump
        if player and player.tp < 1000 then
            -- Still below 1000 TP, check if second jump available
            local recasts = windower.ffxi.get_ability_recasts()
            if not recasts then return end

            local second_jump_recast = (second_jump == "Jump") and (recasts[158] or 0) or (recasts[159] or 0)

            if is_recast_ready(second_jump_recast) then
                -- Second jump ready, execute it
                send_command('input /ja "' .. second_jump .. '" <t>')
            end
        end
        -- If TP ≥ 1000 after first jump, do nothing (stop chaining)
    end, 1.0)
end

return DRGJumpManager
