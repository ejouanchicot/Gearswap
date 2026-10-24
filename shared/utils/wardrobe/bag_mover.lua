---============================================================================
--- Bag Mover - plays the tidy-up plan of the Atelier page, by rounds of moves
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
--- By rounds, the way the wardrobe organizer moves gear: a round sends up to
--- BURST calls, waits, and is checked whole before the next one starts.
---   1. what the run holds in the inventory goes to its bag;
---   2. items leave their bags: as many as the inventory has slots for (the
---      slots step 1 frees are counted), and only those whose bag has a slot
---      for them, kept for them from then on. Two full bags that wait for each
---      other's slots: the items holding those slots are taken out first.
---   3. the game must show every change of the round: each bag holds that
---      many more, or fewer, of each item.
--- Before a call: the item is still in the bag the plan says, not worn, not
--- in the bazaar; both bags are open to the character (a Mog House bag only
--- in the Mog House). Anything else: that move is skipped and said. A move
--- whose bag stays full to the end is skipped too.
--- Where and when: only a bag the game gives the character right now is
--- touched. The four Mog House bags (Mog Safe, Mog Safe 2, Storage, Mog
--- Locker) only inside the Mog House (a Nomad Moogle gives three of them
--- inside its own menu only, by hand: not from here); a wardrobe not bought or a locker whose
--- lease ran out is closed everywhere; the Porter Moogle's slips and the
--- delivery box are never touched at all. The character must stand idle:
--- engaged, dead, resting, in an event or a menu, the run stops before the
--- next move. //gs c bags lists the bags open where you stand.
--- A round the game does not confirm stops the whole run: every item is then
--- where it was, in the inventory or in the bag it was going to, never
--- anywhere else; //gs c bags go takes up what waits in the inventory. Every
--- move is written to <Character>/atelier/bag_moves.log.
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
-- (A Nomad Moogle gives the Mog Safe, the Mog Safe 2 and the Mog Locker inside its own dialogue menu only: seen in
-- game on 2026-10-12, where the game reports them not enabled beside one. Nothing can be moved from here then.)
local BAG_NAMES = {[0] = 'Inventory', [1] = 'Mog Safe', [2] = 'Storage', [4] = 'Mog Locker', [5] = 'Mog Satchel',
    [6] = 'Mog Sack', [7] = 'Mog Case', [8] = 'Wardrobe', [9] = 'Mog Safe 2', [10] = 'Wardrobe 2', [11] = 'Wardrobe 3',
    [12] = 'Wardrobe 4', [13] = 'Wardrobe 5', [14] = 'Wardrobe 6', [15] = 'Wardrobe 7', [16] = 'Wardrobe 8'}
-- The wardrobes: the game puts equipment in them and nothing else
local WARDROBE = {[8] = true, [10] = true, [11] = true, [12] = true, [13] = true, [14] = true, [15] = true, [16] = true}
-- Seconds between two checks of a round, and how many checks before the run stops
local STEP_WAIT, TRIES = 0.8, 5
-- A round: how many calls are sent at once, and the wait before its check (a tenth of a second a call, between
-- one and three seconds). The wardrobe organizer's own numbers (lib/config.lua: BURST_SIZE, POST_BURST_DELAY),
-- found in game: the server takes about ten moves a second.
local BURST, WAIT_FLOOR, WAIT_CEIL, WAIT_PER_CALL = 30, 1.0, 3.0, 0.1
do
    local ok, Organizer = pcall(require, 'shared/utils/wardrobe/lib/config')
    if ok and type(Organizer) == 'table' then
        BURST, WAIT_CEIL = tonumber(Organizer.BURST_SIZE) or BURST, tonumber(Organizer.POST_BURST_DELAY) or WAIT_CEIL
    end
end

--- The run's state, kept on windower so a job reload does not lose it:
--- {moves (each with its state), at, token, running, done, skipped, char, last}
local function state()
    windower._bag_mover = windower._bag_mover or {moves = {}}
    return windower._bag_mover
end

local function bag_name(id) return BAG_NAMES[id] or ('bag ' .. tostring(id)) end

local function say(title, fields, lines)
    require('shared/utils/messages/info_block').show({tag = 'BAGS', title = title, fields = fields, lines = lines})
end

--- One line in the journal of moves (past 2 MB it goes to bag_moves.old.log, looked at once a load: log_keeper.lua).
local journal_checked = false
local function journal(text)
    local ok, path = pcall(function() return require('shared/utils/core/char_paths').writable('atelier', 'bag_moves.log') end)
    if ok and path and not journal_checked then
        journal_checked = true
        pcall(function() require('shared/utils/core/log_keeper').rotate(path) end)
    end
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

--- Whether an item is a piece of equipment (the game's category: Weapon or Armor). Unknown: not taken for one.
local function is_equipment(id)
    local ok, res = pcall(require, 'resources')
    local info = ok and res and res.items and res.items[id]
    return info ~= nil and (info.category == 'Weapon' or info.category == 'Armor')
end

--- Why a bag cannot be used now, or nil.
local function closed(bag)
    if HOUSE[bag] and not (windower.ffxi.get_info() or {}).mog_house then return 'only in the Mog House' end
    local info = windower.ffxi.get_bag_info(bag)
    if not (info and info.enabled) then return 'bag not available' end
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

--- Every bag this file knows, open or not where the character stands (the test made before each move).
--- @return table {{id, name, open, why}}
function BagMover.bags_here()
    local list = {}
    for _, id in ipairs({0, 8, 10, 11, 12, 13, 14, 15, 16, 5, 6, 7, 1, 9, 2, 4}) do
        local why = closed(id)
        list[#list + 1] = {id = id, name = bag_name(id), open = why == nil, why = why}
    end
    return list
end

--- The bags open where the character stands, and the closed ones with why.
--- @return table open names, table closed {name .. ' (' .. why .. ')'}
local function bags_here()
    local open, shut = {}, {}
    for _, bag in ipairs(BagMover.bags_here()) do
        if bag.open then open[#open + 1] = bag.name else shut[#shut + 1] = bag.name .. ' (' .. bag.why .. ')' end
    end
    return open, shut
end

--- Why a move cannot be made now, or nil with the slot to take.
--- @return string|nil reason, number|nil slot, number|nil count
local function check(move)
    local why = closed(move.from) or closed(move.to)
    if why then return why end
    if WARDROBE[move.to] and not is_equipment(move.id) then return 'a wardrobe only takes equipment' end
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
            moves[#moves + 1] = {id = id, from = from, to = to, name = name ~= '' and name or ('#' .. id), state = 'todo'}
        elseif line:match('%S') then
            refused = refused + 1
        end
    end
    st.moves, st.at, st.done, st.skipped = moves, os.date('%Y-%m-%d %H:%M'), 0, {}
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
    lines[#lines + 1] = '//gs c bags go plays the moves that are ready, several at a time.'
    lines[#lines + 1] = 'Nothing is ever dropped, sold or sent: items only go from a bag to another.'
    say('Tidy-up (nothing moved)', fields, lines)
end

---============================================================================
--- THE RUN
---============================================================================
--- A move is 'todo', 'out' (asked out of its bag, not shown by the game yet), 'hand' (its item is in the
--- inventory, on its way), then 'done' or 'skipped'.
--- A round sends as many calls as the game takes at once: first what is in the inventory goes to its bag, then
--- items leave their bags, as many as the inventory can hold and only those whose bag has a slot for them.

local function finish(st, title, kind, why)
    st.running = false
    local hand = 0
    for _, move in ipairs(st.moves) do if move.state == 'hand' or move.state == 'out' then hand = hand + 1 end end
    local fields = {{'Moved', st.done, 'good'}, {'Skipped', #st.skipped, #st.skipped > 0 and 'warn' or nil}}
    if why then fields[#fields + 1] = {'Stopped', why, kind} end
    if hand > 0 then fields[#fields + 1] = {'In the inventory', hand .. ' taken out, not put away: //gs c bags go', 'warn'} end
    local lines = {}
    for i = 1, math.min(#st.skipped, 8) do lines[#lines + 1] = st.skipped[i] end
    if #st.skipped > 8 then lines[#lines + 1] = ('... and %d more (bag_moves.log)'):format(#st.skipped - 8) end
    say(title, fields, lines)
    journal(('%s: %d moved, %d skipped, %d left in the inventory%s'):format(title, st.done, #st.skipped, hand,
        why and (' - ' .. why) or ''))
    -- the page learns it: the run is kept for the export (atelier_export_bags.lua), and the bags are exported
    -- again a moment later, once the game has settled them
    st.last = {at = os.date('%Y-%m-%d %H:%M:%S'), moved = st.done, skipped = #st.skipped, stopped = why}
    pcall(function() require('shared/utils/atelier/atelier_export_bags').changed(2) end)
end

local function skip(st, move, why)
    move.state = 'skipped'
    st.skipped[#st.skipped + 1] = move.name .. ': ' .. why
    journal(('skipped  %s  %s > %s  (%s)'):format(move.name, bag_name(move.from), bag_name(move.to), why))
end

--- What a round may still use, counted as it is built: calls, inventory slots, the room of each bag.
local function new_round()
    return {sent = {}, calls = BURST, inv = free_slots(INVENTORY), room = {}, taken = {}, delta = {}, waiting = {}}
end

local function room(round, bag)
    if round.room[bag] == nil then round.room[bag] = free_slots(bag) end
    return round.room[bag]
end

--- What a call must change, read before it is sent: the bag holds `by` more (or fewer) of the item afterwards.
local function expect(round, bag, id, by)
    local key = bag .. ':' .. id
    round.delta[key] = round.delta[key] or {bag = bag, id = id, had = (held(bag, id)), by = 0}
    round.delta[key].by = round.delta[key].by + by
end

--- A slot of a bag that holds the move's item and that no call of this round has taken yet.
--- In the inventory, for an item the run took out: the slot that appeared since, when there is one.
local function pick_slot(round, bag, move, fresh)
    local _, slots = held(bag, move.id)
    local any, merged
    for index, n in pairs(slots) do
        if not round.taken[bag .. ':' .. index] and (not move.count or n == move.count) then
            if not (fresh and move.before and move.before[index]) then return index, n end
            any = any or index
        elseif fresh and move.count and n > move.count and not round.taken[bag .. ':' .. index] then
            merged = merged or index                 -- the game stacked it on what was there: that many are taken off it
        end
    end
    if any then return any, slots[any] end
    return merged, merged and move.count
end

local function wardrobe_refuses(move)
    return WARDROBE[move.to] and not is_equipment(move.id) and 'a wardrobe only takes equipment' or nil
end

--- From the inventory into its bag. A full bag: the move waits for a later round.
local function try_put(st, round, move)
    local why = closed(move.to) or wardrobe_refuses(move)
    if why and move.state == 'todo' then return skip(st, move, why) end
    local slot, count = pick_slot(round, INVENTORY, move, true)
    if not slot then return skip(st, move, 'not in the inventory any more (or worn)') end
    if why or room(round, move.to) < 1 then
        round.waiting[#round.waiting + 1] = {move = move, why = why or (bag_name(move.to) .. ' full')}
        return
    end
    if round.calls < 1 then return end
    expect(round, INVENTORY, move.id, -count)
    expect(round, move.to, move.id, count)
    round.calls, round.inv, round.room[move.to] = round.calls - 1, round.inv + 1, round.room[move.to] - 1
    round.taken[INVENTORY .. ':' .. slot] = true
    move.count = count
    round.sent[#round.sent + 1] = {move = move, put = true}
    windower.ffxi.put_item(move.to, slot, count)
end

--- Out of its bag into the inventory. Only when its bag has a slot for it (kept for it from then on), unless
--- `forced`: taken out to free a slot another move waits for.
local function try_get(st, round, move, forced)
    local why = closed(move.from) or closed(move.to) or wardrobe_refuses(move)
    if why then return skip(st, move, why) end
    move.count = nil
    local slot, count = pick_slot(round, move.from, move)
    if not slot then return skip(st, move, 'not in ' .. bag_name(move.from) .. ' any more (or worn)') end
    local full = round.inv < 1 and 'inventory full'
        or (not forced and move.to ~= INVENTORY and room(round, move.to) < 1 and bag_name(move.to) .. ' full')
    if full then
        round.waiting[#round.waiting + 1] = {move = move, why = full}
        return
    end
    if round.calls < 1 then return end
    expect(round, move.from, move.id, -count)
    expect(round, INVENTORY, move.id, count)
    round.calls, round.inv = round.calls - 1, round.inv - 1
    if move.to ~= INVENTORY and not forced then round.room[move.to] = round.room[move.to] - 1 end
    round.taken[move.from .. ':' .. slot] = true
    local _, before = held(INVENTORY, move.id)
    move.count, move.before, move.state = count, before, 'out'
    round.sent[#round.sent + 1] = {move = move}
    windower.ffxi.get_item(move.from, slot, count)
end

--- Two full bags that wait for each other's slots: the items that hold those slots are taken out first.
local function unblock(st, round)
    local wanted, waiting = {}, round.waiting
    for _, w in ipairs(waiting) do wanted[w.move.to] = true end
    round.waiting = {}
    for _, w in ipairs(waiting) do
        if w.move.state == 'todo' and w.move.from ~= INVENTORY and wanted[w.move.from] then
            try_get(st, round, w.move, true)
        else
            round.waiting[#round.waiting + 1] = w
        end
    end
end

--- Build a round and send its calls.
local function send_round(st)
    local round = new_round()
    for _, move in ipairs(st.moves) do
        if move.state == 'hand' or (move.state == 'todo' and move.from == INVENTORY) then try_put(st, round, move) end
    end
    for _, move in ipairs(st.moves) do
        if move.state == 'todo' and move.from ~= INVENTORY then try_get(st, round, move, false) end
    end
    if #round.sent == 0 and #round.waiting > 0 then unblock(st, round) end
    return round
end

--- Whether the game shows everything the round's calls had to change.
local function confirmed(round)
    for _, d in pairs(round.delta) do
        local now = held(d.bag, d.id)
        if (d.by > 0 and now < d.had + d.by) or (d.by < 0 and now > d.had + d.by) then return false end
    end
    return true
end

local function settle(st, round)
    for _, s in ipairs(round.sent) do
        local move = s.move
        if s.put or move.to == INVENTORY then
            move.state = 'done'
            st.done = st.done + 1
            journal(('moved  %s x%d  %s > %s'):format(move.name, move.count or 1, bag_name(move.from), bag_name(move.to)))
        else
            move.state = 'hand'
        end
    end
end

--- Whether the inventory holds the item of a move a run before took out (a slot of the same count).
local function in_inventory(move)
    local _, slots = held(INVENTORY, move.id)
    for _, n in pairs(slots) do if n == move.count then return true end end
    return false
end

local next_round

--- Wait until the game shows the round, then go on; the run stops when it never does.
local function wait_for(st, token, round, left)
    if state().token ~= token then return end
    if confirmed(round) then
        settle(st, round)
        return next_round(token)
    end
    if left <= 0 then
        return finish(st, 'Tidy-up stopped', 'bad',
            'a move was not confirmed by the game (every item is where it was, in the inventory or in its bag)')
    end
    coroutine.schedule(function() wait_for(st, token, round, left - 1) end, STEP_WAIT)
end

next_round = function(token)
    local st = state()
    if st.token ~= token or not st.running then return end
    local not_now = busy()
    if not_now then return finish(st, 'Tidy-up stopped', 'warn', not_now) end
    local round = send_round(st)
    if #round.sent == 0 then
        -- nothing can go any more: what waits is said (an item taken out for a bag that stayed full is in the inventory)
        for _, w in ipairs(round.waiting) do
            local in_hand = w.move.state == 'hand'
            skip(st, w.move, w.why .. (in_hand and ' (it is in the inventory)' or ''))
            if in_hand then w.move.state = 'hand' end
        end
        return finish(st, 'Tidy-up done', 'good')
    end
    local wait = math.max(WAIT_FLOOR, math.min(WAIT_CEIL, #round.sent * WAIT_PER_CALL))
    coroutine.schedule(function() wait_for(st, token, round, TRIES) end, wait)
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
    -- an item a run before left in the inventory is taken up from there; everything else is looked at again
    for _, move in ipairs(st.moves) do
        local waits = (move.state == 'hand' or move.state == 'out') and in_inventory(move)
        move.state, move.before = waits and 'hand' or 'todo', nil
        if not waits then move.count = nil end
    end
    st.running, st.done, st.skipped = true, 0, {}
    st.token = (st.token or 0) + 1
    journal(('run started: %d moves'):format(#st.moves))
    say('Tidy-up started', {{'Moves', #st.moves}},
        {('Up to %d at a time, through the inventory. //gs c bags stop to stop.'):format(BURST)})
    next_round(st.token)
end

--- Stop now: what was taken out and not put away yet stays in the inventory.
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
