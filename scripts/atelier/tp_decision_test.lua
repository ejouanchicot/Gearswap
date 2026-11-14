-- Off-game test of the TP piece decision (shared/utils/weaponskill/tp_piece_decision.lua through
-- TPBonusCalculator.decide), on the real weaponskill database and a WAR-like TP config.
--
--   lua5.1 scripts/atelier/tp_decision_test.lua        (from data/; run by scripts/run_tests.py)
--
-- Expected values worked out by hand from the database's fTP (linear between 1000 / 2000 / 3000 TP),
-- Moonshade +250 and Boii Cuisses +3 +100, 3 % a set piece replaced (the formula's default):
--   Disaster (3.235 / 6.47 / 9.705, 1 hit), no table:
--     1000 / 1300 / 1650 / 2000: +35.0 / +26.9 / +21.2 / +17.5 % for both, both kept (net beats Moonshade alone)
--     2700: both +11.1 % - 6 = 5.1 ; Moonshade alone (to 2950) +9.25 % - 3 = 6.25 -> Moonshade alone
--     3000: capped, nothing
--   Savage Blade (4 / 10.25 / 13.75, 2 hits) with Fencer (+860): real TP 1860 -> 2210, first hit 90.4 % of
--     the fTP, +15.5 % for both -> both; without Fencer at 1000: +44 % -> both
--   Ukko's Fury, Evisceration (fixed fTP): nothing, even at 1000 TP
--   Rudra's Storm (5 / 10.19 / 13, 1 hit) at 1000: +36.3 % -> both
--   Shadowstitch (fTP at 2000 / 3000 unknown): the thresholds rule (1700 TP: Moonshade + Boii close 300)
--   the Atelier's table, set worn = its set: its row (1300 TP row: Moonshade alone); row {}: nothing
--   the table, set changed: the formula
--   Warcry (+700): counted in the real TP and in the table's TP
--   Chango (+500 from the config): in the real TP, not in the table's TP
--
-- @file    scripts/atelier/tp_decision_test.lua
-- @author  ejouanchicot

package.path = './?.lua;' .. package.path
_G.windower = {addon_path = './', register_event = function() end}
_G.add_to_chat = function() end
_G.player = {main_job = 'WAR'}

-- the weapon's TP Bonus: the config's list only (the real module also reads the game and the gear scan)
package.loaded['shared/utils/weaponskill/weapon_tp_bonus'] = {of = function(name, config)
    return config.get_weapon_bonus and config.get_weapon_bonus(name) or 0
end}

local Calc = require('shared/utils/weaponskill/tp_bonus_calculator')
local Table = require('shared/utils/weaponskill/tp_pieces_table')
local real_read = Table.read

local PIECES = {{slot = 'ear1', name = 'Moonshade Earring', bonus = 250}, {slot = 'legs', name = 'Boii Cuisses +3', bonus = 100}}
local CONFIG = {
    pieces = PIECES,
    weapons = {{name = 'Chango', bonus = 500}},
    get_weapon_bonus = function(w) return w == 'Chango' and 500 or 0 end,
    get_warcry_bonus = function() return 700 end,
    get_fencer_bonus = function(main, sub) return (main == 'Naegling' and sub == 'Blurred Shield +1') and 860 or 0 end,
}
local SET = {ear1 = 'Hoxne Earring', legs = 'Nyame Flanchard', head = 'Agoge Mask +4'}

local failures, count = 0, 0

local function gear_text(g)
    if not g then return 'nothing' end
    local t = {}
    for slot, name in pairs(g) do t[#t + 1] = slot .. '=' .. name end
    table.sort(t)
    return table.concat(t, ', ')
end

local function check(label, args, expect_gear, expect_source, expect_gain, expect_real, expect_key)
    count = count + 1
    args.config = args.config or CONFIG
    args.job = args.job or 'WAR'
    local gear, why = Calc.decide(args)
    local ok = gear_text(gear) == gear_text(expect_gear)
        and (not expect_source or why.source == expect_source)
        and (not expect_gain or math.abs((why.gain or 0) - expect_gain) < 0.002)
        and (not expect_real or why.real_tp == expect_real)
        and (not expect_key or why.key_tp == expect_key)
    if not ok then failures = failures + 1 end
    print(string.format('%s %-46s -> %-46s %s gain %+.1f%% real %s key %s', ok and 'ok  ' or 'FAIL', label, gear_text(gear),
        why.source, (why.gain or 0) * 100, tostring(why.real_tp), tostring(why.key_tp)))
    if not ok then print('       expected ' .. gear_text(expect_gear) .. ' ' .. tostring(expect_source)) end
end

local BOTH = {ear1 = 'Moonshade Earring', legs = 'Boii Cuisses +3'}
local MOON = {ear1 = 'Moonshade Earring'}

-- no table at all
Table.read = function() return nil end
for _, c in ipairs({{1000, 0.35}, {1300, 0.2691}, {1650, 0.2121}, {2000, 0.175}}) do
    check('Disaster ' .. c[1], {tp = c[1], main = 'Laphria', sub = 'Telopanos Grip', ws = 'Disaster', skill = 'Great Axe', worn = SET},
        BOTH, 'formula', c[2])
end
check('Disaster 2700', {tp = 2700, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = SET}, MOON, 'formula', 0.0925)
check('Disaster 3000', {tp = 3000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = SET}, nil, 'capped')
check('Savage Blade 1000 with Fencer', {tp = 1000, main = 'Naegling', sub = 'Blurred Shield +1', ws = 'Savage Blade',
    skill = 'Sword', worn = SET}, BOTH, 'formula', 0.1552, 1860)
check('Savage Blade 1000 without Fencer', {tp = 1000, main = 'Naegling', sub = 'Sword', ws = 'Savage Blade',
    skill = 'Sword', worn = SET}, BOTH, 'formula', nil, 1000)
check("Ukko's Fury 1000", {tp = 1000, main = 'Ukonvasara', ws = "Ukko's Fury", skill = 'Great Axe', worn = SET}, nil,
    'formula, fixed fTP')
check('Evisceration 1000', {tp = 1000, main = 'Tauret', ws = 'Evisceration', skill = 'Dagger', worn = SET}, nil,
    'formula, fixed fTP')
check("Rudra's Storm 1000", {tp = 1000, main = 'Tauret', ws = "Rudra's Storm", skill = 'Dagger', worn = SET}, BOTH,
    'formula', 0.3628)
check('Shadowstitch 1700 (fTP unknown)', {tp = 1700, main = 'Tauret', ws = 'Shadowstitch', skill = 'Dagger', worn = SET},
    BOTH, 'thresholds (fTP unknown)')
check('Disaster 1000 under Warcry', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = SET,
    buffs = {Warcry = true}}, BOTH, 'formula', nil, 1700, 1700)
check('Disaster 1000 with Chango', {tp = 1000, main = 'Chango', ws = 'Disaster', skill = 'Great Axe', worn = SET},
    BOTH, 'formula', nil, 1500, 1000)
check('a set wearing Boii already', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = {ear1 = 'Hoxne Earring', legs = 'Boii Cuisses +3'}}, MOON, 'formula', nil, 1100)

-- the Atelier's table
local ROWS = {}
for i = 1, 41 do ROWS[i] = {p = BOTH, g = 0.2} end
ROWS[7] = {p = MOON, g = 0.12}            -- 1300 TP
ROWS[40] = {p = {}, g = -0.04}            -- 2950-2999 TP
local DATA = {WAR = {at = '2026-11-12 14:00', weaponskills = {Disaster = {Laphria = {
    {path = 'sets.precast.WS.Disaster', set = SET, from = 1000, step = 50, rows = ROWS}}},
    ["Ukko's Fury"] = {Ukonvasara = {{set = SET, from = 1000, step = 50, rows = {{p = BOTH, g = 0.05}}}}}}}}
Table.read = function() return DATA end
check('table, set worn = its set, 1300', {tp = 1300, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = SET},
    MOON, 'table', 0.12)
check('table, 1320 (same row as 1300)', {tp = 1320, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = SET},
    MOON, 'table', 0.12)
check('table, Warcry moves the row (1000 + 700)', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = SET, buffs = {Warcry = true}}, BOTH, 'table', 0.2)
check('table says nothing (2999: row 2950)', {tp = 2999, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = {ear1 = 'Hoxne Earring', legs = 'Nyame Flanchard', head = 'Agoge Mask +4'}}, nil, 'table')
check('table, set changed -> formula', {tp = 1300, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = {ear1 = 'Thrud Earring', legs = 'Nyame Flanchard', head = 'Agoge Mask +4'}}, BOTH, 'formula (set changed)')
check('table, no worn list -> formula', {tp = 1300, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe'},
    BOTH, 'formula (set changed)')
check("table can put pieces on a fixed fTP (Ukko)", {tp = 1000, main = 'Ukonvasara', ws = "Ukko's Fury", skill = 'Great Axe',
    worn = SET}, BOTH, 'table', 0.05)
check('table for another weapon only -> formula', {tp = 1000, main = 'Chango', ws = 'Disaster', skill = 'Great Axe',
    worn = SET}, BOTH, 'formula')

-- the table as the page writes it since version 2: segments where the pieces change
local SET6 = {ear1 = 'Hoxne Earring', legs = 'Nyame Flanchard', head = 'Agoge Mask +4', body = 'Nyame Mail',
    hands = 'Nyame Gauntlets', feet = 'Nyame Sollerets'}
DATA = {WAR = {at = '2026-11-12 18:00', weaponskills = {Disaster = {Laphria = {{path = 'sets.precast.WS.Disaster', set = SET6,
    segments = {{tp = 1000, p = BOTH, g = 0.262}, {tp = 2000, p = MOON, g = 0.117}, {tp = 3000, p = {}, g = 0}}}}}}}}
local function worn_with(changes)
    local w = {}
    for k, v in pairs(SET6) do w[k] = v end
    for k, v in pairs(changes or {}) do w[k] = v ~= false and v or nil end
    return w
end
check('segments: 1950 -> the 1000 one', {tp = 1950, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = worn_with()},
    BOTH, 'table', 0.262)
check('segments: 2000 -> the 2000 one', {tp = 2000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = worn_with()},
    MOON, 'table', 0.117)
check('segments: 2990 -> still the 2000 one', {tp = 2990, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = worn_with()}, MOON, 'table', 0.117)
check('segments: names in another case', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = worn_with({ear1 = 'hoxne earring', body = {name = 'NYAME MAIL'}})}, BOTH, 'table')
check('locked ear1 (not in the equip list): still the variant', {tp = 1000, main = 'Laphria', ws = 'Disaster',
    skill = 'Great Axe', worn = worn_with({ear1 = false})}, BOTH, 'table')
check('more than half the set locked: formula', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = {head = 'Agoge Mask +4', body = 'Nyame Mail'}}, BOTH, 'formula (set changed)')
check('one slot differs: formula', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = worn_with({feet = 'Sulev. Leggings +2'})}, BOTH, 'formula (set changed)')

-- each set written once in the job's `sets`, the variants pointing at it by path (the real reader, not a stub)
local LuaData = require('shared/utils/core/lua_data')
local parsed = LuaData.parse([[return {WAR = {at = 'x', sig = 'y',
    sets = {['sets.precast.WS.Disaster'] = {ear1 = 'Hoxne Earring', legs = 'Nyame Flanchard', head = 'Agoge Mask +4'}},
    weaponskills = {Disaster = {Laphria = {{path = 'sets.precast.WS.Disaster', segments = {
        {tp = 1000, p = {ear1 = 'Moonshade Earring', legs = 'Boii Cuisses +3'}, g = 0.262}, {tp = 3000, p = {}, g = 0}}}}}}}}]])
Table.read = function() return parsed end
check('table at 3000 TP: its segment, not the cap', {tp = 3000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = SET}, nil, 'table')
check('shared sets: the variant finds its set by path', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe',
    worn = SET}, BOTH, 'table', 0.262)

-- one file a job (tp_pieces_<JOB>.lua, since 2026-11-14): the real reader, on files written here
Table.read = real_read
local DIR = (os.getenv('TEMP') or '.') .. '/'
local function put(name, text) local f = assert(io.open(DIR .. name, 'wb')) f:write(text) f:close() end
local reads = 0
package.loaded['shared/utils/core/char_paths'] = {file = function(_, name) reads = reads + 1 return DIR .. name end}
put('tp_pieces_WAR.lua', [[return {WAR = {at = 'w', sets = {['sets.precast.WS.Disaster'] = {ear1 = 'Hoxne Earring',
    legs = 'Nyame Flanchard', head = 'Agoge Mask +4'}}, weaponskills = {Disaster = {Laphria = {{path = 'sets.precast.WS.Disaster',
    segments = {{tp = 1000, p = {ear1 = 'Moonshade Earring'}, g = 0.1}}}}}}}}]])
put('tp_pieces_PLD.lua', [[return {WAR = {at = 'a WAR table under the PLD name'}}]])
os.remove(DIR .. 'tp_pieces_DRK.lua')
local function job_check(label, ok)
    count = count + 1
    if not ok then failures = failures + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. label)
end
Table.forget()
job_check('the file name of a job', Table.file('war') == 'tp_pieces_WAR.lua')
job_check('WAR: its own file read', Table.date('WAR') == 'w')
check('WAR: its table used', {tp = 1000, main = 'Laphria', ws = 'Disaster', skill = 'Great Axe', worn = SET}, MOON, 'table', 0.1)
job_check('WAR: read once per load', (function() local n = reads Table.read('WAR') Table.variants('WAR', 'Disaster', 'Laphria') return reads == n end)())
job_check('PLD: a file holding another job is refused', Table.read('PLD') == nil)
job_check('DRK: no file, nothing', Table.read('DRK') == nil and Table.variants('DRK', 'Disaster', 'Laphria') == nil)
put('tp_pieces_WAR.lua', [[return {WAR = {at = 'w2', weaponskills = {}}}]])
job_check('rewritten, still the one read until forget()', Table.date('WAR') == 'w')
Table.forget()
job_check('after forget(): read again', Table.date('WAR') == 'w2')
os.remove(DIR .. 'tp_pieces_WAR.lua')
os.remove(DIR .. 'tp_pieces_PLD.lua')

print(string.format('\n%d checks, %d failed', count, failures))
os.exit(failures == 0 and 0 or 1)
