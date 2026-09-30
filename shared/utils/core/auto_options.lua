---============================================================================
--- Auto Options - the automatic job abilities a character turns on
---============================================================================
--- Read from <Character>/_common/combat/AUTO_ABILITIES.lua (template in
--- _master/config_global/). Two kinds of option.
---
--- Off unless the file sets it true (AutoOptions.on):
---   sam_hasso        SAM: the chosen stance (state.Stance) when engaging,
---                    unless Hasso or Seigan is up
---   geo_entrust      GEO: an Indi- aimed at a party member gets Entrust first
---   geo_full_circle  GEO: a Geo- cast while a luopan is out gets Full Circle first
---   blu_unbridled    BLU: Unbridled Learning before an unbridled spell
---                    (shared/jobs/blu/functions/logic/unbridled.lua)
---   blu_expiacion_window  BLU: Expiacion held once under 3000 TP without
---                    Aftermath: Lv.3 (logic/expiacion_guard.lua)
---
--- On unless the file sets it false (AutoOptions.enabled(name, true)): the
--- automations that always ran before they could be turned off:
---   sam_third_eye_ws        SAM: Third Eye before a weaponskill
---   pld_divine_emblem       PLD: Divine Emblem before Flash
---   pld_majesty             PLD: Majesty before Protect / Cure
---   blm_dark_arts           BLM/SCH: Dark Arts before a nuke
---   blm_klimaform           BLM/SCH: Klimaform before a storm (//gs c storm)
---   dnc_presto              DNC: Presto before a step (//gs c step)
---   war_retaliation_cancel  WAR: Retaliation cancelled after 5 s of running
---
--- @file    shared/utils/core/auto_options.lua
--- @author  ejouanchicot
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
        local ok, cfg = require('shared/utils/core/char_paths').load('common', 'AUTO_ABILITIES')
        options = (ok and type(cfg) == 'table') and cfg or {}
        _G._auto_options = options
    end
    return options[name] == true
end

--- An option with its own default: the file's true / false, else `default`.
--- @param name string Option name
--- @param default boolean Value when the file does not set it
--- @return boolean
function AutoOptions.enabled(name, default)
    AutoOptions.on(name)
    local value = rawget(_G, '_auto_options')[name]
    if value == nil then return default == true end
    return value == true
end

return AutoOptions
