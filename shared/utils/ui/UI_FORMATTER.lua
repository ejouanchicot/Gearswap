---============================================================================
--- UI Formatter - Text Formatting and Layout Management
---============================================================================
--- Handles all text formatting, headers, alignment, and color formatting
--- for the keybind UI system.
---
--- @file shared/utils/ui/UI_FORMATTER.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-09-26
---============================================================================

local UIFormatter = {}

local UIConfig = _G.UIConfig or {}  -- Set by config_loader.lua (only read by get_statistics)
local ColorSystem = require('shared/utils/ui/COLOR_SYSTEM')
local UIStyle = require('shared/utils/ui/ui_style')

---============================================================================
--- HEADER AND TITLE FORMATTING
---============================================================================

-- Job title mappings
local job_titles = {
    BRD = "Bard Settings",
    THF = "Thief Settings",
    WAR = "Warrior Settings",
    PLD = "Paladin Settings",
    DNC = "Dancer Settings",
    BST = "Beastmaster Settings",
    BLM = "Black Mage Settings",
    BLU = "Blue Mage Settings",
    DRG = "Dragoon Settings",
    RDM = "Red Mage Settings",
    COR = "Corsair Settings",
    GEO = "Geomancer Settings",
    RUN = "Rune Fencer Settings"
}

--- Calculate EXACT total UI width by measuring actual lines
--- @param keybinds table List of keybinds
--- @param key_column_width number Calculated key column width
--- @param function_column_width number Calculated function column width
--- @param get_all_values_func function Function to get ALL possible state values (for max width calculation)
--- @return number Exact width for UI (separators, centering, everything)
function UIFormatter.calculate_content_width(keybinds, key_column_width, function_column_width, get_all_values_func)
    local max_width = 0
    local layout = UIStyle.get().layout
    local sp = layout.spacing
    local left, gap, gap_value = string.rep(" ", sp.left), string.rep(" ", sp.gap), string.rep(" ", sp.gap_value)
    -- Standard layout: byte length, as it always was (a "●" counts 3, which
    -- leaves 2 columns of slack on the right). Exact layouts count columns.
    local measure = sp.exact and UIStyle.display_len or string.len

    -- Measure header first (same margins and gaps as the rendered lines)
    local formatted_key = string.format("%-" .. key_column_width .. "s", "Key")
    local formatted_func = string.format("%-" .. function_column_width .. "s", "Function")
    local header_line = left .. formatted_key .. gap .. formatted_func .. gap_value .. "Current"
    max_width = measure(header_line)

    -- Measure each keybind line with ALL possible values to find absolute maximum width
    if get_all_values_func then
        for _, bind in ipairs(keybinds) do
            -- Get ALL possible values for this state
            local all_values = get_all_values_func(bind.state)

            local formatted_key_line = string.format("%-" .. key_column_width .. "s", UIStyle.display_key(bind.key))
            local formatted_desc_line = string.format("%-" .. function_column_width .. "s", bind.desc)
            local prefix = left .. formatted_key_line .. gap .. formatted_desc_line .. gap_value .. layout.bullet .. " "

            -- Test with each possible value to find the longest
            for _, value in ipairs(all_values) do
                max_width = math.max(max_width, measure(prefix .. value))
            end
        end
    end

    -- Right margin (padding added directly in format strings)
    return max_width + sp.right
end

--- Calculate dynamic header/footer width based on content (no caller in the repository)
--- @param job string The job abbreviation
--- @return number Width for separators
function UIFormatter.calculate_header_width(job)
    local title = job_titles[job] or job .. " Settings"
    local title_width = string.len(title) + 6  -- Add space for >> <<

    -- Return exact width needed
    return title_width
end

--- Create the UI header with title and legend
--- @param job string The job abbreviation
--- @param content_width number Total UI content width for centering
--- @return string Formatted header text
function UIFormatter.create_header(job, content_width)
    -- Use global config state instead of local UIConfig
    if not _G.ui_display_config or not _G.ui_display_config.show_header then
        return ""
    end

    local title = job_titles[job] or job .. " Settings"

    local text = ""

    -- Add top margin (empty line with padding and color code for background)
    text = text .. "\\cs(0,0,0)" .. string.rep(" ", content_width) .. "\\cr\n"

    -- Center the title (accounting for 2 space left margin already in content_width)
    local title_length = string.len(title)
    local padding = math.floor((content_width - title_length) / 2)
    padding = math.max(2, padding)  -- Minimum 2 for left margin
    local centered_title = string.rep(" ", padding) .. title

    -- Title in bright color (right margin added via content_width calculation)
    text = text .. UIStyle.color('title') .. centered_title .. "  \\cr\n"

    -- Separator line under title (with 2 space margins on both sides)
    if content_width then
        text = text .. "  " .. UIStyle.color('separator', "\\cs(100,180,255)") .. string.rep("=", content_width - 4) .. "  \\cr\n"
    end

    -- Symbol legend (optional). Keys written out in words need no legend.
    if _G.ui_display_config and _G.ui_display_config.show_legend
        and UIStyle.get().layout.key_style ~= 'words' then
        local legend_color = UIStyle.color('legend')
        for _, line in ipairs(UIFormatter.legend_lines(UIStyle.get().layout.legend)) do
            text = text .. legend_color .. line .. "\\cr\n"
        end
    end

    return text
end

--- Legend lines, two items per line with 2 space margins on both sides.
--- The first column is 18 wide (wider when an item needs it).
--- @param items table Legend texts ("^ = Ctrl", ...)
--- @return table Lines without color codes
function UIFormatter.legend_lines(items)
    local col1_width = 18
    for i = 1, #items, 2 do
        col1_width = math.max(col1_width, string.len("● " .. items[i]) + 3)
    end
    local lines = {}
    for i = 1, #items, 2 do
        if items[i + 1] then
            lines[#lines + 1] = string.format("  %-" .. col1_width .. "s● %s  ", "● " .. items[i], items[i + 1])
        else
            lines[#lines + 1] = "  ● " .. items[i] .. "  "
        end
    end
    return lines
end

--- Create column headers with dynamic alignment
--- @param key_column_width number Width of the key column
--- @param function_column_width number Width of the function column
--- @param content_width number Total UI content width for top margin
--- @return string Formatted column headers
function UIFormatter.create_column_headers(key_column_width, function_column_width, content_width)
    -- Use global config state instead of local UIConfig
    if not _G.ui_display_config or not _G.ui_display_config.show_column_headers then
        return ""
    end

    local text = ""

    -- Add top margin if NO header (header adds its own margin)
    if not _G.ui_display_config.show_header and content_width then
        text = text .. "\\cs(0,0,0)" .. string.rep(" ", content_width) .. "\\cr\n"
    end

    -- Build header with colors (Consolas monospace = safe)
    local formatted_key = string.format("%-" .. key_column_width .. "s", "Key")
    local formatted_func = string.format("%-" .. function_column_width .. "s", "Function")

    -- Multiple colors for header columns (same margins and gaps as the rows)
    local sp = UIStyle.get().layout.spacing
    text = text .. string.rep(" ", sp.left)
        .. UIStyle.color('column_key') .. formatted_key .. string.rep(" ", sp.gap)
        .. UIStyle.color('column_function') .. formatted_func .. string.rep(" ", sp.gap_value)
        .. UIStyle.color('column_current') .. "Current" .. string.rep(" ", sp.right) .. "\\cr\n"

    return text
end

---============================================================================
--- SECTION TITLE FORMATTING
---============================================================================

--- Create a centered section title
--- @param title string The section title
--- @param content_width number Total UI content width (optional)
--- @return string Formatted centered title
function UIFormatter.create_section_title(title, content_width)
    if not content_width then
        -- Fallback to left-aligned with margin
        return "    " .. title  -- 4 space left margin for fallback
    end

    -- Calculate padding to center the title (accounting for 2 space left margin already in content_width)
    local title_length = string.len(title)
    local padding = math.floor((content_width - title_length) / 2)

    -- Ensure minimum padding (at least 2 for left margin)
    padding = math.max(2, padding)

    return string.rep(" ", padding) .. title
end

--- Get appropriate section title for job and category
--- @param job string The job abbreviation
--- @param category string The section category (spell, ja, weapon, mode, enhancing)
--- @return string The section title
function UIFormatter.get_section_title(job, category)
    local custom = UIStyle.get().layout.section_titles[category]
    if custom then
        return custom
    end
    if category == "spell" then
        if job == "BST" then
            return "Pet Abilities"
        elseif job == "BRD" then
            return "Song Settings"
        elseif job == "COR" then
            return "Rolls & Quick Draw"
        else
            return "Spells"
        end
    elseif category == "ja" then
        if job == "BRD" then
            return "Song Slots"
        elseif job == "WAR" then
            -- WAR fills this section with its weapon-aware WS slots, not JAs
            return "Weapon Skills"
        else
            return "JA"
        end
    elseif category == "weapon" then
        return "Weapons"
    elseif category == "mode" then
        return "Modes"
    elseif category == "enhancing" then
        return "Enhancing"
    else
        return category:upper()
    end
end

---============================================================================
--- KEYBIND LINE FORMATTING
---============================================================================

--- Format a single keybind line with perfect column alignment
--- @param bind table Keybind object {key, desc, state}
--- @param key_column_width number Width for key column alignment
--- @param function_column_width number Width for function column alignment
--- @param get_state_value_func function Function to get state values
--- @param value_column_width number|nil Value column width (value left unpadded when nil)
--- @return string Formatted keybind line
function UIFormatter.format_keybind_line(bind, key_column_width, function_column_width, get_state_value_func, value_column_width)
    -- Get current state value
    local value = get_state_value_func(bind.state, bind.key)

    -- Format with dynamic widths using %-Ns for left-align padding
    local layout = UIStyle.get().layout
    local sp = layout.spacing
    local formatted_key = string.format("%-" .. key_column_width .. "s", UIStyle.display_key(bind.key))
    local formatted_desc = string.format("%-" .. function_column_width .. "s", bind.desc)

    local desc_color = UIStyle.color('description')
    local key_color = UIStyle.color('key', desc_color)
    local value_color = UIStyle.color('value', ColorSystem.get_value_color(value, bind.desc))

    -- Pad value to fixed width (if value_column_width provided)
    local formatted_value = value
    if value_column_width then
        local value_padding = value_column_width - (UIStyle.display_len(layout.bullet) + 1)
        formatted_value = string.format("%-" .. value_padding .. "s", value)
    end

    -- Consolas is monospace: color codes don't break the alignment.
    -- Layout: <left>key<gap>desc<gap_value><bullet> value<right>
    local desc_prefix = key_color ~= desc_color and desc_color or ""
    return string.rep(" ", sp.left) .. key_color .. formatted_key .. string.rep(" ", sp.gap)
        .. desc_prefix .. formatted_desc .. string.rep(" ", sp.gap_value)
        .. value_color .. layout.bullet .. " " .. formatted_value .. string.rep(" ", sp.right) .. "\\cr\n"
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Calculate optimal key column width from keybinds
--- @param keybinds table List of keybind objects
--- @return number Optimal column width
function UIFormatter.calculate_key_column_width(keybinds)
    local width = 2 -- Minimum width
    for _, bind in ipairs(keybinds) do
        width = math.max(width, string.len(UIStyle.display_key(bind.key)))
    end
    return width
end

--- Calculate optimal function/description column width from keybinds
--- @param keybinds table List of keybind objects
--- @return number Optimal column width
function UIFormatter.calculate_function_column_width(keybinds)
    local width = 8 -- Minimum width (length of "Function")
    for _, bind in ipairs(keybinds) do
        width = math.max(width, string.len(bind.desc))
    end
    return width
end

--- Calculate optimal value column width (max of ALL possible values)
--- @param keybinds table List of keybinds
--- @param get_all_values_func function Function to get ALL possible state values
--- @return number Maximum value width
function UIFormatter.calculate_value_column_width(keybinds, get_all_values_func)
    local width = 7  -- "Current" header length
    local prefix_width = UIStyle.display_len(UIStyle.get().layout.bullet) + 1

    if get_all_values_func then
        for _, bind in ipairs(keybinds) do
            -- Get ALL possible values for this state
            local all_values = get_all_values_func(bind.state)

            -- Find the longest value
            for _, value in ipairs(all_values) do
                local value_width = string.len(value) + prefix_width
                width = math.max(width, value_width)
            end
        end
    end

    return width
end

--- Add section separator line with dynamic width
--- @param width number Width for separator
--- @return string Separator line
function UIFormatter.create_section_separator(width)
    if not width then
        width = 50  -- Default fallback
    end
    -- Add 2 space margins on both sides and adjust separator width accordingly
    return "  " .. UIStyle.color('separator', "\\cs(80,160,255)") .. string.rep("=", width - 4) .. "  \\cr\n"
end

--- Create colored section header
--- @param title string The section title
--- @param content_width number Total UI content width (optional)
--- @return string Colored section header
function UIFormatter.create_colored_section_header(title, content_width)
    local centered_title = UIFormatter.create_section_title(title, content_width)

    -- Add spacing before section (with background) instead of simple \n
    local spacing = ""
    if content_width then
        spacing = "\\cs(0,0,0)" .. string.rep(" ", content_width) .. "\\cr\n"
    else
        spacing = "\n"
    end

    -- Fixed 2 space right margin (symmetrical with left margin in centered_title);
    -- the blank line under the title is dropped in the compact layout.
    local after = UIStyle.get().layout.spacing.title_gap and "\n" or ""
    return spacing .. UIStyle.color('section_title') .. centered_title .. "  \\cr\n" .. after
end

--- Format empty state message (no caller in the repository)
--- @param category string The category name
--- @return string Formatted empty message
function UIFormatter.format_empty_section(category)
    return "\\cs(128,128,128) No " .. category .. " configured\\cr\n"
end

---============================================================================
--- VALIDATION AND DIAGNOSTICS
---============================================================================

--- Validate formatter configuration (no caller in the repository)
--- @return boolean, table valid, issues
function UIFormatter.validate_configuration()
    local issues = {}

    -- Check job titles completeness
    local expected_jobs = { "BRD", "THF", "WAR", "PLD", "DNC", "BST", "BLM", "DRG", "RDM", "COR", "GEO", "RUN" }
    for _, job in ipairs(expected_jobs) do
        if not job_titles[job] then
            table.insert(issues, "Missing job title for: " .. job)
        end
    end

    -- Check ColorSystem availability
    if not ColorSystem then
        table.insert(issues, "ColorSystem dependency not available")
    end

    return #issues == 0, issues
end

--- Get formatting statistics (no caller in the repository)
--- @return table Statistics about formatter configuration
function UIFormatter.get_statistics()
    -- Count job titles
    local job_count = 0
    for _ in pairs(job_titles) do
        job_count = job_count + 1
    end

    return {
        job_titles_count = job_count,
        dependencies_loaded = {
            ColorSystem = ColorSystem ~= nil,
            UIConfig = UIConfig ~= nil
        }
    }
end

return UIFormatter
