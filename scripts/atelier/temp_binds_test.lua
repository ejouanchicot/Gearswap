---============================================================================
--- Test of the temporary keys (shared/utils/keybinds/temp_binds.lua)
---============================================================================
--- //gs c tb force over a key of the job, then tb del or tb clear: the job's
--- own bind comes back (KeybindManager records the key as bound to it and
--- would never send it again); a key of nobody is unbound. Everything goes
--- through the paced queue, and a key has one name whatever the order of its
--- modifiers.
---
--- Run from data/: lua5.1 scripts/atelier/temp_binds_test.lua
---
--- @file scripts/atelier/temp_binds_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-15
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

-- the saved list in a scratch file of the system's temporary folder
local scratch = os.tmpname()
package.loaded['shared/utils/core/char_paths'] = {writable = function() return scratch end}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
package.loaded['shared/utils/messages/formatters/system/message_tempbind'] =
    setmetatable({}, {__index = function() return function() end end})

-- the game's resources, one ability is enough (read by temp_binds_parse.lua)
res = {job_abilities = {[35] = {en = 'Provoke'}}, spells = {}, weapon_skills = {}, items = {}}

local sent = {}
-- tb sends through the paced queue, the one the job's keys use
package.loaded['shared/utils/core/command_queue'] = {push = function(_, cmd) sent[#sent + 1] = cmd end}
player = {name = 'Tester', main_job = 'PLD'}
-- the job's keys as KeybindManager laid them down (PLD_KEYBINDS: ^numpad9 cycles HybridMode)
PLDKeybinds = {binds = {{key = '^numpad9', desc = 'HybridMode'}}}
windower = {_keybind_manager_bound = {['^numpad9'] = 'gs c cycle HybridMode'}}

local TempBinds = require('shared/utils/keybinds/temp_binds')
local function last() return sent[#sent] end

-- 1. a key of the job: refused without force
TempBinds.handle({'^numpad9', '/ja', 'Provoke', '<t>'})
check('a job key is refused without force', #sent, 0)

-- 2. force, then del: the job's bind comes back
TempBinds.handle({'force', '^numpad9', '/ja', 'Provoke', '<t>'})
check('force binds the key to the tb', last(), 'bind ^numpad9 gs c tb run ^numpad9')
TempBinds.handle({'del', '^numpad9'})
check('del gives the job its key back', last(), 'bind ^numpad9 gs c cycle HybridMode')

-- 3. a key of nobody, then del: unbound
TempBinds.handle({'^f3', '/ja', 'Provoke', '<t>'})
check('a free key is bound', last(), 'bind ^f3 gs c tb run ^f3')
TempBinds.handle({'del', '^f3'})
check('del unbinds a key of nobody', last(), 'unbind ^f3')

-- 4. clear: each key back to what it was
TempBinds.handle({'force', '^numpad9', '/ja', 'Provoke', '<t>'})
TempBinds.handle({'^f3', '/ja', 'Provoke', '<t>'})
sent = {}
TempBinds.handle({'clear'})
table.sort(sent)
check('clear: two commands', #sent, 2)
check('clear gives the job its key back', sent[1], 'bind ^numpad9 gs c cycle HybridMode')
check('clear unbinds the free key', sent[2], 'unbind ^f3')

-- 5. one name per key, whatever the order the modifiers were typed in
local Parse = require('shared/utils/keybinds/temp_binds_parse')
check('ctrl+alt+f1', Parse.key('ctrl+alt+f1'), '^!f1')
check('alt+ctrl+f1', Parse.key('alt+ctrl+f1'), '^!f1')
check('caf1', Parse.key('caf1'), '^!f1')
check('acf1', Parse.key('acf1'), '^!f1')
check('!^f1', Parse.key('!^f1'), '^!f1')
check('ctrl+shift+f2', Parse.key('ctrl+shift+f2'), '^~f2')
check('plain f3', Parse.key('F3'), 'f3')

-- 6. a key bound by tb is not re-sent by KeybindGuard over it
sent = {}
windower._keybind_sent_this_load = {['^f4'] = 'gs c something'}
TempBinds.handle({'^f4', '/ja', 'Provoke', '<t>'})
check('KeybindGuard forgets a key tb took', windower._keybind_sent_this_load['^f4'], nil)
TempBinds.handle({'clear'})

os.remove(scratch)
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
