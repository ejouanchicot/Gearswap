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

-- Valid FFXI job codes - used to filter directory listing
-- (so non-job files like sets_template.lua, util_sets.lua etc. are ignored)
local VALID_JOBS = {
    blm=true, blu=true, brd=true, bst=true, cor=true, dnc=true, drg=true,
    drk=true, geo=true, mnk=true, nin=true, pld=true, pup=true, rdm=true,
    rng=true, run=true, sam=true, sch=true, smn=true, thf=true, war=true, whm=true,
}

--- Resolve the active character's sets directory. Each char has its own
--- sets folder under data/<CharName>/sets/. Falls back to 'Tetsouo/sets/'
--- if no player info is available (rare race during init).
--- @return string Absolute path with trailing slash
local function sets_dir()
    local p = windower.ffxi.get_player()
    local char_name = (p and p.name) or 'Tetsouo'
    return windower.addon_path .. 'data/' .. char_name .. '/sets/'
end

--- Recursively walk a directory tree and return all .lua file paths.
--- Defined here (instead of further down) because discover_job_files() needs
--- it. The modular sets layout (2026-05) puts gear definitions under subfolders
--- (e.g. Tetsouo/sets/common/rings.lua, Tetsouo/sets/brd/armor.lua), so a
--- flat scan would miss them.
--- Heuristic: entries ending in `.lua` are files; everything else is a subdir
--- (windower API doesn't expose is_dir).
--- @param root_dir string Absolute path WITH trailing slash
--- @return table Array of absolute .lua file paths
local function walk_lua_files(root_dir)
    local out = {}
    local stack = {root_dir}
    local visited = {}  -- guard against pathological loops
    while #stack > 0 do
        local dir = table.remove(stack)
        if not visited[dir] then
            visited[dir] = true
            local entries = windower.get_dir(dir)
            if entries then
                for _, name in ipairs(entries) do
                    if name:lower():match('%.lua$') then
                        table.insert(out, dir .. name)
                    else
                        table.insert(stack, dir .. name .. '/')
                    end
                end
            end
        end
    end
    return out
end

--- Discover job set files and group them by job. Supports both layouts:
---   - Flat:    Tetsouo/sets/blm_sets.lua          (legacy + Kaories)
---   - Modular: Tetsouo/sets/blm/blm_sets.lua      (migrated 2026-05-11)
---              Tetsouo/sets/blm/armor.lua, capes.lua, weapons.lua, ...
--- Files in `common/` (e.g. rings.lua) apply to every discovered job because
--- they typically declare equipment shared across all jobs.
--- @return table {[job_lower] = {file_path, file_path, ...}}
local function discover_job_files()
    local dir = sets_dir()
    local common = {}
    local jobs = {}

    for _, path in ipairs(walk_lua_files(dir)) do
        local rel = path:sub(#dir + 1):gsub('\\', '/')
        if rel:match('^common/') then
            table.insert(common, path)
        else
            -- Try flat layout first: <job>_sets.lua at root
            local flat = rel:match('^(%w+)_sets%.lua$')
            -- Then modular: <job>/anything.lua
            local nested = rel:match('^(%w+)/')
            local job = (flat or nested or ''):lower()
            if VALID_JOBS[job] then
                jobs[job] = jobs[job] or {}
                table.insert(jobs[job], path)
            end
        end
    end

    -- Common files apply to every discovered job
    for _, paths in pairs(jobs) do
        for _, cp in ipairs(common) do
            table.insert(paths, cp)
        end
    end

    return jobs
end

--- Auto-discover job set files in <CharName>/sets/. Drop a new <job>_sets.lua
--- (flat) or <job>/anything.lua (modular) and it's picked up automatically.
--- @return table Array of job_lower strings, sorted alphabetically
local function discover_jobs()
    local jobs = {}
    for job in pairs(discover_job_files()) do
        table.insert(jobs, job)
    end
    table.sort(jobs)
    return jobs
end

local WARDROBE_BAGS = {
    'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
    'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'
}

-- Wardrobes whose contents are intentionally NOT in any job's gear sets:
--   wardrobe7 = craft gear + utility items (Warp Ring, Nexus Cape, etc.)
-- These bags are still scanned for total counts but their items are NEVER
-- flagged as "unused" in the report.
local IGNORED_WARDROBES = {
    wardrobe7 = true,
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

--- Read and parse all set files belonging to a single job. Handles flat
--- (<job>_sets.lua) and modular (<job>/*.lua + common/*.lua) layouts uniformly
--- by consulting discover_job_files().
--- @param job_lower string Lowercase job abbreviation (e.g. 'war')
--- @param used_items table Accumulator for item names
--- @return boolean|string status: true=loaded, 'missing'=no files (skip), false=error
--- @return string|nil error message (only when status is false)
local function parse_job_sets(job_lower, used_items)
    local paths = discover_job_files()[job_lower]
    if not paths or #paths == 0 then
        return 'missing', nil
    end

    local job_upper = job_lower:upper()
    local any_loaded = false
    local last_err

    for _, path in ipairs(paths) do
        local file, open_err = io.open(path, 'r')
        if file then
            local content = file:read('*all')
            file:close()
            if content and content ~= '' then
                extract_items_from_text(content, used_items, job_upper)
                any_loaded = true
            end
        else
            last_err = open_err or ('Cannot open ' .. path)
        end
    end

    if not any_loaded then
        return false, last_err or 'no files readable'
    end
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

local REPORT_SEP = string.rep("=", 75)

--- @return number Number of keys in a set-style table
local function count_keys(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

--- What was scanned and what refused to load.
local function write_report_header(lines, used_items, jobs_loaded, jobs_failed)
    table.insert(lines, REPORT_SEP)
    table.insert(lines, "  WARDROBE AUDIT - Unused Items Report")
    table.insert(lines, "  Date: " .. os.date('%Y-%m-%d %H:%M'))

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

    table.insert(lines, "  Unique items in sets: " .. count_keys(used_items))
    table.insert(lines, REPORT_SEP)
    table.insert(lines, "")
end

--- One block per wardrobe, listing what no job asks for.
--- @return number Total unused items across every wardrobe judged
local function write_report_body(lines, unused)
    local total_unused = 0

    for _, bag_name in ipairs(WARDROBE_BAGS) do
        local bag_unused = unused[bag_name]
        table.insert(lines, "--- " .. (BAG_DISPLAY[bag_name] or bag_name) .. " ---")

        if IGNORED_WARDROBES[bag_name] then
            table.insert(lines, "  (ignored - reserved for craft/utility)")
        elseif bag_unused and #bag_unused > 0 then
            for _, item_name in ipairs(bag_unused) do
                table.insert(lines, "  " .. item_name)
                total_unused = total_unused + 1
            end
        else
            table.insert(lines, "  (all items used)")
        end

        table.insert(lines, "")
    end

    return total_unused
end

--- The three numbers that have to add up to the wardrobe total.
local function write_report_summary(lines, total_items, total_unused, total_ignored)
    table.insert(lines, REPORT_SEP)
    table.insert(lines, string.format("  Total wardrobe items:     %d", total_items))
    if total_ignored > 0 then
        table.insert(lines, string.format("  Ignored (craft/utility):  %d", total_ignored))
    end
    table.insert(lines, string.format("  Used by at least 1 job:   %d",
        total_items - total_unused - total_ignored))
    table.insert(lines, string.format("  UNUSED:                   %d", total_unused))
    table.insert(lines, REPORT_SEP)
end

--- Build and write the audit report
--- @param unused table {bag_name = {item_name, ...}}
--- @param total_items number Total wardrobe items
--- @param total_ignored number Items in IGNORED_WARDROBES (not counted as used/unused)
--- @param used_items table Master used items set
--- @param jobs_loaded table {job_upper = true}
--- @param jobs_failed table {job_upper = error_msg}
--- @return string|nil File path on success
local function export_report(unused, total_items, total_ignored, used_items, jobs_loaded, jobs_failed)
    local output_path = windower.addon_path .. 'data/wardrobe_audit.txt'
    local lines = {}

    write_report_header(lines, used_items, jobs_loaded, jobs_failed)
    local total_unused = write_report_body(lines, unused)
    write_report_summary(lines, total_items, total_unused, total_ignored)

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
--- Parse every job whose set file auto-discovery found.
--- Drop a new job_sets.lua in Tetsouo/sets/ and the next audit picks it up;
--- no edit here is needed.
--- @return table used_items {[item_name_lower] = {[JOB]=true}}
--- @return table jobs_loaded {[JOB] = true}
--- @return table jobs_failed {[JOB] = error message}
local function parse_all_job_sets()
    local used_items, jobs_loaded, jobs_failed = {}, {}, {}

    for _, job_lower in ipairs(discover_jobs()) do
        local job_upper = job_lower:upper()
        local status, err = parse_job_sets(job_lower, used_items)

        if status == true then
            jobs_loaded[job_upper] = true
        elseif status ~= 'missing' then
            -- 'missing' cannot happen here: the job came from discovery
            jobs_failed[job_upper] = err or 'unknown error'
        end
    end

    return used_items, jobs_loaded, jobs_failed
end

--- Wardrobe items no job asks for.
--- Every name variant is checked, not just the one res.items reports: a set
--- file may spell a piece out in full ("Spaekona's Coat +4") where the
--- resource gives the abbreviation ("Spae. Coat +4").
--- @return table [bag_name] = { item names }
local function find_unused_items(wardrobe_contents, used_items)
    local unused = {}

    for _, bag_name in ipairs(WARDROBE_BAGS) do
        unused[bag_name] = {}
        -- Ignored wardrobes hold gear deliberately absent from every job's
        -- sets - craft gear, utility items - so nothing there is "unused".
        if not IGNORED_WARDROBES[bag_name] then
            for _, item in ipairs(wardrobe_contents[bag_name] or {}) do
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

    return unused
end

--- @return number Items sitting in wardrobes the audit does not judge
local function count_ignored_items(wardrobe_contents)
    local total = 0
    for bag_name in pairs(IGNORED_WARDROBES) do
        local bag_items = wardrobe_contents[bag_name]
        if bag_items then
            total = total + #bag_items
        end
    end
    return total
end

function WardrobeAuditor.audit()
    local used_items, jobs_loaded, jobs_failed = parse_all_job_sets()
    local loaded_count = count_keys(jobs_loaded)

    if loaded_count == 0 then
        add_to_chat(167, red .. "[WARDROBE AUDIT] Failed to load any job sets")
        add_to_chat(167, red .. "[WARDROBE AUDIT] Scanned dir: " .. sets_dir())
        return false
    end

    for job, err in pairs(jobs_failed) do
        add_to_chat(200, yellow .. "[WARDROBE AUDIT] Failed to load " .. job .. ": " .. tostring(err):sub(1, 80))
    end

    local wardrobe_contents, total_items = scan_wardrobes()
    if total_items == 0 then
        add_to_chat(200, yellow .. "[WARDROBE AUDIT] No items found in wardrobes")
        return false
    end

    local unused = find_unused_items(wardrobe_contents, used_items)
    local total_ignored = count_ignored_items(wardrobe_contents)

    local export_path = export_report(unused, total_items, total_ignored, used_items,
        jobs_loaded, jobs_failed)
    show_ingame_summary(unused, total_items, loaded_count, count_keys(used_items), export_path)

    return true
end

--- Public: build the cross-job item usage map without exporting a report.
--- Used by the wardrobe organizer to compute frequency-based wardrobe layout.
--- @return table {[item_name_lower] = {[JOB]=true, ...}}
function WardrobeAuditor.build_frequency_map()
    local used_items = {}
    for _, job_lower in ipairs(discover_jobs()) do
        parse_job_sets(job_lower, used_items)
    end
    return used_items
end

-- Map "wardrobe N" -> bag id used by FFXI internally
local BAG_NAME_TO_ID = {
    ['wardrobe']=8, ['wardrobe 1']=8, ['wardrobe1']=8,
    ['wardrobe 2']=10, ['wardrobe2']=10,
    ['wardrobe 3']=11, ['wardrobe3']=11,
    ['wardrobe 4']=12, ['wardrobe4']=12,
    ['wardrobe 5']=13, ['wardrobe5']=13,
    ['wardrobe 6']=14, ['wardrobe6']=14,
    ['wardrobe 7']=15, ['wardrobe7']=15,
    ['wardrobe 8']=16, ['wardrobe8']=16,
}

--- Public: extract bag constraints from all set files. Items defined as
--- `{name='X', bag='wardrobe N', ...}` need to physically live in that bag
--- for GearSwap to find them (especially important for multi-instance rings
--- like Chirich Ring +1 x2 that must be in different wardrobes).
---
--- Recursively scans every .lua file under data/<CharName>/sets/ so pin
--- definitions in shared modules (e.g. common/rings.lua) and in modular
--- per-job folders (e.g. brd/armor.lua) are all picked up.
--- @return table {[item_name_lower] = {bag_id_1, bag_id_2, ...}} (set as array)
function WardrobeAuditor.build_pinned_bags()
    local pinned = {}  -- item_name_lower -> set of bag ids (deduped)

    local function add_pin(name, bag)
        local bag_id = BAG_NAME_TO_ID[bag:lower()]
        if not bag_id then return end
        local key = name:lower()
        pinned[key] = pinned[key] or {}
        for _, b in ipairs(pinned[key]) do
            if b == bag_id then return end
        end
        table.insert(pinned[key], bag_id)
    end

    for _, path in ipairs(walk_lua_files(sets_dir())) do
        local file = io.open(path, 'r')
        if file then
            local content = file:read('*all')
            file:close()
            if content and content ~= '' then
                -- Strip comments
                local clean = content:gsub('%-%-[^\n]*', '')
                -- Iteratively process innermost {...} blocks (those with NO
                -- nested braces). Each pass extracts name/bag from leaf-level
                -- tables, then replaces the block with '' so the formerly-outer
                -- table becomes a new leaf for the next pass.
                --
                -- This handles three layouts uniformly:
                --   1. Flat:        {name='X', bag='W1'}                 (single pass)
                --   2. With augs:   {name='X', augments={...}, bag='W1'} (augments
                --                                                          stripped pass 1,
                --                                                          name/bag pass 2)
                --   3. Nested map:  local Rings = { A = {name='X', bag='W1'},
                --                                   B = {name='X', bag='W2'} }
                --                   (all inner ring defs found in pass 1; the
                --                    old %b{} loop only matched the OUTER table
                --                    and grabbed the FIRST name/bag — missing
                --                    every other entry, including the W2 pin)
                local guard = 0
                while clean:find('{[^{}]*}') and guard < 200 do
                    guard = guard + 1
                    clean = clean:gsub('({[^{}]*})', function(block)
                        local name = block:match("name%s*=%s*['\"]([^'\"]+)['\"]")
                        local bag = block:match("bag%s*=%s*['\"]([^'\"]+)['\"]")
                        if name and bag then
                            add_pin(name, bag)
                        end
                        return ''
                    end)
                end
            end
        end
    end

    return pinned
end

--- Public: collect every item name used by ANY job set file in the active
--- character's sets folder.
--- Used by the alt-character wardrobe organize mode (//gs c wo alt) which
--- considers items globally rather than per-active-job.
---
--- The value is a sub-table mapping each job that uses the item, but most
--- callers only need a truthy/falsy presence check (any non-nil sub-table
--- is truthy in Lua) - that's why `Items.is_used_name` works without
--- inspecting the inner table.
---
--- @return table {[item_name_lower] = {[JOB_UPPER] = true, ...}}
function WardrobeAuditor.collect_all_used_names()
    local used = {}
    for _, job_lower in ipairs(discover_jobs()) do
        local status, _err = parse_job_sets(job_lower, used)
        -- status ∈ {true, 'missing', false}; we only care about success
    end
    return used
end

return WardrobeAuditor
