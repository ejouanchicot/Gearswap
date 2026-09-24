---  ═══════════════════════════════════════════════════════════════════════════
---   Smartbuff Manager - Subjob Buff Application (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically applies appropriate buffs based on current subjob with
---   intelligent recast checking and professional status display.
---
---   Features:
---   • DNC subjob buffs (Haste Samba - requires 350 TP)
---   • WAR subjob buffs (Berserk, Aggressor, Warcry - priority order)
---   • NIN subjob buffs (Utsusemi: Ni >> Ichi fallback)
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
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

local SmartbuffManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageBuffs     = require('shared/utils/messages/formatters/magic/message_buffs')
local SubjobWarBuffs   = require('shared/utils/smartbuff/subjob_war_buffs')

-- is_recast_ready / is_on_cooldown resolved as globals from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

---  ═══════════════════════════════════════════════════════════════════════════
---   SUBJOB BUFF FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply DNC subjob buffs (Haste Samba)
---   @return boolean Success status
function SmartbuffManager.apply_dnc_buffs()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local status_data = {}
    local current_tp = player.tp or 0
    local required_tp = 350  -- Haste Samba TP cost
    local job_tag = MessageFormatter.get_job_tag()

    -- Haste Samba (recast id 216, shared by all Sambas; res/job_abilities.lua)
    local samba_recast = ability_recasts[216] or 0
    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok_t and Trace then
        Trace.log('SAMBA', 'recast[216] %s buff %s tp %s -> %s', samba_recast, buffactive['Haste Samba'] ~= nil,
            current_tp, buffactive['Haste Samba'] and 'active' or (is_recast_ready(samba_recast) and 'cast' or 'cooldown'))
    end
    if buffactive['Haste Samba'] then
        table.insert(status_data, { name = 'Haste Samba', status = 'active' })
    elseif is_recast_ready(samba_recast) then
        -- Check TP requirement before casting
        if current_tp >= required_tp then
            send_command('input /ja "Haste Samba" <me>')
        else
            -- Not enough TP - show grouped message (like DNC waltz system)
            local messages = {{type = "tp", name = "Haste Samba", value = current_tp, extra = required_tp}}
            MessageFormatter.show_multi_status(messages, job_tag)
            return false
        end
    else
        table.insert(status_data, { name = 'Haste Samba', status = 'cooldown', time = math.ceil(samba_recast) })
    end

    -- Only display status if there are NO abilities to cast
    -- (DNC only has 1 ability, so this is when Haste Samba is active or on cooldown)
    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    return true
end

---   Apply WAR subjob buffs (Berserk, Aggressor, Warcry in priority order)
---   @return boolean Success status
function SmartbuffManager.apply_war_buffs()
    local abilities_to_cast, status_data = SubjobWarBuffs.collect()

    -- THF: display status only if no casts happening — avoids duplicate
    -- messages with CooldownChecker which reports cooldowns during cast cycle.
    if #status_data > 0 and #abilities_to_cast == 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    SubjobWarBuffs.cast(abilities_to_cast)
    return true
end

---   Apply NIN subjob buffs (Utsusemi Ni first, Ichi fallback)
---   @return boolean Success status
function SmartbuffManager.apply_nin_buffs()
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local ni_recast = (spell_recasts[339] or 0) / 100  -- Convert centiseconds to seconds
    local ichi_recast = (spell_recasts[338] or 0) / 100
    local status_data = {}

    -- Try Ni first, then Ichi
    if is_recast_ready(ni_recast) then
        windower.send_command('input /ma "Utsusemi: Ni" <me>')
    elseif is_recast_ready(ichi_recast) then
        windower.send_command('input /ma "Utsusemi: Ichi" <me>')
        table.insert(status_data, { name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni_recast) })
    else
        -- Both on cooldown
        table.insert(status_data, { name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni_recast) })
        table.insert(status_data, { name = 'Utsusemi: Ichi', status = 'cooldown', time = math.ceil(ichi_recast) })
    end

    -- Always display status
    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN ENTRY POINT
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply smartbuff based on current subjob
---   @return boolean Success status
function SmartbuffManager.apply()
    local subjob = player.sub_job

    if not subjob then
        MessageFormatter.show_error('Unable to detect subjob')
        return false
    end

    if subjob == 'DNC' then
        return SmartbuffManager.apply_dnc_buffs()
    elseif subjob == 'WAR' then
        return SmartbuffManager.apply_war_buffs()
    elseif subjob == 'NIN' then
        return SmartbuffManager.apply_nin_buffs()
    else
        MessageFormatter.show_warning('No smartbuff configured for /' .. subjob)
        return false
    end
end

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

-- Despoil is learned at THF 77, out of reach of a THF subjob.
local STEAL_ABILITIES = {
    {name = 'Steal',   recast_id = 60, target = '<t>'},
    {name = 'Mug',     recast_id = 65, target = '<t>'},
    {name = 'Despoil', recast_id = 61, target = '<t>', main_only = true},
}

--- Sort a sequence into what can be used and what has to be reported.
--- Main-job-only abilities are dropped silently when THF is the subjob.
--- @param abilities table Sequence (FBC_ABILITIES or STEAL_ABILITIES)
--- @param ability_recasts table windower.ffxi.get_ability_recasts()
--- @return table to cast, table status lines for the ones that cannot
local function triage(abilities, ability_recasts)
    local to_cast, status = {}, {}
    local is_main = player and player.main_job == 'THF'

    for _, ability in ipairs(abilities) do
        local recast = ability_recasts[ability.recast_id] or 0

        if ability.main_only and not is_main then
            -- not available, nothing to report
        elseif ability.buff and buffactive[ability.buff] then
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

    -- The abilities about to go out are knowingly on the way; CooldownChecker
    -- would otherwise report each one as blocked.
    _G.suppress_cooldown_messages = true

    cast_sequence(to_cast)

    -- Deferred inside GearSwap on purpose. `lua i _G.X = ...` writes to the
    -- Windower scope, not this sandbox, so the flag would never come back and
    -- cooldown messages would stay suppressed for the rest of the session.
    if #to_cast > 0 then
        coroutine.schedule(function()
            _G.suppress_cooldown_messages = false
        end, 3.0)
    else
        _G.suppress_cooldown_messages = false
    end

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
