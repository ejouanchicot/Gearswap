---============================================================================
--- Smartbuff Manager - Subjob Buff Application (Logic Module)
---============================================================================
--- Automatically applies appropriate buffs based on current subjob with
--- intelligent recast checking and professional status display.
---
--- Features:
---   • WAR subjob buffs (Berserk, Aggressor, Warcry - priority order)
---   • NIN subjob buffs (Utsusemi: Ni >> Ichi fallback)
---   • SAM subjob buffs (Hasso)
---   • THF subjob buffs (Sneak Attack + Trick Attack combo @ 1000 TP)
---   • Intelligent recast checking (RECAST_CONFIG integration)
---   • Sequential ability casting (2s spacing to avoid conflicts)
---   • Status display (active/cooldown with time remaining)
---   • Fallback for other subjobs (default to Haste Samba)
---
--- @file    jobs/dnc/functions/logic/smartbuff_manager.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local SmartbuffManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrappers for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast == 0)
    end
end

local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)
    end
end

---============================================================================
--- SUBJOB BUFF FUNCTIONS
---============================================================================

--- Apply WAR subjob buffs (Berserk, Aggressor, Warcry in priority order)
--- @return boolean Success status
function SmartbuffManager.apply_war_buffs()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local abilities_to_cast = {}
    local status_data = {}

    -- Berserk (Recast ID: 1) - Priority 1
    if not buffactive['Berserk'] then
        local berserk_recast = ability_recasts[1] or 0
        if is_recast_ready(berserk_recast) then
            table.insert(abilities_to_cast, { name = 'Berserk' })
        else
            table.insert(status_data, { name = 'Berserk', status = 'cooldown', time = math.ceil(berserk_recast) })
        end
    else
        table.insert(status_data, { name = 'Berserk', status = 'active' })
    end

    -- Aggressor (Recast ID: 4) - Priority 2
    if not buffactive['Aggressor'] then
        local aggressor_recast = ability_recasts[4] or 0
        if is_recast_ready(aggressor_recast) then
            table.insert(abilities_to_cast, { name = 'Aggressor' })
        else
            table.insert(status_data, { name = 'Aggressor', status = 'cooldown', time = math.ceil(aggressor_recast) })
        end
    else
        table.insert(status_data, { name = 'Aggressor', status = 'active' })
    end

    -- Warcry (Recast ID: 2) - Priority 3
    if not buffactive['Warcry'] then
        local warcry_recast = ability_recasts[2] or 0
        if is_recast_ready(warcry_recast) then
            table.insert(abilities_to_cast, { name = 'Warcry' })
        else
            table.insert(status_data, { name = 'Warcry', status = 'cooldown', time = math.ceil(warcry_recast) })
        end
    else
        table.insert(status_data, { name = 'Warcry', status = 'active' })
    end

    -- Display buff status
    if #status_data > 0 and show_dnc_buff_status then
        show_dnc_buff_status(status_data)
    end

    -- Cast abilities sequentially (2 second spacing)
    for i, ability in ipairs(abilities_to_cast) do
        local command = 'input /ja "' .. ability.name .. '" <me>'
        if i == 1 then
            send_command(command)
        else
            local wait_time = (i - 1) * 2
            send_command('wait ' .. wait_time .. '; ' .. command)
        end
    end

    return true
end

--- Apply NIN subjob buffs (Utsusemi Ni first, Ichi fallback)
--- @return boolean Success status
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
        if show_dnc_buff_status then
            show_dnc_buff_status(status_data)
        end
    end

    return true
end

--- Apply SAM subjob buffs (Hasso)
--- @return boolean Success status
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
    if #status_data > 0 and show_dnc_buff_status then
        show_dnc_buff_status(status_data)
    end

    -- Cast abilities
    for _, ability in ipairs(abilities_to_cast) do
        send_command('input /ja "' .. ability.name .. '" <me>')
    end

    return true
end

--- Apply THF subjob buffs (Sneak Attack + Trick Attack if TP allows)
--- @return boolean Success status
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
            if #status_data > 0 and show_dnc_buff_status then
                show_dnc_buff_status(status_data)
            end
        end
    else
        MessageFormatter.show_warning('Need 1000+ TP for SA/TA combo (Current: ' .. player.tp .. ')')
    end

    return true
end

---============================================================================
--- MAIN ENTRY POINT
---============================================================================

--- Apply smartbuff based on current subjob
--- @return boolean Success status
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

---============================================================================
--- MODULE EXPORT
---============================================================================

return SmartbuffManager
