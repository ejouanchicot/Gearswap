---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles aftercast behavior for Bard job.
---   Returns to idle/engaged sets after songs/spells complete.
---
---   @file    BRD_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-13
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil

---   Handle post-action cleanup
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Clear Pianissimo flag after ANY song completes (success or interrupted)
    -- This allows next Pianissimo to trigger immediately
    if spell.type == 'BardSong' then
        _G.pianissimo_in_progress = false
    end

    -- Clear instrument lock flags after ANY action completes
    -- (Prevents flags from staying stuck if spell interrupted or error occurred)
    if _G.casting_locked_song then
        local song_name = _G.locked_song_name
        local instrument = _G.locked_instrument

        -- Clear all lock flags
        _G.casting_locked_song = nil
        _G.locked_song_name = nil
        _G.locked_instrument = nil

        -- Display release message if song completed successfully
        if spell.type == 'BardSong' and spell.english == song_name and not spell.interrupted then
            -- Lazy load MessageFormatter only when needed
            if not MessageFormatter then
                local ok, mf = pcall(require, 'shared/utils/messages/message_formatter')
                if ok then MessageFormatter = mf end
            end
            MessageFormatter.show_instrument_released(song_name, instrument)
        end
    end

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export to global scope
_G.job_aftercast = job_aftercast

