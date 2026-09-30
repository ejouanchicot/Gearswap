---  ═══════════════════════════════════════════════════════════════════════════
---   Smartbuff Manager - Subjob Buff Application (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   THF ability chains. //gs c smartbuff (the subjob buffs) is the common
---   command of every job: shared/utils/smartbuff/subjob_buffs.lua.
---
---   Features:
---   • THF Feint / Bully / Conspirator opener (//gs c fbc)
---   • THF Steal / Mug / Despoil chain (//gs c steal)
---   • Intelligent recast checking (RECAST_CONFIG integration)
---   • Sequential ability casting (1-2s spacing to avoid conflicts)
---   • Status display (active/cooldown with time remaining)
---
---   Dependencies:
---   • MessageFormatter (status display, error messages)
---   • RECAST_CONFIG (recast tolerance configuration)
---   • MessageBuffs (buff status display module)
---
---   @file    shared/jobs/thf/functions/logic/smartbuff_manager.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

local SmartbuffManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageBuffs     = require('shared/utils/messages/formatters/magic/message_buffs')

-- is_recast_ready / is_on_cooldown resolved as globals from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

---  ═══════════════════════════════════════════════════════════════════════════
---   THF DEBUFF COMBO
---  ═══════════════════════════════════════════════════════════════════════════

-- The Feint-Bully-Conspirator opener, in the order it is fired.
--
-- Bully carries no buff name on purpose: it lands a debuff on the mob, not a
-- buff on the player, so buffactive has nothing to say about it and only its
-- recast decides whether it can go out.
local FBC_ABILITIES = {
    {name = 'Feint',       recast_id = 68,  buff = 'Feint',       target = '<me>'},
    {name = 'Bully',       recast_id = 240, buff = nil,           target = '<t>'},
    {name = 'Conspirator', recast_id = 40,  buff = 'Conspirator', target = '<me>'},
}

local STEAL_ABILITIES = {
    {name = 'Steal',   recast_id = 60, target = '<t>'},
    {name = 'Mug',     recast_id = 65, target = '<t>'},
    {name = 'Despoil', recast_id = 61, target = '<t>'},
}

--- Sort a sequence into what can be used and what has to be reported.
--- @param abilities table Sequence (FBC_ABILITIES or STEAL_ABILITIES)
--- @param ability_recasts table windower.ffxi.get_ability_recasts()
--- @return table to cast, table status lines for the ones that cannot
local function triage(abilities, ability_recasts)
    local to_cast, status = {}, {}

    for _, ability in ipairs(abilities) do
        local recast = ability_recasts[ability.recast_id] or 0

        if ability.buff and buffactive[ability.buff] then
            table.insert(status, {name = ability.name, status = 'active'})
        elseif is_on_cooldown(recast) then
            table.insert(status, {name = ability.name, status = 'cooldown',
                                  time = math.ceil(recast)})
        else
            table.insert(to_cast, ability)
        end
    end

    return to_cast, status
end

--- Fire the abilities a second apart.
---
--- The first goes out immediately, the second a second later, the third after
--- two.
---
--- A safety margin, for one of two reasons and possibly both: so each ability
--- actually fires, and so the gear for it lands - FFXI rate-limits equipment
--- changes, and actions sent too close together can equip wrong. DNC and WAR
--- take the same precaution at two seconds. Neither reason has been measured,
--- so the value is left alone rather than tightened.
--- @param to_cast table From triage
local function cast_sequence(to_cast)
    for i, ability in ipairs(to_cast) do
        local command = 'input /ja "' .. ability.name .. '" ' .. ability.target
        if i == 1 then
            send_command(command)
        else
            send_command('wait ' .. ((i - 1) * 1) .. '; ' .. command)
        end
    end
end

--- Fire the ready abilities of a sequence, report the others.
--- @param abilities table Sequence (FBC_ABILITIES or STEAL_ABILITIES)
--- @return boolean Always true
local function run_sequence(abilities)
    local to_cast, status_data = triage(abilities, windower.ffxi.get_ability_recasts())

    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    -- Only ready abilities are sent, so CooldownChecker lets them through; a
    -- second press before they land is caught by it like any other repeat.
    cast_sequence(to_cast)

    return true
end

--- Fire Feint, Bully and Conspirator (those ready), report the others.
--- @return boolean Always true
function SmartbuffManager.apply_fbc()
    return run_sequence(FBC_ABILITIES)
end

--- True when <t> is a living monster (spawn_type 16).
--- @return boolean
local function target_is_enemy()
    local t = windower.ffxi.get_mob_by_target('t')
    return t ~= nil and t.spawn_type == 16 and t.valid_target and (t.hpp or 0) > 0
end

--- Fire Steal, Mug and Despoil on the target (those ready), report the others.
--- Nothing is sent unless <t> is a living enemy.
--- @return boolean False when the target is not an enemy
function SmartbuffManager.apply_steal()
    if not target_is_enemy() then
        MessageFormatter.show_error('Steal: no enemy targeted.')
        return false
    end
    return run_sequence(STEAL_ABILITIES)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SmartbuffManager
