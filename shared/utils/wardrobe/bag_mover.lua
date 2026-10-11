---============================================================================
--- Bag Mover - plays the tidy-up plan of the Atelier page, one item at a time
---============================================================================
--- The Atelier page works out where each misplaced item should go and sends
--- the list here (atelier_live.lua, /bag_plan). In game:
---
---   //gs c bags          what the plan would do, nothing moves
---   //gs c bags go       play it
---   //gs c bags stop     stop now (an item in hand stays in the inventory)
---
--- What this file can do to an item, and nothing else: take it out of a bag
--- into the inventory (windower.ffxi.get_item), put it from the inventory into
--- a bag (windower.ffxi.put_item). It never drops, sells, trades, sends, uses
--- or sorts anything, and holds no other call that changes a bag
--- (scripts/atelier/bag_mover_test.lua checks the file for that).
---
--- One item at a time, each step checked before the next:
---   1. the item is still in the bag and slot kind the plan says, not worn,
---      not in the bazaar; both bags are open to the character (a Mog House
---      bag only in the Mog House); a free slot in the inventory and in the
---      bag it goes to. Anything else: that move is skipped and said.
---   2. out of its bag into the inventory; the game must show it there.
---   3. from the inventory into its bag; the game must show it there.
--- Where and when: only a bag the game gives the character right now is
--- touched. The four Mog House bags (Mog Safe, Mog Safe 2, Storage, Mog
--- Locker) only inside the Mog House; a wardrobe not bought or a locker whose
--- lease ran out is closed everywhere; the Porter Moogle's slips and the
--- delivery box are never touched at all. The character must stand idle:
--- engaged, dead, resting, in an event or a menu, the run stops before the
--- next move. //gs c bags lists the bags open where you stand.
--- A step the game does not confirm stops the whole run: the item is then
--- either where it was or in the inventory, never anywhere else. Every move
--- is written to <Character>/atelier/bag_moves.log.
---
--- @file    shared/utils/wardrobe/bag_mover.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local BagMover = {}

local INVENTORY = 0
-- Bags of the Mog House: open only inside it
local HOUSE = {[1] = true, [2] = true, [4] = true, [9] = true}
local BAG_NAMES = {[0] = 'Inventory', [1] = 'Mog Safe', [2] = 'Storage', [4] = 'Mog Locker', [5] = 'Mog Satchel',
    [6] = 'Mog Sack', [7] = 'Mog Case', [8] = 'Wardrobe', [9] = 'Mog Safe 2', [10] = 'Wardrobe 2', [11] = 'Wardrobe 3',
    [12] = 'Wardrobe 4', [13] = 'Wardrobe 5', [14] = 'Wardrobe 6', [15] = 'Wardrobe 7', [16] = 'Wardrobe 8'}
-- Seconds between a step and its check, and how many checks before the run stops
local STEP_WAIT, TRIES = 0.8, 5

--- The run's state, kept on windower so a job reload does not lose it:
--- {moves, at, token, running, index, done, skipped, char}
local function state()
    windower._bag_mover = windower._bag_mover or {moves = {}}
    return windower._bag_mover
end

local function bag_name(id) return BAG_NAMES[id] or ('bag ' .. tostring(id)) end

local function say(title, fields, lines)
    require('shared/utils/messages/info_block').show({tag = 'BAGS', title = title, fields = fields, lines = lines})
end

--- One line in the journal of moves.
local function journal(text)
    local ok, path = pcall(function() return require('shared/utils/core/char_paths').writable('atelier', 'bag_moves.log') end)
    local file = ok and path and io.open(path, 'a')
    if not file then return end
    file:write(os.date('%Y-%m-%d %H:%M:%S') .. '  ' .. text .. '\n')
    file:close()
end

--- How many of an item a bag holds, and the slots that hold it (movable ones: not worn, not in the bazaar).
--- @return number count, table slots {index = count}
local function held(bag, id)
    local items, count, slots = windower.ffxi.get_items(bag), 0, {}
    for index, item in ipairs(type(items) == 'table' and items or {}) do
        if type(item) == 'table' and item.id == id then
            count = count + (item.count or 1)
            if item.status == 0 then slots[index] = item.count or 1 end
        end
    end
    return count, slots
end

local function free_slots(bag)
    local info = windower.ffxi.get_bag_info(bag)
    return (info and info.enabled and info.max and info.count) and (info.max - info.count) or 0
end

--- Why a bag cannot be used now, or nil.
local function closed(bag)
    local info = windower.ffxi.get_bag_info(bag)
    if not (info and info.enabled) then return 'bag not available' end
    if HOUSE[bag] and not (windower.ffxi.get_info() or {}).mog_house then return 'only in the Mog House' end
    return nil
end

--- Why nothing may be moved right now, or nil: the character must be logged in and standing idle
--- (status 0; engaged, dead, resting, in an event: not now).
local function busy()
    local info, me = windower.ffxi.get_info() or {}, windower.ffxi.get_player()
    if info.logged_in == false or not me then return 'not in game' end
    if me.status ~= 0 then return 'you are not idle (fighting, resting, in an event or dead)' end
    return nil
end

--- The bags open where the character stands, and the closed ones with why.
--- @return table open names, table closed {name .. ' (' .. why .. ')'}
local function bags_here()
    local open, shut = {}, {}
    for _, id in ipairs({0, 8, 10, 11, 12, 13, 14, 15, 16, 5, 6, 7, 1, 9, 2, 4}) do
        local why = closed(id)
        if why then shut[#shut + 1] = bag_name(id) .. ' (' .. why .. ')' else open[#open + 1] = bag_name(id) end
    end
    return open, shut
end

--- Why a move cannot be made now, or nil with the slot to take.
--- @return string|nil reason, number|nil slot, number|nil count
local function check(move)
    local why = closed(move.from) or closed(move.to)
    if why then return why end
    local _, slots = held(move.from, move.id)
    local slot, count = next(slots)
    if not slot then return 'not in ' .. bag_name(move.from) .. ' any more (or worn)' end
    if move.from ~= INVENTORY and free_slots(INVENTORY) < 1 then return 'inventory full' end
    if move.to ~= INVENTORY and free_slots(move.to) < 1 then return bag_name(move.to) .. ' full' end
    return nil, slot, count
end

---============================================================================
--- THE PLAN
---============================================================================

--- Take the plan the page sends: one move a line, "id<TAB>from<TAB>to<TAB>name".
--- A line that is not exactly that, or names a bag this file does not know, is refused.
--- @param text string
--- @return table {ok, moves, refused}
function BagMover.set_plan(text)
    local st, moves, refused = state(), {}, 0
    if st.running then return {ok = false, error = 'running'} end
    for line in (tostring(text or '') .. '\n'):gmatch('([^\n]*)\n') do
        local id, from, to, name = line:match('^(%d+)\t(%d+)\t(%d+)\t(.-)\r?$')
        id, from, to = tonumber(id), tonumber(from), tonumber(to)
        if id and BAG_NAMES[from] and BAG_NAMES[to] and from ~= to then
            moves[#moves + 1] = {id = id, from = from, to = to, name = name ~= '' and name or ('#' .. id)}
        elseif line:match('%S') then
            refused = refused + 1
        end
    end
    st.moves, st.at, st.index, st.done, st.skipped = moves, os.date('%Y-%m-%d %H:%M'), 0, 0, {}
    st.char = player and player.name or nil
    journal(('plan received: %d moves (%d lines refused)'):format(#moves, refused))
    return {ok = true, moves = #moves, refused = refused}
end

--- What the plan would do now: nothing moves.
function BagMover.preview()
    local st, by, blocked, ready = state(), {}, {}, 0
    if #st.moves == 0 then
        return say('Tidy-up', {{'Plan', 'none', 'warn'}}, {'Send it from the Atelier page: My character > Bags > The plan.'})
    end
    for _, move in ipairs(st.moves) do
        local why = check(move)
        if why then
            blocked[why] = (blocked[why] or 0) + 1
        else
            ready = ready + 1
            local key = bag_name(move.from) .. ' > ' .. bag_name(move.to)
            by[key] = (by[key] or 0) + 1
        end
    end
    local fields = {{'Plan of', st.at or '?'}, {'Moves', #st.moves}, {'Ready now', ready, ready > 0 and 'good' or 'warn'}}
    local not_now = busy()
    if not_now then fields[#fields + 1] = {'Cannot start', not_now, 'bad'} end
    for key, n in pairs(by) do fields[#fields + 1] = {key, n} end
    for why, n in pairs(blocked) do fields[#fields + 1] = {'Waiting: ' .. why, n, 'warn'} end
    local open, shut = bags_here()
    local lines = {'Open here: ' .. table.concat(open, ', ')}
    if #shut > 0 then lines[#lines + 1] = 'Closed here: ' .. table.concat(shut, ', ') end
    lines[#lines + 1] = '//gs c bags go plays the moves that are ready, one at a time.'
    lines[#lines + 1] = 'Nothing is ever dropped, sold or sent: items only go from a bag to another.'
    say('Tidy-up (nothing moved)', fields, lines)
end

---============================================================================
--- THE RUN
---============================================================================

local step

local function finish(st, title, kind, why)
    st.running = false
    local fields = {{'Moved', st.done, 'good'}, {'Skipped', #st.skipped, #st.skipped > 0 and 'warn' or nil}}
    if why then fields[#fields + 1] = {'Stopped', why, kind} end
    local lines = {}
    for i = 1, math.min(#st.skipped, 8) do lines[#lines + 1] = st.skipped[i] end
    if #st.skipped > 8 then lines[#lines + 1] = ('... and %d more (bag_moves.log)'):format(#st.skipped - 8) end
    say(title, fields, lines)
    journal(('%s: %d moved, %d skipped%s'):format(title, st.done, #st.skipped, why and (' - ' .. why) or ''))
end

--- Wait until a bag holds `want` of the item, then go on; the run stops when the game never shows it.
local function wait_for(st, token, bag, id, want, left, what, after)
    if state().token ~= token then return end
    if (held(bag, id)) >= want then return after() end
    if left <= 0 then
        return finish(st, 'Tidy-up stopped', 'bad', what .. ' not confirmed by the game (the item is where it was or in the inventory)')
    end
    coroutine.schedule(function() wait_for(st, token, bag, id, want, left - 1, what, after) end, STEP_WAIT)
end

--- From the inventory into the bag the move names.
local function put(st, token, move, count, before)
    -- the slot that holds it now and did not before the item was taken out; any slot of it when it was there already
    local _, slots = held(INVENTORY, move.id)
    local slot
    for index, n in pairs(slots) do
        if n == count and not before[index] then slot = index break end
    end
    if not slot then for index, n in pairs(slots) do if n == count then slot = index break end end end
    if not slot then return finish(st, 'Tidy-up stopped', 'bad', move.name .. ': not found in the inventory') end
    if free_slots(move.to) < 1 then return finish(st, 'Tidy-up stopped', 'warn', bag_name(move.to) .. ' full (' .. move.name .. ' is in the inventory)') end
    local had = held(move.to, move.id)
    windower.ffxi.put_item(move.to, slot, count)
    coroutine.schedule(function()
        wait_for(st, token, move.to, move.id, had + count, TRIES, move.name .. ' into ' .. bag_name(move.to), function()
            st.done = st.done + 1
            journal(('moved  %s x%d  %s > %s'):format(move.name, count, bag_name(move.from), bag_name(move.to)))
            step(token)
        end)
    end, STEP_WAIT)
end

--- The next move of the plan.
step = function(token)
    local st = state()
    if st.token ~= token or not st.running then return end
    st.index = st.index + 1
    local move = st.moves[st.index]
    if not move then return finish(st, 'Tidy-up done', 'good') end
    local not_now = busy()
    if not_now then
        st.index = st.index - 1                      -- that move was not tried: //gs c bags go takes it up again
        return finish(st, 'Tidy-up stopped', 'warn', not_now)
    end
    local why, slot, count = check(move)
    if why then
        st.skipped[#st.skipped + 1] = move.name .. ': ' .. why
        journal(('skipped  %s  %s > %s  (%s)'):format(move.name, bag_name(move.from), bag_name(move.to), why))
        return coroutine.schedule(function() step(token) end, 0.05)
    end
    if move.from == INVENTORY then return put(st, token, move, count, {}) end
    local had, before = held(INVENTORY, move.id)
    windower.ffxi.get_item(move.from, slot, count)
    coroutine.schedule(function()
        wait_for(st, token, INVENTORY, move.id, had + count, TRIES, move.name .. ' out of ' .. bag_name(move.from), function()
            if move.to == INVENTORY then
                st.done = st.done + 1
                journal(('moved  %s x%d  %s > Inventory'):format(move.name, count, bag_name(move.from)))
                return step(token)
            end
            put(st, token, move, count, before)
        end)
    end, STEP_WAIT)
end

--- Play the plan.
function BagMover.start()
    local st = state()
    if st.running then return say('Tidy-up', {{'State', 'already running', 'warn'}}, {'//gs c bags stop to stop it.'}) end
    if #st.moves == 0 then return BagMover.preview() end
    if st.char and player and player.name ~= st.char then
        return say('Tidy-up', {{'Plan', 'made for ' .. st.char, 'bad'}}, {'Send the plan again from the page of this character.'})
    end
    local not_now = busy()
    if not_now then return say('Tidy-up', {{'Cannot start', not_now, 'bad'}}) end
    st.running, st.index, st.done, st.skipped = true, 0, 0, {}
    st.token = (st.token or 0) + 1
    journal(('run started: %d moves'):format(#st.moves))
    say('Tidy-up started', {{'Moves', #st.moves}}, {'One item at a time. //gs c bags stop to stop.'})
    step(st.token)
end

--- Stop now: the item in hand, if any, stays in the inventory.
function BagMover.stop()
    local st = state()
    if not st.running then return say('Tidy-up', {{'State', 'not running'}}) end
    st.token = (st.token or 0) + 1
    finish(st, 'Tidy-up stopped', 'warn', 'by you')
end

--- //gs c bags [go|stop]
--- @param args table
function BagMover.handle(args)
    local sub = tostring(args and args[1] or ''):lower()
    if sub == 'go' or sub == 'start' then return BagMover.start() end
    if sub == 'stop' then return BagMover.stop() end
    return BagMover.preview()
end

return BagMover
