---  ═══════════════════════════════════════════════════════════════════════════
---   Smartbuff Manager - Subjob Buff Application (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically applies appropriate buffs based on current subjob with
---   intelligent recast checking and professional status display.
---
---   Features:
---   • WAR subjob buffs (Berserk, Aggressor, Warcry - priority order)
---   • NIN subjob buffs (Utsusemi: Ni >> Ichi fallback)
---   • SAM subjob buffs (Hasso)
---   • THF subjob buffs (Sneak Attack + Trick Attack combo @ 1000 TP)
---   • Intelligent recast checking (RECAST_CONFIG integration)
---   • Sequential ability casting (2s spacing to avoid conflicts)
---   • Status display (active/cooldown with time remaining)
---   • Fallback for other subjobs (default to Haste Samba)
---
---   @file    jobs/dnc/functions/logic/smartbuff_manager.lua
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

---   Apply WAR subjob buffs (Berserk, Aggressor, Warcry in priority order)
---   @return boolean Success status
function SmartbuffManager.apply_war_buffs()
    local abilities_to_cast, status_data = SubjobWarBuffs.collect()

    -- DNC: always display status (no overlap with CooldownChecker on DNC main JAs)
    if #status_data > 0 then
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

    if is_recast_ready(ni_recast) then
        windower.send_command('input /ma "Utsusemi: Ni" <me>')
    elseif is_recast_ready(ichi_recast) then
        windower.send_command('input /ma "Utsusemi: Ichi" <me>')
    else
        -- Both on cooldown - display status
        local status_data = {}
        table.insert(status_data, { name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni_recast) })
        table.insert(status_data, { name = 'Utsusemi: Ichi', status = 'cooldown', time = math.ceil(ichi_recast) })
        MessageBuffs.show_buff_status(status_data)
    end

    return true
end

---   Apply SAM subjob buffs (Hasso)
---   @return boolean Success status
function SmartbuffManager.apply_sam_buffs()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local status_data = {}
    local abilities_to_cast = {}

    if not buffactive['Hasso'] then
        local hasso_recast = ability_recasts[138] or 0
        if is_recast_ready(hasso_recast) then
            table.insert(abilities_to_cast, { name = 'Hasso' })
        else
            table.insert(status_data, { name = 'Hasso', status = 'cooldown', time = math.ceil(hasso_recast) })
        end
    else
        table.insert(status_data, { name = 'Hasso', status = 'active' })
    end

    -- Display buff status
    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    -- Cast abilities
    for _, ability in ipairs(abilities_to_cast) do
        send_command('input /ja "' .. ability.name .. '" <me>')
    end

    return true
end

---   Apply THF subjob buffs (Sneak Attack + Trick Attack if TP allows)
---   @return boolean Success status
function SmartbuffManager.apply_thf_buffs()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local status_data = {}

    -- Lag tolerance: check >= 900 TP (GearSwap sees 800-950 when player has 1000)
    if player.tp >= 900 then
        local sa_recast = ability_recasts[65] or 0
        local ta_recast = ability_recasts[66] or 0

        if is_recast_ready(sa_recast) and is_recast_ready(ta_recast) then
            send_command('input /ja "Sneak Attack" <me>; wait 1; input /ja "Trick Attack" <me>')
        else
            if is_on_cooldown(sa_recast) then
                table.insert(status_data, { name = 'Sneak Attack', status = 'cooldown', time = math.ceil(sa_recast) })
            end
            if is_on_cooldown(ta_recast) then
                table.insert(status_data, { name = 'Trick Attack', status = 'cooldown', time = math.ceil(ta_recast) })
            end
            if #status_data > 0 then
                MessageBuffs.show_buff_status(status_data)
            end
        end
    else
        MessageFormatter.show_warning('Need 1000+ TP for SA/TA combo (Current: ' .. player.tp .. ')')
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

    if subjob == 'WAR' then
        return SmartbuffManager.apply_war_buffs()
    elseif subjob == 'NIN' then
        return SmartbuffManager.apply_nin_buffs()
    elseif subjob == 'SAM' then
        return SmartbuffManager.apply_sam_buffs()
    elseif subjob == 'THF' then
        return SmartbuffManager.apply_thf_buffs()
    else
        -- Fallback for other subjobs - use general DNC abilities
        send_command('input /ja "Haste Samba" <me>')
        return true
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SmartbuffManager
