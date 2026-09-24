---============================================================================
--- Alt Window - small overlay with the alts' state, on the main
---============================================================================
---   ALTS
---   Kaories   GEO/RDM  online
---   Auto      ON
---   Follow    Tetsouo
---   Mirror    ?
---
--- Job and online come from the dual-box job exchange. Auto, Follow and
--- Mirror are the last orders sent from this box (//gs c alts, the common
--- keys, //gs c sortie): the automation addon keeps its real state to itself,
--- so "?" means nothing was sent since the game started.
---
--- Shown on the main only, when the box group has other members.
--- //gs c alts window shows / hides it; drag it with the mouse. Both are
--- saved in <Character>/config/alt_window.lua. Font and background follow
--- the HUD.
---
--- @file shared/utils/dualbox/alt_window.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local AltWindow = {}

local texts = require('texts')

local REFRESH_EVERY = 5    -- seconds, catches an alt going offline
local DEFAULT = {x = 1600, y = 120, visible = true}

local WHITE, GRAY, BLUE = {255, 255, 255}, {150, 150, 150}, {110, 190, 255}
local GREEN, RED, YELLOW = {110, 230, 110}, {255, 100, 100}, {255, 220, 90}

local function paint(rgb, text)
    return string.format('\\cs(%d,%d,%d)%s\\cr', rgb[1], rgb[2], rgb[3], text)
end

---============================================================================
--- PREFERENCES (position, visible)
---============================================================================

local function prefs_file()
    local name = player and player.name
    return name and (windower.addon_path .. 'data/' .. name .. '/config/alt_window.lua')
end

local function load_prefs()
    local path, prefs = prefs_file(), {}
    local ok, saved = pcall(dofile, path or '')
    for key, value in pairs(DEFAULT) do
        prefs[key] = (ok and type(saved) == 'table' and saved[key] ~= nil) and saved[key] or value
    end
    return prefs
end

local function save_prefs(prefs)
    local path = prefs_file()
    local file = path and io.open(path, 'w')
    if not file then return end
    file:write('-- Written by the alt window (//gs c alts window, drag to move).\n')
    file:write(string.format('return {x = %d, y = %d, visible = %s}\n',
        prefs.x, prefs.y, tostring(prefs.visible)))
    file:close()
end

local function prefs()
    _G._alt_window_prefs = _G._alt_window_prefs or load_prefs()
    return _G._alt_window_prefs
end

---============================================================================
--- CONTENT
---============================================================================

local function group()
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    return ok and AltGroup or nil
end

local function manager()
    local ok, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    return ok and DualBoxManager or nil
end

local function on_off(value)
    if value == nil then return paint(GRAY, '?') end
    return value and paint(GREEN, 'ON') or paint(RED, 'OFF')
end

local function follow_text(value)
    if value == nil then return paint(GRAY, '?') end
    return value and paint(WHITE, value) or paint(RED, 'OFF')
end

--- One line per alt. The job exchange knows one partner: its job goes on
--- the first alt's line.
local function alt_lines(alts)
    local lines, dbm = {}, manager()
    for i, name in ipairs(alts) do
        local info = ''
        if i == 1 and dbm then
            if dbm.is_alt_online() then
                local job, sub = dbm.get_alt_job(), dbm.get_alt_subjob()
                info = paint(YELLOW, (job or '?') .. (sub and ('/' .. sub) or '')) .. '  ' .. paint(GREEN, 'online')
            else
                info = paint(RED, 'offline')
            end
        end
        lines[#lines + 1] = paint(WHITE, string.format('%-9s', name)) .. ' ' .. info
    end
    return lines
end

local function build_text(alts)
    local state = group().state()
    local lines = {paint(BLUE, 'ALTS')}
    for _, line in ipairs(alt_lines(alts)) do lines[#lines + 1] = line end
    lines[#lines + 1] = paint(GRAY, 'Auto     ') .. ' ' .. on_off(state.on)
    lines[#lines + 1] = paint(GRAY, 'Follow   ') .. ' ' .. follow_text(state.follow)
    lines[#lines + 1] = paint(GRAY, 'Mirror   ') .. ' ' .. on_off(state.mirror)
    return table.concat(lines, '\n')
end

---============================================================================
--- DISPLAY
---============================================================================

--- The alts to show, or nil when the window has nothing to do here.
local function alts_to_show()
    local cfg, g = _G.DualBoxConfig, group()
    if not cfg or cfg.enabled == false or cfg.role ~= 'main' or not g then return nil end
    local alts = g.get_alts()
    return #alts > 0 and alts or nil
end

local function create()
    local p = prefs()
    local ok, UISettingsResolver = pcall(require, 'shared/utils/ui/ui_settings_resolver')
    local font_ok, UISettings = pcall(require, 'shared/config/ui_settings')
    local font = font_ok and UISettings.get_font() or {}
    _G._alt_window_display = texts.new({
        pos = {x = p.x, y = p.y},
        text = {size = font.size or 10, font = font.name or 'Consolas',
                stroke = {width = 2, alpha = 200, red = 0, green = 0, blue = 0}},
        bg = ok and UISettingsResolver.get_background_settings() or {alpha = 180, red = 0, green = 0, blue = 0},
        flags = {draggable = true},
        padding = 4,
    })
    return _G._alt_window_display
end

--- Redraw the window, or hide it when it should not be up.
function AltWindow.refresh()
    local alts = alts_to_show()
    local display = _G._alt_window_display
    if not alts or not prefs().visible then
        if display then display:hide() end
        return
    end
    display = display or create()
    display:text(build_text(alts))
    display:show()
end

--- Save the position if the window was dragged since the last check.
---
--- Polled from the refresh loop rather than a `mouse` event on purpose: an
--- event registered from a job file goes through GearSwap's wrapper, which
--- runs refresh_globals and a full equip_sets on every call - on every mouse
--- move, that made dragging the window lag badly.
local function save_if_moved()
    local display = _G._alt_window_display
    if not display or not display:visible() then return end
    local x, y = display:pos()
    local p = prefs()
    if x and y and (x ~= p.x or y ~= p.y) then
        p.x, p.y = x, y
        save_prefs(p)
    end
end

--- //gs c alts window - show / hide, saved.
function AltWindow.toggle()
    save_if_moved()
    local p = prefs()
    p.visible = not p.visible
    save_prefs(p)
    AltWindow.refresh()
    local ok, m = pcall(require, 'shared/utils/messages/formatters/system/message_altgroup')
    if ok and m then m.show_window(p.visible) end
end

--- Called once per load by the dual-box auto-init: draw, then every few
--- seconds redraw (an alt going offline shows) and keep a drag. The loop of
--- an older load stops on its own when a newer one starts (generation
--- counter on `windower`: coroutines outlive the sandbox).
function AltWindow.start()
    windower._alt_window_gen = (windower._alt_window_gen or 0) + 1
    local gen = windower._alt_window_gen
    local function tick()
        if gen ~= windower._alt_window_gen then return end
        save_if_moved()
        AltWindow.refresh()
        coroutine.schedule(tick, REFRESH_EVERY)
    end
    tick()
end

return AltWindow
