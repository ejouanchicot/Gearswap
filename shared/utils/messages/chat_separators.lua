---============================================================================
--- Chat Separators - the player's separator options on every chat line
---============================================================================
--- UI_CONFIG.lua `chat` (//gs c ui separators / sepchar / sepcolor /
--- chatwidth) chooses whether separator lines are shown, their character,
--- color and width. Separators are written by many modules: the message
--- templates, InfoBlock, HelpScreen, formatters that build their own lines,
--- and diagnostic tools that write to the chat themselves. Rather than
--- relying on each of them, every chat line passes through apply():
---
---   "=====...", "-----..."        a separator line: dropped when separators
---                                  are off, else redrawn with the player's
---                                  character and color; a full-width line
---                                  (69 or more) follows chat.width
---   "===== TITLE =====",
---   "--- name --------"           a framed title: the runs of 3+ separator
---                                  characters are dropped when off, else
---                                  redrawn with the player's character
---   anything else                 unchanged
---
--- With the standard options (on, "=", no color, width 69) every line is
--- returned untouched.
---
--- @file    shared/utils/messages/chat_separators.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-27
---============================================================================

local ChatSeparators = {}

local SEP_CLASS = '[=%-~%*#_]'
local RUN = SEP_CLASS .. SEP_CLASS .. SEP_CLASS .. '+'
local DEFAULT_WIDTH = 69

--- The player's chat options, or nil when they are the standard ones.
local function options()
    local ok, UIStyle = pcall(require, 'shared/utils/ui/ui_style')
    if not ok or not UIStyle or not UIStyle.get then return nil end
    local chat = UIStyle.get().chat or {}
    local char = chat.separator_char or '='
    local width = chat.width or DEFAULT_WIDTH
    if chat.separators ~= false and char == '=' and not chat.separator_color and width == DEFAULT_WIDTH then
        return nil
    end
    return {on = chat.separators ~= false, char = char, color = chat.separator_color, width = width}
end

--- Split a chat line into color codes (0x1E / 0x1F + one byte) and text.
--- @param text string
--- @return table Array of {code = s} / {text = s}
local function segments(text)
    local out, i = {}, 1
    while i <= #text do
        local b = text:byte(i)
        if b == 30 or b == 31 then
            out[#out + 1] = {code = text:sub(i, i + 1)}
            i = i + 2
        else
            local j = i
            while j <= #text and text:byte(j) ~= 30 and text:byte(j) ~= 31 do j = j + 1 end
            out[#out + 1] = {text = text:sub(i, j - 1)}
            i = j
        end
    end
    return out
end

local function plain_of(parts)
    local out = {}
    for _, p in ipairs(parts) do out[#out + 1] = p.text or '' end
    return table.concat(out)
end

--- `char` repeated to `n` characters (a multi-character choice is cut).
local function rule(char, n)
    return string.rep(char, math.ceil(n / #char)):sub(1, n)
end

--- A separator line redrawn: its first color (or the player's), the
--- player's character, full width when it was full width.
local function redraw_line(parts, length, opts)
    local color = opts.color and string.char(0x1F, opts.color) or ''
    if color == '' then
        for _, p in ipairs(parts) do
            if p.code then color = p.code break end
        end
    end
    local n = length >= DEFAULT_WIDTH and opts.width or length
    return color .. rule(opts.char, n)
end

--- Index of the text segment holding the title's last separator run.
local function last_run_segment(parts)
    for i = #parts, 1, -1 do
        if parts[i].text and parts[i].text:find(RUN) then return i end
    end
end

--- A framed title: separator runs dropped (off) or redrawn with the
--- player's character; a full-width title follows chat.width through its
--- last run.
local function redraw_title(parts, opts, length)
    local out, last = {}, last_run_segment(parts)
    local delta = length >= DEFAULT_WIDTH and (opts.width - length) or 0
    for i, p in ipairs(parts) do
        if p.code then
            out[#out + 1] = p.code
        elseif opts.on then
            local text = p.text:gsub(RUN, function(run) return rule(opts.char, #run) end)
            if i == last and delta ~= 0 then
                text = text:gsub('(' .. RUN .. ')(%s*)$', function(run, tail)
                    return rule(opts.char, math.max(3, #run + delta)) .. tail
                end)
            end
            out[#out + 1] = text
        else
            out[#out + 1] = (p.text:gsub('%s*' .. RUN .. '%s*', ' '))
        end
    end
    local line = table.concat(out)
    if not opts.on then line = '  ' .. line:gsub('^%s+', ''):gsub('%s+$', '') end
    return line
end

--- The chat line as the player's separator options want it.
--- @param text any The line about to be written
--- @return any The line to write, or nil to write nothing
function ChatSeparators.apply(text)
    if type(text) ~= 'string' or not text:find(SEP_CLASS .. SEP_CLASS .. SEP_CLASS) then return text end
    local opts = options()
    if not opts then return text end
    local parts = segments(text)
    local trimmed = plain_of(parts):match('^%s*(.-)%s*$')
    if #trimmed >= 5 and not trimmed:find('[^=%-~%*#_]') then
        if not opts.on then return nil end
        return redraw_line(parts, #trimmed, opts)
    end
    if trimmed:find('^' .. RUN .. '%s') and trimmed:find('%s' .. RUN .. '$') then
        return redraw_title(parts, opts, #plain_of(parts))
    end
    return text
end

return ChatSeparators
