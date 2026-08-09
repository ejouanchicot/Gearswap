---  ═══════════════════════════════════════════════════════════════════════════
---   Smartbuff Manager - Subjob Buff Application (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically applies the selected dance plus the appropriate subjob buffs
---   with intelligent recast checking and professional status display.
---
---   Features:
---   • Selected dance always first (state.Dance: Saber Dance / Fan Dance)
---   • Selected samba (state.Samba) when TP covers its cost
---   • WAR subjob buffs (Berserk, Aggressor, Warcry - priority order)
---   • NIN subjob buffs (Utsusemi: Ni >> Ichi fallback)
---   • SAM subjob buffs (Hasso)
---   • Any other subjob (DRG, THF, etc.) - dance only
---   • Intelligent recast checking (RECAST_CONFIG integration)
---   • Sequential casting (2s spacing to avoid conflicts)
---   • Status display (active/cooldown with time remaining)
---
---   @file    jobs/dnc/functions/logic/smartbuff_manager.lua
---   @author  Tetsouo
---   @version 2.0 - Dance integrated into smartbuff
---   @date    Created: 2025-10-06
---   @date    Updated: 2026-07-28
---  ═══════════════════════════════════════════════════════════════════════════

local SmartbuffManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageBuffs     = require('shared/utils/messages/formatters/magic/message_buffs')
local SubjobWarBuffs   = require('shared/utils/smartbuff/subjob_war_buffs')

-- is_recast_ready resolved as a global from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

--- Dance abilities selectable via state.Dance, keyed by recast_id (res/job_abilities).
local DANCES = {
    ['Saber Dance'] = 219,
    ['Fan Dance']   = 224,
}

--- Sambas selectable via state.Samba.
--- `buff` is the status name FFXI actually applies: Drain Samba II grants the
--- plain "Drain Samba" buff (status 368), so buffactive['Drain Samba II'] is
--- always false and cannot be used to detect it.
local SAMBAS = {
    ['Haste Samba']    = { tp_cost = 350, buff = 'Haste Samba' },
    ['Drain Samba II'] = { tp_cost = 250, buff = 'Drain Samba' },
    ['Aspir Samba']    = { tp_cost = 100, buff = 'Aspir Samba' },
}

--- Every samba shares a single recast timer.
local SAMBA_RECAST_ID = 216

--- Cast spacing between queued abilities (seconds).
---
--- A safety margin, for one of two reasons and possibly both: so each ability
--- actually fires, and so the gear for it lands - FFXI rate-limits equipment
--- changes, and actions sent too close together can equip wrong. Neither has
--- been measured, so the value is deliberately generous.
---
--- Anyone tightening this should test it in game rather than reason about it:
--- drop it to 0, queue several buffs, and watch both the abilities and the
--- gear.
local CAST_SPACING = 2

---  ═══════════════════════════════════════════════════════════════════════════
---   QUEUE HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

---   Cast a queue of abilities sequentially with fixed spacing
---   @param queue table List of { name = string, magic = boolean|nil }
local function cast_queue(queue)
    for i, entry in ipairs(queue) do
        local prefix = entry.magic and '/ma' or '/ja'
        local command = 'input ' .. prefix .. ' "' .. entry.name .. '" <me>'
        if i == 1 then
            send_command(command)
        else
            send_command('wait ' .. ((i - 1) * CAST_SPACING) .. '; ' .. command)
        end
    end
end

---   Append every element of src at the end of dst (in place)
---   @param dst table Destination list
---   @param src table Source list
local function append_all(dst, src)
    for _, entry in ipairs(src) do
        table.insert(dst, entry)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DANCE
---  ═══════════════════════════════════════════════════════════════════════════

---   Collect the dance selected via state.Dance (Saber Dance / Fan Dance)
---   @param skip_if_active boolean True to report an already-active dance instead
---                                 of refreshing it (smartbuff behavior)
---   @return table abilities_to_cast List of { name = string }
---   @return table status_data       List of { name, status, time? }
function SmartbuffManager.collect_dance(skip_if_active)
    local abilities_to_cast, status_data = {}, {}

    local dance_name = (state.Dance and state.Dance.current) or 'Saber Dance'
    local recast_id = DANCES[dance_name]
    if not recast_id then return abilities_to_cast, status_data end

    if skip_if_active and buffactive[dance_name] then
        table.insert(status_data, { name = dance_name, status = 'active' })
        return abilities_to_cast, status_data
    end

    local recast = windower.ffxi.get_ability_recasts()[recast_id] or 0
    if is_recast_ready(recast) then
        table.insert(abilities_to_cast, { name = dance_name })
    else
        table.insert(status_data, { name = dance_name, status = 'cooldown', time = math.ceil(recast) })
    end

    return abilities_to_cast, status_data
end

---   Apply the selected dance only (used by //gs c dance)
---   An explicit press refreshes the dance even when already active
---   @return boolean Success status
function SmartbuffManager.apply_dance()
    local abilities_to_cast, status_data = SmartbuffManager.collect_dance(false)

    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    cast_queue(abilities_to_cast)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SAMBA
---  ═══════════════════════════════════════════════════════════════════════════

---   Collect the samba selected via state.Samba, when TP covers its cost
---   Skipped entirely under Fan Dance, which cannot be paired with a samba.
---   Insufficient TP stays silent: the samba is a bonus on top of the dance, a
---   warning on every smartbuff below its cost would be pure noise.
---   @return table abilities_to_cast, table status_data
function SmartbuffManager.collect_samba()
    local abilities_to_cast, status_data = {}, {}

    local dance_name = (state.Dance and state.Dance.current) or 'Saber Dance'
    if dance_name == 'Fan Dance' then return abilities_to_cast, status_data end

    local samba_name = (state.Samba and state.Samba.current) or 'Haste Samba'
    local samba = SAMBAS[samba_name]
    if not samba then return abilities_to_cast, status_data end

    if buffactive[samba.buff] then
        table.insert(status_data, { name = samba_name, status = 'active' })
        return abilities_to_cast, status_data
    end

    if player.tp < samba.tp_cost then
        return abilities_to_cast, status_data
    end

    local recast = windower.ffxi.get_ability_recasts()[SAMBA_RECAST_ID] or 0
    if is_recast_ready(recast) then
        table.insert(abilities_to_cast, { name = samba_name })
    else
        table.insert(status_data, { name = samba_name, status = 'cooldown', time = math.ceil(recast) })
    end

    return abilities_to_cast, status_data
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SUBJOB BUFF COLLECTORS
---  ═══════════════════════════════════════════════════════════════════════════

---   Collect NIN subjob buffs (Utsusemi Ni first, Ichi fallback)
---   @return table abilities_to_cast, table status_data
function SmartbuffManager.collect_nin_buffs()
    local abilities_to_cast, status_data = {}, {}
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local ni_recast = (spell_recasts[339] or 0) / 100  -- Convert centiseconds to seconds
    local ichi_recast = (spell_recasts[338] or 0) / 100

    if is_recast_ready(ni_recast) then
        table.insert(abilities_to_cast, { name = 'Utsusemi: Ni', magic = true })
    elseif is_recast_ready(ichi_recast) then
        table.insert(abilities_to_cast, { name = 'Utsusemi: Ichi', magic = true })
    else
        table.insert(status_data, { name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni_recast) })
        table.insert(status_data, { name = 'Utsusemi: Ichi', status = 'cooldown', time = math.ceil(ichi_recast) })
    end

    return abilities_to_cast, status_data
end

---   Collect SAM subjob buffs (Hasso)
---   @return table abilities_to_cast, table status_data
function SmartbuffManager.collect_sam_buffs()
    local abilities_to_cast, status_data = {}, {}
    local hasso_recast = windower.ffxi.get_ability_recasts()[138] or 0

    if buffactive['Hasso'] then
        table.insert(status_data, { name = 'Hasso', status = 'active' })
    elseif is_recast_ready(hasso_recast) then
        table.insert(abilities_to_cast, { name = 'Hasso' })
    else
        table.insert(status_data, { name = 'Hasso', status = 'cooldown', time = math.ceil(hasso_recast) })
    end

    return abilities_to_cast, status_data
end

---   Collect buffs for the current subjob (empty when the subjob has none)
---   Subjobs are capped at level 49, so only low-level JAs are reachable.
---   /THF is deliberately absent: at 49 it only gets Steal/Mug/SA/TA/Flee/Hide,
---   none of which is a self-buff (Conspirator, Feint and Bully are main-only).
---   @param subjob string Current subjob code
---   @return table abilities_to_cast, table status_data
function SmartbuffManager.collect_subjob_buffs(subjob)
    if subjob == 'WAR' then
        return SubjobWarBuffs.collect()
    elseif subjob == 'NIN' then
        return SmartbuffManager.collect_nin_buffs()
    elseif subjob == 'SAM' then
        return SmartbuffManager.collect_sam_buffs()
    end

    -- Any other subjob (DRG, THF, etc.): dance only
    return {}, {}
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN ENTRY POINT
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply the selected dance, then the selected samba, then the subjob buffs
---   @return boolean Success status
function SmartbuffManager.apply()
    local subjob = player.sub_job

    if not subjob then
        MessageFormatter.show_error('Unable to detect subjob')
        return false
    end

    local abilities_to_cast, status_data = SmartbuffManager.collect_dance(true)

    local samba_abilities, samba_status = SmartbuffManager.collect_samba()
    append_all(abilities_to_cast, samba_abilities)
    append_all(status_data, samba_status)

    local sub_abilities, sub_status = SmartbuffManager.collect_subjob_buffs(subjob)
    append_all(abilities_to_cast, sub_abilities)
    append_all(status_data, sub_status)

    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data)
    end

    cast_queue(abilities_to_cast)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SmartbuffManager
