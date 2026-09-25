---  ═══════════════════════════════════════════════════════════════════════════
---   Message Mode Config - Builds the JA / WS / Enhancing / Enfeebling configs
---  ═══════════════════════════════════════════════════════════════════════════
---   The four *_MESSAGES_CONFIG.lua files expose the same API over a different
---   persisted mode (message_settings.lua). This builds that API once:
---     display_mode        - the mode read when the config was loaded
---     VALID_MODES         - accepted modes, including legacy aliases
---     is_enabled()        - mode is not off (or an off alias)
---     show_description()  - mode is 'full'
---     <short check>()     - mode is 'on' or one of its legacy aliases
---                           (is_name_only, or is_tp_only for weaponskills)
---     set_display_mode(m) - validate, persist, update display_mode
---
---   @file    shared/config/message_mode_config.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-25
---  ═══════════════════════════════════════════════════════════════════════════

local MessageSettings = require('shared/config/message_settings')

local MessageModeConfig = {}

--- Build one message config table.
--- @param opts table {
---     getter        = string  MessageSettings getter name ('get_ja_mode'),
---     setter        = string  MessageSettings setter name ('set_ja_mode'),
---     tag           = string  Error prefix ('JA_CONFIG'),
---     short_check   = string  Name of the 'on' check ('is_name_only'),
---     short_aliases = table   Legacy names for 'on' ({'name_only', 'name'}) }
--- @return table The config module
function MessageModeConfig.create(opts)
    local cfg = {}

    -- Read through the settings module on every call: the persisted mode can
    -- change after this config was loaded.
    local function mode()
        return MessageSettings[opts.getter]()
    end

    cfg.display_mode = mode()

    cfg.VALID_MODES = { full = true, on = true, off = true, disabled = true, disable = true }
    local short = { on = true }
    for _, alias in ipairs(opts.short_aliases) do
        cfg.VALID_MODES[alias] = true
        short[alias] = true
    end

    --- @return boolean True unless the mode is off (or an off alias)
    function cfg.is_enabled()
        local m = mode()
        return m ~= 'off' and m ~= 'disabled' and m ~= 'disable'
    end

    --- @return boolean True when the mode is full
    function cfg.show_description()
        return mode() == 'full'
    end

    cfg[opts.short_check] = function()
        return short[mode()] == true
    end

    --- @param new_mode string 'full' | 'on' | 'off' (legacy aliases accepted)
    --- @return boolean True if the mode was valid and saved
    function cfg.set_display_mode(new_mode)
        if cfg.VALID_MODES[new_mode] then
            MessageSettings[opts.setter](new_mode)
            cfg.display_mode = new_mode
            return true
        end
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error('[' .. opts.tag .. '] Invalid mode: ' .. tostring(new_mode))
        MessageFormatter.show_error('[' .. opts.tag .. '] Valid modes: full, on, off')
        return false
    end

    return cfg
end

return MessageModeConfig
