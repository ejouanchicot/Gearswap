---============================================================================
--- BRD Song Owner - which of the songs on this character are ours
---============================================================================
--- The buff list says no one's name: a March of ours and a March of another
--- bard or a Trust (Joachim) look the same. Each buff comes with its end time
--- though (packet 0x063 order 9, shared/utils/buffs/buff_timers.lua): a song
--- buff is one instance, `<buff id>:<end time>`.
---   - a song of ours finishes on us (record, from BRD_AFTERCAST): the song
---     instance that appears or is renewed (new end time) within CLAIM_WINDOW
---     seconds of it, of that song's family, is ours;
---   - an instance that appears without a song of ours is someone else's;
---   - one of ours whose end time changes without us (another bard sang over
---     it) or that goes (wore off, dispelled, overwritten) is no longer ours.
--- The instances of ours are saved in <Character>/saved/brd_own_songs.lua, so
--- a //lua reload gearswap keeps them. Until the first packet of a session,
--- the saved ones count when a buff of their id is up.
---
--- @file shared/jobs/brd/functions/logic/song_owner.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01 (replaces the ledger of song_slots.lua)
--- Started from shared/entry/brd.lua (user_setup).
---============================================================================

local SongOwner = {}

local CLAIM_WINDOW = 3
local SAVE_FILE = 'brd_own_songs.lua'

--- Song buff families (res/buffs.lua names): Honor March gives "March".
local FAMILIES = {}
for _, name in ipairs({'Minuet', 'March', 'Madrigal', 'Minne', 'Paeon',
        'Ballad', 'Etude', 'Carol', 'Mambo', 'Prelude', 'Aubade', 'Pastoral', 'Fantasia',
        'Operetta', 'Capriccio', 'Round', 'Gavotte', 'Hymnus', 'Mazurka', 'Sirvente',
        'Dirge', 'Scherzo', 'Aria'}) do
    FAMILIES[name:lower()] = true
end
SongOwner.FAMILIES = FAMILIES

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

--- Family of a song name ('Valor Minuet V' -> 'minuet'), nil for a debuff song.
--- @param song string
--- @return string|nil
function SongOwner.family_of(song)
    local name = (song or ''):lower()
    for family in pairs(FAMILIES) do
        if name:find(family, 1, true) then return family end
    end
    return nil
end

---============================================================================
--- STATE: the instances of ours on windower and in the file; what the last
--- packet showed, per load (another job may have run in between, unheard)
---============================================================================

local live = {snapshot = nil, recent = {}, pending = {}}

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
--- CLAIMS
---============================================================================

--- Ours: the instance `key` of `family`.
local function claim(key, family)
    load_owned()[key] = true
    trace('ours: %s (%s)', key, family)
    save_owned()
end

--- A song of ours finished on us (BRD_AFTERCAST, through song_slots.record).
--- @param spell table Spell object from GearSwap
function SongOwner.record(spell)
    if not spell or spell.interrupted or spell.type ~= 'BardSong' then return end
    local target = spell.target
    local me = windower.ffxi.get_player()
    if not target or not (target.type == 'SELF' or (me and target.id == me.id)) then return end
    local family = SongOwner.family_of(spell.english)
    if not family then return end
    local s, now = live, os.clock()
    -- the packet may have come first: a new instance of that family just now
    for i, seen in ipairs(s.recent) do
        if seen.family == family and now - seen.at <= CLAIM_WINDOW then
            table.remove(s.recent, i)
            return claim(seen.key, family)
        end
    end
    s.pending[#s.pending + 1] = {family = family, until_at = now + CLAIM_WINDOW}
end

--- Packet 0x063 order 9: the song instances up now.
local function on_buffs(data)
    local by_id = families_by_id()
    local current = {}
    for _, buff in ipairs(require('shared/utils/buffs/buff_timers').read(data)) do
        if by_id[buff.id] then current[buff.id .. ':' .. buff.finish] = by_id[buff.id] end
    end
    local s, now = live, os.clock()
    -- first packet of this load: what is up was there before, nothing new
    local previous = s.snapshot or current
    for key, family in pairs(current) do
        if not previous[key] then
            local claimed = false
            for i, want in ipairs(s.pending) do
                if want.family == family and now <= want.until_at then
                    table.remove(s.pending, i)
                    claim(key, family)
                    claimed = true
                    break
                end
            end
            if not claimed then s.recent[#s.recent + 1] = {key = key, family = family, at = now} end
        end
    end
    local owned, dropped = load_owned(), false
    for key in pairs(owned) do
        if not current[key] then owned[key] = nil; dropped = true end
    end
    if dropped then save_owned() end
    local keep = {}
    for _, seen in ipairs(s.recent) do
        if now - seen.at <= CLAIM_WINDOW and current[seen.key] then keep[#keep + 1] = seen end
    end
    s.recent = keep
    local pending = {}
    for _, want in ipairs(s.pending) do
        if now <= want.until_at then pending[#pending + 1] = want end
    end
    s.pending = pending
    s.snapshot = current
end

---============================================================================
--- COUNTS
---============================================================================

--- Songs of ours up on us, and every song up (any bard).
--- Before the first packet of a session: the saved instances whose buff id is
--- up, no more per id than the buffs of that id.
--- @return number own, number all
function SongOwner.counts()
    local s, owned = live, load_owned()
    if s.snapshot then
        local own, all = 0, 0
        for key in pairs(s.snapshot) do
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

--- Listen to packet 0x063, once per load (a raw event).
function SongOwner.start()
    if rawget(_G, '_brd_song_owner_listener') then return end
    _G._brd_song_owner_listener = windower.raw_register_event('incoming chunk', function(id, data)
        if id == 0x063 and data:byte(5) == 9 then pcall(on_buffs, data) end
    end)
end

return SongOwner
