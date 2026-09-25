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

-- Action types
MessageColors.SPELL = 205          -- Cyan - Magic spells
MessageColors.JA = 50              -- Yellow - Job Abilities
MessageColors.WS = 50              -- Yellow - Weapon Skills
MessageColors.ITEM_COLOR = 211     -- Item color - All items

-- UI Elements
MessageColors.SEPARATOR = 160      -- Gray - Separators, info text
MessageColors.GRAY = 160           -- Gray - Alias for SEPARATOR
MessageColors.JOB_TAG = 207        -- Light Blue - Job tags [WAR]
MessageColors.HEADER = 207         -- Light Blue - Headers
MessageColors.INFO_HEADER = 207    -- Light Blue - Info headers (alias)
MessageColors.INFO = 158           -- Green - Info text/counts

-- Status/States
MessageColors.SUCCESS = 158        -- Green - Success, Ready, Active
MessageColors.ERROR = 167          -- Red - Errors
MessageColors.WARNING = get_region_orange()  -- Region-specific Orange - Warnings
trace_region(MessageColors.WARNING)
MessageColors.DEBUFF = 208         -- Purple - Debuffs
MessageColors.READY = 158          -- Green - Ready state
MessageColors.ACTIVE = 158         -- Green - Active state
MessageColors.COOLDOWN = 125       -- Dark red - Cooldown timers
MessageColors.BLOCKED = 167        -- Red - Blocked actions
MessageColors.WS_BLOCKED = 200     -- Orange - WS blocked
MessageColors.RANGE_ERROR = 167    -- Red - Range errors

-- TP Colors
MessageColors.TP_NORMAL = 1        -- White - 1000-1999 TP
MessageColors.TP_ENHANCED = 207    -- Light Blue - 2000-2999 TP
MessageColors.TP_ULTIMATE = 158    -- Green - 3000 TP
MessageColors.TP_LABEL = 160       -- Gray - TP label

-- System/Keybinds
MessageColors.SYSTEM_LOADED = 207  -- Light Blue - System loaded messages
MessageColors.KEYBIND_KEY = 158    -- Green - Keybind keys
MessageColors.KEYBIND_DESC = 160   -- Gray - Keybind descriptions

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
    return get_region_orange()
end

return MessageColors
