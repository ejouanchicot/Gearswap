---============================================================================
--- Message Buffs - Buff status display functions
---============================================================================
--- @file utils/message_buffs.lua
--- @author Tetsouo
--- @version 1.1
--- @date Updated: 2025-10-02 - Migrated to centralized colors
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS  -- Centralized color configuration
local MessageCooldowns = require('shared/utils/messages/message_cooldowns')
local MessageBuffs = {}

--- Display buff status with color formatting (one buff per line)
--- @param buffs_data table Array of buff status objects
---   Each object: { name = string, status = string, time = number (optional), action_type = string (optional) }
---   Status values: 'active', 'cooldown', 'excluded'
--- @param action_type string Optional action type override ("Ability" or "Magic"), defaults to "Ability"
function MessageBuffs.show_buff_status(buffs_data, action_type)
    if not buffs_data or #buffs_data == 0 then return end

    -- Default to "Ability" for backwards compatibility with WAR/PLD/DNC
    local default_action_type = action_type or "Ability"

    -- Get dynamic job tag (e.g., "WAR/SAM", "PLD/BLU")
    local job_tag = MessageCore.get_job_tag()

    -- Separator at the top of the block
    local separator = string.rep("=", 50)
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    add_to_chat(1, colorGray .. separator)

    -- Display each buff using professional cooldown format (no separators per line)
    for _, buff in ipairs(buffs_data) do
        -- Use buff-specific action_type if provided, otherwise use default
        local buff_action_type = buff.action_type or default_action_type

        if buff.status == 'active' then
            MessageCooldowns.show_cooldown_message(job_tag, buff_action_type, buff.name, nil, "Active", true)
        elseif buff.status == 'ready' then
            MessageCooldowns.show_cooldown_message(job_tag, buff_action_type, buff.name, nil, "Ready", true)
        elseif buff.status == 'cooldown' then
            MessageCooldowns.show_cooldown_message(job_tag, buff_action_type, buff.name, buff.time or 0, nil, true)
        end
        -- Note: 'excluded' status is no longer used (excluded buffs are filtered before display)
    end

    -- Separator at the bottom of the block
    add_to_chat(1, colorGray .. separator)
end

-- Make it globally available for GearSwap include() system
function show_war_buff_status(buffs_data)
    MessageBuffs.show_buff_status(buffs_data)
end

function show_pld_buff_status(buffs_data)
    MessageBuffs.show_buff_status(buffs_data)
end

function show_run_buff_status(buffs_data)
    MessageBuffs.show_buff_status(buffs_data)
end

function show_dnc_buff_status(buffs_data)
    MessageBuffs.show_buff_status(buffs_data)
end

function show_thf_buff_status(buffs_data)
    MessageBuffs.show_buff_status(buffs_data)
end

return MessageBuffs