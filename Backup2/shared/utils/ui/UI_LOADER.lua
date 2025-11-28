---============================================================================
--- Keybind Configuration Loader - Character-Aware System
---============================================================================
--- Intelligent loader that automatically detects the current character
--- and loads the appropriate keybind configuration files.
---
--- @file ui/UI_LOADER.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-26
---============================================================================

local KeybindLoader = {}

---============================================================================
--- MAIN LOADING FUNCTION
---============================================================================

--- Get keybind configuration for the specified job
--- @param job string The job abbreviation (BRD, WAR, etc.)
--- @return table|nil Keybind configuration or nil if not found
function KeybindLoader.get_job_keybinds(job)
    -- Validation: ensure we have a job
    if not job or job == "UNK" then
        return nil
    end

    -- Build the configuration path based on job
    -- Format: config/war/WAR_KEYBINDS.lua
    local config_path = 'config/' .. job:lower() .. '/' .. job:upper() .. '_KEYBINDS'

    -- Try to load the configuration module
    local success, keybind_config = pcall(require, config_path)

    -- Check if module loaded
    if success and keybind_config then
        -- If module has get_active_binds() function, use it (supports subjob filtering)
        if keybind_config.get_active_binds and type(keybind_config.get_active_binds) == 'function' then
            return keybind_config.get_active_binds()
        end

        -- Otherwise, return the binds table directly (legacy support)
        if keybind_config.binds then
            return keybind_config.binds
        end
    end

    -- No configuration found for this job
    return nil
end

---============================================================================
--- FALLBACK KEYBINDS
---============================================================================

--- Get fallback keybinds for jobs without configuration files
--- @param job string The job abbreviation
--- @return table Default keybind configuration
function KeybindLoader.get_fallback_keybinds(job)
    local fallbacks = {
        -- Corsair fallback
        COR = {
            { key = "Alt+1", desc = "Main Weapon", state = "WeaponSet" },
            { key = "Alt+2", desc = "Sub Weapon",  state = "SubSet" },
        },

        -- Geomancer fallback (should use config/geo/GEO_KEYBINDS.lua instead)
        GEO = {
            { key = "Alt+1", desc = "Main Indi",   state = "MainIndi" },
            { key = "Alt+2", desc = "Main Geo",    state = "MainGeo" },
            { key = "Alt+3", desc = "Light Spell", state = "MainLightSpell" },
            { key = "Alt+4", desc = "Dark Spell",  state = "MainDarkSpell" },
            { key = "Alt+5", desc = "Light AOE",   state = "MainLightAOE" },
            { key = "Alt+6", desc = "Dark AOE",    state = "MainDarkAOE" },
            { key = "Alt+7", desc = "Hybrid Mode", state = "HybridMode" },
        },
    }

    return fallbacks[job] or {}
end

---============================================================================
--- SPECIAL ADDITIONS
---============================================================================

--- Add job-specific display elements (non-keybind items)
--- @param job string The job abbreviation
--- @param keybinds table The existing keybind table
--- @return table Modified keybind table with additions
function KeybindLoader.add_job_specific_elements(job, keybinds)
    keybinds = keybinds or {}

    -- BRD: Add song slot displays
    if job == "BRD" then
        for i = 1, 5 do
            table.insert(keybinds, {
                key = "", -- No key, display only
                desc = "Slot " .. i,
                state = "BRDSong" .. i  -- Changed from BRDSlot to BRDSong to match TETSOUO_BRD states
            })
        end
    end

    return keybinds
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Check if a configuration file exists for the job
--- @param job string The job abbreviation
--- @return boolean True if configuration exists
function KeybindLoader.config_exists(job)
    if not job then
        return false
    end

    local config_path = 'config/' .. job:upper() .. '_KEYBINDS'
    local success, config = pcall(require, config_path)

    return success and config ~= nil
end

--- Get the configuration path for debugging
--- @param job string The job abbreviation
--- @return string The configuration path
function KeybindLoader.get_config_path(job)
    return 'config/' .. (job and job:upper() or "UNKNOWN") .. '_KEYBINDS'
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return KeybindLoader
