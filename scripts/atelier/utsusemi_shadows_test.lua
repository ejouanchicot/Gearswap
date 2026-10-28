---============================================================================
--- Test of Utsusemi Shadows (shared/utils/midcast/utsusemi_shadows.lua)
---============================================================================
--- The shadows are cancelled during Utsusemi: Ichi's cast, before its end: from
--- the precast's cast time, at most 2.3 s, 0.8 s before the end, never before
--- 0.2 s; 2.3 s when no cast time is known; nothing for another spell.
---
--- Run from data/: lua5.1 scripts/atelier/utsusemi_shadows_test.lua
---
--- @file scripts/atelier/utsusemi_shadows_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-28
---============================================================================
package.path = './?.lua;' .. package.path
local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then failed = failed + 1; print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want))) end
end
local sent = {}
send_command = function(cmd) sent[#sent + 1] = cmd end
local U = require('shared/utils/midcast/utsusemi_shadows')
local ICHI = {id = 338, english = 'Utsusemi: Ichi'}

local function first_wait(cast)
    sent = {}
    _G._precast_cast_time = cast
    U.on_midcast(ICHI)
    return sent[1] and sent[1]:match('^wait ([%d.]+);')
end

check('no Fast Cast (4 s): 2.3 s as before', first_wait({id = 338, seconds = 4.0}), '2.3')
check('50 % Fast Cast (2 s): 1.2 s, before the end', first_wait({id = 338, seconds = 2.0}), '1.2')
check('80 % Fast Cast (0.8 s): at the earliest', first_wait({id = 338, seconds = 0.8}), '0.2')
check('cast time of another spell: 2.3 s', first_wait({id = 339, seconds = 1.0}), '2.3')
check('no cast time: 2.3 s', first_wait(nil), '2.3')
check('four buffs cancelled', (function() first_wait(nil) return #sent end)(), 4)
sent = {}
U.on_midcast({id = 339, english = 'Utsusemi: Ni'})
check('Ni: nothing cancelled', #sent, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
