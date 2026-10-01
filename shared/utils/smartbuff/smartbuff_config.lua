---============================================================================
--- Smartbuff Config - the buff lists, shared defaults and the character's own
---============================================================================
--- The character's _common/combat/SMARTBUFF_CONFIG.lua over the defaults
--- below: `subjob` merged per subjob (a subjob not named keeps its default
--- list), the other keys replaced whole. The names are read by
--- shared/utils/smartbuff/buff_list.lua.
---
--- @file shared/utils/smartbuff/smartbuff_config.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local SmartbuffConfig = {}

--- The lists the code used before they could be set (2026-10-01).
SmartbuffConfig.DEFAULTS = {
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

--- The settings: defaults with the character's file over them.
--- @return table
function SmartbuffConfig.get()
    local D = SmartbuffConfig.DEFAULTS
    local ok, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'SMARTBUFF_CONFIG')
    end)
    user = (ok and type(user) == 'table') and user or {}
    local out = {subjob = {}}
    for sub, list in pairs(D.subjob) do out.subjob[sub] = list end
    for sub, list in pairs(type(user.subjob) == 'table' and user.subjob or {}) do
        if type(list) == 'table' then out.subjob[sub] = list end
    end
    for key, value in pairs(D) do
        if key ~= 'subjob' then
            local mine = user[key]
            -- not `cond and mine or value`: mine may be false
            if mine ~= nil and type(mine) == type(value) then
                out[key] = mine
            else
                out[key] = value
            end
        end
    end
    return out
end

return SmartbuffConfig
