---============================================================================
--- BRD Instrument Lock Configuration
---============================================================================
--- Defines which songs require specific instruments to be locked during cast
---
--- Why instrument locking is needed:
---   - Some songs (Honor March, Aria of Passion) have special mechanics
---   - The instrument MUST remain equipped throughout the ENTIRE cast
---   - If instrument changes during precast/midcast/movement, the song fails
---   - This system protects critical instruments from being swapped
---
--- How it works:
---   1. PRECAST: Detect song + equip instrument + set lock flag
---   2. MIDCAST: Force instrument to stay equipped
---   3. MOVEMENT: Prevent speed gear from replacing instrument
---   4. AFTERCAST: Clear lock flag + release instrument
---
--- @file    instrument_lock_config.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-11-07
---============================================================================

local InstrumentLockConfig = {}

---============================================================================
--- CONFIGURATION TABLE
---============================================================================

--- Songs that require instrument locking during cast
--- Key: Song name (spell.english)
--- Value: Instrument name (exact item name)
InstrumentLockConfig.LOCKED_SONGS = {
    ['Honor March'] = 'Marsyas',        -- Honor March requires Marsyas
    ['Aria of Passion'] = 'Loughnashade' -- Aria of Passion requires Loughnashade
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if a song requires instrument locking
--- @param song_name string Song name (spell.english)
--- @return boolean True if song requires instrument lock
function InstrumentLockConfig.requires_lock(song_name)
    return InstrumentLockConfig.LOCKED_SONGS[song_name] ~= nil
end

--- Get the required instrument for a song
--- @param song_name string Song name (spell.english)
--- @return string|nil Instrument name, or nil if not found
function InstrumentLockConfig.get_instrument(song_name)
    return InstrumentLockConfig.LOCKED_SONGS[song_name]
end

--- Get all locked songs (for debugging/display)
--- @return table Table of song names
function InstrumentLockConfig.get_all_locked_songs()
    local songs = {}
    for song_name, _ in pairs(InstrumentLockConfig.LOCKED_SONGS) do
        table.insert(songs, song_name)
    end
    return songs
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return InstrumentLockConfig
