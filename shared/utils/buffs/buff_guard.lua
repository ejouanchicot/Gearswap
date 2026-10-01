---============================================================================
--- Buff Guard - a debuff landing while //gs c buff runs its queue
---============================================================================
--- Checked just before each action of the buff queue (ActionQueue guard),
--- and before each song of //gs c songs (BRD song_queue.lua):
---   asleep, petrified, stunned, terrified, charmed  the buff queue stops:
---                       nothing more is sent, the player has the hand back
---   Paralysis           cured first: Paralyna when this character can cast
---                       it now (WHM, /WHM, SCH under Addendum: White), else
---                       the item of CLEANSE_CONFIG.lua (Remedy); then the
---                       queue goes on. No way, or an aura: it goes on anyway
---                       (paralysis only makes an action fail some of the time)
---   Silence             before a spell: the item (Echo Drops, Remedy), then
---                       the spells go on; no item, or an aura: the spells
---                       left are dropped, the abilities go on
---   Mute / Omerta       before a spell: the spells left are dropped
---   Amnesia             before an ability: that ability is dropped
--- One cure try per debuff and per buff press: if it did not take the debuff
--- off, the rule without cure applies.
---
--- @file shared/utils/buffs/buff_guard.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local BuffGuard = {}

local NO_ACTION = {[2] = 'asleep', [19] = 'asleep', [193] = 'asleep', [7] = 'petrified',
    [10] = 'stunned', [28] = 'terrified', [14] = 'charmed', [17] = 'charmed'}
local SILENCE, MUTE, OMERTA, AMNESIA = 6, 29, 262, 16
--- Paralysis, and its geomancy aura id (DEBUFF_REMOVAL.lua)
local PARALYSIS_IDS = {4, 566}
local AFTER_SPELL, AFTER_ITEM = 3.0, 1.0

--- Label of the messages: 'buff', or the step's own (BRD songs: 'songs').
local label = 'buff'

local function warn(text)
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter and MessageFormatter.show_warning then MessageFormatter.show_warning(label .. ': ' .. text) end
end

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('BUFF', fmt, unpack(args)) end)
end

--- The debuffs on now, read from the game (buffactive lags in a coroutine).
local function debuffs()
    local me = windower.ffxi.get_player()
    local ids = {}
    for _, id in ipairs(me and me.buffs or {}) do ids[id] = true end
    return ids
end

--- Tries made this press, per debuff (reset() at each press).
local function tries()
    windower._buff_cure_tries = windower._buff_cure_tries or {}
    return windower._buff_cure_tries
end

--- The cure steps of a debuff, or nil when there is no way: own spell
--- (`spell_ok` false when silenced) then item, from cleanse_methods.lua.
local function cure_steps(key, spell_ok)
    local Methods = require('shared/utils/debuff/cleanse_methods')
    local entry
    for _, e in ipairs(require('shared/data/debuffs/DEBUFF_REMOVAL')) do
        if e.key == key then entry = e break end
    end
    if not entry then return nil end
    local ok, Uncurable = pcall(require, 'shared/utils/debuff/uncurable_debuffs')
    if ok and Uncurable and Uncurable.is_marked(entry.name:lower()) then return nil, 'aura' end
    if spell_ok and entry.spell and Methods.can_cast(entry.spell) then
        return {{command = ('input /ma "%s" <me>'):format(entry.spell),
            wait = Methods.cast_time(entry.spell) + 3 + AFTER_SPELL, delay = AFTER_SPELL, tag = 'BUFF'}}, entry.spell
    end
    local up = {}
    up[key] = true
    local item = Methods.best_item(Methods.items_for(entry, Methods.settings()), key, up)
    if not item then return nil end
    return {{command = ('input /item "%s" <me>'):format(item.name), wait = 4 + AFTER_ITEM,
        delay = AFTER_ITEM, tag = 'BUFF'}}, item.name
end

--- Cure first, once per press; nil when no cure applies or it was tried.
local function cure_first(key, spell_ok)
    local t = tries()
    if t[key] then return nil end
    t[key] = true
    local steps, what = cure_steps(key, spell_ok)
    if steps then
        trace('%s: %s first', key, what)
        warn(('%s: %s first'):format(key, what))
    end
    return steps, what
end

--- The guard of a buff step (see the header).
--- @param step table {command, magic...}
--- @return string|nil verdict, table|nil steps to run first
function BuffGuard.check(step)
    label = step.label or 'buff'
    local ids = debuffs()
    for id, what in pairs(NO_ACTION) do
        if ids[id] then
            warn(what .. ((label == 'songs') and ': the songs left are dropped' or ': the buffs left are dropped'))
            trace('%s: queue stopped', what)
            return 'stop'
        end
    end
    if step.magic then
        if ids[MUTE] or ids[OMERTA] then
            warn('cannot cast (Mute / Omerta): the ' .. ((label == 'songs') and 'songs' or 'spells') .. ' left are dropped')
            return 'stop_magic'
        end
        if ids[SILENCE] then
            local first = cure_first('silence', false)
            if first then return 'before', first end
            warn('silenced, no cure: the ' .. ((label == 'songs') and 'songs' or 'spells') .. ' left are dropped')
            return 'stop_magic'
        end
    elseif ids[AMNESIA] then
        trace('amnesia: %s dropped', tostring(step.command))
        return 'skip'
    end
    local paralyzed = false
    for _, id in ipairs(PARALYSIS_IDS) do paralyzed = paralyzed or ids[id] == true end
    if paralyzed then
        local first = cure_first('paralysis', not (ids[SILENCE] or ids[MUTE] or ids[OMERTA]))
        if first then return 'before', first end
    end
    return nil
end

--- A new press: the cure tries start over.
function BuffGuard.reset()
    windower._buff_cure_tries = {}
end

return BuffGuard
