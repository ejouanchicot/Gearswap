---============================================================================
--- Info Command - Display Detailed Information for JA/Spells/WS
---============================================================================
--- Universal command to query and display formatted information from databases.
--- Works for ALL jobs and displays data with proper message formatting.
---
--- Usage:
---   //gs c info <name>           Display info for JA/Spell/WS
---   //gs c info Last Resort       Display Job Ability details
---   //gs c info Haste             Display Spell details
---   //gs c info Torcleaver        Display Weaponskill details
---
--- Features:
---   - Searches JA, Spell, and WS databases
---   - Formatted output with color codes (ASCII-safe)
---   - Shows all available data fields
---   - Works for any job/subjob combination
---
--- @file commands/info_command.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-04
---============================================================================

local InfoCommand = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local MessageColors = require('shared/utils/messages/message_colors')

-- Data sources (lazy loaded)
local DataLoader = require('shared/utils/data/data_loader')

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Create color code for inline use
--- @param color_code number FFXI color code
--- @return string Formatted color code
local function color(color_code)
    return string.char(0x1F, color_code)
end

--- Sanitize text for FFXI chat (ASCII only, no special chars)
--- @param text string Input text
--- @return string Sanitized ASCII text
local function sanitize_ascii(text)
    if not text then return "" end

    -- Convert to string if not already
    text = tostring(text)

    -- Remove non-ASCII characters (keep only 32-126)
    text = text:gsub("[^\32-\126]", "")

    -- Replace common Unicode chars with ASCII equivalents
    text = text:gsub("\226\128\153", "'")  -- Right single quote to regular quote
    text = text:gsub("\226\128\156", '"')  -- Left double quote
    text = text:gsub("\226\128\157", '"')  -- Right double quote
    text = text:gsub("\226\128\148", "-")  -- Em dash to hyphen
    text = text:gsub("\226\128\147", "-")  -- En dash to hyphen
    text = text:gsub("\226\128\166", "...") -- Ellipsis to three dots

    return text
end

--- Format a table value into readable string
--- @param tbl table Table to format
--- @param key string Optional key name for special formatting
--- @return string Formatted table content
local function format_table_value(tbl, key)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end

    -- Check if it's an array (skillchain)
    if #tbl > 0 then
        return table.concat(tbl, ", ")
    end

    -- Special formatting for FTP (1000/2000/3000 TP values)
    if key == "ftp" or key == "FTP" then
        local ftp_1000 = tbl[1000] or "?"
        local ftp_2000 = tbl[2000] or "?"
        local ftp_3000 = tbl[3000] or "?"
        return string.format("%s/%s/%s", ftp_1000, ftp_2000, ftp_3000)
    end

    -- Special formatting for Mods (stat modifiers)
    if key == "mods" then
        local parts = {}
        -- Sort for consistent display: STR, DEX, VIT, AGI, INT, MND, CHR
        local stat_order = {"STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR"}
        for _, stat in ipairs(stat_order) do
            if tbl[stat] then
                table.insert(parts, stat .. " " .. tostring(tbl[stat]) .. "%")
            end
        end
        if #parts > 0 then
            return table.concat(parts, ", ")
        end
    end

    -- Special formatting for Jobs (job levels)
    if key == "jobs" then
        local parts = {}
        for job, level in pairs(tbl) do
            table.insert(parts, job .. " Lv" .. tostring(level))
        end
        if #parts > 0 then
            table.sort(parts)  -- Alphabetical order
            return table.concat(parts, ", ")
        end
    end

    -- Generic keyed table
    local parts = {}
    for k, v in pairs(tbl) do
        table.insert(parts, tostring(k) .. ": " .. tostring(v))
    end
    if #parts > 0 then
        table.sort(parts)
        return table.concat(parts, ", ")
    end

    return "N/A"
end

--- Convert time value to readable format
--- @param value number Time value
--- @param is_centiseconds boolean True if value is in centiseconds (1/100th sec)
--- @return string Formatted time (e.g., "5m" or "30s" or "1.5s")
local function format_time(value, is_centiseconds)
    if not value or value == 0 then
        return nil
    end

    -- Convert centiseconds to seconds if needed
    local seconds
    if is_centiseconds then
        seconds = value / 100  -- Convert centiseconds to seconds
    else
        seconds = value
    end

    if seconds >= 60 then
        local minutes = math.floor(seconds / 60)
        local remaining_seconds = seconds % 60
        if remaining_seconds == 0 then
            return string.format("%dm", minutes)
        else
            return string.format("%dm %ds", minutes, math.floor(remaining_seconds))
        end
    else
        -- Show decimal for sub-second values from centiseconds
        if is_centiseconds and seconds < 10 then
            return string.format("%.1fs", seconds)
        else
            return string.format("%ds", math.floor(seconds))
        end
    end
end

--- Format a key-value pair with colors
--- @param key string Field name
--- @param value any Field value
--- @param key_color number Color code for key
--- @param value_color number Color code for value
--- @param is_spell boolean True if this is spell data (uses centiseconds)
--- @return string Formatted line
local function format_field(key, value, key_color, value_color, is_spell)
    if not value or value == "" or value == 0 then
        return nil  -- Skip empty/zero fields
    end

    local c_key = color(key_color)
    local c_value = color(value_color)
    local c_reset = color(1)  -- White

    -- Format value (handle tables specially, pass key for context)
    local value_str
    if type(value) == "table" then
        value_str = format_table_value(value, key)
    elseif key == "Recast" or key == "Duration" then
        -- JA: seconds, Spells: centiseconds
        local is_centiseconds = (is_spell == true)
        value_str = format_time(tonumber(value), is_centiseconds)
        if not value_str then
            return nil  -- Skip if conversion failed
        end
    elseif key == "Cast Time" then
        -- Cast time is always in centiseconds for spells
        value_str = format_time(tonumber(value), true)
        if not value_str then
            return nil  -- Skip if conversion failed
        end
    else
        value_str = tostring(value)
    end

    -- Sanitize value for ASCII
    value_str = sanitize_ascii(value_str)

    return string.format("%s  %s:%s %s%s", c_key, key, c_reset, c_value, value_str)
end

---============================================================================
--- DATA DISPLAY FUNCTIONS
---============================================================================

--- Display Job Ability information
--- @param ability_name string Ability name
--- @param ability_data table Ability data from database
local function display_job_ability(ability_name, ability_data)
    local c_header = color(MessageColors.JOB_TAG)
    local c_name = color(MessageColors.JA)
    local c_reset = color(1)

    -- Header
    add_to_chat(1, c_header .. "=== Job Ability Information ===" .. c_reset)
    add_to_chat(1, c_name .. "Name: " .. c_reset .. sanitize_ascii(ability_name))

    -- Fields
    local fields = {
        {"Type", ability_data.type, MessageColors.GRAY, MessageColors.INFO},
        {"Description", ability_data.description, MessageColors.GRAY, MessageColors.SPELL},
        {"Recast", ability_data.recast, MessageColors.GRAY, MessageColors.COOLDOWN},
        {"Duration", ability_data.duration, MessageColors.GRAY, MessageColors.SUCCESS},
        {"Effect", ability_data.effect, MessageColors.GRAY, MessageColors.INFO},
        {"Range", ability_data.range, MessageColors.GRAY, MessageColors.INFO},
        {"Radius", ability_data.radius, MessageColors.GRAY, MessageColors.INFO},
        {"Cost", ability_data.cost, MessageColors.GRAY, MessageColors.WARNING},
        {"Job", ability_data.job, MessageColors.GRAY, MessageColors.JOB_TAG},
        {"Level", ability_data.level, MessageColors.GRAY, MessageColors.INFO},
        {"Category", ability_data.category, MessageColors.GRAY, MessageColors.GRAY},
    }

    for _, field in ipairs(fields) do
        local line = format_field(field[1], field[2], field[3], field[4], false)  -- JA uses seconds
        if line then
            add_to_chat(1, line)
        end
    end

    add_to_chat(1, color(MessageColors.SEPARATOR) .. string.rep("=", 40))
end

--- Display Spell information
--- @param spell_name string Spell name
--- @param spell_data table Spell data from database
local function display_spell(spell_name, spell_data)
    local c_header = color(MessageColors.JOB_TAG)
    local c_name = color(MessageColors.SPELL)
    local c_reset = color(1)

    -- Header
    add_to_chat(1, c_header .. "=== Spell Information ===" .. c_reset)
    add_to_chat(1, c_name .. "Name: " .. c_reset .. sanitize_ascii(spell_name))

    -- Fields
    local fields = {
        {"Type", spell_data.type, MessageColors.GRAY, MessageColors.INFO},
        {"Category", spell_data.category, MessageColors.GRAY, MessageColors.GRAY},
        {"Description", spell_data.description, MessageColors.GRAY, MessageColors.SPELL},
        {"Effect", spell_data.effect, MessageColors.GRAY, MessageColors.INFO},
        {"Duration", spell_data.duration, MessageColors.GRAY, MessageColors.SUCCESS},
        {"Cast Time", spell_data.cast_time, MessageColors.GRAY, MessageColors.INFO},
        {"Recast", spell_data.recast, MessageColors.GRAY, MessageColors.COOLDOWN},
        {"MP Cost", spell_data.mp_cost, MessageColors.GRAY, MessageColors.WARNING},
        {"Range", spell_data.range, MessageColors.GRAY, MessageColors.INFO},
        {"Target", spell_data.target, MessageColors.GRAY, MessageColors.INFO},
        {"Element", spell_data.element, MessageColors.GRAY, MessageColors.SPELL},
        {"Skill", spell_data.skill, MessageColors.GRAY, MessageColors.GRAY},
        {"Job", spell_data.job, MessageColors.GRAY, MessageColors.JOB_TAG},
        {"Level", spell_data.level, MessageColors.GRAY, MessageColors.INFO},
    }

    for _, field in ipairs(fields) do
        local line = format_field(field[1], field[2], field[3], field[4], true)  -- Spells use centiseconds
        if line then
            add_to_chat(1, line)
        end
    end

    add_to_chat(1, color(MessageColors.SEPARATOR) .. string.rep("=", 40))
end

--- Display Weaponskill information
--- @param ws_name string Weaponskill name
--- @param ws_data table Weaponskill data from database
local function display_weaponskill(ws_name, ws_data)
    local c_header = color(MessageColors.JOB_TAG)
    local c_name = color(MessageColors.WS)
    local c_reset = color(1)

    -- Header
    add_to_chat(1, c_header .. "=== Weaponskill Information ===" .. c_reset)
    add_to_chat(1, c_name .. "Name: " .. c_reset .. sanitize_ascii(ws_name))

    -- Fields (using actual database field names)
    local fields = {
        {"Type", ws_data.type, MessageColors.GRAY, MessageColors.INFO},
        {"Description", ws_data.description, MessageColors.GRAY, MessageColors.WS},
        {"Skillchain", ws_data.skillchain, MessageColors.GRAY, MessageColors.SPELL},
        {"Element", ws_data.element, MessageColors.GRAY, MessageColors.SPELL},
        {"Mods", ws_data.mods, MessageColors.GRAY, MessageColors.INFO},
        {"Hits", ws_data.hits, MessageColors.GRAY, MessageColors.INFO},
        {"FTP", ws_data.ftp, MessageColors.GRAY, MessageColors.SUCCESS},
        {"Skill Required", ws_data.skill_required, MessageColors.GRAY, MessageColors.INFO},
        {"Jobs", ws_data.jobs, MessageColors.GRAY, MessageColors.JOB_TAG},
        {"Weapon Type", ws_data.weapon_type, MessageColors.GRAY, MessageColors.GRAY},
        {"Special Notes", ws_data.special_notes, MessageColors.GRAY, MessageColors.WARNING},
    }

    for _, field in ipairs(fields) do
        local line = format_field(field[1], field[2], field[3], field[4], false)  -- WS has no time fields
        if line then
            add_to_chat(1, line)
        end
    end

    add_to_chat(1, color(MessageColors.SEPARATOR) .. string.rep("=", 40))
end

---============================================================================
--- SEARCH FUNCTIONS
---============================================================================

--- Search for entity in all databases (case-insensitive)
--- @param name string Entity name to search
--- @return table|nil data Entity data if found
--- @return string|nil type Entity type ("ability", "spell", "weaponskill")
--- @return string|nil actual_name Actual name from database (proper case)
local function search_all_databases(name)
    -- Normalize name (case-insensitive search)
    local name_lower = name:lower()

    -- Try exact match first (faster)
    local ability_data = DataLoader.get_ability(name)
    if ability_data then
        return ability_data, "ability", name
    end

    local spell_data = DataLoader.get_spell(name)
    if spell_data then
        return spell_data, "spell", name
    end

    local ws_data = DataLoader.get_weaponskill(name)
    if ws_data then
        return ws_data, "weaponskill", name
    end

    -- Exact match failed, try case-insensitive search
    -- This requires iterating through all databases

    -- Search Job Abilities (case-insensitive)
    if not _G.FFXI_DATA.loaded.abilities then
        DataLoader.load_abilities()
    end
    for ability_name, data in pairs(_G.FFXI_DATA.abilities) do
        if ability_name:lower() == name_lower then
            return data, "ability", ability_name
        end
    end

    -- Search Spells (case-insensitive)
    if not _G.FFXI_DATA.loaded.spells then
        DataLoader.load_spells()
    end
    for spell_name, data in pairs(_G.FFXI_DATA.spells) do
        if spell_name:lower() == name_lower then
            return data, "spell", spell_name
        end
    end

    -- Search Weaponskills (case-insensitive)
    if not _G.FFXI_DATA.loaded.weaponskills then
        DataLoader.load_weaponskills()
    end
    for ws_name, data in pairs(_G.FFXI_DATA.weaponskills) do
        if ws_name:lower() == name_lower then
            return data, "weaponskill", ws_name
        end
    end

    return nil, nil, nil
end

---============================================================================
--- MAIN COMMAND HANDLER
---============================================================================

--- Handle info command
--- @param args table Command arguments (name parts)
--- @return boolean True if command was handled
function InfoCommand.handle(args)
    if not args or #args == 0 then
        local c_error = color(MessageColors.ERROR)
        add_to_chat(167, c_error .. "[INFO] Usage: //gs c info <name>")
        add_to_chat(167, c_error .. "[INFO] Example: //gs c info Last Resort")
        add_to_chat(167, c_error .. "[INFO] Example: //gs c info Haste")
        add_to_chat(167, c_error .. "[INFO] Example: //gs c info Torcleaver")
        return true
    end

    -- Join args to handle multi-word names
    local name = table.concat(args, " ")

    -- Search databases (case-insensitive)
    local data, entity_type, actual_name = search_all_databases(name)

    if not data then
        local c_error = color(MessageColors.ERROR)
        add_to_chat(167, c_error .. "[INFO] Not found: " .. sanitize_ascii(name))
        add_to_chat(167, c_error .. "[INFO] Searched: Job Abilities, Spells, Weaponskills")
        return true
    end

    -- Display based on type (use actual_name with proper capitalization)
    if entity_type == "ability" then
        display_job_ability(actual_name, data)
    elseif entity_type == "spell" then
        display_spell(actual_name, data)
    elseif entity_type == "weaponskill" then
        display_weaponskill(actual_name, data)
    end

    return true
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return InfoCommand
