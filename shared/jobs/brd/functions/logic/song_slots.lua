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
--- Slots are per bard: another bard's or a Trust's songs on this character
--- hold none of ours. The buff list does not say who cast a buff;
--- song_owner.lua pairs each song instance with the action packet of the song
--- that put it up, which names its caster, and only ours count.
--- //gs c songs full sings every dummy whatever is up.
---
--- @file    shared/jobs/brd/functions/logic/song_slots.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local SongSlots = {}

local BASE_SLOTS = 2

local function resources()
    local ok, res = pcall(require, 'resources')
    return ok and res or {}
end

local SongOwner = require('shared/jobs/brd/functions/logic/song_owner')

--- Songs of this character up on itself, and every song up (any bard).
--- @return number own, number all
function SongSlots.songs_up()
    return SongOwner.counts()
end

--- Extra songs an instrument grants, from the version this character owns.
--- The last value found is kept per instrument (on windower): while the bags
--- read empty (zoning), it stands.
--- @param name string|nil Instrument name
--- @return number 0, 1 or 2
function SongSlots.instrument_extra(name)
    if type(name) ~= 'string' or name == '' then return 0 end
    local res = resources()
    local owned = require('shared/utils/precast/cast_time').owned_ids()
    windower._brd_instrument_extra = windower._brd_instrument_extra or {}
    if not next(owned) then return windower._brd_instrument_extra[name] or 0 end
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
    windower._brd_instrument_extra[name] = best
    return best
end

--- Instrument name of a set slot value (string or {name = ...}).
local function piece_name(piece)
    return type(piece) == 'table' and piece.name or piece
end

--- What plan() reads, for //gs c songplan.
--- @return table {clarion, main, main_extra, dummy, dummy_extra, up}
function SongSlots.inputs()
    local own, all = SongSlots.songs_up()
    local main = state and state.MainInstrument and state.MainInstrument.current
    local dummy_set = sets and sets.midcast and sets.midcast.DummySong
    local dummy = dummy_set and piece_name(dummy_set.range)
    return {
        clarion = buffactive['Clarion Call'] and true or false,
        main = main, main_extra = SongSlots.instrument_extra(main),
        dummy = dummy, dummy_extra = SongSlots.instrument_extra(dummy),
        up = own, up_all = all,
    }
end

--- Plan of a rotation: songs it holds and dummies it needs.
--- @param pack_size number Songs in the pack
--- @param full boolean|nil Every dummy, whatever songs are up
--- @return number songs, number dummies, number base (slots the main instrument opens)
function SongSlots.plan(pack_size, full)
    local i = SongSlots.inputs()
    local clarion = i.clarion and 1 or 0
    local base = BASE_SLOTS + i.main_extra + clarion
    local held = full and 0 or i.up
    -- A slot one of our songs holds stays open, Clarion Call or not: the 5th
    -- song sung under Clarion Call can be sung again while it is up (it was
    -- left out once Clarion Call ended, then wore off and the slot was lost)
    local capacity = BASE_SLOTS + math.max(i.main_extra, i.dummy_extra) + clarion
    local total = math.min(pack_size, math.max(capacity, held))
    local dummies = math.max(0, total - math.max(held, base))
    pcall(function()
        require('shared/utils/debug/trace_log').log('SONGS',
            'plan: main %s +%d, dummy %s +%d, clarion %d, ours up %d / all %d -> %d songs, %d dummies, base %d',
            tostring(i.main), i.main_extra, tostring(i.dummy), i.dummy_extra, clarion,
            i.up, i.up_all, total, dummies, math.min(base, total))
    end)
    return total, dummies, math.min(base, total)
end

return SongSlots
