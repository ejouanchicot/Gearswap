---============================================================================
--- Test of the HUD rows without a key (shared/utils/ui/UI_SECTIONS.lua)
---============================================================================
--- Every row without a key has the key '': a section used to draw every such
--- row as soon as its own list held one. On BRD (five song slots without a
--- key), one mode set to "no key" (//gs c combatmode key none, or '' in the
--- Atelier's Keys page) drew the slots again under Modes and the mode under
--- Song Slots. Each row is drawn once, in its own section.
---
--- Run from data/: lua5.1 scripts/atelier/hud_keyless_rows_test.lua
---
--- @file scripts/atelier/hud_keyless_rows_test.lua
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

player = {main_job = 'BRD', sub_job = 'WHM', name = 'Tester'}
windower = {addon_path = '/nonexistent/'}
_G.UIConfig = {}
_G.ui_display_config = {show_header = false, show_legend = false, show_column_headers = false,
    show_footer = false, enabled = true}
package.loaded['shared/utils/keybinds/keybind_manager'] = {conflict_keys = function() return {} end}
package.loaded['shared/utils/ui/hud_job_config'] =
    {section_order = function() return nil end, row_order = function() return nil end}
package.loaded['shared/utils/messages/message_formatter'] =
    setmetatable({}, {__index = function() return function() end end})

local UISections = require('shared/utils/ui/UI_SECTIONS')
local Builder = require('shared/utils/ui/UI_DISPLAY_BUILDER')
local Loader = require('shared/utils/ui/UI_LOADER')

local function render(binds)
    Loader.get_job_keybinds = function() return binds end
    local rows = Loader.add_job_specific_elements('BRD', binds)
    local structure = Builder.build_display_structure('BRD', rows)
    local text = UISections.render_complete_ui(structure, rows, 'BRD',
        function() return 'x' end, function() return {'x'} end)
    return (text:gsub('\\cs%(%d+,%d+,%d+%)', ''):gsub('\\cr', ''))
end

local function count(text, word)
    local n = 0
    for _ in text:gmatch(word) do n = n + 1 end
    return n
end

-- 1. Combat Mode with no key: every row once
local text = render({
    {key = '^numpad1', desc = 'Song Mode', state = 'SongMode', command = 'cyclestate SongMode'},
    {key = '', desc = 'Combat Mode', state = 'CombatMode', command = 'cyclestate CombatMode'},
})
check('Combat Mode drawn once', count(text, 'Combat Mode'), 1)
check('Slot 1 drawn once', count(text, 'Slot 1'), 1)
check('Slot 5 drawn once', count(text, 'Slot 5'), 1)
local songs, modes = text:find('Song Slots', 1, true), text:find('Modes', 1, true)
local combat = text:find('Combat Mode', 1, true)
check('Combat Mode under Modes', combat ~= nil and modes ~= nil and combat > modes, true)
check('the slots under Song Slots', songs ~= nil and text:find('Slot 1', 1, true) > songs, true)

-- 2. every row keyed: unchanged
text = render({
    {key = '^numpad1', desc = 'Song Mode', state = 'SongMode', command = 'cyclestate SongMode'},
    {key = '^numpad2', desc = 'Combat Mode', state = 'CombatMode', command = 'cyclestate CombatMode'},
})
check('keyed Combat Mode once', count(text, 'Combat Mode'), 1)
check('slots once with every mode keyed', count(text, 'Slot 3'), 1)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
