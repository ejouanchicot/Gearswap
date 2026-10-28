---============================================================================
--- Test of KeybindManager next to //gs c tb (shared/utils/keybinds/keybind_manager.lua)
---============================================================================
--- A key //gs c tb holds is left alone by the job's keys: a job key not
--- wanted any more is not unbound under it, one that comes back is not bound
--- over it, and its line is still recorded so `tb del` gives it back. A key
--- tb does not hold behaves as before.
---
--- Run from data/: lua5.1 scripts/atelier/keybind_temp_test.lua
---
--- @file scripts/atelier/keybind_temp_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-28
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

local sent = {}
local function has(cmd)
    for _, c in ipairs(sent) do if c == cmd then return true end end
    return false
end

package.loaded['shared/utils/core/command_queue'] = {push = function(_, cmd) sent[#sent + 1] = cmd end}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
package.loaded['shared/utils/messages/message_formatter'] =
    setmetatable({}, {__index = function() return function() end end})
-- the optional layers create() adds (Combat Mode, TH, Jump, custom, common keys, Atelier overrides): none here
local noop = setmetatable({}, {__index = function() return function() end end})
for _, name in ipairs({'shared/utils/core/combat_mode', 'shared/utils/drg/auto_jump',
    'shared/utils/custom/custom_states', 'shared/utils/keybinds/common_keybinds',
    'shared/utils/keybinds/key_overrides'}) do
    package.loaded[name] = noop
end
package.loaded['shared/utils/equipment/treasure_hunter'] = {optional = noop}
local held = {}
package.loaded['shared/utils/keybinds/temp_binds'] = {current = function() return held end}

player = {name = 'Tester', main_job = 'WAR', sub_job = 'NIN'}
windower = {raw_register_event = function() end, send_command = function() end, _keybind_manager_bound = {}}

local KeybindManager = require('shared/utils/keybinds/keybind_manager')

-- ^f1 is the job's only under /SAM; ^f2 always
local module = {binds = {
    {key = '^f1', command = 'one', desc = 'One', subjob = 'SAM'},
    {key = '^f2', command = 'two', desc = 'Two'},
}}
KeybindManager.create('WAR', module)

-- 1. a previous /SAM load left ^f1 down, then the player put a tb on it
windower._keybind_manager_bound['^f1'] = 'gs c one'
held = {['^f1'] = '/ja Provoke <t>'}
module.bind_all(true)
check('a tb key is not unbound under it', has('unbind ^f1'), false)
check('the job line is forgotten (not wanted under /NIN)', windower._keybind_manager_bound['^f1'], nil)
check('the other key is bound', has('bind ^f2 gs c two'), true)

-- 2. back to /SAM while the tb holds ^f1: not bound over it, but recorded
sent = {}
player.sub_job = 'SAM'
module.refresh()
check('a job key coming back is not bound over a tb', has('bind ^f1 gs c one'), false)
check('its line is recorded for tb del', windower._keybind_manager_bound['^f1'], 'gs c one')

-- 3. the same with no tb: as before
sent = {}
held = {}
player.sub_job = 'NIN'
module.refresh()
check('without tb the key is unbound', has('unbind ^f1'), true)
sent = {}
player.sub_job = 'SAM'
module.refresh()
check('without tb the key is bound', has('bind ^f1 gs c one'), true)

-- 4. a load that binds no key of its own (no job file) leaves a tb key down
sent = {}
held = {['^f2'] = '/ja Provoke <t>'}
KeybindManager.release_all()
check('release_all leaves the tb key', has('unbind ^f2'), false)
check('release_all unbinds the others', has('unbind ^f1'), true)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
