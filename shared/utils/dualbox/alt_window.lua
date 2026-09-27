---============================================================================
--- Alt Window - small overlay with the alts' state, on the main
---============================================================================
---   Kaories
---   Job    GEO/RDM
---   Party  online
---   Zone   Ru'Lude Gardens
---   Auto   ON
---   Follow Tetsouo
---   Mirror ON  Home Point #1
---   Step   Kaories Injecting 2/5
---   (plus Sneak / Invi rows per alt)
---
--- Same size whatever it shows (FIXED LAYOUT below). Job comes from the
--- dual-box job exchange, online and zone from the party list ("no party"
--- when the alt is not in it). Step follows a mirror in progress. Auto, Follow and Mirror are the
--- real state reported by each box when the automation addon carries the
--- StateReport addition (AltGroup.receive_report); otherwise the last orders
--- sent from this box (//gs c alts, the common keys, //gs c sortie). "?"
--- means nothing is known yet since the game started.
---
--- Shown on the main only, when the box group has other members.
--- //gs c alts window shows / hides it; drag it with the mouse. Both are
--- saved in <Character>/config/alt_window.lua. Font and background follow
--- the HUD.
---
--- @file shared/utils/dualbox/alt_window.lua
--- @author ejouanchicot
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

--- Game resources: not a global in a job file's sandbox.
local function resources()
    local r = rawget(_G, 'res')
    if r then return r end
    local ok, loaded = pcall(require, 'resources')
    return ok and loaded or nil
end

---============================================================================
--- FIXED LAYOUT
---============================================================================
--- The window keeps one size whatever it shows: every line is exactly
--- LABEL_WIDTH + 1 + VALUE_WIDTH characters (padded with spaces, cut when
--- longer) in the HUD's monospace font, and the rows are always the same
--- ones, "-" when there is nothing to show. A value is a list of
--- {text, color} pieces, so its visible length can be counted.

local LABEL_WIDTH = 6      -- "Follow", "Mirror"
local VALUE_WIDTH = 24
local DASH = {{'-', GRAY}}

--- Pieces cut to `width` visible characters, then padded to it.
local function fit(pieces, width)
    local out, used = {}, 0
    for _, piece in ipairs(pieces) do
        local text = piece[1]:sub(1, width - used)
        if #text > 0 then
            out[#out + 1] = paint(piece[2], text)
            used = used + #text
        end
    end
    return table.concat(out) .. string.rep(' ', width - used)
end

local function row(label, pieces)
    return paint(GRAY, string.format('%-' .. LABEL_WIDTH .. 's', label)) .. ' ' .. fit(pieces, VALUE_WIDTH)
end

local function title(name)
    return fit({{name, BLUE}}, LABEL_WIDTH + 1 + VALUE_WIDTH)
end

local function on_off(value)
    if value == nil then return {{'?', GRAY}} end
    return value and {{'ON', GREEN}} or {{'OFF', RED}}
end

local function follow_value(value)
    if value == nil then return {{'?', GRAY}} end
    return value and {{value, WHITE}} or {{'OFF', RED}}
end

--- The party / alliance entry of `name`, or nil.
local function party_member(name)
    local party = windower.ffxi.get_party() or {}
    for key, member in pairs(party) do
        if type(key) == 'string' and key:match('^[pa]%d') and type(member) == 'table'
            and member.name and member.name:lower() == name:lower() then
            return member
        end
    end
    return nil
end

--- Presence from the party list (the job exchange only speaks at a load or
--- a job change, so its 30 s "online" timeout reads a quiet alt as gone),
--- and the alt's zone.
--- @return table party value, table zone value
local function presence(name)
    local member = party_member(name)
    if not member then return {{'no party', GRAY}}, DASH end
    local r = resources()
    local zone = member.zone and r and r.zones and r.zones[member.zone]
    return {{'online', GREEN}}, zone and {{zone.en, WHITE}} or DASH
end

--- Time left on Sneak and Invisible (stealth_timers.lua): yellow under
--- a minute, "-" when not up or not known.
local function stealth_lines(lines, name)
    local ok, Timers = pcall(require, 'shared/utils/stealth/stealth_timers')
    for _, kind in ipairs({'sneak', 'invi'}) do
        local left = ok and Timers and Timers.left(kind, name) or nil
        local value = left and {{Timers.format(left), left < 60 and YELLOW or GREEN}} or DASH
        lines[#lines + 1] = row(kind == 'sneak' and 'Sneak' or 'Invi', value)
    end
end

--- One block per alt: its name as the title, its job, whether it is in the
--- party, its zone. The job exchange knows one partner: its last job goes
--- on the first alt.
local function alt_lines(alts)
    local lines = {}
    local job_state = _G.AltJobState
    for i, name in ipairs(alts) do
        local job = DASH
        if i == 1 and job_state and job_state.job then
            local sub = job_state.subjob and job_state.subjob ~= 'NON' and ('/' .. job_state.subjob) or ''
            job = {{job_state.job .. sub, YELLOW}}
        end
        local here, zone = presence(name)
        lines[#lines + 1] = title(name)
        lines[#lines + 1] = row('Job', job)
        lines[#lines + 1] = row('Party', here)
        lines[#lines + 1] = row('Zone', zone)
        stealth_lines(lines, name)
    end
    return lines
end

--- The addon's step, short: packet codes dropped and "(2 of 5)" -> "2/5".
--- "Injecting [0x01A] - Retry [2]" -> "Injecting - Retry 2".
local function step_text(step)
    local text = step:gsub('%[?0x%x+%]?', ''):gsub('%((%d+) of (%d+)%)', '%1/%2')
    text = text:gsub('[%[%]]', ''):gsub('%s+', ' ')
    return (text:gsub('^%s+', ''):gsub('%s+$', ''))
end

--- The mirror line: ON/OFF, then the NPC while one runs.
local function mirror_value(state, phases)
    local pieces = on_off(state.mirror)
    for _, phase in pairs(phases) do
        if phase.npc then
            pieces[#pieces + 1] = {'  ' .. phase.npc, GRAY}
            break
        end
    end
    return pieces
end

--- The Step line: the latest step of a running mirror (Recording on the box
--- that records, Injecting / Trading on the ones that replay), else the
--- program's results for a few seconds (OK in green once completed), else "-".
local function step_value(phases, results)
    local latest, latest_name
    for name, phase in pairs(phases) do
        if not latest or phase.time > latest.time then latest, latest_name = phase, name end
    end
    if latest then
        return {{latest_name .. ' ', WHITE}, {step_text(latest.step), YELLOW}}
    end
    local pieces = {}
    for i, result in ipairs(results or {}) do
        local done = result.status == 'Completed'
        pieces[#pieces + 1] = {(i > 1 and ', ' or '') .. result.name .. ' ', WHITE}
        pieces[#pieces + 1] = done and {'OK', GREEN} or {result.status, YELLOW}
    end
    return #pieces > 0 and pieces or DASH
end

local function build_text(alts)
    local g = group()
    local state = g.state()
    local phases, results = {}, nil
    if g.mirror_progress then phases, results = g.mirror_progress() end
    local lines = alt_lines(alts)
    lines[#lines + 1] = row('Auto', on_off(state.on))
    lines[#lines + 1] = row('Follow', follow_value(state.follow))
    lines[#lines + 1] = row('Mirror', mirror_value(state, phases))
    lines[#lines + 1] = row('Step', step_value(phases, results))
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

--- The window's text object, or nil. A reload destroys every text of the
--- old load while that load's refresh loop can still run for a few seconds
--- (coroutines are never cancelled): touching the destroyed object raised
--- "texts.lua:353 attempt to index field '?'". Found destroyed, this load is
--- over: it is marked dead and never draws again, so it cannot leave a
--- stray window behind either.
--- @return table|nil
local function live_display()
    if rawget(_G, '_alt_window_dead') then return nil end
    local display = rawget(_G, '_alt_window_display')
    if display == nil then return nil end
    if pcall(display.visible, display) then return display end
    _G._alt_window_display = nil
    _G._alt_window_dead = true
    return nil
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
    local display = live_display()
    if rawget(_G, '_alt_window_dead') then return end
    if not alts or not prefs().visible then
        if display then display:hide() end
        return
    end
    display = display or create()
    display:text(build_text(alts))
    display:show()
end

--- Whether the window is on screen now (its orders need no chat line then).
--- @return boolean
function AltWindow.is_shown()
    local display = live_display()
    return display ~= nil and display:visible() == true
end

--- Save the position if the window was dragged since the last check.
---
--- Polled from the refresh loop rather than a `mouse` event on purpose: an
--- event registered from a job file goes through GearSwap's wrapper, which
--- runs refresh_globals and a full equip_sets on every call - on every mouse
--- move, that made dragging the window lag badly.
local function save_if_moved()
    local display = live_display()
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
    local ok, m = pcall(require, 'shared/utils/messages/formatters/system/message_altgroup')
    local cfg = _G.DualBoxConfig
    if not cfg or cfg.role ~= 'main' then
        -- alts_to_show() keeps the window hidden off the main: flipping the
        -- saved flag here would announce "Window ON" with nothing drawn.
        if ok and m then m.show_window_main_only() end
        return
    end
    save_if_moved()
    local p = prefs()
    p.visible = not p.visible
    save_prefs(p)
    AltWindow.refresh()
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
        if gen ~= windower._alt_window_gen or rawget(_G, '_alt_window_dead') then return end
        save_if_moved()
        AltWindow.refresh()
        coroutine.schedule(tick, REFRESH_EVERY)
    end
    tick()
end

return AltWindow
