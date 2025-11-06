---============================================================================
--- DRG Jump Manager - Intelligent Jump System for Sub-DRG
---============================================================================
--- Centralized jump management for any job with DRG subjob.
--- Handles Jump/High Jump rotation with TP-based decision making.
---
--- Performance: Optimized 0.8s animation delay (down from 1.5s)
---
--- @file utils/drg/DRG_JUMP_MANAGER.lua
--- @author Tetsouo
--- @version 1.1 - Optimized Timing
--- @date Created: 2025-10-04
--- @date Updated: 2025-10-10 (Optimized lag: 1.5s→0.8s)
---============================================================================

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

-- Load message system for formatted output
include('../shared/utils/messages/message_buffs.lua')

--- Handle smart jump command with TP checking
--- Uses Jump first, High Jump as fallback
--- Chains jumps only if TP < 1000 after first jump
function DRGJumpManager.execute_jump()
    -- Check if player has DRG subjob
    if not player or player.sub_job ~= 'DRG' then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        if MessageFormatter then
            MessageFormatter.show_error("Requires DRG subjob")
        else
            add_to_chat(167, '[Jump] Requires DRG subjob')
        end
        return
    end

    -- ODYSSEY FIX: Check if subjob is active (level > 0)
    -- In Odyssey Sheol Gaol, player.sub_job_level = 0 (subjob disabled)
    if not player.sub_job_level or player.sub_job_level == 0 then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        if MessageFormatter then
            MessageFormatter.show_error("Subjob disabled (Odyssey Sheol Gaol)")
        else
            add_to_chat(167, '[Jump] Subjob disabled (level 0 - Odyssey)')
        end
        return
    end

    -- Check initial TP - if already >=1000, don't jump
    if player.tp >= 1000 then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        local job_tag = MessageFormatter.get_job_tag()
        MessageFormatter.show_tp_ready(job_tag, 1000)
        return
    end

    local ability_recasts = windower.ffxi.get_ability_recasts()
    local jump_recast = ability_recasts[158] or 0        -- Jump recast_id
    local high_jump_recast = ability_recasts[159] or 0   -- High Jump recast_id

    -- Determine which jump to use first
    local first_jump, second_jump
    local first_recast, second_recast

    if is_recast_ready(jump_recast) then
        -- Jump ready - use it first
        first_jump = "Jump"
        second_jump = "High Jump"
        first_recast = jump_recast
        second_recast = high_jump_recast
    elseif is_recast_ready(high_jump_recast) then
        -- Jump on cooldown, use High Jump first
        first_jump = "High Jump"
        second_jump = "Jump"
        first_recast = high_jump_recast
        second_recast = jump_recast
    else
        -- Both on cooldown - show grouped recasts
        local status_data = {
            { name = 'Jump', status = 'cooldown', time = math.ceil(jump_recast) },
            { name = 'High Jump', status = 'cooldown', time = math.ceil(high_jump_recast) }
        }

        -- Use job-appropriate buff status display
        if show_dnc_buff_status then
            show_dnc_buff_status(status_data)
        elseif show_war_buff_status then
            show_war_buff_status(status_data)
        elseif show_pld_buff_status then
            show_pld_buff_status(status_data)
        else
            -- Fallback to basic display
            add_to_chat(167, string.format('[Jump] Jump on cooldown (%.1fs)', jump_recast))
            add_to_chat(167, string.format('[Jump] High Jump on cooldown (%.1fs)', high_jump_recast))
        end
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
