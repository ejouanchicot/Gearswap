---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Dummy Next - sing the next song as a dummy, then switch back off
---  ═══════════════════════════════════════════════════════════════════════════
---   A real song cast in sets.midcast.DummySong (short duration, dummy
---   instrument) overwrites the same song already up with a low timer, so the
---   game picks it first when a new song needs a slot.
---
---   The switch is state.DummySong, declared by the player in BRD_CUSTOM.lua
---   (values 'onoff' or {'off', 'on'}): the code only reads it. While it is on,
---   the next buff song whose instrument is free goes through the dummy path
---   of midcast_router, instrument included (a CUSTOM rule cannot touch the
---   instrument of a song), and keeps the weapons worn, as a listed dummy
---   does. Once that song has landed, the switch goes back off; an
---   interrupted song leaves it on for the next try.
---
---   Left out: songs with a required instrument (Honor March, Aria of
---   Passion), debuff songs, and the songs already in DUMMY_SONGS.
---
---   @file    shared/jobs/brd/functions/logic/dummy_next.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local DummyNext = {}

local STATE = 'DummySong'

-- Song turned into a dummy by the switch, until its aftercast
local pending = nil

--- @return boolean True when the player switched it on
function DummyNext.is_on()
    local mode = state and state[STATE]
    if not mode then return false end
    return mode.value == true or tostring(mode.current):lower() == 'on'
end

--- Record that this song goes out as a dummy because of the switch.
--- @param spell table
function DummyNext.mark(spell)
    pending = spell.english
end

--- Repaint the HUD if it is up (a state set from code does not repaint it).
local function refresh_hud()
    local ok, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ok and KeybindUI and KeybindUI.is_visible and KeybindUI.is_visible()
            and type(KeybindUI.update) == 'function' then
        KeybindUI.update()
    end
end

--- Switch the state back off: false for 'onoff', 'off' for a list.
local function switch_off()
    local mode = state[STATE]
    if type(mode.value) == 'boolean' then
        mode:set(false)
    else
        pcall(mode.set, mode, 'off')
    end
    require('shared/utils/messages/message_formatter').show_state_display(
        mode.description or STATE, tostring(mode.current))
    refresh_hud()
end

--- Aftercast of a song: the switch goes off once the marked song landed.
--- @param spell table
function DummyNext.on_aftercast(spell)
    if pending == nil or spell.english ~= pending then return end
    pending = nil
    if not spell.interrupted and DummyNext.is_on() then
        switch_off()
    end
end

return DummyNext
