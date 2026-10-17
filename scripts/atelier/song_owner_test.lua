---============================================================================
--- Test of the song owner (shared/jobs/brd/functions/logic/song_owner.lua)
---============================================================================
--- Played from the trace of Tetsouo BRD on 2026-10-17: four songs of ours, then
--- an Event that held the timers 3 to 4 s. The next buff packet gave every song
--- an end time later by that much, and the songs were taken for another bard's
--- (//gs c songs sang the dummies again). They must stay ours; a song sung by
--- another bard, which comes with its action packet, must not.
---
--- Run from data/: lua5.1 scripts/atelier/song_owner_test.lua
---
--- @file scripts/atelier/song_owner_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-17
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local ME, OTHER = 441611, 999
local chunk_handler, action_handler
local clock = 1000
os.clock = function() return clock end

windower = {
    ffxi = {
        get_player = function() return {id = ME, buffs = {}} end,
        get_mob_by_id = function(id) return {name = id == ME and 'Tetsouo' or 'Other'} end,
        get_party = function() return {} end,
    },
    raw_register_event = function(_, fn) chunk_handler = fn return 1 end,
    file_exists = function() return false end,
}
res = {buffs = {[198] = {en = 'Minuet'}, [199] = {en = 'Madrigal'}, [214] = {en = 'March'}, [207] = {en = 'Capriccio'}}}
package.loaded['shared/utils/buffs/buff_timers'] = {read = function(list) return list end}
package.loaded['shared/utils/core/action_listener'] = {on = function(_, fn) action_handler = fn end}
package.loaded['shared/utils/core/char_paths'] = {writable = function() return nil end}
package.loaded['shared/utils/party/party_jobs'] = {job_of = function() return {main_job = 'BRD'} end}
-- a party with another bard: the songs are told apart by their packets only (no sole_singer shortcut)
windower.ffxi.get_party = function() return {p0 = {name = 'Tetsouo', zone = 1}, p1 = {name = 'Bard', zone = 1}} end

local SongOwner = require('shared/jobs/brd/functions/logic/song_owner')
SongOwner.start()

--- A buff packet 0x063 order 9 with these songs ({id, finish} pairs).
local function buffs(list)
    local data = {}
    for _, b in ipairs(list) do data[#data + 1] = {id = b[1], finish = b[2]} end
    -- the handler checks the order byte (5) of the raw packet: a string stands in, the stub reads the list
    local packet = setmetatable({}, {__index = {byte = function(_, n) return n == 5 and 9 or 0 end}})
    local real = package.loaded['shared/utils/buffs/buff_timers'].read
    package.loaded['shared/utils/buffs/buff_timers'].read = function() return data end
    chunk_handler(0x063, packet)
    package.loaded['shared/utils/buffs/buff_timers'].read = real
end

--- A song landing on us (0x028 category 4, message 230).
local function sung(actor, buff)
    action_handler({category = 4, actor_id = actor, param = 0,
        targets = {{id = ME, actions = {{param = buff, message = 230}}}}})
end

-- first packet of the load: nothing new
buffs({})
-- four songs of ours, each its action then its buff (as in the trace, 13:28)
local up = {}
for _, b in ipairs({{214, 1792237239}, {198, 1792237200}, {198, 1792237213}, {199, 1792237241}}) do
    clock = clock + 4
    sung(ME, b[1])
    up[#up + 1] = b
    buffs(up)
end
local own, all = SongOwner.counts()
check('four songs of ours up', own, 4)
check('four songs up', all, 4)

-- an Event held the timers: every end time later by 3 or 4 s, no song sung (13:29:10)
clock = clock + 20
buffs({{214, 1792237242}, {198, 1792237204}, {198, 1792237216}, {199, 1792237245}})
own, all = SongOwner.counts()
check('after the event, still four of ours', own, 4)
check('and four up', all, 4)

-- a second event, shorter one by one (13:33:47): still ours
clock = clock + 20
buffs({{214, 1792237246}, {198, 1792237207}, {198, 1792237220}, {199, 1792237248}})
own = SongOwner.counts()
check('after a second event, still four of ours', own, 4)

-- another bard sings Madrigal over ours: its action, then the buff with a new end time
clock = clock + 20
sung(OTHER, 199)
buffs({{214, 1792237246}, {198, 1792237207}, {198, 1792237220}, {199, 1792237600}})
own, all = SongOwner.counts()
check("another bard's Madrigal is not ours", own, 3)
check('four songs up', all, 4)

-- the songs moved by different times (not one held timer): not the same songs
clock = clock + 20
buffs({{214, 1792237260}, {198, 1792237207}, {198, 1792237220}, {199, 1792237600}})
own = SongOwner.counts()
check('one song moved alone by 14 s is not taken for ours', own, 2)

print(('%d checks, %d failed'):format(done, failed))
if failed > 0 then os.exit(1) end
