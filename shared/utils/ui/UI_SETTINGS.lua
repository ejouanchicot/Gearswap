---============================================================================
--- Keybind UI Settings - Position persistence in UI_CONFIG.lua
---============================================================================

local KeybindSettings = {}

-- Settings file path (UI_CONFIG.lua)
local function get_config_file()
    -- Detect character name from player data
    local char_name = player and player.name or 'Tetsouo'

    -- Build absolute path to UI_CONFIG.lua for this character
    local config_path = windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/UI_CONFIG.lua'

    -- Verify file exists, fallback to Tetsouo if not found
    local file = io.open(config_path, 'r')
    if file then
        file:close()
        return config_path
    else
        -- Fallback to Tetsouo
        return windower.windower_path .. 'addons/GearSwap/data/Tetsouo/config/UI_CONFIG.lua'
    end
end

--- Load settings from UI_CONFIG
function KeybindSettings.load()
    -- Use _G.UIConfig (loaded from main file)
    -- Note: We can't reload from file here because Windower/GearSwap environment
    -- doesn't support package.loaded manipulation. The config is loaded once
    -- at job load time and persists in _G.UIConfig
    local UIConfig = _G.UIConfig or {}

    -- Provide defaults if UIConfig not fully loaded
    local default_pos = { x = 1600, y = 300 }
    local default_bg = { r = 0, g = 0, b = 0, a = 150 }

    return {
        pos = UIConfig.default_position or default_pos,
        visible = UIConfig.enabled ~= nil and UIConfig.enabled or true,
        enabled = UIConfig.enabled ~= nil and UIConfig.enabled or true,
        show_header = UIConfig.show_header ~= nil and UIConfig.show_header or true,
        show_legend = UIConfig.show_legend ~= nil and UIConfig.show_legend or true,
        show_column_headers = UIConfig.show_column_headers ~= nil and UIConfig.show_column_headers or true,
        show_footer = UIConfig.show_footer ~= nil and UIConfig.show_footer or true,
        bg_r = UIConfig.background and UIConfig.background.r or default_bg.r,
        bg_g = UIConfig.background and UIConfig.background.g or default_bg.g,
        bg_b = UIConfig.background and UIConfig.background.b or default_bg.b,
        bg_a = UIConfig.background and UIConfig.background.a or default_bg.a,
        bg_visible = UIConfig.background and UIConfig.background.visible ~= nil and UIConfig.background.visible or true
    }
end

--- Save settings to UI_CONFIG.lua
function KeybindSettings.save(settings)
    local config_file = get_config_file()

    -- Read the entire config file
    local file = io.open(config_file, 'r')
    if not file then
        add_to_chat(167, "[UI] Error: Could not open UI_CONFIG.lua for reading")
        return false
    end

    local content = file:read("*all")
    file:close()

    -- Update default_position in the content
    local new_position = string.format("UIConfig.default_position = {\n    x = %d,\n    y = %d\n}",
        math.floor(settings.pos.x), math.floor(settings.pos.y))

    -- Replace the default_position line
    content = content:gsub("UIConfig%.default_position = %b{}", new_position)

    -- Update UI display settings if provided
    if settings.enabled ~= nil then
        content = content:gsub("UIConfig%.enabled = %a+",
            "UIConfig.enabled = " .. tostring(settings.enabled))
    end

    if settings.show_header ~= nil then
        content = content:gsub("UIConfig%.show_header = %a+",
            "UIConfig.show_header = " .. tostring(settings.show_header))
    end

    if settings.show_legend ~= nil then
        content = content:gsub("UIConfig%.show_legend = %a+",
            "UIConfig.show_legend = " .. tostring(settings.show_legend))
    end

    if settings.show_column_headers ~= nil then
        content = content:gsub("UIConfig%.show_column_headers = %a+",
            "UIConfig.show_column_headers = " .. tostring(settings.show_column_headers))
    end

    if settings.show_footer ~= nil then
        content = content:gsub("UIConfig%.show_footer = %a+",
            "UIConfig.show_footer = " .. tostring(settings.show_footer))
    end

    -- Update background settings if provided
    if settings.bg_r ~= nil then
        content = content:gsub("r = %d+,%s*%-%- Red", "r = " .. settings.bg_r .. ", -- Red")
    end

    if settings.bg_g ~= nil then
        content = content:gsub("g = %d+,%s*%-%- Green", "g = " .. settings.bg_g .. ", -- Green")
    end

    if settings.bg_b ~= nil then
        content = content:gsub("b = %d+,%s*%-%- Blue", "b = " .. settings.bg_b .. ", -- Blue")
    end

    if settings.bg_a ~= nil then
        content = content:gsub("a = %d+,%s*%-%- Alpha", "a = " .. settings.bg_a .. ", -- Alpha")
    end

    if settings.bg_visible ~= nil then
        content = content:gsub("visible = %a+%s*%-%- Show background",
            "visible = " .. tostring(settings.bg_visible) .. "  -- Show background")
    end

    -- Write back to file
    file = io.open(config_file, 'w')
    if not file then
        add_to_chat(167, "[UI] Error: Could not open UI_CONFIG.lua for writing")
        return false
    end

    file:write(content)
    file:close()

    -- Update _G.UIConfig in memory immediately so changes take effect without reload
    if _G.UIConfig then
        if settings.pos then
            if not _G.UIConfig.default_position then
                _G.UIConfig.default_position = {}
            end
            _G.UIConfig.default_position.x = math.floor(settings.pos.x)
            _G.UIConfig.default_position.y = math.floor(settings.pos.y)
        end

        if settings.enabled ~= nil then
            _G.UIConfig.enabled = settings.enabled
        end

        if settings.show_header ~= nil then
            _G.UIConfig.show_header = settings.show_header
        end

        if settings.show_legend ~= nil then
            _G.UIConfig.show_legend = settings.show_legend
        end

        if settings.show_column_headers ~= nil then
            _G.UIConfig.show_column_headers = settings.show_column_headers
        end

        if settings.show_footer ~= nil then
            _G.UIConfig.show_footer = settings.show_footer
        end
    end

    return true
end

return KeybindSettings
