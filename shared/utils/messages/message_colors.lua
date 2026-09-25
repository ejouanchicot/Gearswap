---============================================================================
--- Message Colors - Centralized Color Configuration for All Messages
---============================================================================
--- Central configuration for all color codes used in the messaging system.
--- This ensures consistency across all message types and makes it easy to
--- adjust colors globally.
---
--- REGION-SPECIFIC COLORS:
--- Orange/Warning color codes differ by FFXI region (POL account):
---   US Region (NBCP): Code 057 = Orange
---   EU Region (BQJS): Code 003 = Orange equivalent for EU
---   JP Region: Code 057 = Orange
---
--- Region is configured in <Char>/config/REGION_CONFIG.lua (exposed by the
--- entry point as _G.RegionConfig). Users add their character name to that
--- file to set their region.
---
--- _G.ORANGE_COLOR_CODE and _G.DETECTED_FFXI_REGION are also honored as
--- overrides, but nothing sets them: //gs c setregion is not implemented.
---
--- @file shared/utils/messages/message_colors.lua
--- @author Tetsouo
--- @version 1.3
--- @date Created: 2025-10-02 | Updated: 2025-10-12 - Added config-based region detection
---============================================================================

local MessageColors = {}

-- Read once at require time: _G.RegionConfig must already be set when this
-- module is first required.
local RegionConfig = _G.RegionConfig or {}

---============================================================================
--- REGION DETECTION
---============================================================================

--- Get orange/warning color code based on detected region
--- @return number warning_code Region-specific warning color code
local function get_region_orange()
    -- Priority 1: explicit color override (no setter exists today)
    if _G.ORANGE_COLOR_CODE then
        return _G.ORANGE_COLOR_CODE
    end

    -- Priority 2: explicit region override (no setter exists today)
    if _G.DETECTED_FFXI_REGION then
        if _G.DETECTED_FFXI_REGION == "EU" then
            return 003  -- Orange equivalent for EU
        else
            return 057  -- Orange (US/JP)
        end
    end

    -- Priority 3: <Char>/config/REGION_CONFIG.lua
    if RegionConfig and RegionConfig.get_region and player and player.name then
        local region = RegionConfig.get_region(player.name)
        if RegionConfig.get_orange_code then
            return RegionConfig.get_orange_code(region)
        end
    end

    -- Priority 4: Default to US (most common)
    return 057
end

--- Record which orange this load ended up with (//gs c trace).
--- @param code number
local function trace_region(code)
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok and Trace then
        local region = RegionConfig and RegionConfig.get_region and player and player.name
            and RegionConfig.get_region(player.name)
        Trace.log('REGION', 'orange %s (RegionConfig loaded at require: %s, region %s, _G.RegionConfig now %s)',
            code, RegionConfig.get_region ~= nil, region, rawget(_G, 'RegionConfig') ~= nil)
    end
end

---============================================================================
--- FLAT COLOR DEFINITIONS (all at root level for easy access)
---============================================================================

-- Standard codes. MessageColors.X reads them through the metatable below,
-- so the player's chat.colors (UI_CONFIG.lua) can replace any of them.
local DEFAULTS = {}

-- Action types
DEFAULTS.SPELL = 205          -- Cyan - Magic spells
DEFAULTS.JA = 50              -- Yellow - Job Abilities
DEFAULTS.WS = 50              -- Yellow - Weapon Skills
DEFAULTS.ITEM_COLOR = 211     -- Item color - All items

-- UI Elements
DEFAULTS.SEPARATOR = 160      -- Gray - Separators, info text
DEFAULTS.GRAY = 160           -- Gray - Alias for SEPARATOR
DEFAULTS.JOB_TAG = 207        -- Light Blue - Job tags [WAR]
DEFAULTS.HEADER = 207         -- Light Blue - Headers
DEFAULTS.INFO_HEADER = 207    -- Light Blue - Info headers (alias)
DEFAULTS.INFO = 158           -- Green - Info text/counts

-- Status/States
DEFAULTS.SUCCESS = 158        -- Green - Success, Ready, Active
DEFAULTS.ERROR = 167          -- Red - Errors
DEFAULTS.WARNING = get_region_orange()  -- Region-specific Orange - Warnings
trace_region(DEFAULTS.WARNING)
DEFAULTS.DEBUFF = 208         -- Purple - Debuffs
DEFAULTS.READY = 158          -- Green - Ready state
DEFAULTS.ACTIVE = 158         -- Green - Active state
DEFAULTS.COOLDOWN = 125       -- Dark red - Cooldown timers
DEFAULTS.BLOCKED = 167        -- Red - Blocked actions
DEFAULTS.WS_BLOCKED = 200     -- Orange - WS blocked
DEFAULTS.RANGE_ERROR = 167    -- Red - Range errors

-- TP Colors
DEFAULTS.TP_NORMAL = 1        -- White - 1000-1999 TP
DEFAULTS.TP_ENHANCED = 207    -- Light Blue - 2000-2999 TP
DEFAULTS.TP_ULTIMATE = 158    -- Green - 3000 TP
DEFAULTS.TP_LABEL = 160       -- Gray - TP label

-- System/Keybinds
DEFAULTS.SYSTEM_LOADED = 207  -- Light Blue - System loaded messages
DEFAULTS.KEYBIND_KEY = 158    -- Green - Keybind keys
DEFAULTS.KEYBIND_DESC = 160   -- Gray - Keybind descriptions

--- Palette color each constant follows when the player remaps that color
--- (chat.colors.green = N also changes SUCCESS, READY...). Constants with no
--- palette color of the same code (SPELL 205, ITEM_COLOR 211, COOLDOWN 125,
--- WS_BLOCKED 200) only change when set by their own name.
local FOLLOWS = {
    JA = 'yellow', WS = 'yellow',
    SEPARATOR = 'gray', GRAY = 'gray', TP_LABEL = 'gray', KEYBIND_DESC = 'gray',
    JOB_TAG = 'lightblue', HEADER = 'lightblue', INFO_HEADER = 'lightblue',
    TP_ENHANCED = 'lightblue', SYSTEM_LOADED = 'lightblue',
    INFO = 'green', SUCCESS = 'green', READY = 'green', ACTIVE = 'green',
    TP_ULTIMATE = 'green', KEYBIND_KEY = 'green',
    ERROR = 'red', BLOCKED = 'red', RANGE_ERROR = 'red',
    WARNING = 'orange', DEBUFF = 'purple', TP_NORMAL = 'white',
}

--- Constant names a player can set in chat.colors (lowercase: success...).
MessageColors.SETTABLE = {}
for name in pairs(DEFAULTS) do MessageColors.SETTABLE[name:lower()] = true end

local function player_colors()
    local ok, ChatPalette = pcall(require, 'shared/utils/messages/chat_palette')
    return ok and ChatPalette and ChatPalette.overrides() or {}
end

-- MessageColors.SUCCESS etc.: the player's own code for that name, else the
-- code of the palette color it follows when the player remapped it, else
-- the standard code. Read at each use, like before (callers never cached).
setmetatable(MessageColors, {__index = function(_, key)
    local default = DEFAULTS[key]
    if default == nil then return nil end
    local colors = player_colors()
    local own = colors[key:lower()]
    if own then return own end
    local follows = FOLLOWS[key]
    if follows and colors[follows] then return colors[follows] end
    return default
end})

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get color code for an action type
--- @param action_type string Action type ("Magic", "Ability", "WeaponSkill", "Item")
--- @return number color_code The color code for the action type
function MessageColors.get_action_color(action_type)
    if not action_type then
        return MessageColors.ITEM_COLOR
    end

    local action_lower = action_type:lower()

    if action_lower:find("magic") or action_lower:find("spell") then
        return MessageColors.SPELL
    elseif action_lower:find("ability") or action_lower:find("ja") then
        return MessageColors.JA
    elseif action_lower:find("weapon") or action_lower:find("ws") then
        return MessageColors.WS
    elseif action_lower:find("item") then
        return MessageColors.ITEM_COLOR
    else
        return MessageColors.ITEM_COLOR
    end
end

--- Get color code for TP value
--- @param tp number TP value
--- @return number color_code The color code for the TP value
function MessageColors.get_tp_color(tp)
    if tp >= 3000 then
        return MessageColors.TP_ULTIMATE
    elseif tp >= 2000 then
        return MessageColors.TP_ENHANCED
    else
        return MessageColors.TP_NORMAL
    end
end

--- Get current orange/warning color dynamically (for runtime calls)
--- @return number warning_code Current region-specific warning color
function MessageColors.get_warning_color()
    local colors = player_colors()
    return colors.warning or colors.orange or get_region_orange()
end

--- The region's orange, ignoring the player's colors (standard for the
--- palette's orange: reading WARNING there would loop back to the palette).
--- @return number
function MessageColors.region_orange()
    return get_region_orange()
end

return MessageColors
