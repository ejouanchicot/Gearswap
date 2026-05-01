---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - In-Game Chat Messages
---  ═══════════════════════════════════════════════════════════════════════════
---   FFXI-chat helpers following the project's style conventions:
---     - 74-char width, ASCII pure
---     - Centered titles inside the separator (===== Title =====)
---     - --- sub-section dividers
---     - [Wardrobe] tag prefix on info lines
---     - Inline color codes via 0x1F
---
---   Public functions:
---     Chat.separator()                 - 74-char gray '=' rule
---     Chat.divider()                   - 74-char gray '-' rule (sub-section)
---     Chat.banner(title)               - sep + centered title + sep
---     Chat.section(name)               - "--- name ---" sub-section
---     Chat.info(message)               - cyan info line
---     Chat.success(message)            - green success line
---     Chat.error(message)              - red error line
---     Chat.warn(message)               - orange warning line
---     Chat.phase(num, label, info)     - phase progress arrow line
---     Chat.detail(label, value)        - "  label : value" aligned row
---     Chat.kv(label, value)            - alias for detail
---
---   @file shared/utils/wardrobe/lib/chat.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')

local Chat = {}

-- Inline FFXI color codes (string.char(0x1F, color_id))
local C = {
    gray   = string.char(0x1F, 160),
    yellow = string.char(0x1F, 50),
    green  = string.char(0x1F, 158),
    red    = string.char(0x1F, 167),
    cyan   = string.char(0x1F, 121),
    white  = string.char(0x1F, 1),
    orange = string.char(0x1F, 205),
}
Chat.C = C

local CHANNEL = 121
local TAG     = Config.CHAT_TAG
local WIDTH   = Config.SEP_LEN
local SEP     = string.rep('=', WIDTH)

---  ═══════════════════════════════════════════════════════════════════════════
---   PRIMITIVES
---  ═══════════════════════════════════════════════════════════════════════════

--- Full-width gray '=' separator.
function Chat.separator()
    windower.add_to_chat(CHANNEL, C.gray .. SEP)
end

--- Full-width gray '-' divider for sub-sections.
function Chat.divider()
    windower.add_to_chat(CHANNEL, C.gray .. string.rep('-', WIDTH))
end

--- Banner panel: a single line with the title centered between '=' chars
--- (matches MessageKeybinds pattern: `===== Title =====`).
--- Total width is 74 chars. Title is wrapped in spaces for visual breathing.
function Chat.banner(title)
    local padded    = ' ' .. title .. ' '
    local total_pad = math.max(2, WIDTH - #padded)
    local left      = math.floor(total_pad / 2)
    local right     = total_pad - left
    windower.add_to_chat(CHANNEL,
        C.gray   .. string.rep('=', left) ..
        C.yellow .. padded ..
        C.gray   .. string.rep('=', right))
end

--- Sub-section: `--- name ---` left-aligned, dim gray.
function Chat.section(name)
    local padded = ' ' .. name .. ' '
    local right_pad = math.max(3, WIDTH - 3 - #padded)
    windower.add_to_chat(CHANNEL,
        C.gray .. '--- ' .. C.cyan .. name .. C.gray .. ' ' .. string.rep('-', right_pad))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATUS LINES  (with [Wardrobe] tag prefix)
---  ═══════════════════════════════════════════════════════════════════════════

local function tagged(color, message)
    return C.gray .. '[' .. C.cyan .. TAG .. C.gray .. ']' .. C.white .. ' ' .. color .. message
end

function Chat.info(message)
    windower.add_to_chat(CHANNEL, tagged(C.white, message))
end

function Chat.success(message)
    windower.add_to_chat(158, tagged(C.green, message))
end

function Chat.error(message)
    windower.add_to_chat(167, tagged(C.red, 'Error: ' .. C.white .. message))
end

function Chat.warn(message)
    windower.add_to_chat(205, tagged(C.orange, message))
end

--- Like error, but WITHOUT the "Error:" prefix - used for blocking notices
--- (e.g. "PROCESSING - do not move") that need maximum visual urgency.
function Chat.alert(message)
    windower.add_to_chat(167, tagged(C.red, message))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PHASE PROGRESS  (compact arrow style)
---  ═══════════════════════════════════════════════════════════════════════════

--- Phase progress: "[Wardrobe] >> Phase N  label  (info)"
--- @param phase_num number  Phase number (0-4)
--- @param label string      Phase description
--- @param info string|nil   Optional details
function Chat.phase(phase_num, label, info)
    local arrow = C.cyan .. '>>' .. C.white
    local pnum  = C.yellow .. ('Phase %d'):format(phase_num)
    local lbl   = C.white .. label
    local extra = info and (C.gray .. '  (' .. C.green .. info .. C.gray .. ')') or ''
    windower.add_to_chat(CHANNEL,
        C.gray .. '[' .. C.cyan .. TAG .. C.gray .. '] ' ..
        arrow .. ' ' .. pnum .. C.gray .. '  ' .. lbl .. extra)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STRUCTURED ROWS  (panel content)
---  ═══════════════════════════════════════════════════════════════════════════

--- Detail row: "  label ........... value" (dot-leader, 24-char label column).
--- Tighter label-aligned format than the previous fixed-width approach.
function Chat.detail(label, value)
    local label_str = tostring(label)
    local pad_count = math.max(3, 26 - #label_str)
    local pad = string.rep('.', pad_count)
    windower.add_to_chat(CHANNEL,
        '  ' .. C.cyan .. label_str .. ' ' ..
        C.gray .. pad .. ' ' ..
        C.green .. tostring(value))
end

-- Alias (some sites read more naturally as kv)
Chat.kv = Chat.detail

return Chat
