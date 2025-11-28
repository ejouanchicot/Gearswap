---  ═══════════════════════════════════════════════════════════════════════════
---   Message Settings - Persistent Configuration Storage (Per Character)
---  ═══════════════════════════════════════════════════════════════════════════
---   Global variables + file persistence for message display settings.
---   Settings persist within session AND across //lua reload gearswap.
---
---   Features:
---     • Per-character settings ([CharName]/config/message_modes.lua)
---     • Global variable storage (_G.MESSAGE_SETTINGS)
---     • Auto-load from file on startup
---     • Auto-save on every setting change
---     • Legacy compatibility functions
---
---   Architecture:
---     • File persistence via dofile() and io.open()
---     • Default settings if file doesn't exist
---     • Getter/Setter functions for all modes
---     • Automatic file generation with formatted output
---
---   Settings File:
---     • [CharName]/config/message_modes.lua (one file per character)
---
---   @file    shared/config/message_settings.lua
---   @author  Tetsouo
---   @version 2.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local MessageSettings = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   FILE PERSISTENCE
---  ═══════════════════════════════════════════════════════════════════════════

-- Get absolute path to settings file (per character)
local function get_settings_path()
    -- Detect character name from player data
    local char_name = player and player.name or 'Tetsouo'

    -- Save in character's own config directory (using dynamic path)
    local base_path = windower.addon_path .. 'data/'
    return base_path .. char_name .. '/config/message_modes.lua'
end

--- Load settings from file
--- @return table|nil Loaded settings or nil if file doesn't exist
local function load_from_file()
    local file_path = get_settings_path()

    -- Use dofile() instead of loadfile() (GearSwap environment)
    local success, settings = pcall(dofile, file_path)

    if success and settings and type(settings) == 'table' then
        return settings
    end

    return nil
end

--- Save settings to file
--- @param settings table Settings to save
local function save_to_file(settings)
    local file_path = get_settings_path()

    -- Write settings to file
    local file = io.open(file_path, 'w')
    if file then
        file:write('-- Message Display Modes (auto-generated)\n')
        file:write('-- Character: ' .. (player and player.name or 'Unknown') .. '\n')
        file:write('-- File: ' .. file_path .. '\n')
        file:write('-- \n')
        file:write('-- spell_mode: ALL spell types (Enhancing, Enfeebling, Healing, Elemental, etc.)\n')
        file:write('-- ja_mode: Job Abilities\n')
        file:write('-- ws_mode: Weapon Skills\n')
        file:write('return {\n')
        file:write(string.format("    spell_mode = '%s',\n", settings.spell_mode or 'on'))
        file:write(string.format("    ja_mode = '%s',\n", settings.ja_mode or 'on'))
        file:write(string.format("    ws_mode = '%s'\n", settings.ws_mode or 'on'))
        file:write('}\n')
        file:close()
        return true
    else
        add_to_chat(167, '[MESSAGE_SETTINGS] ERROR: Cannot write to ' .. file_path)
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL SETTINGS STORAGE
---  ═══════════════════════════════════════════════════════════════════════════

-- ALWAYS try to load from file first (even if _G.MESSAGE_SETTINGS exists)
-- This ensures settings persist across //lua reload gearswap
local loaded = load_from_file()

if loaded then
    -- File exists, use it (overwrite any existing _G.MESSAGE_SETTINGS)
    _G.MESSAGE_SETTINGS = loaded
elseif _G.MESSAGE_SETTINGS == nil then
    -- No file AND no global variable: create defaults
    _G.MESSAGE_SETTINGS = {
        spell_mode = 'on',         -- ALL spells (enhancing, enfeebling, healing, elemental, etc.)
        ja_mode = 'on',            -- Job Abilities
        ws_mode = 'on'             -- Weapon Skills
    }
    -- Save defaults to file
    save_to_file(_G.MESSAGE_SETTINGS)
end
-- If file doesn't exist but _G.MESSAGE_SETTINGS exists, keep the global (in-session changes)

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS ACCESS
---  ═══════════════════════════════════════════════════════════════════════════

--- Get Spell message mode (ALL spell types)
--- @return string Current mode ('full', 'on', 'off')
function MessageSettings.get_spell_mode()
    return _G.MESSAGE_SETTINGS.spell_mode or 'on'
end

--- Get Job Ability message mode
--- @return string Current mode ('full', 'on', 'off')
function MessageSettings.get_ja_mode()
    return _G.MESSAGE_SETTINGS.ja_mode or 'on'
end

--- Get Weapon Skill message mode
--- @return string Current mode ('full', 'on', 'off')
function MessageSettings.get_ws_mode()
    return _G.MESSAGE_SETTINGS.ws_mode or 'on'
end

--- Legacy compatibility - get_enhancing_mode() redirects to get_spell_mode()
function MessageSettings.get_enhancing_mode()
    return MessageSettings.get_spell_mode()
end

--- Legacy compatibility - get_enfeebling_mode() redirects to get_spell_mode()
function MessageSettings.get_enfeebling_mode()
    return MessageSettings.get_spell_mode()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS MODIFICATION
---  ═══════════════════════════════════════════════════════════════════════════

--- Set Spell message mode (ALL spell types)
--- @param mode string New mode ('full', 'on', 'off')
function MessageSettings.set_spell_mode(mode)
    _G.MESSAGE_SETTINGS.spell_mode = mode
    save_to_file(_G.MESSAGE_SETTINGS)
end

--- Set Job Ability message mode
--- @param mode string New mode ('full', 'on', 'off')
function MessageSettings.set_ja_mode(mode)
    _G.MESSAGE_SETTINGS.ja_mode = mode
    save_to_file(_G.MESSAGE_SETTINGS)
end

--- Set Weapon Skill message mode
--- @param mode string New mode ('full', 'on', 'off')
function MessageSettings.set_ws_mode(mode)
    _G.MESSAGE_SETTINGS.ws_mode = mode
    save_to_file(_G.MESSAGE_SETTINGS)
end

--- Legacy compatibility - set_enhancing_mode() redirects to set_spell_mode()
function MessageSettings.set_enhancing_mode(mode)
    MessageSettings.set_spell_mode(mode)
end

--- Legacy compatibility - set_enfeebling_mode() redirects to set_spell_mode()
function MessageSettings.set_enfeebling_mode(mode)
    MessageSettings.set_spell_mode(mode)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return MessageSettings
