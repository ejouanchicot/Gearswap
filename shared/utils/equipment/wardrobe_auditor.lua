---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Auditor - Find unused items across all jobs
---  ═══════════════════════════════════════════════════════════════════════════
---   Parses ALL job set files as text to extract item names, scans wardrobe
---   bags, and identifies items not referenced by any job's sets.
---   Exports results to wardrobe_audit.txt for easy review.
---
---   Usage: //gs c wardrobeaudit  (or //gs c wa)
---
---   @file    shared/utils/equipment/wardrobe_auditor.lua
---   @author  Tetsouo
---   @version 1.1 - Text parsing (GearSwap blocks loadfile/setfenv)
---   @date    2026-02-13
---  ═══════════════════════════════════════════════════════════════════════════

local WardrobeAuditor = {}

local res = require('resources')

---  ═══════════════════════════════════════════════════════════════════════════
---   CONSTANTS
---  ═══════════════════════════════════════════════════════════════════════════

local ALL_JOBS = {
    'blm', 'brd', 'bst', 'cor', 'dnc', 'drk', 'geo',
    'pld', 'pup', 'rdm', 'run', 'sam', 'thf', 'war', 'whm'
}

local WARDROBE_BAGS = {
    'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
    'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'
}

local BAG_DISPLAY = {
    wardrobe  = 'Wardrobe',
    wardrobe2 = 'Wardrobe 2',
    wardrobe3 = 'Wardrobe 3',
    wardrobe4 = 'Wardrobe 4',
    wardrobe5 = 'Wardrobe 5',
    wardrobe6 = 'Wardrobe 6',
    wardrobe7 = 'Wardrobe 7',
    wardrobe8 = 'Wardrobe 8',
}

-- Equipment slot names used in set files
local SLOT_NAMES = {
    'main', 'sub', 'range', 'ammo',
    'head', 'neck', 'ear1', 'ear2', 'left_ear', 'right_ear',
    'body', 'hands', 'ring1', 'ring2', 'left_ring', 'right_ring',
    'back', 'waist', 'legs', 'feet'
}

---  ═══════════════════════════════════════════════════════════════════════════
---   TEXT-BASED ITEM EXTRACTION
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if a string looks like a valid FFXI item name (not a code/keyword)
--- Filters out augment strings, Lua keywords, and other non-item values
--- @param str string The string to check
--- @return boolean True if it looks like an item name
local function looks_like_item_name(str)
    if not str or str == '' then return false end
    local lower = str:lower()
    -- Skip common non-item strings
    if lower == 'empty' or lower == 'path: a' or lower == 'path: b'
        or lower == 'path: c' or lower == 'path: d' then
        return false
    end
    -- Skip augment-style strings (contain stat patterns like "HP+105", "DEX+20")
    if str:match('^%u%u%u?%u?[%+%-]%d') then return false end
    -- Skip strings that are purely numeric or very short
    if str:match('^%d+$') or #str < 3 then return false end
    -- Skip known Lua/system patterns
    if str:match('^System:') or str:match('^wardrobe') then return false end
    return true
end

--- Add an item name to the used_items accumulator
--- @param item_name string Item name
--- @param used_items table Accumulator
--- @param job_upper string Job abbreviation
local function add_item(item_name, used_items, job_upper)
    if not looks_like_item_name(item_name) then return end
    local lower = item_name:lower()
    if not used_items[lower] then
        used_items[lower] = {}
    end
    used_items[lower][job_upper] = true
end

--- Extract all item names from a set file's text content using pattern matching
--- Catches all string assignments that could be item names:
---   1. = 'Item Name'  (any assignment with single quotes)
---   2. = "Item Name"  (any assignment with double quotes)
---   3. name = 'Item Name' / name = "Item Name"  (augmented item tables)
--- This broad approach catches items in lookup tables (RINGS, EARRINGS, etc.)
--- that are later assigned to slots via variable references.
--- @param content string File content
--- @param used_items table Accumulator {[item_name_lower] = {[job]=true}}
--- @param job_upper string Job abbreviation (e.g. 'WAR')
local function extract_items_from_text(content, used_items, job_upper)
    -- Strip comments to avoid false matches
    local clean = content:gsub('%-%-[^\n]*', '')

    -- Pattern 1: any = 'String Value' (single quotes)
    for item_name in clean:gmatch("=%s*'([^']+)'") do
        add_item(item_name, used_items, job_upper)
    end

    -- Pattern 2: any = "String Value" (double quotes)
    for item_name in clean:gmatch('=%s*"([^"]+)"') do
        add_item(item_name, used_items, job_upper)
    end

    -- Pattern 3: name = 'Item Name' (explicit, in case nested in tables)
    for item_name in clean:gmatch("name%s*=%s*'([^']+)'") do
        add_item(item_name, used_items, job_upper)
    end

    -- Pattern 4: name = "Item Name"
    for item_name in clean:gmatch('name%s*=%s*"([^"]+)"') do
        add_item(item_name, used_items, job_upper)
    end
end

--- Read and parse a single job's set file
--- @param job_lower string Lowercase job abbreviation (e.g. 'war')
--- @param used_items table Accumulator for item names
--- @return boolean success
--- @return string|nil error message
local function parse_job_sets(job_lower, used_items)
    local path = windower.addon_path .. 'data/Tetsouo/sets/' .. job_lower .. '_sets.lua'
    local job_upper = job_lower:upper()

    local file, open_err = io.open(path, 'r')
    if not file then
        return false, open_err or ('Cannot open ' .. path)
    end

    local content = file:read('*all')
    file:close()

    if not content or content == '' then
        return false, 'Empty file'
    end

    extract_items_from_text(content, used_items, job_upper)
    return true, nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WARDROBE SCANNING
---  ═══════════════════════════════════════════════════════════════════════════

--- Collect all name variants for an item (short, full, log forms)
--- Set files may use any variant (e.g. "Spaekona's Coat +4" vs "Spae. Coat +4")
--- @param item_data table Resource item data from res.items[id]
--- @return table Array of lowercase name variants
local function get_all_names(item_data)
    local names = {}
    local seen = {}
    local fields = {'en', 'english', 'enl', 'english_log'}
    for _, field in ipairs(fields) do
        local n = item_data[field]
        if n and type(n) == 'string' and n ~= '' then
            local lower = n:lower()
            if not seen[lower] then
                seen[lower] = true
                table.insert(names, lower)
            end
        end
    end
    return names
end

--- Scan all wardrobe bags and return their contents
--- @return table {bag_name = {{name=string, id=number, all_names=table}, ...}}
--- @return number Total item count
local function scan_wardrobes()
    local items = windower.ffxi.get_items()
    if not items then
        return {}, 0
    end

    local wardrobe_contents = {}
    local total = 0

    for _, bag_name in ipairs(WARDROBE_BAGS) do
        wardrobe_contents[bag_name] = {}
        local bag = items[bag_name]

        if bag and type(bag) == 'table' then
            for _, item in pairs(bag) do
                if type(item) == 'table' and item.id and item.id > 0 then
                    local item_data = res.items[item.id]
                    if item_data then
                        local name = item_data.en or item_data.english
                        if name then
                            table.insert(wardrobe_contents[bag_name], {
                                name = name,
                                id = item.id,
                                all_names = get_all_names(item_data),
                            })
                            total = total + 1
                        end
                    end
                end
            end
        end

        -- Sort alphabetically for clean output
        table.sort(wardrobe_contents[bag_name], function(a, b)
            return a.name:lower() < b.name:lower()
        end)
    end

    return wardrobe_contents, total
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT TO TXT
---  ═══════════════════════════════════════════════════════════════════════════

--- Build and write the audit report
--- @param unused table {bag_name = {item_name, ...}}
--- @param total_items number Total wardrobe items
--- @param used_items table Master used items set
--- @param jobs_loaded table {job_upper = true}
--- @param jobs_failed table {job_upper = error_msg}
--- @return string|nil File path on success
local function export_report(unused, total_items, used_items, jobs_loaded, jobs_failed)
    local output_path = windower.addon_path .. 'data/wardrobe_audit.txt'
    local lines = {}

    -- Header
    local sep = string.rep("=", 75)
    table.insert(lines, sep)
    table.insert(lines, "  WARDROBE AUDIT - Unused Items Report")
    table.insert(lines, "  Date: " .. os.date('%Y-%m-%d %H:%M'))

    -- Jobs info
    local loaded_list = {}
    for job in pairs(jobs_loaded) do
        table.insert(loaded_list, job)
    end
    table.sort(loaded_list)
    table.insert(lines, "  Jobs scanned: " .. table.concat(loaded_list, ', '))

    if next(jobs_failed) then
        local failed_list = {}
        for job, err in pairs(jobs_failed) do
            table.insert(failed_list, job .. ' (' .. tostring(err):sub(1, 50) .. ')')
        end
        table.sort(failed_list)
        table.insert(lines, "  Jobs FAILED: " .. table.concat(failed_list, ', '))
    end

    -- Unique items count
    local unique_count = 0
    for _ in pairs(used_items) do unique_count = unique_count + 1 end
    table.insert(lines, "  Unique items in sets: " .. unique_count)

    table.insert(lines, sep)
    table.insert(lines, "")

    -- Per-wardrobe unused items
    local total_unused = 0

    for _, bag_name in ipairs(WARDROBE_BAGS) do
        local display = BAG_DISPLAY[bag_name] or bag_name
        local bag_unused = unused[bag_name]

        table.insert(lines, "--- " .. display .. " ---")

        if bag_unused and #bag_unused > 0 then
            for _, item_name in ipairs(bag_unused) do
                table.insert(lines, "  " .. item_name)
                total_unused = total_unused + 1
            end
        else
            table.insert(lines, "  (all items used)")
        end

        table.insert(lines, "")
    end

    -- Summary
    local total_used = total_items - total_unused
    table.insert(lines, sep)
    table.insert(lines, string.format("  Total wardrobe items:     %d", total_items))
    table.insert(lines, string.format("  Used by at least 1 job:   %d", total_used))
    table.insert(lines, string.format("  UNUSED:                   %d", total_unused))
    table.insert(lines, sep)

    -- Write file
    local file = io.open(output_path, 'w')
    if not file then
        return nil
    end

    file:write(table.concat(lines, '\n'))
    file:close()

    return output_path
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IN-GAME DISPLAY
---  ═══════════════════════════════════════════════════════════════════════════

local gray   = string.char(0x1F, 160)
local green  = string.char(0x1F, 158)
local yellow = string.char(0x1F, 50)
local red    = string.char(0x1F, 167)
local cyan   = string.char(0x1F, 123)

local function show_ingame_summary(unused, total_items, jobs_count, unique_items, export_path)
    local sep = string.rep("=", 74)

    add_to_chat(121, gray .. sep)
    add_to_chat(121, yellow .. "[WARDROBE AUDIT] " .. cyan .. jobs_count .. " jobs scanned" .. gray .. " | " .. cyan .. unique_items .. " unique items in sets")
    add_to_chat(121, gray .. sep)

    local total_unused = 0

    for _, bag_name in ipairs(WARDROBE_BAGS) do
        local bag_unused = unused[bag_name]
        if bag_unused and #bag_unused > 0 then
            local display = BAG_DISPLAY[bag_name] or bag_name
            add_to_chat(121, red .. "  " .. display .. ": " .. yellow .. #bag_unused .. " unused")
            total_unused = total_unused + #bag_unused
        end
    end

    local total_used = total_items - total_unused

    add_to_chat(121, gray .. sep)
    add_to_chat(121, green .. "  Used: " .. yellow .. total_used .. gray .. "/" .. yellow .. total_items)

    if total_unused > 0 then
        add_to_chat(121, red .. "  Unused: " .. yellow .. total_unused)
    else
        add_to_chat(121, green .. "  All wardrobe items are used!")
    end

    if export_path then
        add_to_chat(121, cyan .. "  Exported: " .. gray .. export_path)
    end

    add_to_chat(121, gray .. sep)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Run the full wardrobe audit across all jobs
--- @return boolean Success
function WardrobeAuditor.audit()
    -- PHASE 1: Parse all job set files and extract item names
    local used_items = {}  -- {[item_name_lower] = {[JOB]=true}}
    local jobs_loaded = {}
    local jobs_failed = {}

    for _, job_lower in ipairs(ALL_JOBS) do
        local job_upper = job_lower:upper()
        local ok, err = parse_job_sets(job_lower, used_items)

        if ok then
            jobs_loaded[job_upper] = true
        else
            jobs_failed[job_upper] = err or 'unknown error'
        end
    end

    local loaded_count = 0
    for _ in pairs(jobs_loaded) do loaded_count = loaded_count + 1 end

    local unique_count = 0
    for _ in pairs(used_items) do unique_count = unique_count + 1 end

    if loaded_count == 0 then
        add_to_chat(167, red .. "[WARDROBE AUDIT] Failed to load any job sets")
        return false
    end

    -- Report failed jobs
    for job, err in pairs(jobs_failed) do
        add_to_chat(200, yellow .. "[WARDROBE AUDIT] Failed to load " .. job .. ": " .. tostring(err):sub(1, 80))
    end

    -- PHASE 2: Scan wardrobes
    local wardrobe_contents, total_items = scan_wardrobes()

    if total_items == 0 then
        add_to_chat(200, yellow .. "[WARDROBE AUDIT] No items found in wardrobes")
        return false
    end

    -- PHASE 3: Compare - find unused items per wardrobe
    local unused = {}

    for _, bag_name in ipairs(WARDROBE_BAGS) do
        unused[bag_name] = {}
        local bag_items = wardrobe_contents[bag_name]

        if bag_items then
            for _, item in ipairs(bag_items) do
                -- Check ALL name variants (en, enl, english, english_log)
                -- Set files may use full name ("Spaekona's Coat +4")
                -- while res.items.en returns abbreviated ("Spae. Coat +4")
                local is_used = false
                for _, variant in ipairs(item.all_names) do
                    if used_items[variant] then
                        is_used = true
                        break
                    end
                end
                if not is_used then
                    table.insert(unused[bag_name], item.name)
                end
            end
        end
    end

    -- PHASE 4: Export to txt
    local export_path = export_report(unused, total_items, used_items, jobs_loaded, jobs_failed)

    -- PHASE 5: Show in-game summary
    show_ingame_summary(unused, total_items, loaded_count, unique_count, export_path)

    return true
end

return WardrobeAuditor
