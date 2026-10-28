---============================================================================
--- Test of the synthesis result blocks (shared/utils/craft/synth_results.lua)
--- Run from data/: lua5.1 scripts/atelier/synth_results_test.lua
--- @file scripts/atelier/synth_results_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-24
---============================================================================
-- Offline check of shared/utils/craft/synth_results.lua: fake 0x030 / 0x06F packets, the chat and the journal captured.
-- Run from GearSwap/data: lua5.1 <this file>
package.path = './?.lua;' .. package.path
local LOG = os.getenv('TEMP') .. '/synth_test.log'
os.remove(LOG)

-- Windower's string:unpack for the two formats the module reads (1-based positions, little endian)
function string.unpack(s, fmt, pos)
    local b = {s:byte(pos, pos + 3)}
    if fmt == 'H' then return b[1] + b[2] * 256 end
    if fmt == 'I' then return b[1] + b[2] * 256 + b[3] * 65536 + b[4] * 16777216 end
    error('fmt ' .. fmt)
end
local ME, OTHER = 0x01020304, 0x0A0B0C0D
local handler
windower = {
    raw_register_event = function(ev, fn) assert(ev == 'incoming chunk'); handler = fn; return 1 end,
    ffxi = {get_player = function() return {id = ME, name = 'Tetsouo'} end, get_info = function() return {language = 'English'} end},
    addon_path = './', file_exists = function() return false end,
}
gearswap = {res = {items = {[100] = {en = 'Bone Hairpin'}, [101] = {en = 'Bone Hairpin +1'}, [200] = {en = 'Giant Femur'}, [201] = {en = 'Bone Chip'}}}}
local chat = {}
function add_to_chat(ch, msg) local t = msg:gsub('\31.', ''); if not t:find('^=') then chat[#chat + 1] = ch .. ' ' .. t end end
require('shared/utils/messages/info_block')  -- loaded before any packet in game (INIT_SYSTEMS)
do local CP = require('shared/utils/core/char_paths'); CP.log = function() return LOG end end

local function u32(n) return string.char(n % 256, math.floor(n / 256) % 256, math.floor(n / 65536) % 256, math.floor(n / 16777216) % 256) end
local function u16(n) return string.char(n % 256, math.floor(n / 256) % 256) end
local function anim(player, param) return string.rep('\0', 4) .. u32(player) .. u16(1) .. u16(0x12) .. string.char(param, 0xC2, 0) end
local function result(r, q, count, item, lost)
    local s = string.rep('\0', 4) .. string.char(r, q % 256, count, 0) .. u16(item)
    for i = 1, 8 do s = s .. u16((lost or {})[i] or 0) end
    return s .. string.rep('\0', 20)
end

local SynthResults = require('shared/utils/craft/synth_results')
SynthResults.init()
local cases = {
    {'NQ x3', {anim(ME, 0), result(0, 0, 3, 100)}, '121   SYNTH :: NQ | 121 Result : NQ | 121 Item   : Bone Hairpin x3'},
    {'HQ 1', {anim(ME, 2), result(0, 1, 1, 101)}, '121   SYNTH :: HQ | 121 Result : HQ 1 | 121 Item   : Bone Hairpin +1'},
    {'HQ 2', {anim(ME, 2), result(0, 2, 1, 101)}, '121   SYNTH :: HQ | 121 Result : HQ 2 | 121 Item   : Bone Hairpin +1'},
    {'HQ 3', {anim(ME, 2), result(0, 3, 2, 101)}, '121   SYNTH :: HQ | 121 Result : HQ 3 | 121 Item   : Bone Hairpin +1 x2'},
    {'Break, 2 lost', {anim(ME, 1), result(1, 0, 3, 100, {200, 201})}, '121   SYNTH :: Break | 121 Result : Break | 121 Lost   : Giant Femur, Bone Chip'},
    {'Break, nothing lost', {anim(ME, 1), result(5, 0, 0, 0)}, '121   SYNTH :: Break | 121 Result : Break | 121 Lost   : the crystal only'},
    {'HQ, no animation seen', {result(0, 2, 1, 101)}, '121   SYNTH :: HQ 2 | 121 Result : HQ 2 | 121 Item   : Bone Hairpin +1'},
    {'someone else animates, mine NQ', {anim(OTHER, 2), result(0, 0, 1, 100)}, '121   SYNTH :: NQ | 121 Result : NQ | 121 Item   : Bone Hairpin'},
    {'cancelled after an animation', {anim(ME, 0), result(6, 0, 0, 0)}, '121   SYNTH :: NQ | 121 Result : cancelled'},
    {'cancelled, no animation', {result(6, 0, 0, 0)}, nil},
    -- a cancel the old list did not know (13, journal 2026-10-28), the last break's item still in the packet
    {'cancelled 13, stale item', {result(13, 255, 1, 100)}, nil},
    {'cancelled 13 after an animation', {anim(ME, 0), result(13, 255, 1, 100)}, '121   SYNTH :: NQ | 121 Result : cancelled'},
    -- the server leaves the last break's ingredients in a success's lost slots (journal 2026-10-28)
    {'NQ after a break, stale lost slots', {anim(ME, 0), result(0, 0, 3, 100, {200, 201})}, '121   SYNTH :: NQ | 121 Result : NQ | 121 Item   : Bone Hairpin x3'},
    {'HQ after a break, stale lost slots', {anim(ME, 2), result(0, 1, 1, 101, {200})}, '121   SYNTH :: HQ | 121 Result : HQ 1 | 121 Item   : Bone Hairpin +1'},
}
local fails = 0
for _, c in ipairs(cases) do
    chat = {}
    for _, p in ipairs(c[2]) do handler(p:byte(1) == 0 and #p < 20 and 0x030 or (#p > 20 and 0x06F or 0x030), p) end
    local got = #chat > 0 and table.concat(chat, ' | ') or nil
    local ok = got == c[3]
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. c[1] .. ': ' .. tostring(got))
end
print('--- journal:')
for line in io.lines(LOG) do print(line) end
print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)
