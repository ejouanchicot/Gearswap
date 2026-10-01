---============================================================================
--- Buff Command - //gs c buff on every job: the main job's buffs, then the subjob's
---============================================================================
--- One press (also the words buffs, buffself, selfbuff, smartbuff):
---   1. the job's own buffs when its files give some (_G.job_buff_extra:
---      DNC's dance and samba, chosen with its states);
---   2. the main job's list (`job` of _common/combat/BUFF_CONFIG.lua);
---   3. the subjob's list (`subjob`), unless the subjob is disabled here.
--- Each list goes through shared/utils/buffs/self_buff_manager.lua: what is
--- up, on recast or out of reach is skipped; the rest goes one action after
--- the other. Nothing set for these jobs: a warning naming the file.
---
--- @file shared/utils/buffs/buff_command.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01 (subjob_buffs.lua and BLM's buff command before)
---============================================================================

local BuffCommand = {}

local function append(into, from)
    for _, v in ipairs(from or {}) do into[#into + 1] = v end
end

--- //gs c buff
--- @return boolean True when something was queued or shown
function BuffCommand.apply()
    local Engine = require('shared/utils/buffs/self_buff_manager')
    local cfg = require('shared/utils/buffs/buff_config').get()
    local main, sub = player and player.main_job, player and player.sub_job
    local to_cast, status = {}, {}
    local lists = 0

    local extra = rawget(_G, 'job_buff_extra')
    if type(extra) == 'function' then
        local ok, a, s = pcall(extra)
        if ok then append(to_cast, a); append(status, s); lists = lists + 1 end
    end
    if type(cfg.job[main or '']) == 'table' and #cfg.job[main] > 0 then
        local a, s = Engine.collect(cfg.job[main])
        append(to_cast, a); append(status, s); lists = lists + 1
    end
    if (player and player.sub_job_level or 0) > 0 and type(cfg.subjob[sub or '']) == 'table'
        and #cfg.subjob[sub] > 0 then
        local a, s = Engine.collect(cfg.subjob[sub])
        append(to_cast, a); append(status, s); lists = lists + 1
    end

    if lists == 0 then
        require('shared/utils/messages/message_formatter').show_warning(
            ('buff: nothing set for %s/%s (_common/combat/BUFF_CONFIG.lua)'):format(tostring(main), tostring(sub)))
        return false
    end
    Engine.show_status(status)
    Engine.cast(to_cast)
    return #to_cast > 0 or #status > 0
end

return BuffCommand
