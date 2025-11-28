---============================================================================
--- Party Messages Module - Party Member Tracking & Display
---============================================================================
--- Provides formatted messages for party member detection and job tracking.
--- Universal module usable by any job (COR, BRD, etc.) that needs party info.
---
--- @file utils/messages/utility/party_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-29
---============================================================================

local PartyMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

---============================================================================
--- PARTY TRACKING MESSAGES
---============================================================================

--- Display party members table with job information
--- @param party_jobs table Party jobs data (_G.cor_party_jobs or similar)
--- Format: {player_id = {name, main_job, sub_job, main_job_level}}
function PartyMessages.show_party_members(party_jobs)
    if not party_jobs then
        MessageCore.error("Party tracking not initialized")
        return
    end

    local count = 0
    for _ in pairs(party_jobs) do count = count + 1 end

    if count == 0 then
        MessageCore.info("No party members detected yet")
        return
    end

    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local info_color = MessageCore.create_color_code(Colors.INFO)

    local separator = '========================================'

    add_to_chat(159, separator)
    add_to_chat(159, string.format('%s[%s]%s Party Members Detected: %s%d',
        job_color, job_tag,
        separator_color,
        info_color, count))
    add_to_chat(159, separator)

    for player_id, job_data in pairs(party_jobs) do
        local job_display = job_data.main_job
        if job_data.sub_job then
            job_display = job_display .. '/' .. job_data.sub_job
        end
        local player_name = job_data.name or "Unknown"

        add_to_chat(159, string.format('%s  %s (ID:%d): %s (Lv%d)',
            info_color,
            player_name, player_id,
            job_display, job_data.main_job_level))
    end

    add_to_chat(159, separator)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PartyMessages
