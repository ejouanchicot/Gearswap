---============================================================================
--- BRD Song Slots - how many songs a rotation can hold, how many dummies
---============================================================================
--- A Bard holds 2 songs, plus what the instrument of the cast grants
--- ("Grants one / an / two additional song effect(s)" in its description:
--- Blurred Harp +1 1, Terpander 1, Daurdabla 1 or 2, Loughnashade 1 or 2
--- depending on the version owned), plus 1 under Clarion Call. The real
--- songs go on the main instrument (state.MainInstrument); the dummies on the
--- instrument of sets.midcast.DummySong. Dummies only help when their
--- instrument opens more slots than the main one, and only for the slots no
--- song holds yet: a slot a song holds is open, and a new song overwrites the
--- one with the least time left.
---
--- Songs up are read from the game (buffactive lags, see
--- AbilityHelper.is_buff_active); another bard's songs would count too.
---
--- @file    shared/jobs/brd/functions/logic/song_slots.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local SongSlots = {}

local BASE_SLOTS = 2

--- Buff names of the songs a BRD puts on the party (one buff per song up).
local SONG_BUFFS = {}
for _, name in ipairs({'Minuet', 'March', 'Honor March', 'Madrigal', 'Minne', 'Paeon',
        'Ballad', 'Etude', 'Carol', 'Mambo', 'Prelude', 'Aubade', 'Pastoral', 'Fantasia',
        'Operetta', 'Capriccio', 'Round', 'Gavotte', 'Hymnus', 'Mazurka', 'Sirvente',
        'Dirge', 'Scherzo', 'Aria of Passion'}) do
    SONG_BUFFS[name:lower()] = true
end

local function resources()
    local ok, res = pcall(require, 'resources')
    return ok and res or {}
end

--- How many songs are on this character now.
--- @return number
function SongSlots.songs_up()
    local me = windower.ffxi.get_player()
    local buffs = resources().buffs or {}
    local count = 0
    for _, id in ipairs(me and me.buffs or {}) do
        local buff = buffs[id]
        if buff and buff.en and SONG_BUFFS[buff.en:lower()] then count = count + 1 end
    end
    return count
end

--- Extra songs an instrument grants, from the version this character owns.
--- @param name string|nil Instrument name
--- @return number 0, 1 or 2
function SongSlots.instrument_extra(name)
    if type(name) ~= 'string' or name == '' then return 0 end
    local res = resources()
    local owned = require('shared/utils/precast/cast_time').owned_ids()
    local best = 0
    for id, item in pairs(res.items or {}) do
        if (item.en == name or item.enl == name) and owned[id] then
            local desc = res.item_descriptions and res.item_descriptions[id]
            local text = desc and desc.en or ''
            if not text:find('Reives:[^\n]*additional song') then
                if text:find('two additional song') then best = math.max(best, 2)
                elseif text:find('an? additional song') or text:find('one additional song') then best = math.max(best, 1) end
            end
        end
    end
    return best
end

--- Instrument name of a set slot value (string or {name = ...}).
local function piece_name(piece)
    return type(piece) == 'table' and piece.name or piece
end

--- What plan() reads, for //gs c songplan.
--- @return table {clarion, main, main_extra, dummy, dummy_extra, up}
function SongSlots.inputs()
    local main = state and state.MainInstrument and state.MainInstrument.current
    local dummy_set = sets and sets.midcast and sets.midcast.DummySong
    local dummy = dummy_set and piece_name(dummy_set.range)
    return {
        clarion = buffactive['Clarion Call'] and true or false,
        main = main, main_extra = SongSlots.instrument_extra(main),
        dummy = dummy, dummy_extra = SongSlots.instrument_extra(dummy),
        up = SongSlots.songs_up(),
    }
end

--- Plan of a rotation: songs it holds and dummies it needs.
--- @param pack_size number Songs in the pack
--- @return number songs, number dummies, number base (slots the main instrument opens)
function SongSlots.plan(pack_size)
    local i = SongSlots.inputs()
    local clarion = i.clarion and 1 or 0
    local base = BASE_SLOTS + i.main_extra + clarion
    local total = math.min(pack_size, BASE_SLOTS + math.max(i.main_extra, i.dummy_extra) + clarion)
    local dummies = math.max(0, total - math.max(i.up, base))
    return total, dummies, math.min(base, total)
end

return SongSlots
