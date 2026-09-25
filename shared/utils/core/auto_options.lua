---============================================================================
--- Auto Options - the automatic job abilities a character turns on
---============================================================================
--- Read from <Character>/config/AUTO_ABILITIES.lua (template in
--- _master/config_global/). Every option is off unless the file sets it true:
---   sam_hasso        SAM: Hasso when engaging, unless Hasso or Seigan is up
---   geo_entrust      GEO: an Indi- aimed at a party member gets Entrust first
---   geo_full_circle  GEO: a Geo- cast while a luopan is out gets Full Circle first
---
--- @file    shared/utils/core/auto_options.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local AutoOptions = {}

--- Whether the character turned this option on.
--- @param name string Option name ('sam_hasso', ...)
--- @return boolean
function AutoOptions.on(name)
    local options = rawget(_G, '_auto_options')
    if options == nil then
        local ok, cfg = pcall(require, 'config/AUTO_ABILITIES')
        options = (ok and type(cfg) == 'table') and cfg or {}
        _G._auto_options = options
    end
    return options[name] == true
end

return AutoOptions
