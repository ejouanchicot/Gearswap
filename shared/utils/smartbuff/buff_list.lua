---============================================================================
--- Buff List - a list of ability / spell names turned into what to cast now
---============================================================================
--- Used by //gs c smartbuff (subjob_buffs.lua) and WAR's //gs c berserk /
--- defender (war smartbuff_manager.lua), whose lists come from the
--- character's _common/combat/SMARTBUFF_CONFIG.lua (smartbuff_config.lua).
---
--- Any name works: a job ability or a spell is found in the game data (its
--- recast), skipped when its buff is up or it is on cooldown, left out
--- quietly when the current jobs do not have it. A few names keep a rule of
--- their own:
---   Warcry       Blood Rage instead when Warcry is on cooldown (WAR main)
---   Hasso        only with a two-handed weapon in hand
---   Utsusemi     Utsusemi: Ni, else Ichi
---   Haste Samba  only with the TP it costs (350)
---
--- @file shared/utils/smartbuff/buff_list.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local BuffList = {}

-- is_recast_ready / is_on_cooldown: globals of RECAST_CONFIG.lua (loaded by
-- the entry point before job functions)

local HASTE_SAMBA_TP = 350

--- Weapon skills (res.items `skill`) of two-handed weapons: Hasso needs one.
local TWO_HANDED = {[4] = true, [6] = true, [7] = true, [8] = true, [10] = true, [12] = true}

local function resources()
    local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
    return ok and res or nil
end

local found_cache = {}

--- The game data of a name: {kind = 'ja'|'ma', id, recast_id}, or false.
local function lookup(name)
    if found_cache[name] ~= nil then return found_cache[name] end
    local res = resources()
    local found = false
    local ja = res and res.job_abilities and res.job_abilities:with('en', name)
    if ja then
        found = {kind = 'ja', id = ja.id, recast_id = ja.recast_id}
    else
        local spell = res and res.spells and res.spells:with('en', name)
        if spell then found = {kind = 'ma', id = spell.id, recast_id = spell.recast_id} end
    end
    found_cache[name] = found
    return found
end

--- Whether the current jobs have this ability / spell (learned, level).
local function known(entry)
    if entry.kind == 'ja' then
        for _, id in ipairs((windower.ffxi.get_abilities() or {}).job_abilities or {}) do
            if id == entry.id then return true end
        end
        return false
    end
    local learned = windower.ffxi.get_spells() or {}
    return learned[entry.id] == true
end

--- Seconds before it is ready.
local function recast_of(entry)
    if entry.kind == 'ja' then
        return (windower.ffxi.get_ability_recasts() or {})[entry.recast_id] or 0
    end
    return ((windower.ffxi.get_spell_recasts() or {})[entry.recast_id] or 0) / 100
end

--- Queue `name` unless its buff is up or it is on cooldown; nothing when the
--- jobs do not have it.
local function collect_plain(name, to_cast, status)
    local entry = lookup(name)
    if not entry or not known(entry) then return false end
    local recast = recast_of(entry)
    if buffactive[name] then
        table.insert(status, {name = name, status = 'active'})
    elseif is_recast_ready(recast) then
        table.insert(to_cast, {name = name, magic = entry.kind == 'ma'})
    else
        table.insert(status, {name = name, status = 'cooldown', time = math.ceil(recast)})
    end
    return true
end

---============================================================================
--- NAMES WITH A RULE OF THEIR OWN
---============================================================================

local function two_handed()
    local name = player and player.equipment and player.equipment.main
    if not name or name == '' or name == 'empty' then return false end
    local res = resources()
    local ok, item = pcall(function() return res.items:with('en', name) end)
    if not ok or not item or not item.skill then return true end
    return TWO_HANDED[item.skill] == true
end

local SPECIAL = {}

--- Warcry; Blood Rage (WAR main) while Warcry is on cooldown. The two share
--- no recast but do not stack.
SPECIAL['Warcry'] = function(to_cast, status)
    local warcry, blood = lookup('Warcry'), lookup('Blood Rage')
    if not (warcry and known(warcry)) then return end
    local w_recast = recast_of(warcry)
    local has_blood = blood and known(blood)
    if buffactive['Warcry'] then
        table.insert(status, {name = 'Warcry', status = 'active'})
    elseif is_recast_ready(w_recast) and not buffactive['Blood Rage'] then
        table.insert(to_cast, {name = 'Warcry'})
    elseif is_on_cooldown(w_recast) then
        table.insert(status, {name = 'Warcry', status = 'cooldown', time = math.ceil(w_recast)})
    end
    if not has_blood then return end
    local b_recast = recast_of(blood)
    if buffactive['Blood Rage'] then
        table.insert(status, {name = 'Blood Rage', status = 'active'})
    elseif is_recast_ready(b_recast) and not buffactive['Warcry'] and is_on_cooldown(w_recast) then
        table.insert(to_cast, {name = 'Blood Rage'})
    elseif is_on_cooldown(b_recast) then
        table.insert(status, {name = 'Blood Rage', status = 'cooldown', time = math.ceil(b_recast)})
    end
end

SPECIAL['Hasso'] = function(to_cast, status)
    if two_handed() then collect_plain('Hasso', to_cast, status) end
end

SPECIAL['Utsusemi'] = function(to_cast, status)
    local recasts = windower.ffxi.get_spell_recasts() or {}
    local learned = windower.ffxi.get_spells() or {}
    local ni, ichi = (recasts[339] or 0) / 100, (recasts[338] or 0) / 100
    if learned[339] and is_recast_ready(ni) then
        table.insert(to_cast, {name = 'Utsusemi: Ni', magic = true})
    elseif learned[338] and is_recast_ready(ichi) then
        table.insert(to_cast, {name = 'Utsusemi: Ichi', magic = true})
    elseif learned[338] then
        table.insert(status, {name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni)})
        table.insert(status, {name = 'Utsusemi: Ichi', status = 'cooldown', time = math.ceil(ichi)})
    end
end

SPECIAL['Haste Samba'] = function(to_cast, status)
    local entry = lookup('Haste Samba')
    if not (entry and known(entry)) then return end
    local recast = recast_of(entry)
    if buffactive['Haste Samba'] then
        table.insert(status, {name = 'Haste Samba', status = 'active'})
    elseif not is_recast_ready(recast) then
        table.insert(status, {name = 'Haste Samba', status = 'cooldown', time = math.ceil(recast)})
    else
        local tp = require('shared/utils/core/live_tp')()
        if tp < HASTE_SAMBA_TP then
            table.insert(status, {name = 'Haste Samba', status = 'tp', value = tp, extra = HASTE_SAMBA_TP})
        else
            table.insert(to_cast, {name = 'Haste Samba'})
        end
    end
end

---============================================================================
--- API
---============================================================================

--- What to cast now from a list of names, in order, and the status of the rest.
--- @param names table Ability / spell names
--- @return table to_cast List of {name, magic?}
--- @return table status List of {name, status, time?}
function BuffList.collect(names)
    local to_cast, status = {}, {}
    for _, name in ipairs(type(names) == 'table' and names or {}) do
        if type(name) == 'string' then
            local special = SPECIAL[name]
            if special then special(to_cast, status) else collect_plain(name, to_cast, status) end
        end
    end
    return to_cast, status
end

--- Cast a queue `spacing` seconds apart (/ma for the entries marked magic).
--- @param queue table From collect()
--- @param spacing number Seconds between two casts
function BuffList.cast(queue, spacing)
    for i, entry in ipairs(queue) do
        local command = 'input ' .. (entry.magic and '/ma' or '/ja') .. ' "' .. entry.name .. '" <me>'
        send_command(i == 1 and command or ('wait ' .. ((i - 1) * spacing) .. '; ' .. command))
    end
end

return BuffList
