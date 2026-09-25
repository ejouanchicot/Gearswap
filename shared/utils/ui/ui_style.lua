---============================================================================
--- UI Style - the player's HUD and chat look, read from UI_CONFIG.lua
---============================================================================
--- Resolves the optional `layout`, `colors` and `chat` tables of
--- <Character>/config/UI_CONFIG.lua into one checked table. Every option
--- left out keeps the look the HUD had before these options existed, so a
--- config without them renders exactly as it always did.
---
--- A wrong value (unknown section, bad color...) is reported once in chat
--- and replaced by its default: a typo must never cost the player the HUD.
---
--- @file shared/utils/ui/ui_style.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local UIStyle = {}

--- Section names a player writes -> HUD bucket used by the renderer.
local SECTION_NAMES = {
    spells = 'spell', spell = 'spell',
    enhancing = 'enhancing',
    abilities = 'ja', ability = 'ja', ja = 'ja',
    weapons = 'weapon', weapon = 'weapon',
    modes = 'mode', mode = 'mode',
}

--- Historical render order, used for any section the player's order omits.
local DEFAULT_ORDER = {'spell', 'enhancing', 'ja', 'weapon', 'mode'}

--- Column spacing. `normal` is the historical layout.
local SPACING = {
    normal  = {left = 2, gap = 4, gap_value = 4, right = 2, title_gap = true,
               margin_top = 1, margin_bottom = 1, padding = 0},
    compact = {left = 1, gap = 2, gap_value = 2, right = 1, title_gap = false,
               margin_top = 0, margin_bottom = 0, padding = 4},
}

--- Historical colors. nil = no override (key: same as description; value:
--- automatic per-value colors from COLOR_SYSTEM).
local DEFAULT_COLORS = {
    title = {255, 255, 255},
    section_title = {120, 220, 255},
    key = nil,
    description = {180, 180, 180},
    value = nil,
    legend = {255, 215, 0},
    separator = nil,
    footer = {128, 128, 128},
    column_key = {100, 180, 255},
    column_function = {120, 200, 255},
    column_current = {140, 220, 255},
}

local COLOR_NAMES = {
    title = true, section_title = true, key = true, description = true,
    value = true, legend = true, separator = true, footer = true,
    column_key = true, column_function = true, column_current = true,
}

--- Historical legend: the four key modifiers.
local DEFAULT_LEGEND = {'^ = Ctrl', '! = Alt', '@ = Windows', '~ = Shift'}

--- Bullet names -> symbol. The FFXI chat line cannot send symbols like "●",
--- so `//gs c ui bullet` takes a name. The symbols are from the WGL4 set,
--- which Consolas (the HUD's font) covers.
local BULLETS = {
    dot = '●', circle = '○', square = '■', smallsquare = '▪', triangle = '►',
    diamond = '◊', arrow = '→', gt = '>', dash = '-', star = '*', none = '',
}
--- Name of a bullet symbol ("●" -> "dot"), for the chat, which cannot print it.
--- @param bullet string|nil Symbol or name as written in UI_CONFIG.lua
--- @return string
function UIStyle.bullet_name(bullet)
    bullet = bullet or '●'
    for name, symbol in pairs(BULLETS) do
        if symbol == bullet then return name end
    end
    return bullet:find('[\128-\255]') and '(symbol)' or bullet
end

UIStyle.BULLET_NAMES = {'dot', 'circle', 'square', 'smallsquare', 'triangle', 'diamond', 'arrow', 'gt', 'dash', 'star', 'none'}

local cache_source, cache = nil, nil

---============================================================================
--- VALIDATION HELPERS
---============================================================================

local function warn(problems, text)
    problems[#problems + 1] = text
end

--- {r, g, b} with each part 0-255, else nil.
local function valid_rgb(value)
    if type(value) ~= 'table' or #value ~= 3 then return false end
    for i = 1, 3 do
        local n = value[i]
        if type(n) ~= 'number' or n < 0 or n > 255 then return false end
    end
    return true
end

local function resolve_order(raw, problems)
    local order, seen = {}, {}
    if raw ~= nil and type(raw) ~= 'table' then
        warn(problems, 'layout.section_order must be a list')
        raw = nil
    end
    for _, name in ipairs(raw or {}) do
        local bucket = SECTION_NAMES[tostring(name):lower()]
        if not bucket then
            warn(problems, ('layout.section_order: unknown section "%s"'):format(tostring(name)))
        elseif not seen[bucket] then
            order[#order + 1] = bucket
            seen[bucket] = true
        end
    end
    for _, bucket in ipairs(DEFAULT_ORDER) do
        if not seen[bucket] then order[#order + 1] = bucket end
    end
    return order
end

--- state/key -> bucket. Enhancing is left out: no state is ever sorted there.
local function resolve_moves(raw, problems)
    local moves = {}
    if raw == nil then return moves end
    if type(raw) ~= 'table' then
        warn(problems, 'layout.move_to_section must be a table')
        return moves
    end
    for name, section in pairs(raw) do
        local bucket = SECTION_NAMES[tostring(section):lower()]
        if not bucket or bucket == 'enhancing' then
            warn(problems, ('layout.move_to_section.%s: unknown section "%s"'):format(tostring(name), tostring(section)))
        else
            moves[name] = bucket
        end
    end
    return moves
end

--- layout.row_order: state names or keys -> position (1 = first).
local function resolve_row_order(raw, problems)
    local rank = {}
    if raw == nil then return rank end
    if type(raw) ~= 'table' then
        warn(problems, 'layout.row_order must be a list')
        return rank
    end
    for i, name in ipairs(raw) do
        if rank[name] == nil then rank[name] = i end
    end
    return rank
end

local function resolve_set(raw, label, problems)
    local set = {}
    if raw == nil then return set end
    if type(raw) ~= 'table' then
        warn(problems, label .. ' must be a list')
        return set
    end
    for _, name in ipairs(raw) do set[name] = true end
    return set
end

--- Legend texts: a list of up to 8 texts, else the standard four.
local function resolve_legend(raw, problems)
    if raw == nil then return DEFAULT_LEGEND end
    if type(raw) ~= 'table' or #raw == 0 or #raw > 8 then
        warn(problems, 'layout.legend must be a list of 1 to 8 texts')
        return DEFAULT_LEGEND
    end
    for _, item in ipairs(raw) do
        if type(item) ~= 'string' then
            warn(problems, 'layout.legend must be a list of texts')
            return DEFAULT_LEGEND
        end
    end
    return raw
end

local function resolve_titles(raw, problems)
    local titles = {}
    if raw == nil then return titles end
    if type(raw) ~= 'table' then
        warn(problems, 'layout.section_titles must be a table')
        return titles
    end
    for name, title in pairs(raw) do
        local bucket = SECTION_NAMES[tostring(name):lower()]
        if not bucket or type(title) ~= 'string' then
            warn(problems, ('layout.section_titles.%s ignored'):format(tostring(name)))
        else
            titles[bucket] = title
        end
    end
    return titles
end

local function resolve_colors(raw, problems)
    local colors = {}
    for name, value in pairs(DEFAULT_COLORS) do colors[name] = value end
    if raw == nil then return colors end
    if type(raw) ~= 'table' then
        warn(problems, 'colors must be a table')
        return colors
    end
    for name, value in pairs(raw) do
        if not COLOR_NAMES[name] then
            warn(problems, ('colors.%s: unknown color'):format(tostring(name)))
        elseif value ~= nil and not valid_rgb(value) then
            warn(problems, ('colors.%s must be {r, g, b} with 0-255 values'):format(tostring(name)))
        else
            colors[name] = value
        end
    end
    return colors
end

--- chat.colors: palette colors (gray, green...) and MessageColors constants
--- (success, error...) -> FFXI chat code 1-255.
local function resolve_chat_colors(raw, problems)
    local colors = {}
    if raw == nil then return colors end
    if type(raw) ~= 'table' then
        warn(problems, 'chat.colors must be a table')
        return colors
    end
    local ChatPalette = require('shared/utils/messages/chat_palette')
    local MessageColors = require('shared/utils/messages/message_colors')
    for name, code in pairs(raw) do
        local key = tostring(name):lower()
        if not ChatPalette.NAMES[key] and not MessageColors.SETTABLE[key] then
            warn(problems, ('chat.colors.%s: unknown color'):format(tostring(name)))
        elseif type(code) ~= 'number' or code < 1 or code > 255 then
            warn(problems, ('chat.colors.%s must be an FFXI chat color 1-255'):format(tostring(name)))
        else
            colors[key] = math.floor(code)
        end
    end
    return colors
end

--- A number within [low, high] from the chat table, or nil (+ warning).
local function chat_number(raw, name, low, high, problems)
    local n = raw[name]
    if n == nil then return nil end
    if type(n) == 'number' and n >= low and n <= high then return math.floor(n) end
    warn(problems, ('chat.%s must be a number from %d to %d'):format(name, low, high))
    return nil
end

--- The separator character: plain characters only.
local function chat_separator_char(raw, problems)
    local char = raw.separator_char
    if char == nil then return '=' end
    -- ASCII only: FFXI's chat does not render UTF-8 (a "─" prints as garbage)
    if type(char) == 'string' and char ~= '' and not char:find('[\128-\255]') then return char end
    warn(problems, 'chat.separator_char must be plain characters such as = - * ~ #')
    return '='
end

local function resolve_chat(raw, problems)
    if raw ~= nil and type(raw) ~= 'table' then
        warn(problems, 'chat must be a table')
        raw = nil
    end
    raw = raw or {}
    return {
        separators = raw.separators ~= false,
        separator_char = chat_separator_char(raw, problems),
        separator_color = chat_number(raw, 'separator_color', 1, 255, problems),
        width = chat_number(raw, 'width', 20, 150, problems),
        job_tag = raw.job_tag ~= false,
        colors = resolve_chat_colors(raw.colors, problems),
    }
end

--- A whole-number option within [low, high], or `fallback` when unset or wrong.
local function resolve_number(raw, name, low, high, fallback, problems)
    local n = raw[name]
    if n == nil then return fallback end
    if type(n) ~= 'number' or n < low or n > high then
        warn(problems, ('layout.%s must be a number from %d to %d'):format(name, low, high))
        return fallback
    end
    return math.floor(n)
end

--- Spacing of the chosen layout, with the player's values on top:
--- column_gap = key -> label, value_gap = label -> value (defaults to
--- column_gap when only that one is set), margin_top/margin_bottom = blank
--- lines above/below the rows, margin_side = spaces left and right of the rows,
--- padding = pixels of background around the text.
local function resolve_spacing(raw, problems)
    local base = raw.compact and SPACING.compact or SPACING.normal
    local gap = resolve_number(raw, 'column_gap', 1, 10, base.gap, problems)
    local value_fallback = raw.column_gap ~= nil and gap or base.gap_value
    local side_left = resolve_number(raw, 'margin_side', 0, 3, base.left, problems)
    local side_right = raw.margin_side ~= nil and side_left or base.right
    return {
        left = side_left, right = side_right, title_gap = base.title_gap,
        gap = gap,
        gap_value = resolve_number(raw, 'value_gap', 1, 10, value_fallback, problems),
        margin_top = resolve_number(raw, 'margin_top', 0, 3, base.margin_top, problems),
        margin_bottom = resolve_number(raw, 'margin_bottom', 0, 3, base.margin_bottom, problems),
        -- Exact geometry: no final newline, and widths counted in displayed
        -- characters ("●" is 3 bytes, one column). The standard layout keeps
        -- its historical slack; compact or a player-set margin gets exact.
        exact = raw.compact == true or raw.margin_bottom ~= nil or raw.margin_side ~= nil,
        padding = resolve_number(raw, 'padding', 0, 20, base.padding, problems),
    }
end

local function resolve_layout(raw, problems)
    if raw ~= nil and type(raw) ~= 'table' then
        warn(problems, 'layout must be a table')
        raw = nil
    end
    raw = raw or {}
    local key_style = raw.key_style or 'symbols'
    if key_style ~= 'symbols' and key_style ~= 'words' then
        warn(problems, ('layout.key_style "%s": use "symbols" or "words"'):format(tostring(key_style)))
        key_style = 'symbols'
    end
    local bullet = raw.bullet or '●'
    if type(bullet) ~= 'string' then
        warn(problems, 'layout.bullet must be a text')
        bullet = '●'
    end
    bullet = BULLETS[bullet:lower()] or bullet
    return {
        section_order = resolve_order(raw.section_order, problems),
        spacing = resolve_spacing(raw, problems),
        move_to_section = resolve_moves(raw.move_to_section, problems),
        hide_rows = resolve_set(raw.hide_rows, 'layout.hide_rows', problems),
        row_order = resolve_row_order(raw.row_order, problems),
        section_titles = resolve_titles(raw.section_titles, problems),
        legend = resolve_legend(raw.legend, problems),
        key_style = key_style,
        bullet = bullet,
    }
end

local function report(problems)
    if #problems == 0 then return end
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if not ok or not MessageFormatter or not MessageFormatter.show_warning then return end
    for _, problem in ipairs(problems) do
        MessageFormatter.show_warning('UI_CONFIG.lua: ' .. problem .. ' (default used)')
    end
end

---============================================================================
--- PUBLIC API
---============================================================================

--- The resolved style. Re-resolved only when UI_CONFIG.lua was reloaded
--- (a new _G.UIConfig table), so problems are reported once per load.
--- @return table {layout = {...}, colors = {...}, chat = {...}}
function UIStyle.get()
    local source = rawget(_G, 'UIConfig') or {}
    if cache and cache_source == source then return cache end
    local style, problems = UIStyle.resolve(source)
    cache, cache_source = style, source
    report(problems)
    return cache
end

--- Resolve a config table without touching the cache or the chat: used to
--- check a value typed in game before it is applied.
--- @param source table A UI_CONFIG-shaped table
--- @return table style
--- @return table problems List of problem texts (empty when all is valid)
function UIStyle.resolve(source)
    local problems = {}
    local style = {
        layout = resolve_layout(source.layout, problems),
        colors = resolve_colors(source.colors, problems),
        chat = resolve_chat(source.chat, problems),
    }
    return style, problems
end

--- Forget the resolved style: the next get() reads _G.UIConfig again. For a
--- change made in place (in-game ui commands keep the same table).
function UIStyle.invalidate()
    cache, cache_source = nil, nil
end

--- "\\cs(r,g,b)" for a style color, or `fallback` when the color is unset.
--- @param name string Color name (key, description, section_title...)
--- @param fallback string|nil Returned when the color is nil
--- @return string
function UIStyle.color(name, fallback)
    local rgb = UIStyle.get().colors[name]
    if not rgb then return fallback or '' end
    return ('\\cs(%d,%d,%d)'):format(rgb[1], rgb[2], rgb[3])
end

--- The key as the HUD shows it: "^f1", or "CTRL+F1" with key_style words.
--- @param key string Windower key
--- @return string
function UIStyle.display_key(key)
    if not key or key == '' or UIStyle.get().layout.key_style ~= 'words' then
        return key
    end
    local ok, MessageCore = pcall(require, 'shared/utils/messages/message_core')
    if not ok or not MessageCore.convert_key_display then return key end
    return MessageCore.convert_key_display(key)
end

--- Rows the player did not hide (layout.hide_rows names a state or a key).
--- @param keybinds table List of bind entries
--- @return table The same list when nothing is hidden, else a filtered copy
function UIStyle.visible_rows(keybinds)
    local hidden = UIStyle.get().layout.hide_rows
    if next(hidden) == nil then return keybinds end
    local shown = {}
    for _, bind in ipairs(keybinds) do
        if not (bind.state and hidden[bind.state]) and not (bind.key and hidden[bind.key]) then
            shown[#shown + 1] = bind
        end
    end
    return shown
end

--- Rows in the player's order (layout.row_order): the rows it names come
--- first, in its order; the others keep the file order after them. Each
--- section keeps only its own rows, so this orders every section at once.
--- @param keybinds table List of bind entries
--- @return table The same list when no order is set, else a sorted copy
function UIStyle.ordered_rows(keybinds)
    local rank = UIStyle.get().layout.row_order
    if next(rank) == nil then return keybinds end
    local indexed = {}
    for i, bind in ipairs(keybinds) do
        local r = (bind.state and rank[bind.state]) or (bind.key and rank[bind.key]) or math.huge
        indexed[i] = {bind = bind, rank = r, pos = i}
    end
    table.sort(indexed, function(a, b)
        if a.rank ~= b.rank then return a.rank < b.rank end
        return a.pos < b.pos
    end)
    local sorted = {}
    for i, item in ipairs(indexed) do sorted[i] = item.bind end
    return sorted
end

--- Bucket the player forced for this bind, or nil.
--- @param bind table Bind entry
--- @return string|nil spell/ja/weapon/mode
function UIStyle.forced_section(bind)
    local moves = UIStyle.get().layout.move_to_section
    return (bind.state and moves[bind.state]) or (bind.key and moves[bind.key]) or nil
end

--- Display width of a text (UTF-8 multi-byte symbols count as one).
--- @param text string
--- @return number
function UIStyle.display_len(text)
    local _, count = tostring(text):gsub('[^\128-\191]', '')
    return count
end

return UIStyle
