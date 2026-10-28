---============================================================================
--- Keybind Configuration Loader - Character-Aware System
---============================================================================
--- Loads a job's keybind configuration, <Character>/<job>/keys/<JOB>_KEYBINDS.lua
--- (CharPaths.module('job', ...), shared/utils/core/char_paths.lua). When it
--- does not load, the HUD shows no rows: EntryKit.keybind_error has already
--- said why in the chat.
---
--- @file shared/utils/ui/UI_LOADER.lua
--- @author ejouanchicot
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

    -- Format: war/keys/WAR_KEYBINDS.lua
    local config_path = require('shared/utils/core/char_paths').module('job', job:upper() .. '_KEYBINDS', job)

    local success, keybind_config = pcall(require, config_path)

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

    -- require failed (missing file OR an error inside the file), or the
    -- module exposes neither get_active_binds nor binds. The error is not kept.
    return nil
end

---============================================================================
--- SPECIAL ADDITIONS
---============================================================================

--- Add job-specific display elements (non-keybind items)
--- Returns a COPY: get_job_keybinds() hands back the config module's own binds
--- table, which require() caches for the whole session. Appending in place made
--- the BRD song slots pile up on every redraw (10 slots on the first render,
--- 20 on the second, ...).
--- @param job string The job abbreviation
--- @param keybinds table The existing keybind table
--- @return table New keybind table with the job's display-only additions
function KeybindLoader.add_job_specific_elements(job, keybinds)
    local result = {}
    for i, bind in ipairs(keybinds or {}) do
        result[i] = bind
    end

    -- BRD: Add song slot displays
    if job == "BRD" then
        for i = 1, 5 do
            table.insert(result, {
                key = "", -- No key, display only
                desc = "Slot " .. i,
                state = "BRDSong" .. i  -- BRDSong1..5 states (BRD_STATES.lua)
            })
        end
    end

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return KeybindLoader
