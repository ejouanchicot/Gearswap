---============================================================================
--- GEO Keybind Configuration
---============================================================================
--- Defines all keybinds for Geomancer job with descriptions.
--- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
---
--- @file config/geo/GEO_KEYBINDS.lua
--- @author Morphetrix
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

local GEOKeybinds = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

--- Keybind list with key, command, description, and state
--- Key format: ! = Alt, ^ = Ctrl, @ = Windows, # = Shift
GEOKeybinds.binds = {
    ---========================================================================
    --- GEOCOLURE & INDICOLURE
    ---========================================================================

    -- Cycle Spells
    { key = "!1", command = "cycle MainIndi", desc = "Main Indi", state = "MainIndi" },
    { key = "!2", command = "cycle MainGeo", desc = "Main Geo", state = "MainGeo" },

    -- Cast Spells (Ctrl+1/2)
    { key = "^1", command = "indi", desc = "Cast Indi (<me>)", state = nil },
    { key = "^2", command = "geo", desc = "Cast Geo (auto target)", state = nil },

    ---========================================================================
    --- ELEMENTAL SPELLS
    ---========================================================================

    -- Elemental Spells (Light then Dark)
    { key = "!3", command = "cycle MainLightSpell", desc = "Light Spell", state = "MainLightSpell" },
    { key = "!4", command = "cycle MainDarkSpell", desc = "Dark Spell", state = "MainDarkSpell" },

    -- Spell Tier (V, IV, III, II, I)
    { key = "!-", command = "cycle SpellTier", desc = "Spell Tier", state = "SpellTier" },

    -- AOE Spells (Light then Dark)
    { key = "!5", command = "cycle MainLightAOE", desc = "Light AOE", state = "MainLightAOE" },
    { key = "!6", command = "cycle MainDarkAOE", desc = "Dark AOE", state = "MainDarkAOE" },

    -- AOE Tier (III, II, I)
    { key = "!=", command = "cycle AOETier", desc = "AOE Tier", state = "AOETier" },

    -- Combat Modes
    { key = "!7", command = "cycle HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },
    { key = "!8", command = "cycle CombatMode", desc = "Combat Mode",  state = "CombatMode" },
    { key = "!9", command = "cycle LuopanMode", desc = "Luopan Mode",  state = "LuopanMode" },

    -- Indicolure Mode (Self vs Entrust)
    { key = "!0", command = "cycle IndicolureMode", desc = "Indi Mode", state = "IndicolureMode" },
}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Apply all keybinds
function GEOKeybinds.bind_all()
    if not GEOKeybinds.binds or #GEOKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("GEO")
        return false
    end

    local bound_count = 0
    for _, bind in pairs(GEOKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            add_to_chat(167, '[GEO] Keybind Error: ' .. tostring(error_msg))
        end
    end

    if bound_count > 0 then
        -- Show intro with system info like other jobs
        GEOKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
function GEOKeybinds.unbind_all()
    if not GEOKeybinds.binds then
        return
    end

    for _, bind in pairs(GEOKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end
end

--- Display GEO system intro message with macrobook and lockstyle info
function GEOKeybinds.show_intro()
    -- Try to get macro info from GEO_MACROBOOK module
    local macro_info = nil
    local success, GEO_MACROBOOK = pcall(require, 'shared/jobs/geo/functions/GEO_MACROBOOK')
    if success and GEO_MACROBOOK and GEO_MACROBOOK.get_geo_macro_info then
        macro_info = GEO_MACROBOOK.get_geo_macro_info()
    end

    -- Try to get lockstyle info from GEO_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, GEO_LOCKSTYLE = pcall(require, 'shared/jobs/geo/functions/GEO_LOCKSTYLE')
    if lockstyle_success and GEO_LOCKSTYLE and GEO_LOCKSTYLE.get_info then
        lockstyle_info = GEO_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("GEO SYSTEM LOADED", GEOKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("GEO SYSTEM LOADED", GEOKeybinds.binds)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return GEOKeybinds
