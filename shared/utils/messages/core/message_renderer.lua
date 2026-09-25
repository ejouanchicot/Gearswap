---============================================================================
--- Message Renderer - Smart chat output with filtering and configuration
---============================================================================
--- Last step of the template path: applies the toggle, filter level, color
--- scheme and timestamp settings, splits multi-line messages and calls
--- add_to_chat. No production caller changes any setting, so the defaults
--- below are what the player always gets.
---
--- @file shared/utils/messages/core/message_renderer.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

local MessageRenderer = {}

---============================================================================
--- CONFIGURATION
---============================================================================

-- Global configuration
local _config = {
    enabled = true,                  -- Master toggle
    filter_level = 0,                -- 0=all, 1=important, 2=critical
    color_mode = "normal",           -- "normal", "colorblind", "monochrome"
    timestamp = false,               -- Add timestamps
    prefix_style = "brackets"        -- Not read anywhere
}

-- Color scheme definitions (accessibility)
local COLOR_SCHEMES = {
    normal = {
        -- Standard FFXI chat colors
        default = 1,
        info = 122,
        success = 158,
        warning = 200,
        error = 167,
        debug = 8,
        combat = 200,
        magic = 1,
        ability = 158
    },

    colorblind = {
        -- High contrast, color-blind friendly
        default = 1,
        info = 122,      -- Blue
        success = 122,   -- Blue instead of green
        warning = 200,   -- Purple
        error = 167,     -- Red
        debug = 8,       -- Gray
        combat = 200,
        magic = 1,
        ability = 122
    },

    monochrome = {
        -- For players who prefer no colors
        default = 1,
        info = 1,
        success = 1,
        warning = 8,
        error = 8,
        debug = 8,
        combat = 1,
        magic = 1,
        ability = 1
    }
}

-- Statistics tracking
local _stats = {
    total_sent = 0,
    by_namespace = {},
    by_color = {},
    errors = 0
}

---============================================================================
--- RENDERING FUNCTIONS
---============================================================================

--- Send message to chat with rendering options
--- @param message string The formatted message
--- @param color number FFXI color code
--- @param options table? {level = number (filter level), namespace = string (stats)}
function MessageRenderer.send(message, color, options)
    options = options or {}

    -- Check if enabled (master toggle)
    if not _config.enabled then
        return
    end

    -- Check filter level
    local level = options.level or 0
    if level < _config.filter_level then
        return -- Filtered out
    end

    -- Apply color scheme transformation
    if _config.color_mode ~= "normal" then
        color = MessageRenderer.transform_color(color)
    end

    -- Ensure message is a string
    message = tostring(message)

    -- Add timestamp if enabled
    if _config.timestamp then
        local time = os.date("%H:%M:%S")
        message = string.format("[%s] %s", time, message)
    end

    -- One add_to_chat per line (fixes FFXI alignment issues with \n).
    -- Empty lines are dropped: templates use "\n \n" for a blank line.
    if message:find("\n") then
        local lines = {}
        for line in message:gmatch("[^\n]+") do
            table.insert(lines, line)
        end

        for _, line in ipairs(lines) do
            add_to_chat(color, line)
        end
    else
        add_to_chat(color, message)
    end

    -- Update statistics
    _stats.total_sent = _stats.total_sent + 1

    if options.namespace then
        _stats.by_namespace[options.namespace] = (_stats.by_namespace[options.namespace] or 0) + 1
    end

    _stats.by_color[color] = (_stats.by_color[color] or 0) + 1
end

--- Transform color code based on current color scheme
--- @param color number Original color
--- @return number Transformed color
function MessageRenderer.transform_color(color)
    local scheme = COLOR_SCHEMES[_config.color_mode]
    if not scheme then
        return color
    end

    -- Map common colors to semantic types
    local color_map = {
        [1] = scheme.default,
        [8] = scheme.debug,
        [122] = scheme.info,
        [158] = scheme.success,
        [167] = scheme.error,
        [200] = scheme.warning
    }

    return color_map[color] or color
end

---============================================================================
--- CONFIGURATION API
---============================================================================

--- Configure renderer settings
--- @param config table Configuration options
function MessageRenderer.configure(config)
    for key, value in pairs(config) do
        if _config[key] ~= nil then
            _config[key] = value
        end
    end
end

--- Get current configuration
--- @return table Current config
function MessageRenderer.get_config()
    return _config
end

--- Toggle all messages on/off
--- @return boolean New state
function MessageRenderer.toggle()
    _config.enabled = not _config.enabled

    local status = _config.enabled and "enabled" or "disabled"
    add_to_chat(158, "[Messages] System " .. status)

    return _config.enabled
end

--- Set filter level
--- @param level number 0=all, 1=important, 2=critical
function MessageRenderer.set_filter_level(level)
    _config.filter_level = level

    local levels = {"all", "important", "critical"}
    add_to_chat(158, string.format(
        "[Messages] Filter level: %s",
        levels[level + 1] or "unknown"
    ))
end

--- Set color mode
--- @param mode string "normal", "colorblind", "monochrome"
function MessageRenderer.set_color_mode(mode)
    if not COLOR_SCHEMES[mode] then
        add_to_chat(167, "[Messages] Unknown color mode: " .. mode)
        return
    end

    _config.color_mode = mode
    add_to_chat(158, "[Messages] Color mode: " .. mode)
end

--- Toggle timestamps
--- @return boolean New state
function MessageRenderer.toggle_timestamp()
    _config.timestamp = not _config.timestamp

    local status = _config.timestamp and "enabled" or "disabled"
    add_to_chat(158, "[Messages] Timestamps " .. status)

    return _config.timestamp
end

---============================================================================
--- STATISTICS & DEBUGGING
---============================================================================

--- Reset statistics
function MessageRenderer.reset_stats()
    _stats = {
        total_sent = 0,
        by_namespace = {},
        by_color = {},
        errors = 0
    }
    add_to_chat(158, "[Messages] Statistics reset")
end

---============================================================================
--- ERROR HANDLING
---============================================================================

--- Show error message
--- @param error_msg string Error message
function MessageRenderer.show_error(error_msg)
    _stats.errors = _stats.errors + 1
    add_to_chat(167, "[MessageSystem ERROR] " .. error_msg)
end

return MessageRenderer
