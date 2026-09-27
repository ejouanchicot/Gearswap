---============================================================================
--- Stealth Config - <Character>/config/STEALTH_CONFIG.lua, read and saved
---============================================================================
--- The settings of //gs c stealth: refresh_below, alert_before, overwrite,
--- alerts, delay. Read once per load (a missing file or key keeps the default);
--- an in-game change rewrites only that key's line of the file, keeping its
--- comments and line endings.
---
--- @file shared/utils/stealth/stealth_config.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local StealthConfig = {}

StealthConfig.DEFAULTS = {
    refresh_below = 180,
    alert_before = 60,
    overwrite = false,
    alerts = true,
    delay = 2.5,
}

--- Path of the character's settings file.
--- @return string|nil
function StealthConfig.path()
    if not (player and player.name) then return nil end
    return ('%sdata/%s/config/STEALTH_CONFIG.lua'):format(windower.addon_path, player.name)
end

--- The settings, read once per load.
--- @return table {refresh_below, alert_before, overwrite, alerts}
function StealthConfig.get()
    if rawget(_G, '_stealth_settings') then return _G._stealth_settings end
    local settings = {}
    local ok, data = pcall(dofile, StealthConfig.path() or '')
    for key, value in pairs(StealthConfig.DEFAULTS) do
        local saved = ok and type(data) == 'table' and data[key]
        settings[key] = (saved ~= nil and type(saved) == type(value)) and saved or value
    end
    _G._stealth_settings = settings
    return settings
end

--- Rewrite the `key = ...,` line of the file, or add it before the closing
--- brace when the file lacks it.
--- @return boolean saved
local function save(key, value)
    local path = StealthConfig.path()
    local file = path and io.open(path, 'rb')
    if not file then return false end
    local text = file:read('*a')
    file:close()
    local nl = text:find('\r\n', 1, true) and '\r\n' or '\n'
    local line = ('%s = %s,'):format(key, tostring(value))
    local count
    text, count = text:gsub('(\n%s*)' .. key .. '%s*=%s*[^,\r\n]*,', '%1' .. line, 1)
    if count == 0 then
        text, count = text:gsub('(\n)(}%s*)$', '%1    ' .. line .. nl .. '%2', 1)
    end
    if count == 0 then return false end
    file = io.open(path, 'wb')
    if not file then return false end
    file:write(text)
    file:close()
    return true
end

--- Change one setting now and in the file.
--- @param key string One of DEFAULTS
--- @param value number|boolean Same type as the default
--- @return boolean saved False when the file could not be written
function StealthConfig.set(key, value)
    StealthConfig.get()[key] = value
    return save(key, value)
end

return StealthConfig
