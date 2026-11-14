---============================================================================
--- Test of shared/utils/messages/party_callouts.lua (the lines, not the game)
--- Run from data/: lua5.1 scripts/atelier/party_callouts_test.lua
--- @file scripts/atelier/party_callouts_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================
package.path = './?.lua;' .. package.path

local config = {party_callouts = {'Stun', 'Absorb-TP'}}
package.loaded['shared/utils/core/job_config'] = {get = function(_, key, default)
    local v = config[key]
    if v == nil then return default end
    return v
end}
windower = {ffxi = {}}
local PC = dofile('shared/utils/messages/party_callouts.lua')

local fails = 0
local function check(name, ok, detail)
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. name .. (detail and (': ' .. tostring(detail)) or ''))
end

check('stun landed', PC.line('Stun', 'Degei', 236) == 'Stun > Degei: STUNNED', PC.line('Stun', 'Degei', 236))
check('stun magic burst', PC.line('Stun', 'Degei', 271) == 'Stun > Degei: STUNNED (MB)')
check('stun resisted', PC.line('Stun', 'Degei', 85) == 'Stun > Degei: RESISTED')
check('stun no effect', PC.line('Stun', 'Degei', 75) == 'Stun > Degei: NO EFFECT')
check('absorb-tp drained', PC.line('Absorb-TP', 'Aminon', 454, 387) == 'Absorb-TP > Aminon: -387 TP')
check('absorb-tp nothing taken', PC.line('Absorb-TP', 'Aminon', 454, 0) == 'Absorb-TP > Aminon: no TP to take')
check('unknown message: nothing', PC.line('Stun', 'Degei', 999) == nil)
check('absorb-tp magic burst', PC.line('Absorb-TP', 'Aminon', 753, 300) == 'Absorb-TP > Aminon: -300 TP (MB)')
check('no command break', PC.line('Stun', 'A;b', 236) == 'Stun > Ab: STUNNED')
check('no chat token, ASCII only', PC.line('Stun', 'Mob<t>\200', 236) == 'Stun > Mobt>: STUNNED', PC.line('Stun', 'Mob<t>\200', 236))

check('nuke damage', PC.line('Fire', 'Degei', 2, 1520) == 'Fire > Degei: 1520 dmg')
check('nuke magic burst', PC.line('Fire', 'Degei', 252, 3000) == 'Fire > Degei: 3000 dmg (MB)')
check('nuke absorbed', PC.line('Water', 'Degei', 7, 840) == 'Water > Degei: ABSORBED +840 HP')
check('after a TP move', PC.line('Fire', 'Degei', 2, 1520, 'Icy Grasp') == 'Fire > Degei (after Icy Grasp): 1520 dmg',
    PC.line('Fire', 'Degei', 2, 1520, 'Icy Grasp'))

local wanted = PC.wanted('GEO')
check('config: both spells', wanted and wanted['Stun'] and wanted['Absorb-TP'])
config.party_callouts = {}
check('config {}: off', PC.wanted('GEO') == nil)
config.party_callouts = {'Stun', 'Absorb-TP'}

local deps = {spells = {[252] = {en = 'Stun'}, [275] = {en = 'Absorb-TP'}, [144] = {en = 'Fire'}},
    mob_by_id = function(id) return ({[50] = {name = 'Degei', spawn_type = 16}, [60] = {name = 'Hysoka', spawn_type = 13}})[id] end}
local function act(t)
    local a = {actor_id = 1, category = 4, param = 252, targets = {{id = 50, actions = {{message = 236, param = 0}}}}}
    for k, v in pairs(t or {}) do a[k] = v end
    return a
end
local l = PC.lines(act(), 1, wanted, deps)
check('my stun on a monster: one line', #l == 1 and l[1] == 'Stun > Degei: STUNNED')
check('someone else\'s stun: nothing', #PC.lines(act({actor_id = 2}), 1, wanted, deps) == 0)
check('a spell not listed: nothing', #PC.lines(act({param = 144}), 1, wanted, deps) == 0)
check('the start of a cast (category 8): nothing', #PC.lines(act({category = 8}), 1, wanted, deps) == 0)
check('on a player: nothing', #PC.lines(act({targets = {{id = 60, actions = {{message = 236}}}}}), 1, wanted, deps) == 0)
l = PC.lines(act({param = 275, targets = {{id = 50, actions = {{message = 454, param = 412}}}}}), 1, wanted, deps)
check('absorb-tp: TP in the line', l[1] == 'Absorb-TP > Degei: -412 TP', l[1])
deps.spells[144] = {en = 'Fire'}
local w2 = {Fire = true}
deps.after = function(id) return id == 50 and 'Icy Grasp' or nil end
l = PC.lines(act({param = 144, targets = {{id = 50, actions = {{message = 2, param = 1520}}}}}), 1, w2, deps)
check('fire after icy grasp: the move named', l[1] == 'Fire > Degei (after Icy Grasp): 1520 dmg', l[1])

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)
