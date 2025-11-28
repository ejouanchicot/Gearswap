---============================================================================
--- BRD Timing Configuration - All Song Casting Delays
---============================================================================
--- Centralized timing configuration for BRD song casting system.
--- Defines all delays for different casting scenarios.
---
--- @file config/brd/BRD_TIMING_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local BRDTimingConfig = {}

---============================================================================
--- BASE SONG CASTING DELAYS
---============================================================================
--- These are the base delays between songs depending on active buffs

BRDTimingConfig.SONG_DELAYS = {
    -- Normal casting (no buffs)
    normal = 6.0,           -- 6 seconds between songs (slow casting)

    -- Nightingale + Troubadour (Nitro mode)
    nitro = 2.5,            -- 2.5 seconds between songs (fast casting)

    -- Nightingale + Troubadour + Marcato
    nitro_marcato = 3.5,    -- 3.5 seconds between songs (2.5 + 1.0 Marcato offset)
}

---============================================================================
--- ABILITY DELAYS
---============================================================================
--- Delays for job abilities before songs can be cast

BRDTimingConfig.ABILITY_DELAYS = {
    -- Marcato delays
    marcato_initial = 2.5,      -- Initial delay after Marcato before first song (allow gear swap + animation)
    marcato_offset = 1.0,       -- Offset added to all subsequent song delays

    -- Nightingale + Troubadour combo
    nightingale_delay = 2.0,    -- Delay after Nightingale
    troubadour_delay = 2.0,     -- Delay after Troubadour
    nt_combo_delay = 2.0,       -- Delay between Nightingale and Troubadour

    -- Pianissimo
    pianissimo_delay = 1.5,     -- Delay after Pianissimo for targeting

    -- General ability delay
    general_ability = 1.5,      -- Generic ability usage delay
}

---============================================================================
--- ROTATION-SPECIFIC DELAYS
---============================================================================
--- Special delays for specific song rotation scenarios

BRDTimingConfig.ROTATION_DELAYS = {
    -- Phase switching delays
    dummy_phase_delay = 0.5,    -- Extra delay when switching to dummy songs
    party_phase_delay = 0.5,    -- Extra delay when switching back to party songs

    -- Song refresh delays (no dummies)
    refresh_normal = 6.0,       -- Normal refresh delay
    refresh_nitro = 3.5,        -- Nitro refresh delay
}

---============================================================================
--- CASTING WINDOW ADJUSTMENTS
---============================================================================
--- Fine-tuning adjustments for latency and animation times

BRDTimingConfig.ADJUSTMENTS = {
    -- Latency compensation (adjust based on your connection)
    latency_offset = 0.0,       -- Add extra delay for high latency (0.1-0.3s recommended)

    -- Animation completion buffer
    animation_buffer = 0.1,     -- Small buffer to ensure animations complete

    -- Fast cast adjustment
    fast_cast_reduction = 0.0,  -- Reduce delay if wearing Fast Cast gear (optional)
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get the appropriate song delay based on active buffs and Marcato state
--- @param has_nightingale boolean Nightingale active
--- @param has_troubadour boolean Troubadour active
--- @param marcato_used boolean Marcato was used for this rotation
--- @return number Song delay in seconds
function BRDTimingConfig.get_song_delay(has_nightingale, has_troubadour, marcato_used)
    -- Check for Nitro mode (Nightingale + Troubadour)
    if has_nightingale and has_troubadour then
        -- If Marcato was used, add offset
        if marcato_used then
            return BRDTimingConfig.SONG_DELAYS.nitro_marcato
        else
            return BRDTimingConfig.SONG_DELAYS.nitro
        end
    end

    -- Default: normal casting speed
    return BRDTimingConfig.SONG_DELAYS.normal
end

--- Get the initial delay before first song (after abilities)
--- @param marcato_used boolean Marcato was used
--- @return number Initial delay in seconds
function BRDTimingConfig.get_initial_delay(marcato_used)
    if marcato_used then
        return BRDTimingConfig.ABILITY_DELAYS.marcato_initial
    end

    return 0
end

--- Calculate total delay with adjustments
--- @param base_delay number Base delay
--- @return number Adjusted delay
function BRDTimingConfig.apply_adjustments(base_delay)
    local adjusted = base_delay
    adjusted = adjusted + BRDTimingConfig.ADJUSTMENTS.latency_offset
    adjusted = adjusted + BRDTimingConfig.ADJUSTMENTS.animation_buffer
    adjusted = adjusted - BRDTimingConfig.ADJUSTMENTS.fast_cast_reduction

    -- Ensure minimum delay of 0.1s
    if adjusted < 0.1 then
        adjusted = 0.1
    end

    return adjusted
end

---============================================================================
--- CONFIGURATION SUMMARY
---============================================================================
--- Quick reference for all timing scenarios:
---
--- SCENARIO 1: Normal Casting (no buffs)
---   - Song delay: 6.0s
---   - Total time for 4 songs: ~24 seconds
---
--- SCENARIO 2: Nitro Mode (Nightingale + Troubadour)
---   - Song delay: 2.5s
---   - Total time for 4 songs: ~10 seconds
---
--- SCENARIO 3: Nitro + Marcato
---   - Initial delay: 1.0s (Marcato animation)
---   - Song delay: 3.5s (2.5s + 1.0s Marcato offset)
---   - Total time for 4 songs: ~15 seconds (1.0 + 3.5 + 3.5 + 3.5)
---
--- SCENARIO 4: Song Refresh (no dummies)
---   - Normal: 6.0s between songs
---   - Nitro: 2.5s between songs
---============================================================================

return BRDTimingConfig
