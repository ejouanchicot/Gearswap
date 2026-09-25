---============================================================================
--- BRD Timing Configuration
---============================================================================
--- A song rotation (//gs c songs, //gs c dummy) no longer runs on fixed
--- delays: each song goes out once the previous one is over
--- (shared/jobs/brd/functions/logic/song_queue.lua). What is left to tune:
---   ROTATION_DELAYS.after_song      pause after a song ends, before the next
---                                   (raise it if songs are refused as "too soon")
---   ROTATION_DELAYS.after_locked_song  added after a song that holds its own
---                                   instrument (Honor March, Aria of Passion)
---   ABILITY_DELAYS.nt_combo_delay   Nightingale -> Troubadour (//gs c nt)
---
--- @file config/brd/BRD_TIMING_CONFIG.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-13 | Updated: 2026-09-25 (queued rotation)
---============================================================================

local BRDTimingConfig = {}

BRDTimingConfig.ROTATION_DELAYS = {
    after_song = 3.0,
    after_locked_song = 1.0,   -- added after Honor March / Aria of Passion
}

BRDTimingConfig.ABILITY_DELAYS = {
    nt_combo_delay = 2.0,
}

return BRDTimingConfig
