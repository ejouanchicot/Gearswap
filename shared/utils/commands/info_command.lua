---  ═══════════════════════════════════════════════════════════════════════════
---   Info Command - Display Detailed Information for JA/Spells/WS
---  ═══════════════════════════════════════════════════════════════════════════
---   Universal command to query and display formatted information from databases.
---   Works for ALL jobs and displays data with proper message formatting.
---
---   Usage:
---     //gs c info <name>           Display info for JA/Spell/WS
---     //gs c info Last Resort       Display Job Ability details
---     //gs c info Haste             Display Spell details
---     //gs c info Torcleaver        Display Weaponskill details
---
---   Features:
---     - Searches JA, Spell, and WS databases
---     - Shown as a data block, one colour per kind of field (ASCII-safe)
---     - Shows the fields the databases store (description, levels, ...)
---     - Works for any job/subjob combination
---
---   @file    shared/utils/commands/info_command.lua
---   @author  Tetsouo
---   @version 1.3 - Card rendered as an InfoBlock (the look of every data block)
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local InfoCommand = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local MessageInfo = require('shared/utils/messages/formatters/ui/message_info')

-- DataLoader loads each database (abilities, spells, WS) on first use
local DataLoader = require('shared/utils/data/data_loader')

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Sanitize text for FFXI chat (ASCII only, no special chars)
--- @param text string Input text
--- @return string Sanitized ASCII text
local function sanitize_ascii(text)
    if not text then return "" end

    text = tostring(text)

    -- Convert the common Unicode punctuation first: the strip below removes
    -- every non-ASCII byte.
    text = text:gsub("\226\128\153", "'")  -- Right single quote to regular quote
    text = text:gsub("\226\128\156", '"')  -- Left double quote
    text = text:gsub("\226\128\157", '"')  -- Right double quote
    text = text:gsub("\226\128\148", "-")  -- Em dash to hyphen
    text = text:gsub("\226\128\147", "-")  -- En dash to hyphen
    text = text:gsub("\226\128\166", "...") -- Ellipsis to three dots
    text = text:gsub("\195\151", "x")        -- Multiplication sign

    -- Remove non-ASCII characters (keep only 32-126)
    text = text:gsub("[^\32-\126]", "")

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
--- @return string|nil Formatted time (e.g., "5m" or "30s" or "1.5s"), nil for 0/nil
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
        -- One decimal for centisecond values under 10 seconds
        if is_centiseconds and seconds < 10 then
            return string.format("%.1fs", seconds)
        else
            return string.format("%ds", math.floor(seconds))
        end
    end
end

--- Text of a field value, or nil when it is empty or zero.
--- @param key string Field name (Recast/Duration/Cast Time are times)
--- @param value any Field value
--- @param is_spell boolean True if this is spell data (uses centiseconds)
--- @return string|nil
local function format_value(key, value, is_spell)
    if not value or value == "" or value == 0 then
        return nil  -- Skip empty/zero fields
    end

    local value_str
    if type(value) == "table" then
        value_str = format_table_value(value, key)
    elseif key == "Recast" or key == "Duration" then
        -- JA: seconds, Spells: centiseconds
        value_str = format_time(tonumber(value), is_spell == true)
    elseif key == "Cast Time" then
        -- Cast time is always in centiseconds for spells
        value_str = format_time(tonumber(value), true)
    else
        value_str = tostring(value)
    end

    return value_str and sanitize_ascii(value_str) or nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DATA DISPLAY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Display one entity: a data block of its non-empty fields
--- @param name string Entity name
--- @param kind string "Job ability", "Spell" or "Weapon skill"
--- @param fields table Array of {label, value, kind}
--- @param use_centiseconds boolean True if time fields are in centiseconds
local function display_entity(name, kind, fields, use_centiseconds)
    local shown = {}
    for _, field in ipairs(fields) do
        local text = format_value(field[1], field[2], use_centiseconds)
        if text then shown[#shown + 1] = {field[1], text, field[3]} end
    end
    MessageInfo.show_entity(sanitize_ascii(name), kind, shown)
end

--- Display Job Ability information
--- @param ability_name string Ability name
--- @param ability_data table Ability data from database
local function display_job_ability(ability_name, ability_data)
    local fields = {
        {"Type",        ability_data.type},
        {"Description", ability_data.description, 'spell'},
        {"Recast",      ability_data.recast, 'bad'},
        {"Duration",    ability_data.duration, 'good'},
        {"Effect",      ability_data.effect},
        {"Radius",      ability_data.radius},
        {"Cost",        ability_data.cost, 'warn'},
        {"Level",       ability_data.level},
        {"Category",    ability_data.category, 'dim'},
    }

    display_entity(ability_name, "Job ability", fields, false)
end

local JOB_CODES = {
    'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG',
    'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN',
}

--- Spell data stores each job's learn level under the job code (WHM = 21).
--- @param spell_data table Spell data from database
--- @return string|nil "WHM 21, RDM 26", or nil when no job level is stored
local function job_levels(spell_data)
    local parts = {}
    for _, code in ipairs(JOB_CODES) do
        if type(spell_data[code]) == 'number' then
            parts[#parts + 1] = code .. ' ' .. spell_data[code]
        end
    end
    return #parts > 0 and table.concat(parts, ', ') or nil
end

--- Display Spell information
--- @param spell_name string Spell name
--- @param spell_data table Spell data from database
local function display_spell(spell_name, spell_data)
    local fields = {
        {"Type",        spell_data.type},
        {"Category",    spell_data.category, 'dim'},
        {"Description", spell_data.description, 'spell'},
        {"Effect",      spell_data.effect},
        {"Duration",    spell_data.duration, 'good'},
        {"Recast",      spell_data.recast, 'bad'},
        {"MP Cost",     spell_data.mp_cost, 'warn'},
        {"Target",      spell_data.target_type},
        {"Magic",       spell_data.magic_type},
        {"Tier",        spell_data.tier},
        {"Element",     spell_data.element, 'spell'},
        {"Skill",       spell_data.skill, 'dim'},
        {"Level",       spell_data.level},
        {"Jobs",        job_levels(spell_data)},
        {"Notes",       spell_data.notes, 'dim'},
    }

    display_entity(spell_name, "Spell", fields, true)
end

--- Display Weaponskill information
--- @param ws_name string Weaponskill name
--- @param ws_data table Weaponskill data from database
local function display_weaponskill(ws_name, ws_data)
    local fields = {
        {"Type",           ws_data.type},
        {"Description",    ws_data.description},
        {"Skillchain",     ws_data.skillchain, 'spell'},
        {"Element",        ws_data.element, 'spell'},
        {"Mods",           ws_data.mods},
        {"Hits",           ws_data.hits},
        {"FTP",            ws_data.ftp, 'good'},
        {"Skill Required", ws_data.skill_required},
        {"Jobs",           ws_data.jobs},
        {"Weapon Type",    ws_data.weapon_type, 'dim'},
        {"Special Notes",  ws_data.special_notes, 'warn'},
    }

    display_entity(ws_name, "Weapon skill", fields, false)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SEARCH FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN COMMAND HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle info command
--- @param args table Command arguments (name parts)
--- @return boolean True if command was handled
function InfoCommand.handle(args)
    if not args or #args == 0 or (#args == 1 and args[1]:lower() == 'help') then
        MessageInfo.show_usage()
        return true
    end

    -- Join args to handle multi-word names
    local name = table.concat(args, " ")

    -- Search databases (case-insensitive)
    local data, entity_type, actual_name = search_all_databases(name)

    if not data then
        MessageInfo.show_not_found(sanitize_ascii(name))
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return InfoCommand
