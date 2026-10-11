---============================================================================
--- Test: the pieces of a lockstyle set are read from the game's packet
---============================================================================
--- shared/utils/lockstyle/lockstyle_pieces.lua listens to the packet the game
--- sends when a lockstyle is applied (outgoing 0x053) and writes the pieces
--- down. This builds such packets byte by byte, as Windower describes them
--- (addons/libs/packets/fields.lua), and checks what is read and written.
---
---   lua5.1 scripts/atelier/lockstyle_pieces_test.lua        (from data/)
---
--- @file    scripts/atelier/lockstyle_pieces_test.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

package.path = './?.lua;' .. package.path
local failed = 0
local function check(what, got, want)
    if got ~= want then
        failed = failed + 1
        print(('FAIL %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    else
        print('ok   ' .. what)
    end
end

local saved = os.tmpname() .. '_lockstyle_pieces.lua'
local events = {}
windower = {raw_register_event = function(name, fn) events[name] = fn end}
player = {main_job = 'WAR'}
-- the character's lockstyle files: WAR and PLD share set 4, PLD/RUN wears 9, BLM has none, craft 19 and fishing 17
local CONFIGS = {WAR_LOCKSTYLE = {default = 4, by_subjob = {SAM = 4}}, PLD_LOCKSTYLE = {default = 4, by_subjob = {RUN = 9}},
    CRAFT_CONFIG = {craft_lockstyle = 19, fish_lockstyle = 17}}
package.preload['shared/utils/core/char_paths'] = function() return {writable = function() return saved end,
    load = function(_, name) if CONFIGS[name] then return true, CONFIGS[name] end return false, 'no file' end} end
package.preload['shared/utils/messages/info_block'] = function() return {show = function() end} end
package.preload['resources'] = function() return {items = {[25449] = {en = "Asn. Gorget +2"}, [300] = {en = 'Odd "Hat"'}}} end
local Pieces = require('shared/utils/lockstyle/lockstyle_pieces')

--- A 0x053 packet: its 4 bytes of header, count, type, two unknown bytes, then the entries.
--- @param kind number 3 sets a style
--- @param list table {{index, slot, bag, id}}
local function packet(kind, list)
    local out = {string.char(0x53, 0x24, 0, 0), string.char(#list, kind, 0, 0)}
    for _, e in ipairs(list) do
        out[#out + 1] = string.char(e[1], e[2], e[3], 0, e[4] % 256, math.floor(e[4] / 256), 0, 0)
    end
    return table.concat(out)
end

-- reading a packet
local items = Pieces.parse(packet(3, {{5, 9, 8, 25449}, {12, 4, 10, 300}, {0, 5, 0, 0}}))
check('two pieces read (an empty slot is left out)', items and #items, 2)
check('the neck slot is named', items[1].slot, 'neck')
check('its item id is read on two bytes', items[1].id, 25449)
check('the head slot is named', items[2].slot, 'head')
check('"stop locking style" names no piece', Pieces.parse(packet(0, {{5, 9, 8, 25449}})), nil)
check('"continue locking style" names no piece', Pieces.parse(packet(1, {{5, 9, 8, 25449}})), nil)
check('a packet too short is refused', Pieces.parse('abc'), nil)

-- the set asked for just before is the one the pieces go to
os.remove(saved)
Pieces.listen()
events['outgoing text']('/lockstyleset 4')
events['outgoing chunk'](0x053, packet(3, {{5, 9, 8, 25449}, {12, 4, 10, 300}}))
local sets = Pieces.read()
check('the pieces are filed under set 4', sets['4'] and #sets['4'].items, 2)
check('with the job that wore it', sets['4'].job, 'WAR')
check('with the item names, quotes kept', sets['4'].items[2].name, 'Odd "Hat"')

-- another set is added, the first is kept; the same set again replaces its pieces
Pieces.expect(7)
events['outgoing chunk'](0x053, packet(3, {{1, 4, 8, 300}}))
events['outgoing text']('/lockstyleset 4')
events['outgoing chunk'](0x053, packet(3, {{5, 9, 8, 25449}}))
sets = Pieces.read()
check('set 7 is added', sets['7'] and #sets['7'].items, 1)
check('set 4 holds its new pieces only', #sets['4'].items, 1)

-- another packet does nothing; a style set with no command before goes under "other"
events['outgoing chunk'](0x01A, packet(3, {{1, 4, 8, 300}}))
windower._lockstyle_asked = nil
events['outgoing chunk'](0x053, packet(3, {{1, 4, 8, 300}}))
sets = Pieces.read()
check('with no set asked for, the pieces go under "other"', sets.other and #sets.other.items, 1)
check('and the known sets are untouched', #sets['4'].items + #sets['7'].items, 2)

-- the scan: every set of the files once, in order; a set the game refuses is asked again, then given up
os.remove(saved)
local tasks, sent, refuse, restored = {}, {}, {}, 0
coroutine.schedule = function(fn) tasks[#tasks + 1] = fn end
local function run_all() local n = 0 while #tasks > 0 and n < 500 do n = n + 1 table.remove(tasks, 1)() end end
-- the game: a /lockstyleset it accepts is followed by its packet (set 17 is empty: no packet ever)
send_command = function(text)
    local set = tonumber(text:match('/lockstyleset (%d+)'))
    sent[#sent + 1] = set
    if set == 17 or (refuse[set] or 0) > 0 then refuse[set] = (refuse[set] or 0) - 1 return end
    events['outgoing chunk'](0x053, packet(3, {{1, 4, 8, 300}}))
end
_G.select_default_lockstyle = function() restored = restored + 1 end
check('the sets of the files, each once, sorted', table.concat(Pieces.sets_in_use(), ' '), '4 9 17 19')
refuse[9] = 1
Pieces.scan({})
run_all()
sets = Pieces.read()
check('sets 4, 9 and 19 are written down', (sets['4'] and 1 or 0) + (sets['9'] and 1 or 0) + (sets['19'] and 1 or 0), 3)
check('a set refused once is asked again', table.concat(sent, ' '), '4 9 9 17 17 19')
check('an empty set is given up, not written', sets['17'], nil)
check('the scan is over', windower._lockstyle_scan.running, false)
check('the lockstyle of the job is put back', restored, 1)
-- stopped by the player: nothing more is asked
sent = {}
Pieces.scan({})
Pieces.scan({'stop'})
run_all()
check('stopped: only the set in hand was asked', #sent, 1)

os.remove(saved)
print(failed == 0 and '\nthe pieces of a lockstyle are read and kept, set by set' or ('\n' .. failed .. ' check(s) failed'))
os.exit(failed == 0 and 0 or 1)
