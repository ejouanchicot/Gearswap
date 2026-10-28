---============================================================================
--- UI Display - Render Keybind Display Text
---============================================================================
--- Builds and renders the UI text by combining the current job's keybinds,
--- the display structure (sections + columns) and live state values. Two
--- functions:
---   • get_current_job_keybinds() - load keybinds for current job
---   • update_display()           - render and push text to keybind_ui_display
---
--- @file shared/utils/ui/ui_display.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-05-09
---============================================================================

local KeybindLoader     = require('shared/utils/ui/UI_LOADER')
local UIDisplayBuilder  = require('shared/utils/ui/UI_DISPLAY_BUILDER')
local UISections        = require('shared/utils/ui/UI_SECTIONS')
local StateValue        = require('shared/utils/ui/ui_state_value')

local Display = {}

--- The current job's rows via KeybindLoader, BRD song slots included.
--- @return table Keybind list (only the job's display-only rows when the key file did not load)
function Display.get_current_job_keybinds()
    local job = player and player.main_job or "UNK"
    return KeybindLoader.add_job_specific_elements(job, KeybindLoader.get_job_keybinds(job) or {})
end

--- Say a render error: in the trace every time, in the chat once a load.
--- A key or CUSTOM file that makes a row raise used to leave the HUD frozen
--- without a word (recreated after 5 failures, the cause never shown).
--- @param err any What pcall returned
function Display.report_error(err)
    pcall(function() require('shared/utils/debug/trace_log').log('HUD', 'render error: %s', tostring(err)) end)
    local ui_state = rawget(_G, 'ui_manager_state')
    if ui_state and ui_state.render_error_told then return end
    if ui_state then ui_state.render_error_told = true end
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then MessageFormatter.show_error('HUD: ' .. tostring(err)) end
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

    -- One list for both: the sections were built from a second pass over the
    -- keys, which on a job with `weapon` keys read the main hand again
    local keybinds = Display.get_current_job_keybinds()
    local display_structure = UIDisplayBuilder.build_display_structure(job, keybinds)

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
