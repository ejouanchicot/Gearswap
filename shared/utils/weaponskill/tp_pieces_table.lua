---============================================================================
--- TP Pieces Table - the Atelier's worked-out TP pieces, read by the game
---============================================================================
--- The Atelier (atelier/app/js/tp_table.js) works out, with its damage engine,
--- which of the job's TP pieces each weaponskill set gains from at each TP,
--- and writes it at each export of the job into its own file,
--- <Char>/atelier/overrides/tp_pieces_<JOB>.lua (one file a job since 2026-11-14:
--- the one file of every job was read again at each export, 46 ms for 2 jobs and
--- growing with each job, audit 2026-11-14 P2-1):
---
---   return {
---       WAR = {
---           at = '2026-11-12 14:00',
---           sets = {    -- each weaponskill set once, as GearSwap puts it on (its weapons point at it)
---               ['sets.precast.WS.Disaster'] = {ear1 = 'Hoxne Earring', legs = 'Nyame Flanchard', ...},
---           },
---           weaponskills = {
---               ['Disaster'] = {
---                   ['Laphria'] = {
---                       {   -- one variant per weaponskill set (Disaster, Disaster.Solo...)
---                           path = 'sets.precast.WS.Disaster',
---                           segments = {              -- from its TP to the next one's
---                               {tp = 1000, p = {ear1 = 'Moonshade Earring', legs = 'Boii Cuisses +3'}, g = 0.262},
---                               {tp = 2000, p = {ear1 = 'Moonshade Earring'}, g = 0.117},
---                               {tp = 3000, p = {}, g = 0},     -- nothing worth it
---                           },
---                       },
---                   },
---               },
---           },
---       },
---   }
---
--- Worked out every 50 TP, only the TP where the pieces change written (a WAR's
--- table: 334 KB with a row every 50 TP, the first version; a load read it in ~0.25 s).
--- The TP of a segment is the TP shown plus the buffs' TP Bonus (Warcry): the
--- weapon's and Fencer's are already in the engine's figures for that weapon.
--- g = what the pieces add to the weaponskill's average damage (0.262 = +26.2 %),
--- once the set pieces they replace are taken off.
--- Read as data, never run (shared/utils/core/lua_data.lua), once per load and
--- only the job's file; forget() after the Atelier writes one again
--- (shared/utils/atelier/atelier_live.lua /save).
---
--- @file shared/utils/weaponskill/tp_pieces_table.lua
--- @author ejouanchicot
--- @version 2.0
--- @date Created: 2026-11-12
---============================================================================

local TPPiecesTable = {}

--- The file of a job's table, as the Atelier saves it (char_paths.lua puts it in atelier/overrides/).
--- @param job string Main job ('WAR')
--- @return string 'tp_pieces_WAR.lua'
function TPPiecesTable.file(job)
    return 'tp_pieces_' .. tostring(job):upper() .. '.lua'
end

local cache = {}   -- by job: the table read, false when the job has no file

--- A job's table, read once per load.
--- @param job string Main job
--- @return table|nil {<JOB> = {at, sig, sets, weaponskills}}
function TPPiecesTable.read(job)
    if not job then return nil end
    if cache[job] ~= nil then return cache[job] or nil end
    cache[job] = false
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    local path = ok and CharPaths and CharPaths.file('atelier', TPPiecesTable.file(job))
    if not path then return nil end
    local f = io.open(path, 'rb')
    if not f then return nil end
    local text = f:read('*a')
    f:close()
    local data = require('shared/utils/core/lua_data').parse(text)
    cache[job] = type(data) == 'table' and type(data[job]) == 'table' and data or false
    return cache[job] or nil
end

--- Read the files again at the next weaponskill (the Atelier just wrote one).
function TPPiecesTable.forget()
    cache = {}
end

--- The variants of a weaponskill with a weapon, for a job.
--- @param job string Main job ('WAR')
--- @param ws string Weaponskill name
--- @param weapon string|nil Main weapon name
--- @return table|nil {{path, set, segments}...}
function TPPiecesTable.variants(job, ws, weapon)
    local data = TPPiecesTable.read(job)
    local mine = data and job and type(data[job]) == 'table' and data[job]
    local by_ws = mine and type(mine.weaponskills) == 'table' and mine.weaponskills[ws]
    local list = type(by_ws) == 'table' and weapon and by_ws[weapon]
    if type(list) ~= 'table' then return nil end
    -- the set from the job's `sets` (a variant written with its own `set`, the first version, keeps it)
    local sets = type(mine.sets) == 'table' and mine.sets or {}
    for _, v in ipairs(list) do
        if type(v) == 'table' and v.set == nil and v.path then v.set = sets[v.path] end
    end
    return list
end

--- When the job's table was worked out ('2026-11-12 14:00'), or nil.
--- @param job string
--- @return string|nil
function TPPiecesTable.date(job)
    local data = TPPiecesTable.read(job)
    return data and type(data[job]) == 'table' and data[job].at or nil
end

_G.TPPiecesTable = TPPiecesTable

return TPPiecesTable
