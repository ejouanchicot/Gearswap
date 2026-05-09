---============================================================================
--- UI Display - Render Keybind Display Text
---============================================================================
--- Builds and renders the UI text by combining the current job's keybinds,
--- the display structure (sections + columns) and live state values. Two
--- functions:
---   • get_current_job_keybinds() - load keybinds for current job (with fallback)
---   • update_display()           - render and push text to keybind_ui_display
---
--- @file ui/ui_display.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local KeybindLoader     = require('shared/utils/ui/UI_LOADER')
local UIDisplayBuilder  = require('shared/utils/ui/UI_DISPLAY_BUILDER')
local UISections        = require('shared/utils/ui/UI_SECTIONS')
local StateValue        = require('shared/utils/ui/ui_state_value')

local Display = {}

--- Resolve current job keybinds with fallback chain via KeybindLoader.
--- @return table Keybind dictionary (empty table if nothing found)
function Display.get_current_job_keybinds()
    local job = player and player.main_job or "UNK"

    local keybinds = KeybindLoader.get_job_keybinds(job)

    -- Fallback if no configuration found
    if not keybinds then
        keybinds = KeybindLoader.get_fallback_keybinds(job)
    end

    -- Add job-specific display elements (like BRD song slots)
    if keybinds then
        keybinds = KeybindLoader.add_job_specific_elements(job, keybinds)
    end

    return keybinds or {}
end

--- Build the complete UI text and push it to the live keybind_ui_display.
--- No-op if display element doesn't exist yet (early call before init).
function Display.update_display()
    if not _G.keybind_ui_display then return end

    local job = player and player.main_job or "UNK"

    -- For BRD, refresh song slots before reading values
    if job == "BRD" and _G.update_brd_song_slots then
        _G.update_brd_song_slots()
    end

    local keybinds = Display.get_current_job_keybinds()
    local display_structure = UIDisplayBuilder.build_display_structure(job)

    -- Render via the modular UI system. Pass both state value getters:
    --   - get_state_value: current value for live display
    --   - get_all_state_values: all values for max column width calculation
    local text = UISections.render_complete_ui(
        display_structure,
        keybinds,
        job,
        StateValue.get_state_value,
        StateValue.get_all_state_values
    )

    _G.keybind_ui_display:text(text)
end

return Display
