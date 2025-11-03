---============================================================================
--- Smartbuff Manager - Subjob Buff Application (Logic Module)
---============================================================================
--- Automatically applies appropriate buffs based on current subjob with
--- intelligent recast checking and professional status display.
---
--- Features:
---   • DNC subjob buffs (Haste Samba - requires 350 TP)
---   • WAR subjob buffs (Berserk, Aggressor, Warcry - priority order)
---   • NIN subjob buffs (Utsusemi: Ni → Ichi fallback)
---   • THF Fighter's Buff Combo (Feint, Bully, Conspirator)
---   • Intelligent recast checking (RECAST_CONFIG integration)
---   • Sequential ability casting (1-2s spacing to avoid conflicts)
---   • Status display (active/cooldown with time remaining)
---
--- Dependencies:
---   • MessageFormatter (status display, error messages)
---   • RECAST_CONFIG (recast tolerance configuration)
---   • show_thf_buff_status (global function for status display)
---
--- @file    jobs/thf/functions/logic/smartbuff_manager.lua
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

--- Apply DNC subjob buffs (Haste Samba)
--- @return boolean Success status
function SmartbuffManager.apply_dnc_buffs()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local status_data = {}
    local current_tp = player.tp or 0
    local required_tp = 350  -- Haste Samba TP cost
    local job_tag = MessageFormatter.get_job_tag()

    -- Haste Samba (Recast ID: 191)
    local samba_recast = ability_recasts[191] or 0
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
    if #status_data > 0 and show_thf_buff_status then
        show_thf_buff_status(status_data)
    end

    return true
end

--- Apply WAR subjob buffs (Berserk, Aggressor, Warcry in priority order)
--- @return boolean Success status
function SmartbuffManager.apply_war_buffs()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local abilities_to_cast = {}
    local status_data = {}

    -- Berserk (Recast ID: 1) - Priority 1
    local berserk_recast = ability_recasts[1] or 0
    if buffactive['Berserk'] then
        table.insert(status_data, { name = 'Berserk', status = 'active' })
    elseif is_recast_ready(berserk_recast) then
        table.insert(abilities_to_cast, { name = 'Berserk' })
    else
        table.insert(status_data, { name = 'Berserk', status = 'cooldown', time = math.ceil(berserk_recast) })
    end

    -- Aggressor (Recast ID: 4) - Priority 2
    local aggressor_recast = ability_recasts[4] or 0
    if buffactive['Aggressor'] then
        table.insert(status_data, { name = 'Aggressor', status = 'active' })
    elseif is_recast_ready(aggressor_recast) then
        table.insert(abilities_to_cast, { name = 'Aggressor' })
    else
        table.insert(status_data, { name = 'Aggressor', status = 'cooldown', time = math.ceil(aggressor_recast) })
    end

    -- Warcry (Recast ID: 2) - Priority 3
    local warcry_recast = ability_recasts[2] or 0
    if buffactive['Warcry'] then
        table.insert(status_data, { name = 'Warcry', status = 'active' })
    elseif is_recast_ready(warcry_recast) then
        table.insert(abilities_to_cast, { name = 'Warcry' })
    else
        table.insert(status_data, { name = 'Warcry', status = 'cooldown', time = math.ceil(warcry_recast) })
    end

    -- Only display status if there are NO abilities to cast (all on cooldown or active)
    -- If we're casting abilities, CooldownChecker will display the messages
    if #status_data > 0 and #abilities_to_cast == 0 and show_thf_buff_status then
        show_thf_buff_status(status_data)
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
    if #status_data > 0 and show_thf_buff_status then
        show_thf_buff_status(status_data)
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

---============================================================================
--- THF DEBUFF COMBO
---============================================================================

--- Apply THF debuff combo: Feint + Bully + Conspirator
--- @return boolean Success status
function SmartbuffManager.apply_fbc()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local abilities_to_cast = {}
    local status_data = {}

    -- Feint (Recast ID: 68) - Buff on player
    local feint_recast = ability_recasts[68] or 0
    if buffactive['Feint'] then
        table.insert(status_data, { name = 'Feint', status = 'active' })
    elseif is_on_cooldown(feint_recast) then
        table.insert(status_data, { name = 'Feint', status = 'cooldown', time = math.ceil(feint_recast) })
    else
        table.insert(abilities_to_cast, { name = 'Feint' })
    end

    -- Bully (Recast ID: 240) - Debuff on mob (no buffactive check)
    local bully_recast = ability_recasts[240] or 0
    if is_on_cooldown(bully_recast) then
        table.insert(status_data, { name = 'Bully', status = 'cooldown', time = math.ceil(bully_recast) })
    else
        table.insert(abilities_to_cast, { name = 'Bully' })
    end

    -- Conspirator (Recast ID: 40) - Buff on player
    local conspirator_recast = ability_recasts[40] or 0
    if buffactive['Conspirator'] then
        table.insert(status_data, { name = 'Conspirator', status = 'active' })
    elseif is_on_cooldown(conspirator_recast) then
        table.insert(status_data, { name = 'Conspirator', status = 'cooldown', time = math.ceil(conspirator_recast) })
    else
        table.insert(abilities_to_cast, { name = 'Conspirator' })
    end

    -- Display buff status (using global function if available)
    if #status_data > 0 and show_thf_buff_status then
        show_thf_buff_status(status_data)
    end

    -- Set flag to suppress CooldownChecker messages for abilities being cast
    _G.suppress_cooldown_messages = true

    -- Cast abilities sequentially (1 second spacing)
    for i, ability in ipairs(abilities_to_cast) do
        -- Determine target based on ability name
        local target = '<me>'
        if ability.name == 'Bully' then
            target = '<t>'
        end

        local command = 'input /ja "' .. ability.name .. '" ' .. target
        if i == 1 then
            send_command(command)
        else
            local wait_time = (i - 1) * 1
            send_command('wait ' .. wait_time .. '; ' .. command)
        end
    end

    -- Reset flag after all abilities have been cast
    if #abilities_to_cast > 0 then
        send_command('wait 3; lua i _G.suppress_cooldown_messages = false')
    else
        _G.suppress_cooldown_messages = false
    end

    return true
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SmartbuffManager
