---============================================================================
--- Test: the HUD's saved settings follow UI_CONFIG.lua only where it changed
---============================================================================
--- shared/config/ui_settings.lua keeps the HUD's settings in
--- <Char>/saved/ui_settings.lua. That file wins over UI_CONFIG.lua (a change
--- made in game with //gs c ui stays), except for a setting the player changed
--- in UI_CONFIG.lua since the last load. This plays several loads in a row on
--- a file of the temp folder and checks who wins each time.
---
---   lua5.1 scripts/atelier/ui_settings_test.lua        (from data/)
---
--- @file    scripts/atelier/ui_settings_test.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local saved = os.tmpname() .. '_ui_settings.lua'
local failed = 0

package.path = './?.lua;' .. package.path
package.preload['shared/utils/core/char_paths'] = function() return {writable = function() return saved end} end
package.preload['shared/utils/messages/message_formatter'] = function() return {show_error = function() end} end
player = {name = 'Test'}

--- UI_CONFIG.lua as the player wrote it
local function config(bg_a, size)
    return {enabled = true, show_legend = true, default_position = {x = 1600, y = 300},
        background = {r = 15, g = 15, b = 35, a = bg_a, visible = true}, text = {size = size, font = 'Consolas'}, sections = {}}
end

--- One load of the job: the module read again, as a new GearSwap sandbox does.
--- @param cfg table|nil UI_CONFIG.lua (nil: not read yet at this load)
local function load(cfg)
    _G.UIConfig, _G.UI_SETTINGS = cfg, nil
    package.loaded['shared/config/ui_settings'] = nil
    return require('shared/config/ui_settings')
end

local function check(what, got, want)
    if got ~= want then
        failed = failed + 1
        print(('FAIL %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    else
        print('ok   ' .. what)
    end
end

-- 1. no saved file: seeded from the config
os.remove(saved)
local UI = load(config(180, 10))
check('first load takes the opacity of UI_CONFIG', UI.get_background().a, 180)

-- 2. a change made in game stays over the config at the next load
UI.set_background(1, 2, 3, 90)
UI.set_font('Consolas', 14)
UI = load(config(180, 10))
check('an opacity set in game stays', UI.get_background().a, 90)
check('a font size set in game stays', UI.get_font().size, 14)

-- 3. UI_CONFIG changed for one setting: that one follows it, the others keep what the game saved
UI = load(config(255, 10))
check('an opacity changed in UI_CONFIG is taken', UI.get_background().a, 255)
check('the red set in game is kept', UI.get_background().r, 1)
check('the font size set in game is kept', UI.get_font().size, 14)

-- 4. and it is taken once: a new change in game wins again
UI.set_background(1, 2, 3, 60)
UI = load(config(255, 10))
check('a change in game after that stays', UI.get_background().a, 60)

-- 5. a load that has not read UI_CONFIG yet changes nothing
UI = load(nil)
check('a load without UI_CONFIG keeps the saved opacity', UI.get_background().a, 60)
UI = load(config(255, 10))
check('and the next one with it does not take it for a change', UI.get_background().a, 60)

-- 6. a file saved before the seed existed: kept as it is, the seed only recorded
local f = io.open(saved, 'w')
f:write('return {pos_x = 100, pos_y = 50, enabled = true, bg_r = 9, bg_g = 9, bg_b = 9, bg_a = 77, bg_visible = true, font_size = 12, font_name = "Consolas"}\n')
f:close()
UI = load(config(255, 10))
check('an older saved file keeps its opacity', UI.get_background().a, 77)
check('an older saved file keeps its position', UI.get_position().x, 100)
UI = load(config(200, 10))
check('then a change in UI_CONFIG is taken', UI.get_background().a, 200)
check('and its position is still kept', UI.get_position().x, 100)

os.remove(saved)
print(failed == 0 and '\nthe saved settings follow UI_CONFIG only where it changed' or ('\n' .. failed .. ' check(s) failed'))
os.exit(failed == 0 and 0 or 1)
