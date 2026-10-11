---============================================================================
--- Lockstyle Pieces - which items each lockstyle set wears
---============================================================================
--- The project only knows a lockstyle by its number (/lockstyleset 4): what
--- the set holds is in the game. When a lockstyle is applied, the game itself
--- sends the list of its pieces (outgoing packet 0x053: for each of the 16
--- slots, the item, its bag and its place in the bag). This listens to that
--- packet and writes the pieces down, set by set, in
--- <Character>/saved/lockstyle_pieces.lua. Nothing is changed or sent.
---
--- The Atelier page reads the file through the export: a piece kept only for
--- its look is then known as such (its bags plan files it under Lockstyle
--- instead of offering to store it away or send it to a mule).
---
--- The number of the set is not in the packet: it is the one asked for just
--- before (LockstyleManager, or /lockstyleset typed by the player); a packet
--- that follows no such command within a few seconds is kept under 'other'.
---
--- @file    shared/utils/lockstyle/lockstyle_pieces.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local LockstylePieces = {}

-- Packet 0x053 (Windower addons/libs/packets/fields.lua): Count at byte 4, Type at 5 (3 = "lock style in this
-- way"), then 16 entries of 8 bytes from byte 8: inventory index, equipment slot, bag, unknown, item id (2 bytes)
local PACKET, TYPE_SET, FIRST, ENTRY, ENTRIES = 0x053, 3, 8, 8, 16
local SLOTS = {[0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
    'ear1', 'ear2', 'ring1', 'ring2', 'back'}
-- Seconds a /lockstyleset command stays the one a packet answers
local ASKED_FOR = 6

local function file_path()
    return require('shared/utils/core/char_paths').writable('saved', 'lockstyle_pieces.lua')
end

--- The sets known so far: {[set] = {at, job, items = {{slot, id, name}}}}.
--- @return table
function LockstylePieces.read()
    local ok_path, path = pcall(file_path)
    if not (ok_path and path) then return {} end
    local ok, sets = pcall(dofile, path)
    return (ok and type(sets) == 'table') and sets or {}
end

local function write(sets)
    local ok_path, path = pcall(file_path)
    local file = ok_path and path and io.open(path, 'w')
    if not file then return false end
    local keys = {}
    for key in pairs(sets) do keys[#keys + 1] = key end
    table.sort(keys, function(a, b) return (tonumber(a) or 1e9) < (tonumber(b) or 1e9) end)
    file:write('-- The pieces of each lockstyle set, read when the game applied it (written by GearSwap:\n')
    file:write('-- shared/utils/lockstyle/lockstyle_pieces.lua). Do not edit: it is rewritten at each lockstyle.\n')
    file:write('return {\n')
    for _, key in ipairs(keys) do
        local set = sets[key]
        file:write(('    [%q] = {at = %q, job = %q, items = {\n'):format(tostring(key), set.at or '', set.job or ''))
        for _, item in ipairs(set.items or {}) do
            file:write(('        {slot = %q, id = %d, name = %q},\n'):format(item.slot or '', item.id or 0, item.name or ''))
        end
        file:write('    }},\n')
    end
    file:write('}\n')
    file:close()
    return true
end

--- The pieces a 0x053 packet names, or nil when it does not set a style.
--- @param data string the packet
--- @return table|nil {{slot, id}}
function LockstylePieces.parse(data)
    if type(data) ~= 'string' or #data < FIRST + ENTRY then return nil end
    local count, kind = data:byte(5), data:byte(6)
    if kind ~= TYPE_SET or not count or count == 0 then return nil end
    local items = {}
    for i = 0, math.min(count, ENTRIES) - 1 do
        local at = FIRST + i * ENTRY
        if #data >= at + ENTRY then
            local slot, lo, hi = data:byte(at + 2), data:byte(at + 5), data:byte(at + 6)
            local id = (lo or 0) + (hi or 0) * 256
            if id > 0 and SLOTS[slot] then items[#items + 1] = {slot = SLOTS[slot], id = id} end
        end
    end
    return #items > 0 and items or nil
end

--- A lockstyle set is about to be asked for: its number goes with the packet that follows.
--- @param set number|string
function LockstylePieces.expect(set)
    windower._lockstyle_asked = {set = tostring(set), at = os.clock()}
end

--- Write down the pieces of the set just applied.
--- @param items table {{slot, id}}
--- @return string|nil the set they were filed under
function LockstylePieces.record(items)
    local asked = windower._lockstyle_asked
    local set = (asked and os.clock() - asked.at <= ASKED_FOR) and asked.set or 'other'
    local ok, res = pcall(require, 'resources')
    for _, item in ipairs(items) do
        local info = ok and res and res.items and res.items[item.id]
        item.name = info and info.en or ''
    end
    local sets = LockstylePieces.read()
    -- the job that wore it; none during a scan, where the sets of every job go by on the job in hand
    local scanning = windower._lockstyle_scan and windower._lockstyle_scan.running
    sets[set] = {at = os.date('%Y-%m-%d %H:%M'), job = (not scanning and player and player.main_job) or '', items = items}
    windower._lockstyle_recorded = {set = set, at = os.clock()}
    return write(sets) and set or nil
end

--- Listen to the game's own lockstyle packet and to the command that asks for a set, once per load.
function LockstylePieces.listen()
    if rawget(_G, '_lockstyle_pieces_listening') then return end
    _G._lockstyle_pieces_listening = true
    windower.raw_register_event('outgoing chunk', function(id, original)
        if id ~= PACKET then return end
        pcall(function()
            local items = LockstylePieces.parse(original)
            if items then LockstylePieces.record(items) end
        end)
    end)
    windower.raw_register_event('outgoing text', function(original)
        local set = type(original) == 'string' and original:lower():match('^/lockstyleset%s+(%d+)')
        if set then LockstylePieces.expect(set) end
    end)
end

---============================================================================
--- SCAN: every lockstyle set the character uses, applied one after the other
---============================================================================
--- //gs c lockscan applies each set of the character's lockstyle files in turn,
--- so that the listener above writes them all down, then puts the job's own
--- lockstyle back. Only /lockstyleset is sent: what the player would type.

local JOBS = {'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG',
    'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'}
-- Seconds between two sets (the game refuses a lockstyle asked too soon after another), seconds given to the
-- game to answer one, and how many times a refused set is asked again
local GAP, ANSWER, RETRIES = 12, 3, 1

--- The set numbers the character's files name: each job's default and by-subjob sets, the craft and fishing ones.
--- @return table sorted list of numbers
function LockstylePieces.sets_in_use()
    local seen, list = {}, {}
    local function take(n)
        n = tonumber(n)
        if n and n >= 1 and n <= 200 and n == math.floor(n) and not seen[n] then seen[n] = true list[#list + 1] = n end
    end
    local CharPaths = require('shared/utils/core/char_paths')
    for _, job in ipairs(JOBS) do
        -- (CharPaths.load answers: loaded, module)
        local ok, loaded, cfg = pcall(CharPaths.load, 'job', job .. '_LOCKSTYLE', job)
        if ok and loaded and type(cfg) == 'table' then
            take(cfg.default)
            for _, n in pairs(type(cfg.by_subjob) == 'table' and cfg.by_subjob or {}) do take(n) end
        end
    end
    local ok_c, craft = pcall(function() local ok, c = CharPaths.load('common', 'CRAFT_CONFIG') return ok and c or nil end)
    if ok_c and type(craft) == 'table' then take(craft.craft_lockstyle) take(craft.fish_lockstyle) end
    table.sort(list)
    return list
end

local function say(title, fields, lines)
    require('shared/utils/messages/info_block').show({tag = 'LOCKSTYLE', title = title, fields = fields, lines = lines})
end

local scan_step

local function scan_end(st, why)
    st.running = false
    local fields = {{'Read', #st.done, 'good'}, {'Not read', #st.failed, #st.failed > 0 and 'warn' or nil}}
    if why then fields[#fields + 1] = {'Stopped', why, 'warn'} end
    local lines = {}
    if #st.failed > 0 then lines[1] = 'Not read: ' .. table.concat(st.failed, ', ') .. ' (an empty set, or refused by the game)' end
    lines[#lines + 1] = 'The lockstyle of your job is put back in a moment.'
    say('Lockstyle scan done', fields, lines)
    -- the job's own lockstyle back, through its usual way
    coroutine.schedule(function()
        local back = rawget(_G, 'select_default_lockstyle')
        if type(back) == 'function' then pcall(back) end
    end, GAP)
end

--- Ask for the set in hand, then see whether the game listed its pieces.
scan_step = function(token, tries)
    local st = windower._lockstyle_scan
    if not (st and st.running and st.token == token) then return end
    if st.job ~= (player and player.main_job) then return scan_end(st, 'job changed') end
    local set = st.queue[st.index]
    if not set then return scan_end(st) end
    local asked_at = os.clock()
    LockstylePieces.expect(set)
    send_command('input /lockstyleset ' .. set)
    coroutine.schedule(function()
        if not (st.running and st.token == token) then return end
        local got = windower._lockstyle_recorded
        if got and got.set == tostring(set) and got.at >= asked_at then
            st.done[#st.done + 1] = set
        elseif tries < RETRIES then
            return coroutine.schedule(function() scan_step(token, tries + 1) end, GAP)
        else
            st.failed[#st.failed + 1] = set
        end
        st.index = st.index + 1
        coroutine.schedule(function() scan_step(token, 0) end, GAP - ANSWER)
    end, ANSWER)
end

--- //gs c lockscan [stop]
--- @param args table
function LockstylePieces.scan(args)
    local sub = tostring(args and args[1] or ''):lower()
    local st = windower._lockstyle_scan
    if sub == 'stop' then
        if st and st.running then st.token = st.token + 1 scan_end(st, 'by you') else say('Lockstyle scan', {{'State', 'not running'}}) end
        return
    end
    if st and st.running then return say('Lockstyle scan', {{'State', 'already running', 'warn'}}, {'//gs c lockscan stop to stop it.'}) end
    LockstylePieces.listen()
    local queue = LockstylePieces.sets_in_use()
    if #queue == 0 then return say('Lockstyle scan', {{'Sets', 'none found in your lockstyle files', 'warn'}}) end
    windower._lockstyle_scan = {running = true, token = ((st and st.token) or 0) + 1, queue = queue, index = 1, done = {}, failed = {},
        job = player and player.main_job}
    say('Lockstyle scan started', {{'Sets', table.concat(queue, ', ')}, {'About', ('%d min'):format(math.ceil(#queue * GAP / 60))}},
        {'Each set is applied in turn and its pieces written down. //gs c lockscan stop to stop.'})
    scan_step(windower._lockstyle_scan.token, 0)
end

return LockstylePieces
