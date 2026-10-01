---  ═══════════════════════════════════════════════════════════════════════════
---   Self Buff Manager - a list of buff names turned into actions, one engine
---  ═══════════════════════════════════════════════════════════════════════════
---   Used by //gs c buff (buff_command.lua: the main job's list, then the
---   subjob's) and WAR's //gs c berserk / defender. The lists come from the
---   character's _common/combat/BUFF_CONFIG.lua (buff_config.lua).
---
---   An entry is a name ('Stoneskin', 'Berserk') or {name = ..., buff = ...,
---   wait = ...}; {spell = ...} / {ability = ...} also work. It is found in the
---   game data (a job ability first, else a spell) and skipped quietly when
---   the current jobs cannot use it (abilities: read from the game; spells:
---   learned and the main or sub level); otherwise skipped, and reported,
---   when its buff is already up (the buff the action gives: Enlight II gives
---   Enlight) or it is on recast, and skipped when it was used seconds ago
---   (double press). Tiers of one buff, best first (Refresh III, Refresh II,
---   Refresh): the first one available goes, the others are left out.
---   A few names keep a rule of their own:
---     Warcry       Blood Rage instead while Warcry is on cooldown (WAR main)
---     Hasso, Seigan  only with a two-handed weapon in hand
---     Utsusemi     Utsusemi: Ni, else Ichi
---     Haste Samba  only with the TP it costs (350)
---   The actions go through the shared queue (shared/utils/core/action_queue.lua):
---   each one when the previous has ended, a refused spell sent again.
---
---   @file    shared/utils/buffs/self_buff_manager.lua
---   @author  ejouanchicot
---   @version 2.0 - names, rules, shared queue (was a factory for BLM's list)
---   @date    Created: 2026-09-17 | Updated: 2026-10-01
---  ═══════════════════════════════════════════════════════════════════════════

local SelfBuffManager = {}

-- is_recast_ready: global of RECAST_CONFIG.lua (loaded by the entry point)

--- Seconds during which a name just queued is not queued again (double press).
local CAST_COOLDOWN = 2.0
--- Seconds after an action ends before the next one goes: after a spell
--- the game refuses a new one for a moment (seen on 2026-10-01: a spell sent
--- 1 s after the previous one ended was refused, then sent again). Both are
--- BUFF_CONFIG.lua settings (wait_after_spell, wait_after_ability).
local DEFAULT_AFTER_SPELL = 3.0
local DEFAULT_AFTER_ABILITY = 0.5
--- Longest wait of a step = its cast time + this, when the game never says it ended.
local WAIT_MARGIN = 3.0

local HASTE_SAMBA_TP = 350
--- Weapon skills (res.items `skill`) of two-handed weapons: Hasso needs one.
local TWO_HANDED = {[4] = true, [6] = true, [7] = true, [8] = true, [10] = true, [12] = true}

local last_use = {}

local function resources()
    local ok, res = pcall(function() return rawget(_G, 'res') or windower.res or require('resources') end)
    return ok and res or nil
end

local function job_id(res, abbrev)
    local job = abbrev and res and res.jobs and res.jobs:with('ens', abbrev)
    return job and job.id
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENTRIES
---  ═══════════════════════════════════════════════════════════════════════════

--- An entry of a list resolved against the game data, or nil.
--- @param entry string|table
--- @param res table
--- @return table|nil {name, buff, is_ability, id, recast_id, levels, wait}
local function resolve(entry, res)
    if type(entry) == 'string' then entry = {name = entry} end
    if type(entry) ~= 'table' then return nil end
    local name = entry.name or entry.ability or entry.spell
    if type(name) ~= 'string' or not res then return nil end
    local data, is_ability
    if not entry.spell then
        data = res.job_abilities and res.job_abilities:with('en', name)
        is_ability = data ~= nil
    end
    if not data and not entry.ability then
        data = res.spells and res.spells:with('en', name)
    end
    if not data then return nil end
    local status = data.status and res.buffs and res.buffs[data.status]
    local cast = (not is_ability and tonumber(data.cast_time)) or 1
    return {
        name = name,
        buff = entry.buff or (status and status.en) or (is_ability and name) or nil,
        is_ability = is_ability == true,
        id = data.id,
        recast_id = data.recast_id or data.id,
        levels = data.levels or {},
        wait = tonumber(entry.wait or entry.delay) or (cast + WAIT_MARGIN),
    }
end

--- What the current jobs can use, read once per press.
local function context(res)
    local abilities = {}
    local ok, got = pcall(windower.ffxi.get_abilities)
    if ok and type(got) == 'table' and type(got.job_abilities) == 'table' then
        for key, value in pairs(got.job_abilities) do
            abilities[(type(value) == 'number') and value or key] = true
        end
    end
    return {
        res = res,
        abilities = abilities,
        known = windower.ffxi.get_spells() or {},
        main_id = job_id(res, player and player.main_job),
        sub_id = job_id(res, player and player.sub_job),
        sub_level = player and player.sub_job_level or 0,
        ja_recasts = windower.ffxi.get_ability_recasts() or {},
        ma_recasts = windower.ffxi.get_spell_recasts() or {},
    }
end

--- Whether the current jobs can use it. Abilities: the game's list already
--- accounts for job and level. Spells: learned, and listed for the main job
--- (the scroll could not have been learned otherwise) or within the subjob level.
local function usable(item, ctx)
    if item.is_ability then return ctx.abilities[item.id] == true end
    if not ctx.known[item.id] then return false end
    if ctx.main_id and item.levels[ctx.main_id] then return true end
    return ctx.sub_id ~= nil and item.levels[ctx.sub_id] ~= nil and item.levels[ctx.sub_id] <= ctx.sub_level
end

--- Seconds before it is ready.
local function recast_of(item, ctx)
    if item.is_ability then return ctx.ja_recasts[item.recast_id] or 0 end
    return (ctx.ma_recasts[item.recast_id] or 0) / 100
end

local function item_of(name, ctx)
    local item = resolve(name, ctx.res)
    return item and usable(item, ctx) and item or nil
end

--- Queue it unless its buff is up, it is on recast or was just queued.
--- @return string 'active', 'cooldown', 'queued' or 'spam'
local function collect_item(item, ctx, to_cast, status)
    local recast = recast_of(item, ctx)
    if item.buff and buffactive[item.buff] then
        table.insert(status, {name = item.name, status = 'active'})
        return 'active'
    elseif not is_recast_ready(recast) then
        table.insert(status, {name = item.name, status = 'cooldown', time = math.ceil(recast)})
        return 'cooldown'
    elseif not (last_use[item.name] and os.clock() - last_use[item.name] < CAST_COOLDOWN) then
        table.insert(to_cast, item)
        return 'queued'
    end
    return 'spam'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   NAMES WITH A RULE OF THEIR OWN
---  ═══════════════════════════════════════════════════════════════════════════

local function two_handed(res)
    local name = player and player.equipment and player.equipment.main
    if not name or name == '' or name == 'empty' then return false end
    local ok, item = pcall(function() return res.items:with('en', name) end)
    if not ok or not item or not item.skill then return true end
    return TWO_HANDED[item.skill] == true
end

local SPECIAL = {}

--- Warcry; Blood Rage (WAR main) while Warcry is on cooldown: they do not stack.
SPECIAL['Warcry'] = function(ctx, to_cast, status)
    local warcry, blood = item_of('Warcry', ctx), item_of('Blood Rage', ctx)
    if not warcry then return end
    local w_recast = recast_of(warcry, ctx)
    if buffactive['Warcry'] then
        table.insert(status, {name = 'Warcry', status = 'active'})
    elseif is_recast_ready(w_recast) and not buffactive['Blood Rage'] then
        table.insert(to_cast, warcry)
    elseif not is_recast_ready(w_recast) then
        table.insert(status, {name = 'Warcry', status = 'cooldown', time = math.ceil(w_recast)})
    end
    if not blood then return end
    local b_recast = recast_of(blood, ctx)
    if buffactive['Blood Rage'] then
        table.insert(status, {name = 'Blood Rage', status = 'active'})
    elseif is_recast_ready(b_recast) and not buffactive['Warcry'] and not is_recast_ready(w_recast) then
        table.insert(to_cast, blood)
    elseif not is_recast_ready(b_recast) then
        table.insert(status, {name = 'Blood Rage', status = 'cooldown', time = math.ceil(b_recast)})
    end
end

for _, stance in ipairs({'Hasso', 'Seigan'}) do
    SPECIAL[stance] = function(ctx, to_cast, status)
        local item = item_of(stance, ctx)
        if item and two_handed(ctx.res) then collect_item(item, ctx, to_cast, status) end
    end
end

--- Ni when ready, else Ichi (no buff check: the shadows are counted by the game).
SPECIAL['Utsusemi'] = function(ctx, to_cast, status)
    local ni, ichi = item_of('Utsusemi: Ni', ctx), item_of('Utsusemi: Ichi', ctx)
    local ni_recast = ni and recast_of(ni, ctx) or math.huge
    local ichi_recast = ichi and recast_of(ichi, ctx) or math.huge
    if ni and is_recast_ready(ni_recast) then
        table.insert(to_cast, ni)
    elseif ichi and is_recast_ready(ichi_recast) then
        table.insert(to_cast, ichi)
    elseif ichi then
        if ni then table.insert(status, {name = 'Utsusemi: Ni', status = 'cooldown', time = math.ceil(ni_recast)}) end
        table.insert(status, {name = 'Utsusemi: Ichi', status = 'cooldown', time = math.ceil(ichi_recast)})
    end
end

SPECIAL['Haste Samba'] = function(ctx, to_cast, status)
    local item = item_of('Haste Samba', ctx)
    if not item then return end
    local recast = recast_of(item, ctx)
    if buffactive['Haste Samba'] then
        table.insert(status, {name = 'Haste Samba', status = 'active'})
    elseif not is_recast_ready(recast) then
        table.insert(status, {name = 'Haste Samba', status = 'cooldown', time = math.ceil(recast)})
    else
        local tp = require('shared/utils/core/live_tp')()
        if tp < HASTE_SAMBA_TP then
            table.insert(status, {name = 'Haste Samba', status = 'tp', value = tp, extra = HASTE_SAMBA_TP})
        else
            table.insert(to_cast, item)
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   API
---  ═══════════════════════════════════════════════════════════════════════════

--- What to use now from a list, in order, and the state of the rest.
--- @param list table Names or entries
--- @return table to_cast Resolved entries ({name, is_ability, wait...})
--- @return table status List of {name, status, time?, value?, extra?}
function SelfBuffManager.collect(list)
    local to_cast, status = {}, {}
    local res = resources()
    if type(list) ~= 'table' or not res then return to_cast, status end
    local ctx = context(res)
    -- Tiers of one buff (Refresh III, Refresh II, Refresh), best first: once
    -- one is up or queued, the others of that buff are left out; a tier on
    -- recast lets the next one go
    local covered = {}
    for _, entry in ipairs(list) do
        local name = type(entry) == 'table' and (entry.name or entry.ability or entry.spell) or entry
        if SPECIAL[name] then
            SPECIAL[name](ctx, to_cast, status)
        else
            local item = resolve(entry, res)
            if item and usable(item, ctx) and not (item.buff and covered[item.buff]) then
                local outcome = collect_item(item, ctx, to_cast, status)
                if item.buff and (outcome == 'active' or outcome == 'queued' or outcome == 'spam') then
                    covered[item.buff] = true
                end
            end
        end
    end
    return to_cast, status
end

--- Send the actions through the shared queue, each when the previous has ended.
--- @param to_cast table From collect() (entries may also be {name, magic?})
function SelfBuffManager.cast(to_cast)
    local ActionQueue = require('shared/utils/core/action_queue')
    local cfg = require('shared/utils/buffs/buff_config').get()
    local after_spell = tonumber(cfg.wait_after_spell) or DEFAULT_AFTER_SPELL
    local after_ability = tonumber(cfg.wait_after_ability) or DEFAULT_AFTER_ABILITY
    local seen = {}
    for _, item in ipairs(to_cast or {}) do
        if not seen[item.name] then
            seen[item.name] = true
            last_use[item.name] = os.clock()
            local magic = item.is_ability == false or item.magic == true
            local command = ('input %s "%s" <me>'):format(magic and '/ma' or '/ja', item.name)
            local delay = magic and after_spell or after_ability
            ActionQueue.push(command, (item.wait or (1 + WAIT_MARGIN)) + delay, {delay = delay, tag = 'BUFF'})
        end
    end
end

--- Report what was not used: active / cooldown lines, then a short TP.
--- @param status table From collect()
--- @param action_type string|nil Label of the status block
function SelfBuffManager.show_status(status, action_type)
    local lines, short_tp = {}, {}
    for _, entry in ipairs(status or {}) do
        if entry.status == 'tp' then
            short_tp[#short_tp + 1] = {type = 'tp', name = entry.name, value = entry.value, extra = entry.extra}
        else
            lines[#lines + 1] = entry
        end
    end
    if #lines > 0 then
        require('shared/utils/messages/formatters/magic/message_buffs').show_buff_status(lines, action_type)
    end
    if #short_tp > 0 then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_multi_status(short_tp, MessageFormatter.get_job_tag())
    end
end

return SelfBuffManager
