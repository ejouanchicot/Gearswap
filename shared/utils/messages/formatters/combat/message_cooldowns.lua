---============================================================================
--- Cooldown Message Formatter - Cooldown Display (NEW SYSTEM - HYBRID)
---============================================================================
--- Professional cooldown and recast timing messages
--- Uses hybrid approach: Templates for separators, direct rendering for dynamic messages
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_cooldowns.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageCooldowns = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS  -- Centralized color configuration

--- Format recast duration for display (exported for use by other modules)
--- @param recast number Recast time in seconds
--- @return string Formatted duration string
function MessageCooldowns.format_recast_duration(recast)
    if not recast or type(recast) ~= 'number' then
        return "0s"
    end

    if recast <= 0 then
        return "Ready"
    end

    -- For very long durations (> 1 hour), show hours
    if recast >= 3600 then
        local hours = math.floor(recast / 3600)
        local minutes = math.floor((recast % 3600) / 60)
        local seconds = recast % 60
        return string.format("%dh %02dm %02ds", hours, minutes, seconds)
    end

    -- For durations > 60 seconds, show MM:SS min format
    if recast >= 60 then
        local minutes = math.floor(recast / 60)
        local seconds = math.floor(recast % 60)
        return string.format("%02d:%02d min", minutes, seconds)
    end

    -- For short durations, show seconds with decimal
    return string.format("%.1f sec", recast)
end


---============================================================================
--- WINDOWER RECAST HELPERS (DIFFERENT TIME UNITS!)
---============================================================================

--- Get spell recast time with proper centiseconds-to-seconds conversion
--- @param spell_id number Spell ID for windower.ffxi.get_spell_recasts()
--- @return number Recast time in seconds (converted from centiseconds)
local function get_spell_recast_seconds(spell_id)
    if not spell_id then return 0 end
    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts or not spell_recasts[spell_id] then return 0 end
    -- CRITICAL: get_spell_recasts() returns centiseconds, convert to seconds
    return spell_recasts[spell_id] / 100
end

--- Get ability recast time (already in seconds)
--- @param ability_id number Ability ID for windower.ffxi.get_ability_recasts()
--- @return number Recast time in seconds (no conversion needed)
local function get_ability_recast_seconds(ability_id)
    if not ability_id then return 0 end
    local ability_recasts = windower.ffxi.get_ability_recasts()
    if not ability_recasts or not ability_recasts[ability_id] then return 0 end
    -- Ability recasts are already in seconds
    return ability_recasts[ability_id]
end

---============================================================================
--- PROFESSIONAL COOLDOWN MESSAGES
---============================================================================

--- Universal cooldown message with professional formatting
--- @param job_name string Job name (e.g., "WAR", "BRD")
--- @param action_type string Type of action ("Magic", "Ability", "WeaponSkill", "Item")
--- @param name string Name of the action
--- @param remaining number Remaining time in seconds
--- @param status string Optional status override ("Ready", "Active", etc.)
--- @param no_separators boolean Optional: true to skip separators (for use in blocks)
function MessageCooldowns.show_cooldown_message(job_name, action_type, name, remaining, status, no_separators)
    if not job_name or not action_type or not name then
        return
    end

    -- Color codes based on action type (from backup system)
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR) -- Gray-violet
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)  -- Light blue for job names
    local colorAction, actionColor

    if action_type:lower():find("magic") or action_type:lower():find("spell") then
        colorAction = MessageCore.create_color_code(Colors.SPELL) -- Cyan for magic
        actionColor = 5
    elseif action_type:lower():find("ability") or action_type:lower():find("ja") then
        colorAction = MessageCore.create_color_code(Colors.JA) -- Yellow for abilities
        actionColor = 50
    elseif action_type:lower():find("weapon") or action_type:lower():find("ws") then
        colorAction = MessageCore.create_color_code(Colors.WS) -- Yellow for weaponskills
        actionColor = 167
    else
        colorAction = MessageCore.create_color_code(Colors.ITEM_COLOR) -- Item color
        actionColor = 30
    end

    -- Separator at the top (skip if in block mode)
    if not no_separators then
        M.send('COOLDOWNS', 'separator')
    end

    -- Build message with professional formatting
    local message_parts = {}

    -- Job tag
    table.insert(message_parts, colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] ')

    -- Action type if different from job
    if action_type ~= job_name then
        table.insert(message_parts, action_type .. ': ')
    end

    -- Action name with color
    table.insert(message_parts, colorAction .. name .. colorGray)

    -- Status/time information
    if status == "Ready" then
        local colorReady = MessageCore.create_color_code(Colors.SUCCESS) -- Green
        table.insert(message_parts, ' (' .. colorReady .. 'READY' .. colorGray .. ')')
    elseif status == "Active" then
        local colorActive = MessageCore.create_color_code(Colors.SUCCESS) -- Green
        table.insert(message_parts, ' (' .. colorActive .. 'ACTIVE' .. colorGray .. ')')
    elseif remaining and remaining > 0 then
        local time_str = MessageCooldowns.format_recast_duration(remaining)
        local colorCooldown = MessageCore.create_color_code(Colors.COOLDOWN) -- Dark red for cooldowns
        table.insert(message_parts, ' (' .. colorCooldown .. time_str .. colorGray .. ')')
    end

    local final_message = table.concat(message_parts)
    MessageRenderer.send(1, final_message) -- White base color, inline colors handle the rest

    -- Separator at the bottom (skip if in block mode)
    if not no_separators then
        M.send('COOLDOWNS', 'separator')
    end
end

--- Display spell cooldown with magic-specific formatting
--- @param spell_name string Spell name
--- @param remaining_centiseconds number Remaining cooldown time in centiseconds (windower.ffxi.get_spell_recasts())
--- @param job_name string Job tag (e.g., "WAR/SAM", "PLD/BLU") - REQUIRED
function MessageCooldowns.show_spell_cooldown(spell_name, remaining_centiseconds, job_name)
    job_name = job_name or MessageCore.get_job_tag()
    -- Convert centiseconds to seconds (Magic spells from get_spell_recasts() are in centiseconds!)
    local remaining_seconds = remaining_centiseconds and (remaining_centiseconds / 100) or 0
    MessageCooldowns.show_cooldown_message(job_name, "Magic", spell_name, remaining_seconds)
end

--- Display job ability cooldown with ability-specific formatting
--- @param ability_name string Job ability name
--- @param remaining_seconds number Remaining cooldown time in seconds (windower.ffxi.get_ability_recasts())
--- @param job_name string Job tag (e.g., "WAR/SAM", "PLD/BLU") - REQUIRED
function MessageCooldowns.show_ability_cooldown(ability_name, remaining_seconds, job_name)
    job_name = job_name or MessageCore.get_job_tag()
    -- Ability recasts are already in seconds (no conversion needed)
    MessageCooldowns.show_cooldown_message(job_name, "Ability", ability_name, remaining_seconds)
end

--- Display weaponskill cooldown with WS-specific formatting
--- @param ws_name string Weaponskill name
--- @param remaining number Remaining cooldown time in seconds
--- @param job_name string Job tag (e.g., "WAR/SAM", "PLD/BLU") - REQUIRED
function MessageCooldowns.show_ws_cooldown(ws_name, remaining, job_name)
    job_name = job_name or MessageCore.get_job_tag()
    MessageCooldowns.show_cooldown_message(job_name, "WeaponSkill", ws_name, remaining)
end

--- Display item recast with item-specific formatting
--- @param item_name string Item name
--- @param remaining number Remaining recast time in seconds
--- @param job_name string Job tag (e.g., "WAR/SAM", "PLD/BLU") - REQUIRED
function MessageCooldowns.show_item_recast(item_name, remaining, job_name)
    job_name = job_name or MessageCore.get_job_tag()
    MessageCooldowns.show_cooldown_message(job_name, "Item", item_name, remaining)
end

--- Display stratagem cooldown (SCH-specific)
--- @param stratagem_name string Stratagem name
--- @param remaining number Remaining cooldown time in seconds
function MessageCooldowns.show_stratagem_cooldown(stratagem_name, remaining)
    MessageCooldowns.show_cooldown_message("SCH", "Stratagem", stratagem_name, remaining)
end

--- Display song duration alert (BRD-specific)
--- @param song_name string Song name
--- @param remaining number Remaining duration in seconds
function MessageCooldowns.show_song_duration(song_name, remaining)
    MessageCooldowns.show_cooldown_message("BRD", "Song", song_name, remaining, "Active")
end

---============================================================================
--- MULTI-MESSAGE BLOCK (grouped cooldowns/TP requirements)
---============================================================================

--- Display multiple cooldown/TP messages in a single block with shared separators
--- @param messages table Array of message objects {type="cooldown|tp", name=string, value=number, extra=number, action_type=string}
--- @param job_name string Job tag (e.g., "DNC/WAR", "PLD/BLU")
function MessageCooldowns.show_multi_status(messages, job_name)
    if not messages or #messages == 0 then return end

    job_name = job_name or MessageCore.get_job_tag()

    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorCooldown = MessageCore.create_color_code(Colors.COOLDOWN)
    local colorError = MessageCore.create_color_code(Colors.ERROR)

    -- Top separator
    M.send('COOLDOWNS', 'separator')

    -- Display each message
    for _, msg in ipairs(messages) do
        local message_parts = {}

        -- Job tag
        table.insert(message_parts, colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] ')

        -- Determine action type and color
        local action_type = msg.action_type or "Ability"
        local colorAction

        if action_type == "Magic" or action_type == "Spell" then
            colorAction = MessageCore.create_color_code(Colors.SPELL) -- Cyan for spells
        else
            colorAction = MessageCore.create_color_code(Colors.JA) -- Yellow for abilities
        end

        -- Action type and name
        table.insert(message_parts, action_type .. ': ' .. colorAction .. msg.name .. colorGray)

        -- Status (cooldown or TP)
        if msg.type == "cooldown" then
            local time_str = MessageCooldowns.format_recast_duration(msg.value)
            table.insert(message_parts, ' (' .. colorCooldown .. time_str .. colorGray .. ')')
        elseif msg.type == "tp" then
            table.insert(message_parts, ' (' .. colorError .. msg.value .. '/' .. msg.extra .. ' TP' .. colorGray .. ')')
        end

        MessageRenderer.send(1, table.concat(message_parts))
    end

    -- Bottom separator
    M.send('COOLDOWNS', 'separator')
end

---============================================================================
--- COMPACT STATUS MESSAGES (from backup system)
---============================================================================

--- Display compact status for multiple cooldowns (like WAR backup system)
--- @param cooldowns table Array of cooldown objects {name, type, time, status}
--- @param job_name string Job tag (e.g., "WAR/SAM", "PLD/BLU") - REQUIRED
function MessageCooldowns.show_compact_status(cooldowns, job_name)
    if not cooldowns or #cooldowns == 0 then
        return
    end

    job_name = job_name or MessageCore.get_job_tag()

    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)   -- Light Blue for job names
    local colorAction = MessageCore.create_color_code(Colors.JA) -- Yellow for ability names
    local colorGreen = MessageCore.create_color_code(Colors.SUCCESS) -- Green for active status
    local colorRed = MessageCore.create_color_code(Colors.COOLDOWN)   -- Red for cooldown time

    -- Start with job tag
    local message_parts = { colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] ' }

    -- Process each cooldown
    for i, cooldown in ipairs(cooldowns) do
        local part = ""

        if cooldown.status == 'active' or cooldown.status == 'Active' then
            part = colorAction .. cooldown.name .. colorGray .. ': ' .. colorGreen .. 'Active'
        elseif cooldown.time and cooldown.time > 0 then
            local time_str = MessageCooldowns.format_recast_duration(cooldown.time)
            part = colorAction .. cooldown.name .. colorGray .. ': ' .. colorRed .. time_str
        elseif cooldown.status == 'ready' or cooldown.status == 'Ready' then
            part = colorAction .. cooldown.name .. colorGray .. ': ' .. colorGreen .. 'Ready'
        else
            part = colorAction .. cooldown.name .. colorGray .. ': ' .. colorGray .. 'Unknown'
        end

        -- Add separator if not first item
        if i > 1 then
            table.insert(message_parts, colorGray .. ' | ')
        end

        table.insert(message_parts, part)
    end

    local full_message = table.concat(message_parts)
    MessageRenderer.send(1, full_message)
end

---============================================================================
--- CONVENIENCE FUNCTIONS WITH AUTOMATIC ID LOOKUP
---============================================================================

--- Display spell cooldown by spell ID with automatic conversion
--- @param spell_id number Spell ID
--- @param spell_name string Spell name for display
--- @param job_name string Optional job name
function MessageCooldowns.show_spell_cooldown_by_id(spell_id, spell_name, job_name)
    local recast_seconds = get_spell_recast_seconds(spell_id)
    MessageCooldowns.show_spell_cooldown(spell_name, recast_seconds * 100, job_name) -- Convert back to centiseconds for the main function
end

--- Display ability cooldown by ability ID
--- @param ability_id number Ability ID
--- @param ability_name string Ability name for display
--- @param job_name string Optional job name
function MessageCooldowns.show_ability_cooldown_by_id(ability_id, ability_name, job_name)
    local recast_seconds = get_ability_recast_seconds(ability_id)
    MessageCooldowns.show_ability_cooldown(ability_name, recast_seconds, job_name)
end

-- Expose helper functions for external use
MessageCooldowns.get_spell_recast_seconds = get_spell_recast_seconds
MessageCooldowns.get_ability_recast_seconds = get_ability_recast_seconds

return MessageCooldowns
