---============================================================================
--- BRD Song Owner - which of the songs on this character are ours
---============================================================================
--- The buff list says no one's name: a March of ours and a March of another
--- bard or a Trust (Joachim) look the same. Two packets together do:
---   - the action packet (0x028, category 4) of every song that lands on us
---     names its caster (actor_id) and the buff it gave (action.param, message
---     230 / 266 "gains the effect of"), read as the server sent it (see
---     shared/utils/core/action_listener.lua: Battlemod rewrites it);
---   - the buff packet (0x063 order 9, shared/utils/buffs/buff_timers.lua)
---     gives each buff its end time: a song buff is one instance,
---     `<buff id>:<end time>`, and a song sung again gets a new end time.
--- The instance that appears or is renewed when a song lands is that song's,
--- paired by buff id in arrival order (either packet may come first, within
--- PAIR_WINDOW seconds). Ours when its caster is this character; another
--- bard's or a Trust's otherwise (seen in play: Joachim and Ulmia, message
--- 266). One of ours whose end time changes (sung over) or that goes (wore
--- off, dispelled) is no longer ours; a shift of JITTER seconds or less is the
--- game's rounding, the same song.
--- The instances of ours are saved in <Character>/saved/brd_own_songs.lua, so
--- a //lua reload gearswap keeps them. Until the first buff packet of a load,
--- the saved ones count when a buff of their id is up.
---
--- @file shared/jobs/brd/functions/logic/song_owner.lua
--- @author ejouanchicot
--- @version 1.1
--- @date Created: 2026-10-01 (replaces the ledger of song_slots.lua)
--- Started from shared/entry/brd.lua (user_setup).
---============================================================================

local SongOwner = {}

local PAIR_WINDOW = 3
local SAVE_FILE = 'brd_own_songs.lua'
--- "<target> gains the effect of <status>" (res/action_messages.lua)
local GAIN_MESSAGES = {[230] = true, [266] = true}

--- Song buff families (res/buffs.lua names): Honor March gives "March".
local FAMILIES = {}
for _, name in ipairs({'Minuet', 'March', 'Madrigal', 'Minne', 'Paeon',
        'Ballad', 'Etude', 'Carol', 'Mambo', 'Prelude', 'Aubade', 'Pastoral', 'Fantasia',
        'Operetta', 'Capriccio', 'Round', 'Gavotte', 'Hymnus', 'Mazurka', 'Sirvente',
        'Dirge', 'Scherzo', 'Aria'}) do
    FAMILIES[name:lower()] = true
end

local family_by_id

--- Buff id -> song family, from the game data (read once).
local function families_by_id()
    if family_by_id then return family_by_id end
    family_by_id = {}
    local ok, res = pcall(function() return rawget(_G, 'res') or require('resources') end)
    for id, buff in pairs(ok and res and res.buffs or {}) do
        local name = type(buff) == 'table' and buff.en and buff.en:lower()
        if name and FAMILIES[name] then family_by_id[id] = name end
    end
    return family_by_id
end

---============================================================================
--- STATE: the instances of ours on windower and in the file; what the last
--- packets showed, per load (another job may have run in between, unheard)
---============================================================================

--- landed: songs seen in 0x028 not paired yet {id, ours, at};
--- appeared: instances seen in 0x063 not paired yet {key, id, at}
local live = {snapshot = nil, landed = {}, appeared = {}}

local function save_path()
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').writable('saved', SAVE_FILE)
    end)
    return ok and path or nil
end

local function load_owned()
    if windower._brd_song_owned then return windower._brd_song_owned end
    local owned = {}
    local path = save_path()
    local ok, saved = pcall(function() return path and windower.file_exists(path) and dofile(path) end)
    for _, key in ipairs(ok and type(saved) == 'table' and saved or {}) do
        if type(key) == 'string' then owned[key] = true end
    end
    windower._brd_song_owned = owned
    return owned
end

local function save_owned()
    local path = save_path()
    if not path then return end
    local keys = {}
    for key in pairs(load_owned()) do keys[#keys + 1] = ('%q'):format(key) end
    local file = io.open(path, 'w')
    if not file then return end
    file:write('-- Song instances of ours (buff id:end time), written by song_owner.lua\nreturn {'
        .. table.concat(keys, ', ') .. '}\n')
    file:close()
end

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('SONGS', fmt, unpack(args)) end)
end

---============================================================================
--- PAIRING
---============================================================================

--- An instance and the song that put it up are paired: kept when ours.
local function settle(key, ours)
    trace('%s: %s', key, ours and 'ours' or 'not ours')
    if not ours then return end
    load_owned()[key] = true
    save_owned()
end

--- What waited longer than PAIR_WINDOW is dropped.
local function fresh(list, now)
    local kept = {}
    for _, e in ipairs(list) do
        if now - e.at <= PAIR_WINDOW then kept[#kept + 1] = e end
    end
    return kept
end

--- The oldest waiting entry of `list` with buff id `id`, taken out.
local function take(list, id)
    for i, e in ipairs(list) do
        if e.id == id then return table.remove(list, i) end
    end
    return nil
end

--- Action packet: a song landing on us, and who sang it.
local function on_action(act)
    if act.category ~= 4 then return end
    local me = windower.ffxi.get_player()
    if not me then return end
    local by_id, now = families_by_id(), os.clock()
    live.landed = fresh(live.landed, now)
    live.appeared = fresh(live.appeared, now)
    for _, target in ipairs(act.targets or {}) do
        if target.id == me.id then
            for _, action in ipairs(target.actions or {}) do
                local id = action.param
                if by_id[id] or act.actor_id == me.id then
                    local actor = windower.ffxi.get_mob_by_id(act.actor_id)
                    trace('0x028 %s (%d) spell %d -> msg %d param %d%s', actor and actor.name or '?',
                        act.actor_id, act.param or 0, action.message or 0, id or 0, by_id[id] and ' (song)' or '')
                end
                if GAIN_MESSAGES[action.message] and by_id[id] then
                    local ours = act.actor_id == me.id
                    local seen = take(live.appeared, id)
                    if seen then settle(seen.key, ours)
                    else live.landed[#live.landed + 1] = {id = id, ours = ours, at = now} end
                end
            end
        end
    end
end

--- The key of `set` that is the same instance as `key`: same buff id, end
--- time within JITTER seconds, not in `used`. The game rounds the end time of
--- one buff differently from one packet to the next (seen in play: 520, 521,
--- 520... with no song sung), and a song sung again ends minutes later.
local JITTER = 2
local function same_instance(key, set, used)
    local id, finish = key:match('^(%d+):(%d+)$')
    for other in pairs(set) do
        local oid, ofinish = other:match('^(%d+):(%d+)$')
        if oid == id and not used[other] and math.abs(tonumber(ofinish) - tonumber(finish)) <= JITTER then
            return other
        end
    end
    return nil
end

--- The instances of ours follow their own end time when it shifts by the
--- rounding (and after a reload, from the saved file); gone otherwise.
local function follow_owned(current)
    local owned, used, lost = load_owned(), {}, {}
    for key in pairs(owned) do
        if current[key] then used[key] = true else lost[#lost + 1] = key end
    end
    -- outside the loop over owned: a key added while pairs() runs breaks it
    for _, key in ipairs(lost) do
        owned[key] = nil
        local now_key = same_instance(key, current, used)
        if now_key then owned[now_key], used[now_key] = true, true end
    end
    local changed = #lost > 0
    if changed then save_owned() end
end

--- Buff packet 0x063 order 9: the song instances up now.
local function on_buffs(data)
    local by_id = families_by_id()
    local current = {}
    for _, buff in ipairs(require('shared/utils/buffs/buff_timers').read(data)) do
        if by_id[buff.id] then current[buff.id .. ':' .. buff.finish] = buff.id end
    end
    local now = os.clock()
    live.landed = fresh(live.landed, now)
    live.appeared = fresh(live.appeared, now)
    -- first packet of this load: what is up was there before, nothing new
    local previous = live.snapshot or current
    local kept = {}
    for key in pairs(current) do
        if previous[key] then kept[key] = true end
    end
    for key in pairs(previous) do
        if not current[key] then
            local shifted = same_instance(key, current, kept)
            if shifted then kept[shifted] = true
            else trace('0x063 gone %s (%s)', key, by_id[previous[key]]) end
        end
    end
    for key, id in pairs(current) do
        if not kept[key] then
            trace('0x063 new %s (%s)', key, by_id[id])
            local song = take(live.landed, id)
            if song then settle(key, song.ours)
            else live.appeared[#live.appeared + 1] = {key = key, id = id, at = now} end
        end
    end
    follow_owned(current)
    live.snapshot = current
end

---============================================================================
--- COUNTS
---============================================================================

--- Songs of ours up on us, and every song up (any bard).
--- Before the first buff packet of a load: the saved instances whose buff id
--- is up, no more per id than the buffs of that id.
--- @return number own, number all
function SongOwner.counts()
    local owned = load_owned()
    if live.snapshot then
        local own, all = 0, 0
        for key in pairs(live.snapshot) do
            all = all + 1
            if owned[key] then own = own + 1 end
        end
        return own, all
    end
    local up, all = {}, 0
    local me = windower.ffxi.get_player()
    local by_id = families_by_id()
    for _, id in ipairs(me and me.buffs or {}) do
        if by_id[id] then up[id] = (up[id] or 0) + 1; all = all + 1 end
    end
    local own = 0
    for key in pairs(owned) do
        local id = tonumber(key:match('^(%d+):'))
        if id and (up[id] or 0) > 0 then up[id] = up[id] - 1; own = own + 1 end
    end
    return own, all
end

--- Listen to the action and buff packets, once per load (a raw event: a plain
--- one from a job file runs GearSwap's refresh on every packet). Both are read
--- as the server sent them: the actions through
--- shared/utils/core/action_listener.lua (Battlemod rewrites 0x028 for the
--- chat), the buffs from `original`.
function SongOwner.start()
    if rawget(_G, '_brd_song_owner_listener') then return end
    _G._brd_song_owner_listener = windower.raw_register_event('incoming chunk', function(id, original)
        if id == 0x063 and original:byte(5) == 9 then pcall(on_buffs, original) end
    end)
    require('shared/utils/core/action_listener').on('brd_song_owner', on_action)
end

return SongOwner
