---============================================================================
--- Subjob Buffs - //gs c smartbuff on every job, from what the subjob gives
---============================================================================
--- One press casts the self-buffs of the current subjob, those not already
--- up and off cooldown, two seconds apart, and reports the others. The list
--- of each subjob: `subjob` of _common/combat/SMARTBUFF_CONFIG.lua
--- (smartbuff_config.lua; defaults /WAR Berserk, Aggressor, Warcry - Defender
--- left out: Attack -25% -, /SAM Hasso, Third Eye, /NIN Utsusemi, /DNC Haste
--- Samba). The names and their rules: buff_list.lua. A subjob without a list
--- (or an empty one) casts nothing.
---
--- Common command: COMMON_COMMANDS routes `smartbuff` here. A job with its own
--- smartbuff handles the word first: DNC (dance + samba, then collect() below
--- for its subjob). WAR main keeps //gs c berserk and defender, which fold the
--- /SAM stance in.
---
--- @file    shared/utils/smartbuff/subjob_buffs.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30 (from subjob_war_buffs.lua and the DNC/THF
---          smartbuff managers)
---============================================================================

local SubjobBuffs = {}

local BuffList = require('shared/utils/smartbuff/buff_list')

--- Seconds between two queued casts (the DNC, THF and WAR smartbuffs used 2).
local CAST_SPACING = 2

--- The list of a subjob, or nil.
local function list_for(sub)
    local list = require('shared/utils/smartbuff/smartbuff_config').get().subjob[sub or '']
    return (type(list) == 'table' and #list > 0) and list or nil
end

--- Buffs of a subjob.
--- @param sub string|nil Subjob code (default: the current one)
--- @return table abilities_to_cast List of {name, magic?}
--- @return table status_data List of {name, status, time?}; status 'tp'
---         (value, extra) when the TP does not cover the cost
function SubjobBuffs.collect(sub)
    sub = sub or (player and player.sub_job)
    local list = list_for(sub)
    if not list or (player and (player.sub_job_level or 0) == 0) then return {}, {} end
    return BuffList.collect(list)
end

--- Whether a subjob has buffs here.
--- @param sub string
--- @return boolean
function SubjobBuffs.handles(sub)
    return list_for(sub) ~= nil
end

--- Cast a queue two seconds apart (/ma for the entries marked magic).
--- @param queue table From collect()
function SubjobBuffs.cast(queue)
    BuffList.cast(queue, CAST_SPACING)
end

--- Report what was not cast: active / cooldown lines, then the short TP.
--- @param status table From collect()
function SubjobBuffs.show_status(status)
    local lines, short_tp = {}, {}
    for _, entry in ipairs(status) do
        if entry.status == 'tp' then
            short_tp[#short_tp + 1] = {type = 'tp', name = entry.name, value = entry.value, extra = entry.extra}
        else
            lines[#lines + 1] = entry
        end
    end
    if #lines > 0 then
        require('shared/utils/messages/formatters/magic/message_buffs').show_buff_status(lines)
    end
    if #short_tp > 0 then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_multi_status(short_tp, MessageFormatter.get_job_tag())
    end
end

--- //gs c smartbuff: the current subjob's buffs.
--- @return boolean False when the subjob gives none
function SubjobBuffs.apply()
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local sub = player and player.sub_job
    if not SubjobBuffs.handles(sub) then
        MessageFormatter.show_warning('smartbuff: no self-buff on /' .. tostring(sub or '---'))
        return false
    end
    if (player.sub_job_level or 0) == 0 then
        MessageFormatter.show_warning('smartbuff: /' .. sub .. ' is disabled here')
        return false
    end
    local to_cast, status = SubjobBuffs.collect(sub)
    SubjobBuffs.show_status(status)
    SubjobBuffs.cast(to_cast)
    return true
end

return SubjobBuffs
