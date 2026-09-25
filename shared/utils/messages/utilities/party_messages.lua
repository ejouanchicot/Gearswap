---============================================================================
--- Party Messages Module - Party Member Tracking & Display
---============================================================================
--- Provides formatted messages for party member detection and job tracking.
--- Universal module usable by any job (COR, BRD, etc.) that needs party info.
---
--- @file shared/utils/messages/utilities/party_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-29
---============================================================================

local PartyMessages = {}

local MessageCore = require('shared/utils/messages/message_core')

---============================================================================
--- PARTY TRACKING MESSAGES
---============================================================================

--- Display the party members and their jobs (//gs c party)
--- @param members table Array of {name, main_job?, sub_job?, main_job_level?}
---   from PartyTracker.members_for_display (no job = not known yet)
function PartyMessages.show_party_members(members)
    if not members or #members == 0 then
        MessageCore.info("No party members")
        return
    end
    local fields = {}
    for _, m in ipairs(members) do
        if m.main_job then
            local jobs = m.main_job .. (m.sub_job and ('/' .. m.sub_job) or '')
            local level = m.main_job_level and (' (Lv' .. m.main_job_level .. ')') or ''
            fields[#fields + 1] = {m.name, jobs .. level}
        else
            fields[#fields + 1] = {m.name, 'job unknown (until it zones or changes job)', 'dim'}
        end
    end
    require('shared/utils/messages/info_block').show({
        tag = 'COR', title = ('Party (%d)'):format(#members), fields = fields,
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PartyMessages
