---============================================================================
--- Wardrobe Organizer - Read-only reports (scan, keep)
---============================================================================
--- `//gs c wo scan` and `//gs c wo keep`. Neither moves an item nor touches
--- the organizer's run state, which is why they live apart from the
--- orchestrator: they can be read without following a run.
---
--- @file shared/utils/wardrobe/lib/reports.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-18
---============================================================================

local Config = require('shared/utils/wardrobe/lib/config')
local Chat = require('shared/utils/wardrobe/lib/chat')
local res = require('resources')

local Reports = {}

--- Four per line: sixty-five names one per line would push the rest of the
--- chat window out of view, and the reader wants the set, not a column.
--- @param names table Array of names (sorted in place)
local function list_names(names)
    table.sort(names)
    for i = 1, #names, 4 do
        local row = {}
        for j = i, math.min(i + 3, #names) do row[#row + 1] = names[j] end
        Chat.info('  ' .. table.concat(row, ',  '))
    end
end

--- Everything owned, by lowercase name, so a declared piece can be told from
--- a piece actually held.
--- @return table [name_lower] = bag api name
local function owned_item_names()
    local owned = {}
    local items = windower.ffxi.get_items()
    if not items then return owned end
    for bag_id in pairs(res.bags) do
        local api = res.bags[bag_id].api
        local bag = items[api]
        if type(bag) == 'table' then
            for _, entry in pairs(bag) do
                local id = type(entry) == 'table' and entry.id or nil
                local data = id and id > 0 and res.items[id]
                if data and data.en then owned[data.en:lower()] = api end
            end
        end
    end
    return owned
end

--- Write the figures a layout decision needs, which chat cannot hold.
---
--- The one that matters: a set naming a piece does not mean the character has
--- it. Sizing wardrobes from the sets alone overestimates, sometimes badly.
--- @param found table Warp items owned
--- @param total number Warp items the database knows
--- @param where table [name] = bag it was found in
--- @return string|nil Path written
local function write_scan_report(found, total, where)
    local p = windower.ffxi.get_player()
    -- Named per character: scanning the alt after the main used to overwrite
    -- the main's report, and the two are meant to be compared.
    local path = windower.addon_path .. 'data/wardrobe_scan_'
        .. ((p and p.name) or 'unknown') .. '.txt'
    local file = io.open(path, 'w')
    if not file then return nil end

    local out = {}
    local function w(line) out[#out + 1] = line end

    w(string.rep('=', 74))
    w('  WARDROBE SCAN - ' .. ((p and p.name) or '?')
        .. ' (' .. ((p and p.main_job) or '?') .. '/' .. ((p and p.sub_job) or '?') .. ')')
    w('  ' .. os.date('%Y-%m-%d %H:%M:%S'))
    w(string.rep('=', 74))
    w('')

    w('BAGS')
    w(string.rep('-', 74))
    local bag_ids = {}
    for id in pairs(res.bags) do bag_ids[#bag_ids + 1] = id end
    table.sort(bag_ids)
    for _, id in ipairs(bag_ids) do
        local info = windower.ffxi.get_bag_info(id)
        if info and info.enabled then
            w(string.format('  %-14s id=%-3d %4d / %-4d used   %4d free%s',
                res.bags[id].en, id, info.count, info.max, info.max - info.count,
                res.bags[id].equippable and '   (equippable)' or ''))
        end
    end
    w('')

    w(string.format('WARP ITEMS  -  %d owned of %d in the database', #found, total))
    w(string.rep('-', 74))
    for _, name in ipairs(found) do
        w(string.format('  %-28s %s', name, where[name] or '?'))
    end
    if #found == 0 then w('  (none found)') end
    w('')

    -- Declared vs held, per job. This is the number the sets cannot give.
    -- The call is guarded as well as the require: build_frequency_map walks
    -- the sets folder, and a character without one would otherwise take the
    -- whole command down after the owned list had already been written.
    local ok, Auditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
    local freq_ok, freq = false, nil
    if ok and Auditor and Auditor.build_frequency_map then
        freq_ok, freq = pcall(Auditor.build_frequency_map)
    end

    if freq_ok and type(freq) == 'table' and next(freq) then
        local owned = owned_item_names()
        local per_job, per_job_owned = {}, {}
        local total_declared, total_owned = 0, 0
        local missing = {}

        for name, jobs in pairs(freq) do
            total_declared = total_declared + 1
            local held = owned[name] ~= nil
            if held then total_owned = total_owned + 1 else missing[#missing + 1] = name end
            for job in pairs(jobs) do
                per_job[job] = (per_job[job] or 0) + 1
                if held then per_job_owned[job] = (per_job_owned[job] or 0) + 1 end
            end
        end

        w(string.format('GEAR  -  %d names in the sets, %d actually held',
            total_declared, total_owned))
        w(string.rep('-', 74))
        local jobs = {}
        for job in pairs(per_job) do jobs[#jobs + 1] = job end
        table.sort(jobs)
        for _, job in ipairs(jobs) do
            w(string.format('  %-6s declared %4d   held %4d', job,
                per_job[job], per_job_owned[job] or 0))
        end
        w('')

        table.sort(missing)
        w(string.format('DECLARED BUT NOT HELD  (%d)', #missing))
        w(string.rep('-', 74))
        for _, name in ipairs(missing) do w('  ' .. name) end
        if #missing == 0 then w('  (none - every declared piece is owned)') end
        w('')
    else
        -- Say nothing was read rather than print zeros: "0 declared, 0 held"
        -- reads as a finding, and it would be a false one.
        w('GEAR')
        w(string.rep('-', 74))
        w('  No set file could be read under data/<char>/sets/.')
        w('  No conclusion about declared or held gear can be drawn from this run.')
        w('')
    end

    w(string.rep('=', 74))
    w('END')

    file:write(table.concat(out, '\n'))
    file:close()
    return path
end

--- Record which warp items this character actually has, and write the list.
---
--- Without it the organizer works from all 65 the database knows, which is
--- harmless for slots but tells you nothing about your own rings.
--- Also writes data/wardrobe_scan_<char>.txt (bags, warp items, declared vs held).
function Reports.scan_warp_items()
    local ok, WarpOwned = pcall(require, 'shared/utils/wardrobe/lib/warp_owned')
    if not ok or not WarpOwned then
        Chat.error('warp_owned module not available')
        return
    end

    local found, total, where = WarpOwned.scan()

    Chat.banner('Wardrobe - warp items owned')
    Chat.detail('Known to the database', total)
    Chat.detail('Found on this character', #found)

    if #found > 0 then
        list_names(found)
        local path, err = WarpOwned.save(found)
        if path then
            Chat.success('List written: ' .. path)
            Chat.info('  Re-run after acquiring or discarding one.')
        else
            Chat.error('Could not write the list: ' .. tostring(err))
        end
    else
        Chat.warn('None found. List not written - the full database stays in use.')
    end

    -- The report goes to a file because the figures that decide a layout -
    -- bag occupancy, declared versus held - do not fit in a chat window.
    local report = write_scan_report(found, total, where)
    if report then
        Chat.success('Report written: ' .. report)
    else
        Chat.error('Could not write the report')
    end
    Chat.separator()
end

--- Show what the organizer keeps out of overflow beyond what the sets name.
---
--- This exists because the rule is otherwise invisible: a player cannot tell
--- whether their Warp Ring is safe without moving their whole wardrobe to find
--- out. Moves nothing.
function Reports.show_kept()
    Config.refresh()

    local overflow_ok = true
    for _, bag_id in ipairs(Config.OVERFLOW_BAGS or {}) do
        local bag = res.bags[bag_id]
        if not (bag and bag.equippable) then overflow_ok = false end
    end

    -- Read the names from their sources rather than from the lowercased set
    -- the organizer works with, so they print the way the game spells them.
    local keep_items = {}
    for _, name in ipairs(Config.KEEP_ITEMS or {}) do keep_items[#keep_items + 1] = tostring(name) end

    local warp_items, warp_source = {}, 'none'
    if not overflow_ok then
        local owned_ok, WarpOwned = pcall(require, 'shared/utils/wardrobe/lib/warp_owned')
        local owned = owned_ok and WarpOwned and WarpOwned.load() or nil
        if owned then
            warp_items, warp_source = owned, 'scanned (//gs c wo scan)'
        else
            local ok, WarpDatabase = pcall(require, 'shared/utils/warp/database/warp_database_core')
            if ok and WarpDatabase and WarpDatabase.get_all_item_names then
                warp_items = WarpDatabase.get_all_item_names()
                warp_source = 'full database - run //gs c wo scan to narrow it'
            end
        end
    end

    Chat.banner('Wardrobe - kept out of overflow')
    Chat.detail('Config', Config.LOADED_CHAR_CONFIG or 'defaults')
    Chat.detail('Overflow equippable', overflow_ok and 'yes' or 'no')
    Chat.detail('Total kept', #keep_items + #warp_items)

    if #keep_items > 0 then
        Chat.section('KEEP_ITEMS (' .. #keep_items .. ')')
        list_names(keep_items)
    end

    if overflow_ok then
        Chat.section('Warp items')
        Chat.info('  not pinned - overflow is equippable, so they work from there')
    else
        Chat.section('Warp items (' .. #warp_items .. ')')
        Chat.info('  pinned - overflow cannot be equipped from')
        Chat.info('  source: ' .. warp_source)
        list_names(warp_items)
    end

    if #keep_items + #warp_items == 0 then
        Chat.info('  nothing beyond what the sets name')
    end
    Chat.separator()
end

return Reports
