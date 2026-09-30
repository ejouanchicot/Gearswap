---============================================================================
--- Subjob Buffs - //gs c smartbuff on every job, from what the subjob gives
---============================================================================
--- One press casts the self-buffs the current subjob gives, those not already
--- up and off cooldown, two seconds apart, and reports the others:
---   /WAR  Berserk, Aggressor, Warcry (Defender left out: Attack -25%)
---   /SAM  Hasso (two-handed weapon only), Third Eye
---   /NIN  Utsusemi: Ni, else Ichi
---   /DNC  Haste Samba (350 TP)
--- Any other subjob has no self-buff worth a press at level 49.
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

-- is_recast_ready resolved as a global from RECAST_CONFIG.lua
-- (loaded by the entry point before job functions). Do not redeclare locally.

--- Seconds between two queued casts (the DNC, THF and WAR smartbuffs used 2).
local CAST_SPACING = 2

local HASTE_SAMBA_TP = 350
local SAMBA_RECAST_ID = 216

--- Weapon skills (res.items `skill`) of two-handed weapons: Hasso needs one.
local TWO_HANDED = {[4] = true, [6] = true, [7] = true, [8] = true, [10] = true, [12] = true}

---============================================================================
--- COLLECTORS (each returns abilities_to_cast, status_data)
---============================================================================

--- Queue an ability unless its buff is up or it is on cooldown.
--- @param name string Ability name (also its buff name)
--- @param recast_id number res/job_abilities recast id
--- @param to_cast table Mutated
--- @param status table Mutated
local function collect_ability(name, recast_id, to_cast, status)
    local recast = windower.ffxi.get_ability_recasts()[recast_id] or 0
    if buffactive[name] then
        table.insert(status, {name = name, status = 'active'})
    elseif is_recast_ready(recast) then
        table.insert(to_cast, {name = name})
    else
        table.insert(status, {name = name, status = 'cooldown', time = math.ceil(recast)})
    end
end

local function collect_war()
    local to_cast, status = {}, {}
    collect_ability('Berserk', 1, to_cast, status)
    collect_ability('Aggressor', 4, to_cast, status)
    collect_ability('Warcry', 2, to_cast, status)
    return to_cast, status
end

--- True when the main hand holds a two-handed weapon (unknown counts as yes:
--- the game refuses Hasso itself).
local function two_handed()
    local name = player and player.equipment and player.equipment.main
    if not name or name == '' or name == 'empty' then return false end
    local ok, item = pcall(function() return res.items:with('en', name) end)
    if not ok or not item or not item.skill then return true end
    return TWO_HANDED[item.skill] == true
end

local function collect_sam()
    local to_cast, status = {}, {}
    if two_handed() then collect_ability('Hasso', 138, to_cast, status) end
    collect_ability('Third Eye', 133, to_cast, status)
    return to_cast, status
end

local function collect_nin()
    local to_cast, status = {}, {}
    local recasts = windower.ffxi.get_spell_recasts()
    local ni, ichi = (recasts[339] or 0) / 100, (recasts[338] or 0) / 100
    if is_recast_ready(ni) then
        table.insert(to_cast, {name = 'Utsusemi: Ni', magic = true})
    elseif is_recast_ready(ichi) then
        table.insert(to_cast, {name = 'Utsusemi: Ichi', magic = true})
    else
        table.insert(status, {name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni)})
        table.insert(status, {name = 'Utsusemi: Ichi', status = 'cooldown', time = math.ceil(ichi)})
    end
    return to_cast, status
end

local function collect_dnc()
    local to_cast, status = {}, {}
    local recast = windower.ffxi.get_ability_recasts()[SAMBA_RECAST_ID] or 0
    if buffactive['Haste Samba'] then
        table.insert(status, {name = 'Haste Samba', status = 'active'})
    elseif not is_recast_ready(recast) then
        table.insert(status, {name = 'Haste Samba', status = 'cooldown', time = math.ceil(recast)})
    else
        local tp = require('shared/utils/core/live_tp')()
        if tp < HASTE_SAMBA_TP then
            table.insert(status, {name = 'Haste Samba', status = 'tp', value = tp, extra = HASTE_SAMBA_TP})
            return to_cast, status
        end
        table.insert(to_cast, {name = 'Haste Samba'})
    end
    return to_cast, status
end

local COLLECTORS = {WAR = collect_war, SAM = collect_sam, NIN = collect_nin, DNC = collect_dnc}

--- Buffs of a subjob.
--- @param sub string|nil Subjob code (default: the current one)
--- @return table abilities_to_cast List of {name, magic?}
--- @return table status_data List of {name, status, time?}; status 'tp'
---         (value, extra) when the TP does not cover the cost
function SubjobBuffs.collect(sub)
    sub = sub or (player and player.sub_job)
    local collector = COLLECTORS[sub or '']
    if not collector or (player and (player.sub_job_level or 0) == 0) then return {}, {} end
    return collector()
end

--- Whether a subjob has buffs here.
--- @param sub string
--- @return boolean
function SubjobBuffs.handles(sub)
    return COLLECTORS[sub or ''] ~= nil
end

--- Cast a queue two seconds apart (/ma for the entries marked magic).
--- @param queue table From collect()
function SubjobBuffs.cast(queue)
    for i, entry in ipairs(queue) do
        local command = 'input ' .. (entry.magic and '/ma' or '/ja') .. ' "' .. entry.name .. '" <me>'
        send_command(i == 1 and command or ('wait ' .. ((i - 1) * CAST_SPACING) .. '; ' .. command))
    end
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
