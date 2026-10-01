---============================================================================
--- Cleanse - take the debuffs off every character of the box group
---============================================================================
---   //gs c cleanse          this character and the others of the box group
---   //gs c cleanse self     this character only
---   //gs c cleanse check    what the key would do now, nothing is used
---
--- Each box handles itself (the key sends `cleanse local <name>` to the
--- others), like //gs c stealth. For every debuff on it, most urgent first
--- (shared/data/debuffs/DEBUFF_REMOVAL.lua, order changed by
--- _common/combat/CLEANSE_CONFIG.lua):
---   1. its own spell (Paralyna, Silena, Cursna, Erase...) when it can cast
---      it now;
---   2. a partner that may have the spell is asked (`cleanse cast <spell>
---      <name>`, it casts only if it can); `partner_wait` seconds later, the
---      debuff still on, the item is used;
---   3. its own item (Echo Drops, Remedy, Holy Water, Panacea...); Doom:
---      Holy Water again while Doom stays, up to `doom_tries`.
---   Asleep, petrified, stunned: only a partner can act (Cure wakes, Stona).
---   A debuff an item did not take off (an aura, uncurable_debuffs.lua) is
---   left alone.
--- Actions go one after the other through the shared queue
--- (shared/utils/core/action_queue.lua). Each box sends what it did to the
--- box that pressed the key, which shows it.
---
--- @file shared/utils/debuff/cleanse.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local Cleanse = {}

local Methods = require('shared/utils/debuff/cleanse_methods')
local ActionQueue = require('shared/utils/core/action_queue')

local DELAY = 1.0        -- seconds after each action before the next
local WAIT_MARGIN = 3.0  -- longest wait = cast time + this

local function others()
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    return ok and AltGroup and AltGroup.get_alts() or {}
end

local function push(command, wait)
    ActionQueue.push(command, wait, {delay = DELAY, tag = 'CLEANSE'})
end

local function push_next(command, wait)
    ActionQueue.push_next(command, wait, {delay = DELAY, tag = 'CLEANSE'})
end

--- Name the aura marks go by: the game's buff name in lowercase, as
--- uncurable_debuffs.lua looks it up ('attack down', 'max hp down').
local function mark_name(entry)
    return entry.name:lower()
end

local function info_block(block)
    local ok, InfoBlock = pcall(require, 'shared/utils/messages/info_block')
    if ok and InfoBlock then InfoBlock.show(block) end
end

local function uncurable()
    return require('shared/utils/debuff/uncurable_debuffs')
end

---============================================================================
--- ACTIONS
---============================================================================

--- Use an item, decided when its turn comes: the debuff may be gone by
--- then (one Panacea takes every erasable debuff off, a partner's spell
--- landed). The aura watch starts as the item goes, so an earlier item of
--- the queue is not counted; not for Doom, whose Holy Water fails two times
--- in three, which says nothing of an aura. Doom: again while it stays.
local function use_item(entry, item, tries, settings, front)
    -- a Doom retry goes right away, before the other debuffs
    local add = front and push_next or push
    add(function()
        if not Methods.is_up(entry) then return end
        if entry.key ~= 'doom' then
            uncurable().watch(mark_name(entry), item, 0, function(name, item_name)
                local ok, MessageDebuffs = pcall(require, 'shared/utils/messages/formatters/magic/message_debuffs')
                if ok then MessageDebuffs.show_debuff_uncurable(name, item_name) end
            end)
        end
        -- In front, in reverse: the item goes next, then the Doom retry
        if entry.key == 'doom' and tries < (settings.doom_tries or 1) then
            push_next(function()
                local again = Methods.is_up(entry) and Methods.first_item(Methods.items_for(entry, settings))
                if again then use_item(entry, again, tries + 1, settings, true) end
            end, 0.1)
        end
        push_next(('input /item "%s" <me>'):format(item.name), Methods.cast_time(item.name) + WAIT_MARGIN)
    end, 0.05)
end

--- The partners that may cast the spell (jobs known from the dual-box
--- exchange; unknown jobs are asked anyway).
local function partners_for(spell)
    local ok, AltStates = pcall(require, 'shared/utils/dualbox/alt_states')
    local names = {}
    for _, name in ipairs(others()) do
        local st = ok and AltStates and AltStates.get(name) or nil
        if Methods.partner_may_cast(spell, st and st.job, st and st.subjob) then names[#names + 1] = name end
    end
    return names
end

local function ask_partners(names, spell)
    for _, name in ipairs(names) do
        send_command(('send %s gs c cleanse cast %s %s'):format(name, spell, player.name))
    end
end

--- Ask the partners that may have the spell of a debuff to cast it on this
--- character (Auto Medicine with no item left, precast_guard.lua).
--- @param key string DEBUFF_REMOVAL key ('silence', 'paralysis')
--- @return table names asked (empty when nobody may have it)
function Cleanse.ask_partners_for(key)
    for _, entry in ipairs(require('shared/data/debuffs/DEBUFF_REMOVAL')) do
        if entry.key == key and entry.spell then
            local names = partners_for(entry.spell)
            ask_partners(names, entry.spell)
            return names
        end
    end
    return {}
end

---============================================================================
--- PLAN: what to do for each debuff (used by the key and by check)
---============================================================================

--- One debuff: the way chosen, as {text, tone, run}. `run` does it.
local function plan_one(entry, settings, up)
    if uncurable().is_marked(mark_name(entry)) then
        return {text = 'left alone (item had no effect: aura?)', tone = 'warn'}
    end
    local item = not entry.no_action and Methods.best_item(Methods.items_for(entry, settings), entry.key, up or {}) or nil
    if entry.spell and settings.use_spells ~= false and not entry.no_action and Methods.can_cast(entry.spell) then
        return {text = entry.spell, tone = 'good', run = function()
            -- decided when its turn comes: an earlier Erase or item may have
            -- taken it off already
            push(function()
                if Methods.is_up(entry) then
                    push_next(('input /ma "%s" <me>'):format(entry.spell), Methods.cast_time(entry.spell) + WAIT_MARGIN)
                end
            end, 0.05)
        end}
    end
    local partners = (entry.spell and settings.ask_partner ~= false) and partners_for(entry.spell) or {}
    if #partners > 0 then
        local text = ('%s from %s'):format(entry.spell, table.concat(partners, '/'))
        if item then text = text .. (', else %s'):format(item.name) end
        -- `later` runs once, after the one partner_wait shared by every
        -- debuff a partner was asked for (run_self)
        return {text = text, tone = 'good', run = function()
            ask_partners(partners, entry.spell)
        end, later = item and function()
            if Methods.is_up(entry) then use_item(entry, item, 1, settings) end
        end or nil}
    end
    if item then
        return {text = item.name, tone = 'good', run = function() use_item(entry, item, 1, settings) end}
    end
    if entry.no_action then return {text = 'cannot act, no partner can help', tone = 'bad'} end
    if entry.spell or entry.items then return {text = 'no item, no spell', tone = 'bad'} end
    return {text = 'nothing removes it', tone = 'dim'}
end

--- The plan for every debuff on this character.
--- @return table list of {entry, text, tone, run}
local function plan()
    local settings = Methods.settings()
    local out = {}
    local active = Methods.active(settings)
    local up = {}
    for _, entry in ipairs(active) do up[entry.key] = true end
    for _, entry in ipairs(active) do
        local way = plan_one(entry, settings, up)
        way.entry = entry
        out[#out + 1] = way
    end
    return out
end

---============================================================================
--- REPORT
---============================================================================

--- Send a line per debuff to the box that pressed the key (spaces as _,
--- lines separated by | : a ; would end the console command).
local function report_to(name, steps)
    local parts = {}
    for _, step in ipairs(steps) do
        parts[#parts + 1] = (step.entry.name .. '=' .. step.text):gsub(' ', '_')
    end
    local body = #parts > 0 and table.concat(parts, '|') or 'none'
    send_command(('send %s gs c cleanse report %s %s'):format(name, player.name, body))
end

local function show(name, steps)
    local fields = {}
    for _, step in ipairs(steps) do
        fields[#fields + 1] = {step.entry.name, step.text, step.tone}
    end
    if #fields == 0 then fields[1] = {'Debuffs', 'none', 'dim'} end
    info_block({tag = 'CLEANSE', title = name, fields = fields})
end

--- `cleanse report <name> <body>`: another box's result.
local function receive_report(name, body)
    if not name then return end
    local fields = {}
    if body and body ~= 'none' then
        for line in body:gmatch('[^|]+') do
            local debuff, text = line:match('^([^=]+)=(.*)$')
            if debuff then fields[#fields + 1] = {debuff:gsub('_', ' '), (text:gsub('_', ' '))} end
        end
    end
    if #fields == 0 then fields[1] = {'Debuffs', 'none', 'dim'} end
    info_block({tag = 'CLEANSE', title = name, fields = fields})
end

---============================================================================
--- COMMAND
---============================================================================

--- This character's part: plan, act, show (and send to `from`).
local function run_self(from)
    local steps = plan()
    local later = {}
    for _, step in ipairs(steps) do
        if step.run then step.run() end
        if step.later then later[#later + 1] = step.later end
    end
    if #later > 0 then
        -- A function step runs first and then waits: an empty step holds the
        -- queue for partner_wait, the check comes after it
        push(function() end, Methods.settings().partner_wait or 5)
        push(function()
            for _, fn in ipairs(later) do fn() end
        end, 0.1)
    end
    if from and from:lower() ~= player.name:lower() then
        report_to(from, steps)
    else
        show(player.name, steps)
    end
end

--- `cleanse cast <spell> <name>`: a partner asks; cast it only if possible now.
local function cast_for(spell, name)
    if not (spell and name and Methods.SPELLS[spell]) then return end
    if not Methods.can_cast(spell) then return end
    push(('input /ma "%s" %s'):format(spell, name), Methods.cast_time(spell) + WAIT_MARGIN)
end

--- //gs c cleanse ...
--- @param args table Words after "cleanse"
--- @return boolean handled
function Cleanse.handle(args)
    local sub = args[1] and args[1]:lower() or ''
    if sub == '' then
        run_self(nil)
        for _, name in ipairs(others()) do
            send_command(('send %s gs c cleanse local %s'):format(name, player.name))
        end
    elseif sub == 'self' then
        run_self(nil)
    elseif sub == 'local' then
        run_self(args[2])
    elseif sub == 'cast' then
        -- spell names have no space (Paralyna, Cursna, Erase, Cure)
        cast_for(args[2], args[3])
    elseif sub == 'report' then
        receive_report(args[2], args[3])
    elseif sub == 'check' then
        local steps = plan()
        local fields = {{'Jobs', ('%s/%s'):format(tostring(player.main_job), tostring(player.sub_job or '-'))}}
        for _, step in ipairs(steps) do fields[#fields + 1] = {step.entry.name, step.text, step.tone} end
        if #steps == 0 then fields[#fields + 1] = {'Debuffs', 'none', 'dim'} end
        info_block({tag = 'CLEANSE', title = 'Check (nothing is used)', fields = fields})
    else
        local ok, HelpScreen = pcall(require, 'shared/utils/messages/help_screen')
        if ok and HelpScreen then
            HelpScreen.show({title = 'CLEANSE', subtitle = 'Debuffs off, you + alts', groups = {
                {title = 'COMMANDS', rows = {
                    {'//gs c cleanse', '', 'You and the box group'},
                    {'//gs c cleanse self', '', 'This character only'},
                    {'//gs c cleanse check', '', 'What it would do, nothing used'},
                }},
            }, notes = {'Settings: _common/combat/CLEANSE_CONFIG.lua'}})
        end
    end
    return true
end

return Cleanse
