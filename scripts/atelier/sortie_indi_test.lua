---============================================================================
--- Test of the Sortie orders' Indi- (shared/utils/sortie/sortie_commands.lua)
---============================================================================
--- With an escort profile, Silmaril casts every Indi- of a profile it loads; the
--- order casts one by hand only when this character does not know which
--- profile runs. That knowledge outlives a GearSwap reload (a job or subjob
--- change of the main): after one, loading a target sends no Indi- by hand
--- (Silmaril's and ours made two, Kaories 2026-10-16).
---
--- Run from data/: lua5.1 scripts/atelier/sortie_indi_test.lua
---
--- @file scripts/atelier/sortie_indi_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-16
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local CFG = {alt = 'Kaories', profile_root = 'Kaories/Sortie/GEO/',
    escort = {indi = 'Indi-Regen', profile = 'Escorte'},
    targets = {melee = {profile = 'Melee', indi = 'Indi-Fury'}}}
local sent = {}
send_command = function(cmd) sent[#sent + 1] = cmd end
coroutine.schedule = function(fn) fn() end
windower = {ffxi = {get_player = function() return {name = 'Tetsouo'} end}}
player = {name = 'Tetsouo', main_job = 'PLD', sub_job = 'RUN'}
package.loaded['shared/utils/core/char_paths'] = {optional = function() return CFG end}
package.loaded['shared/utils/dualbox/alt_group'] = {note = function() end}
package.loaded['shared/utils/messages/formatters/system/message_sortie'] =
    setmetatable({}, {__index = function() return function() end end})

--- A fresh copy of the module: what a GearSwap reload gives (module locals start again).
local function reload()
    package.loaded['shared/utils/sortie/sortie_commands'] = nil
    return require('shared/utils/sortie/sortie_commands')
end
local function by_hand()
    for _, c in ipairs(sent) do if c:find('/ma "Indi%-') then return c end end
    return nil
end

-- 1. a game just started: nothing known, the target's Indi- goes by hand once
local Sortie = reload()
sent = {}
Sortie.handle({'melee'})
check('first load after a game start: by hand', by_hand(), 'send Kaories /ma "Indi-Fury" <me>')

-- 2. the next target: Silmaril's profile casts it, nothing by hand
sent = {}
Sortie.handle({'melee'})
check('known profile: nothing by hand', by_hand(), nil)

-- 3. a GearSwap reload of the main (job / subjob change), then a target: still nothing by hand
Sortie = reload()
sent = {}
Sortie.handle({'melee'})
check('after a reload: nothing by hand', by_hand(), nil)

-- 4. escort after a reload: through the profile (Silmaril casts its Indi-), not by hand
Sortie = reload()
sent = {}
Sortie.handle({'escort'})
local profile_sent = false
for _, c in ipairs(sent) do if c:find('gs c escort Indi%-Regen Tetsouo Kaories/Sortie/GEO/Escorte') then profile_sent = true end end
check('escort after a reload: the profile', profile_sent, true)
check('escort after a reload: nothing by hand', by_hand(), nil)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
