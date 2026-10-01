---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Jumps - //gs c jump on a Dragoon main job
---  ═══════════════════════════════════════════════════════════════════════════
---   Uses the first jump of DRGTPConfig.jumps (drg/combat/DRG_TP_CONFIG.lua)
---   the player has (AbilityHelper.can_use_ability: job, level, job points)
---   and that is off recast (AbilityHelper.is_ability_ready); when none is,
---   one cooldown block lists them with their time left.
---
---   The shared command (shared/utils/drg/DRG_JUMP_MANAGER.lua) serves /DRG
---   only: Jump / High Jump, a second jump while TP stays under 1000. On a
---   Dragoon main job DRG_COMMANDS routes `jump` here instead.
---
---   @file    shared/jobs/drg/functions/logic/jumps.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Jumps = {}

local AbilityHelper = require('shared/utils/precast/ability_helper')

--- Used when DRGTPConfig has no jumps list.
Jumps.DEFAULT_ORDER = {'Soul Jump', 'Spirit Jump', 'Jump', 'High Jump'}

--- The configured order.
--- @return table List of ability names
function Jumps.order()
    local cfg = _G.DRGTPConfig
    if type(cfg) == 'table' and type(cfg.jumps) == 'table' and #cfg.jumps > 0 then
        return cfg.jumps
    end
    return Jumps.DEFAULT_ORDER
end

--- First jump of the order the player has and can use now.
--- @return string|nil name, table known (names the player has)
function Jumps.pick()
    local known = {}
    for _, name in ipairs(Jumps.order()) do
        if AbilityHelper.can_use_ability(name) then
            known[#known + 1] = name
            if AbilityHelper.is_ability_ready(name) then
                return name, known
            end
        end
    end
    return nil, known
end

--- Seconds left on an ability's recast.
--- @param name string
--- @return number
local function recast_left(name)
    local data = require('resources').job_abilities:with('en', name)
    local recasts = windower.ffxi.get_ability_recasts() or {}
    return data and recasts[data.recast_id] or 0
end

--- //gs c jump: send the jump, or say why none went out.
--- @return string|nil The jump sent
function Jumps.execute()
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local name, known = Jumps.pick()
    if name then
        send_command('input /ja "' .. name .. '" <t>')
        return name
    end
    if #known == 0 then
        MessageFormatter.show_error('No jump available on this job and level')
        return nil
    end
    local messages = {}
    for _, jump in ipairs(known) do
        messages[#messages + 1] = {type = 'cooldown', name = jump, value = recast_left(jump), action_type = 'Ability'}
    end
    MessageFormatter.show_multi_status(messages, MessageFormatter.get_job_tag())
    return nil
end

return Jumps
