---============================================================================
--- Chat Palette - the named chat colors, with the player's overrides
---============================================================================
--- One place for the chat colors that have a name: the message engine's
--- template tags ({gray}, {green}...), the MessageColors constants
--- (SUCCESS, ERROR...) and the formatters that used to write the raw code.
---
--- The player remaps a color in UI_CONFIG.lua (`chat.colors`) or in game
--- (//gs c ui chatcolor green 204):
---   green = 204      every green in the chat
---   success = 204    only what MessageColors calls SUCCESS (see message_colors.lua)
--- A color left out keeps its standard code, so without overrides every
--- message is byte-identical to the fixed codes it replaces.
---
--- @file shared/utils/messages/chat_palette.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local ChatPalette = {}

--- Standard FFXI chat code of each named color (the message engine's own
--- codes). Orange depends on the region: read from MessageColors.
local BASE = {
    cyan = 13, lightblue = 207, white = 1, gray = 160, darkgray = 8,
    green = 158, red = 167, yellow = 50, pink = 11, healgreen = 6,
    enhancing = 206, enfeebling = 4, divine = 22, dark = 15, bluemagic = 219,
    blue = 122, purple = 208, itemcolor = 63, orange = false,
    -- Help screens (//gs c help, tb help, ui help)
    gold = 220, aqua = 159, mustard = 36, amber = 68,
}

--- Tags that are another color under a second name. They follow that color
--- unless the player sets them on their own.
local ALIASES = {
    jobtag = 'lightblue', separatorcolor = 'gray', spellcolor = 'cyan', warningcolor = 'orange',
}

--- Every name accepted as a palette color (BASE + ALIASES).
ChatPalette.NAMES = {}
for name in pairs(BASE) do ChatPalette.NAMES[name] = true end
for name in pairs(ALIASES) do ChatPalette.NAMES[name] = true end

--- The player's overrides (chat.colors), or an empty table.
--- @return table name -> code
function ChatPalette.overrides()
    local ok, UIStyle = pcall(require, 'shared/utils/ui/ui_style')
    if not ok or not UIStyle then return {} end
    local ok_get, style = pcall(UIStyle.get)
    return ok_get and style and style.chat and style.chat.colors or {}
end

local function standard(name)
    if name == 'orange' then
        local MessageColors = require('shared/utils/messages/message_colors')
        return MessageColors.region_orange()
    end
    return BASE[name]
end

--- Chat code of a named color: the player's code when set, else the
--- standard one. An alias follows its color unless set itself.
--- @param name string Palette name ("gray", "jobtag"...)
--- @return number|nil Code, nil for an unknown name
function ChatPalette.code(name)
    local overrides = ChatPalette.overrides()
    if overrides[name] then return overrides[name] end
    local base = ALIASES[name]
    if base then return ChatPalette.code(base) end
    return standard(name)
end

--- Inline chat color code (0x1F + code) of a named color.
--- @param name string Palette name
--- @return string
function ChatPalette.tag(name)
    return string.char(0x1F, ChatPalette.code(name) or 1)
end

---============================================================================
--- JOB TAG ([RDM/DRK] in front of messages)
---============================================================================

--- False when the player turned the job tag off (chat.job_tag = false).
--- @return boolean
function ChatPalette.show_job_tag()
    local ok, UIStyle = pcall(require, 'shared/utils/ui/ui_style')
    if not ok or not UIStyle then return true end
    local ok_get, style = pcall(UIStyle.get)
    return not (ok_get and style and style.chat and style.chat.job_tag == false)
end

--- A template without its job tag:
---   "[{job}] "          (color tags aside) goes, with its trailing space
---   "[{job} Phalanx]"   becomes "[Phalanx]"
--- "[{job}_COMMANDS]" or "Main Job: {job}" are text, not a tag, and stay.
--- @param template string
--- @return string
function ChatPalette.strip_job_tag(template)
    return (template:gsub('(%b[])( ?)', function(bracket, space)
        local inner = bracket:sub(2, -2):gsub('{(%w+)}', function(name)
            return ChatPalette.NAMES[name] and '' or '{' .. name .. '}'
        end)
        if inner == '{job}' or inner == '{job_tag}' then return '' end
        if inner:find('^{job} ') or inner:find('^{job_tag} ') then
            return (bracket:gsub('{job_?t?a?g?} ', '', 1)) .. space
        end
        return nil
    end))
end

return ChatPalette
