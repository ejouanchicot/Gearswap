---============================================================================
--- UI Sections - Display Section Rendering Engine
---============================================================================
--- Handles rendering of all UI sections (spells, weapons, modes, etc.)
--- with intelligent categorization and consistent formatting.
---
--- @file ui/UI_SECTIONS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-09-26
---============================================================================

local UISections = {}

-- Load dependencies
local UIConfig = _G.UIConfig or {}  -- Loaded from character main file

-- Provide default sections if not loaded
if not UIConfig.sections then
    UIConfig.sections = {
        spells = true,
        enhancing = true,
        job_abilities = true,
        weapons = true,
        modes = true
    }
end

local UIFormatter = require('shared/utils/ui/UI_FORMATTER')

---============================================================================
--- SECTION RENDERING ENGINE
---============================================================================

--- Render a single section with keybinds
--- @param section_name string Name of the section (spell, ja, weapon, mode)
--- @param keys table List of keys for this section
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param content_width number Total UI content width for centering
--- @param value_column_width number Value column width for fixed padding
--- @return string Rendered section text
local function render_section(section_name, keys, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if not keys or #keys == 0 then
        return ""
    end

    local text = ""
    local section_found = false
    local current_subjob = player and player.sub_job or nil

    for _, bind in ipairs(keybinds) do
        for _, section_key in ipairs(keys) do
            if bind.key == section_key then
                -- Filter by subjob if bind has subjob requirement
                if bind.subjob and bind.subjob ~= current_subjob then
                    -- Skip this bind if subjob requirement not met
                    break
                end

                if not section_found then
                    -- Add section header (centered)
                    local section_title = UIFormatter.get_section_title(job, section_name)
                    text = text .. UIFormatter.create_colored_section_header(section_title, content_width)
                    section_found = true
                end

                -- Add the keybind line (with fixed value column width)
                text = text .. UIFormatter.format_keybind_line(bind, key_column_width, function_column_width, get_state_value_func, value_column_width)
                break
            end
        end
    end

    return text
end

--- Render special display-only keybinds (like BRD song slots)
--- @param keys table List of keys (can include empty keys for display-only)
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param section_title string Title for the section
--- @param content_width number Total UI content width for centering
--- @param value_column_width number Value column width for fixed padding
--- @return string Rendered section text
local function render_display_only_section(keys, keybinds, job, key_column_width, function_column_width, get_state_value_func, section_title, content_width, value_column_width)
    if not keys or #keys == 0 then
        return ""
    end

    local text = ""
    local section_found = false

    for _, bind in ipairs(keybinds) do
        -- Handle display-only items (empty keys) and regular keys
        for _, section_key in ipairs(keys) do
            if (bind.key == section_key) or (section_key == "" and (bind.key == "" and (bind.desc:find("Spell") or bind.desc:find("Gain")))) then
                if not section_found then
                    text = text .. UIFormatter.create_colored_section_header(section_title, content_width)
                    section_found = true
                end

                text = text .. UIFormatter.format_keybind_line(bind, key_column_width, function_column_width, get_state_value_func, value_column_width)
                break
            end
        end
    end

    return text
end

---============================================================================
--- MAIN SECTION RENDERING FUNCTIONS
---============================================================================

--- Render spells section
--- @param display_structure table Display structure from UIDisplayBuilder
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param content_width number Total UI content width
--- @return string Rendered spells section
function UISections.render_spells_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if not UIConfig.sections.spells then
        return ""
    end
    return render_section("spell", display_structure.spell_keys, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
end

--- Render enhancing section (for RDM and similar jobs)
--- @param display_structure table Display structure from UIDisplayBuilder
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param content_width number Total UI content width
--- @return string Rendered enhancing section
function UISections.render_enhancing_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if not UIConfig.sections.enhancing or not display_structure.enhancing_keys then
        return ""
    end

    return render_section("enhancing", display_structure.enhancing_keys, keybinds, job, key_column_width, function_column_width,
        get_state_value_func, content_width, value_column_width)
end

--- Render JA (Job Abilities) section
--- @param display_structure table Display structure from UIDisplayBuilder
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param content_width number Total UI content width
--- @return string Rendered JA section
function UISections.render_ja_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if not UIConfig.sections.job_abilities then
        return ""
    end

    -- Special handling for BRD song slots (display-only)
    if job == "BRD" then
        return render_display_only_section(display_structure.ja_keys, keybinds, job, key_column_width, function_column_width,
            get_state_value_func, "Song Slots", content_width, value_column_width)
    else
        return render_section("ja", display_structure.ja_keys, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    end
end

--- Render weapons section
--- @param display_structure table Display structure from UIDisplayBuilder
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param content_width number Total UI content width
--- @return string Rendered weapons section
function UISections.render_weapons_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if not UIConfig.sections.weapons then
        return ""
    end
    return render_section("weapon", display_structure.weapon_keys, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
end

--- Render modes section
--- @param display_structure table Display structure from UIDisplayBuilder
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param key_column_width number Column width for alignment
--- @param function_column_width number Function column width for alignment
--- @param get_state_value_func function Function to get state values
--- @param content_width number Total UI content width
--- @return string Rendered modes section
function UISections.render_modes_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if not UIConfig.sections.modes then
        return ""
    end
    return render_section("mode", display_structure.mode_keys, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
end

---============================================================================
--- COMPLETE UI RENDERING
---============================================================================

--- Render all sections for a complete UI display
--- @param display_structure table Display structure from UIDisplayBuilder
--- @param keybinds table All keybinds
--- @param job string Current job
--- @param get_state_value_func function Function to get current state value
--- @param get_all_values_func function Function to get all possible state values (for width)
--- @return string Complete rendered UI text
function UISections.render_complete_ui(display_structure, keybinds, job, get_state_value_func, get_all_values_func)
    -- Calculate optimal column widths and EXACT content width using ALL possible values
    local key_column_width = UIFormatter.calculate_key_column_width(keybinds)
    local function_column_width = UIFormatter.calculate_function_column_width(keybinds)
    local value_column_width = UIFormatter.calculate_value_column_width(keybinds, get_all_values_func)
    local content_width = UIFormatter.calculate_content_width(keybinds, key_column_width, function_column_width, get_all_values_func)

    local text = ""

    -- Header (pass content_width for centering title)
    text = text .. UIFormatter.create_header(job, content_width)

    -- Separator after header/legend (only if no header, since header now has its own separator)
    if not _G.ui_display_config or not _G.ui_display_config.show_header then
        -- No separator needed
    elseif _G.ui_display_config.show_legend then
        -- Separator after legend
        text = text .. UIFormatter.create_section_separator(content_width)
    end

    -- Column headers (pass content_width for top margin)
    text = text .. UIFormatter.create_column_headers(key_column_width, function_column_width, content_width)

    -- Render sections in order without separators between them (pass content_width for centering)
    -- 1. Spells/Abilities
    local spells = UISections.render_spells_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if spells ~= "" then
        text = text .. spells
    end

    -- 2. Enhancing (RDM specific)
    local enhancing = UISections.render_enhancing_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if enhancing ~= "" then
        text = text .. enhancing
    end

    -- 3. Job Abilities / Song Slots
    local ja = UISections.render_ja_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if ja ~= "" then
        text = text .. ja
    end

    -- 4. Weapons
    local weapons = UISections.render_weapons_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if weapons ~= "" then
        text = text .. weapons
    end

    -- 5. Modes
    local modes = UISections.render_modes_section(display_structure, keybinds, job, key_column_width, function_column_width, get_state_value_func, content_width, value_column_width)
    if modes ~= "" then
        text = text .. modes
    end

    -- 6. Universal Commands (footer)
    text = text .. UISections.render_commands_footer(job, content_width)

    -- Add bottom margin if NO footer (footer adds its own margin)
    if not _G.ui_display_config or not _G.ui_display_config.show_footer then
        text = text .. "\\cs(0,0,0)" .. string.rep(" ", content_width) .. "\\cr\n"
    end

    return text
end

--- Render simple command footer
--- @param job string Current job
--- @param content_width number Dynamic content width
--- @return string Rendered commands footer
function UISections.render_commands_footer(job, content_width)
    -- Use global config state instead of local UIConfig
    if not _G.ui_display_config or not _G.ui_display_config.show_footer then
        return ""
    end

    local command_text = "//gs c ui"
    local command_length = string.len(command_text)
    local padding = math.floor((content_width - command_length) / 2)
    padding = math.max(2, padding)  -- Minimum 2 for left margin

    local centered_command = string.rep(" ", padding) .. command_text

    -- Add fixed 2 space right margin (symmetrical with left padding)
    local footer_text = UIFormatter.create_section_separator(content_width) .. "\\cs(128,128,128)" .. centered_command .. "  \\cr\n"

    -- Add bottom margin (empty line with padding and color code for background)
    footer_text = footer_text .. "\\cs(0,0,0)" .. string.rep(" ", content_width) .. "\\cr\n"

    return footer_text
end

---============================================================================
--- VALIDATION AND UTILITIES
---============================================================================

--- Validate section rendering configuration
--- @return boolean, table valid, issues
function UISections.validate_configuration()
    local issues = {}

    -- Check UIFormatter availability
    if not UIFormatter then
        table.insert(issues, "UIFormatter dependency not available")
    end

    -- Check required UIFormatter functions
    local required_functions = {
        "create_header", "create_column_headers", "get_section_title",
        "create_colored_section_header", "format_keybind_line", "calculate_key_column_width"
    }

    for _, func_name in ipairs(required_functions) do
        if not UIFormatter[func_name] then
            table.insert(issues, "Missing UIFormatter function: " .. func_name)
        end
    end

    return #issues == 0, issues
end

--- Get section rendering statistics
--- @param display_structure table Display structure to analyze
--- @return table Statistics about sections
function UISections.get_section_statistics(display_structure)
    if not display_structure then
        return { error = "No display structure provided" }
    end

    return {
        spell_keys_count = #(display_structure.spell_keys or {}),
        ja_keys_count = #(display_structure.ja_keys or {}),
        weapon_keys_count = #(display_structure.weapon_keys or {}),
        mode_keys_count = #(display_structure.mode_keys or {}),
        enhancing_keys_count = display_structure.enhancing_keys and #display_structure.enhancing_keys or 0,
        total_sections = 5,
        has_enhancing = display_structure.enhancing_keys ~= nil
    }
end

return UISections
