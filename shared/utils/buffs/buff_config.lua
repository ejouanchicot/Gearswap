---============================================================================
--- Buff Config - the buff lists, shared defaults and the character's own
---============================================================================
--- The character's _common/combat/BUFF_CONFIG.lua over the defaults below:
--- `job` and `subjob` merged per job (a job not named keeps its default
--- list), the other keys replaced whole. The names are read by
--- shared/utils/buffs/self_buff_manager.lua.
---
--- @file shared/utils/buffs/buff_config.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01 (smartbuff_config.lua before)
---============================================================================

local BuffConfig = {}

--- The lists the code used before they could be set (2026-10-01).
BuffConfig.DEFAULTS = {
    job = {
        BLM = {'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes'},
    },
    subjob = {
        WAR = {'Berserk', 'Aggressor', 'Warcry'},
        SAM = {'Hasso', 'Third Eye'},
        NIN = {'Utsusemi'},
        DNC = {'Haste Samba'},
    },
    war_berserk  = {'Berserk', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},
    war_defender = {'Defender', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},
    war_add_sam  = true,
}

local PER_JOB = {job = true, subjob = true}

--- The settings: defaults with the character's file over them.
--- @return table
function BuffConfig.get()
    local D = BuffConfig.DEFAULTS
    local ok, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'BUFF_CONFIG')
    end)
    if not (ok and type(user) == 'table') then user = {} end
    local out = {}
    for key, value in pairs(D) do
        local mine = user[key]
        if PER_JOB[key] then
            out[key] = {}
            for job, list in pairs(value) do out[key][job] = list end
            for job, list in pairs(type(mine) == 'table' and mine or {}) do
                if type(list) == 'table' then out[key][job] = list end
            end
        elseif mine ~= nil and type(mine) == type(value) then
            -- not `cond and mine or value`: mine may be false
            out[key] = mine
        else
            out[key] = value
        end
    end
    return out
end

return BuffConfig
