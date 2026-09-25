---============================================================================
--- UI Style Commands - change the HUD/chat look in game
---============================================================================
---   //gs c ui compact [on|off]        tighter HUD (no value: toggle)
---   //gs c ui gap <1-10>              spaces key -> label
---   //gs c ui valuegap <1-10>         spaces label -> value
---   //gs c ui margin <0-3> [0-3]      blank lines top [bottom] (one value: both)
---   //gs c ui side <0-3>              spaces left and right of the rows
---   //gs c ui padding <0-20>          pixels of background around the text
---   //gs c ui keys symbols|words      ^f1 or CTRL+F1
---   //gs c ui bullet <name|text>      symbol before the values (dot, arrow... or plain characters)
---   //gs c ui order <section> ...     section order (spells enhancing abilities weapons modes)
---   //gs c ui roworder <state> ...    row order inside the sections (state names or keys)
---   //gs c ui color <name> <r> <g> <b>
---   //gs c ui separators [on|off]     the ===== chat line (no value: toggle)
---   //gs c ui sepchar <chars>         its character (= - * ~ #)
---   //gs c ui sepcolor <1-255>        its FFXI chat color
---   //gs c ui chatwidth <20-150>      characters per chat separator line (standard 69)
---   //gs c ui jobtag [on|off]         the [RDM/DRK] in front of chat messages
---   //gs c ui chatcolor <name> <1-255> remap a chat color (gray, green, success...)
---   //gs c ui style                   list the current values
---   //gs c ui <option> reset          back to the standard value
---
--- A value is checked first (same checks as UI_CONFIG.lua), then applied to
--- the live HUD and saved into UI_CONFIG.lua, so a reload keeps it.
---
--- @file shared/utils/ui/ui_style_commands.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local UIStyleCommands = {}

local UIStyle = require('shared/utils/ui/ui_style')
local Writer = require('shared/utils/ui/ui_config_writer')
local MessageUI = require('shared/utils/messages/formatters/ui/message_ui')

--- Chat separator width in use (the player's chat.width or 69).
local function separator_width()
    return require('shared/utils/messages/message_core').SEPARATOR_WIDTH
end

---============================================================================
--- VALUE PARSERS (text typed in game -> value, or nil + error)
---============================================================================

local function parse_int(text)
    local n = tonumber(text)
    if not n then return nil, 'a number is expected' end
    return math.floor(n)
end

local function parse_text(text)
    if not text or text == '' then return nil, 'a value is expected' end
    return text
end

local function parse_word(text)
    if not text or text == '' then return nil, 'a value is expected' end
    return text:lower()
end

--- A bullet name (dot, arrow...) or plain characters. A symbol typed in the
--- FFXI chat does not arrive as the HUD's text encoding, so it is refused
--- with the list of names instead of showing garbage.
local function parse_bullet(text)
    local names = table.concat(UIStyle.BULLET_NAMES, ' ')
    if not text or text == '' then return nil, 'a name is expected: ' .. names end
    if text:find('[\128-\255]') then return nil, 'symbols cannot be typed in chat, use a name: ' .. names end
    return text:lower()
end

--- Option key typed in game -> where it lives in UI_CONFIG.lua.
local OPTIONS = {
    gap = {block = 'layout', name = 'column_gap', parse = parse_int},
    valuegap = {block = 'layout', name = 'value_gap', parse = parse_int},
    padding = {block = 'layout', name = 'padding', parse = parse_int},
    side = {block = 'layout', name = 'margin_side', parse = parse_int},
    sepchar = {block = 'chat', name = 'separator_char', parse = parse_text},
    sepcolor = {block = 'chat', name = 'separator_color', parse = parse_int},
    chatwidth = {block = 'chat', name = 'width', parse = parse_int},
    keys = {block = 'layout', name = 'key_style', parse = parse_word},
    bullet = {block = 'layout', name = 'bullet', parse = parse_bullet},
}

--- On/off options: no value toggles.
local SWITCHES = {
    compact = {block = 'layout', name = 'compact', default = false},
    separators = {block = 'chat', name = 'separators', default = true},
    jobtag = {block = 'chat', name = 'job_tag', default = true},
}

---============================================================================
--- APPLY
---============================================================================

local function config()
    _G.UIConfig = _G.UIConfig or {}
    return _G.UIConfig
end

--- Copy of the config with one option changed, to check before applying.
local function with_change(block, name, value)
    local copy = {}
    for k, v in pairs(config()) do copy[k] = v end
    local sub = {}
    for k, v in pairs(config()[block] or {}) do sub[k] = v end
    sub[name] = value
    copy[block] = sub
    return copy
end

--- Problems the change adds (those already in the file are not its fault).
local function new_problems(block, name, value)
    local _, before = UIStyle.resolve(config())
    local _, after = UIStyle.resolve(with_change(block, name, value))
    local known = {}
    for _, p in ipairs(before) do known[p] = true end
    for _, p in ipairs(after) do
        if not known[p] then return p end
    end
    return nil
end

--- Redraw the HUD with the new look (padding is a property of the box).
local function refresh()
    UIStyle.invalidate()
    local display = rawget(_G, 'keybind_ui_display')
    if display and display.pad then
        pcall(display.pad, display, UIStyle.get().layout.spacing.padding)
    end
    local ok, Display = pcall(require, 'shared/utils/ui/ui_display')
    if ok and Display and Display.update_display then pcall(Display.update_display) end
end

--- Check, apply live, save. value nil = back to the standard value.
--- @return boolean applied
local function apply(block, name, value)
    local problem = value ~= nil and new_problems(block, name, value)
    if problem then
        MessageUI.show_error(problem)
        return false
    end
    config()[block] = config()[block] or {}
    config()[block][name] = value
    refresh()
    local saved, err = Writer.set(block, name, value)
    MessageUI.show_style_set(block .. '.' .. name,
        value == nil and 'standard' or Writer.to_lua(value), saved and nil or err)
    return true
end

---============================================================================
--- COMMANDS
---============================================================================

local function run_switch(spec, word)
    if word == 'reset' then return apply(spec.block, spec.name, nil) end
    local current = (config()[spec.block] or {})[spec.name]
    if current == nil then current = spec.default end
    local value
    if word == 'on' then value = true
    elseif word == 'off' then value = false
    elseif not word then value = not current
    else
        MessageUI.show_error('use on, off or nothing to toggle')
        return false
    end
    return apply(spec.block, spec.name, value)
end

local function run_margin(args)
    if args[1] == 'reset' then
        apply('layout', 'margin_top', nil)
        return apply('layout', 'margin_bottom', nil)
    end
    local top, bottom = tonumber(args[1]), tonumber(args[2] or args[1])
    if not top or not bottom then
        MessageUI.show_error('use: //gs c ui margin <top> [bottom]')
        return false
    end
    return apply('layout', 'margin_top', math.floor(top))
        and apply('layout', 'margin_bottom', math.floor(bottom))
end

local function run_order(args)
    if args[1] == 'reset' then return apply('layout', 'section_order', nil) end
    if #args == 0 then
        MessageUI.show_error('use: //gs c ui order weapons modes spells ...')
        return false
    end
    local order = {}
    for i, name in ipairs(args) do order[i] = name:lower() end
    return apply('layout', 'section_order', order)
end

--- //gs c ui roworder MainWeapon CombatMode ... | reset
local function run_row_order(args)
    if args[1] and args[1]:lower() == 'reset' then return apply('layout', 'row_order', nil) end
    if #args == 0 then
        MessageUI.show_error('use: //gs c ui roworder <state> <state> ... (names as in the HUD file, or keys)')
        return false
    end
    local order = {}
    for i, name in ipairs(args) do order[i] = name end
    return apply('layout', 'row_order', order)
end

local function run_color(args)
    local name = args[1] and args[1]:lower()
    if not name then
        MessageUI.show_error('use: //gs c ui color <name> <r> <g> <b> (or reset)')
        return false
    end
    if args[2] == 'reset' then return apply('colors', name, nil) end
    local r, g, b = tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
    if not (r and g and b) then
        MessageUI.show_error('use: //gs c ui color <name> <r> <g> <b> (or reset)')
        return false
    end
    return apply('colors', name, {math.floor(r), math.floor(g), math.floor(b)})
end

--- HUD bucket -> the section name typed in commands and UI_CONFIG.lua.
local SECTION_WORDS = {spell = 'spells', enhancing = 'enhancing', ja = 'abilities', weapon = 'weapons', mode = 'modes'}

local function section_words(order)
    local words = {}
    for i, bucket in ipairs(order) do words[i] = SECTION_WORDS[bucket] or bucket end
    return table.concat(words, ' ')
end

--- Current values, one line each.
--- "MainWeapon CombatMode", or "standard".
local function row_order_text(list)
    return type(list) == 'table' and #list > 0 and table.concat(list, ' ') or 'standard'
end

--- "success 99, green 204", or "standard".
local function chat_colors_text(colors)
    local names = {}
    for name, code in pairs(colors) do names[#names + 1] = name .. ' ' .. code end
    table.sort(names)
    return #names > 0 and table.concat(names, ', ') or 'standard'
end

local function show_style()
    local layout = UIStyle.get().layout
    local sp = layout.spacing
    local chat = UIStyle.get().chat
    MessageUI.show_style_list({
        {'Compact', (config().layout or {}).compact == true},
        {'Gaps', ('key %d / value %d'):format(sp.gap, sp.gap_value)},
        {'Margins', ('top %d / bottom %d / side %d'):format(sp.margin_top, sp.margin_bottom, sp.left)},
        {'Padding', sp.padding .. ' px'},
        {'Keys', layout.key_style},
        -- The name, not the symbol: the FFXI chat cannot print "●"
        {'Bullet', UIStyle.bullet_name((config().layout or {}).bullet)},
        {'Order', section_words(layout.section_order)},
        {'Row order', row_order_text((config().layout or {}).row_order)},
        {'Separators', chat.separators},
        {'Separator', ('%s / color %s / width %s'):format(chat.separator_char,
            tostring(chat.separator_color or 160), tostring(separator_width()))},
        {'Job tag', chat.job_tag},
        {'Chat colors', chat_colors_text(chat.colors)},
    })
end

--- //gs c ui chatcolor <name> <1-255> | <name> reset
local function run_chatcolor(args)
    local name = args[1] and args[1]:lower()
    local code = args[2] and args[2]:lower()
    if not name or not code then
        MessageUI.show_error('use: //gs c ui chatcolor <name> <1-255> (or reset)')
        return false
    end
    local colors = {}
    for k, v in pairs((config().chat or {}).colors or {}) do colors[k] = v end
    if code == 'reset' then
        colors[name] = nil
    elseif tonumber(code) then
        colors[name] = math.floor(tonumber(code))
    else
        MessageUI.show_error('chatcolor: a number from 1 to 255 is expected')
        return false
    end
    return apply('chat', 'colors', next(colors) and colors or nil)
end

local SPECIAL = {
    chatcolor = run_chatcolor,
    margin = run_margin,
    order = run_order,
    roworder = run_row_order,
    color = run_color,
    colour = run_color,
}

---============================================================================
--- PUBLIC API
---============================================================================

--- True when `subcommand` is one of the look commands.
--- @param subcommand string|nil Lowercased word after "ui"
--- @return boolean
function UIStyleCommands.handles(subcommand)
    return subcommand ~= nil and (OPTIONS[subcommand] ~= nil or SWITCHES[subcommand] ~= nil
        or SPECIAL[subcommand] ~= nil or subcommand == 'style')
end

--- Run a look command.
--- @param subcommand string Lowercased word after "ui"
--- @param cmdParams table Full command parameters ({'ui', subcommand, ...})
--- @return boolean True when a value was applied
function UIStyleCommands.run(subcommand, cmdParams)
    local args = {}
    for i = 3, #cmdParams do args[#args + 1] = cmdParams[i] end
    local word = args[1] and args[1]:lower()

    if subcommand == 'style' then
        show_style()
        return false
    end
    if SPECIAL[subcommand] then return SPECIAL[subcommand](args) end
    if SWITCHES[subcommand] then return run_switch(SWITCHES[subcommand], word) end

    local spec = OPTIONS[subcommand]
    if word == 'reset' then return apply(spec.block, spec.name, nil) end
    local value, err = spec.parse(args[1])
    if value == nil then
        MessageUI.show_error(subcommand .. ': ' .. err)
        return false
    end
    return apply(spec.block, spec.name, value)
end

return UIStyleCommands
