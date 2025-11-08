---============================================================================
--- BRD Song Refinement Logic Module
---============================================================================
--- Handles intelligent song tier downgrading for debuff songs.
--- Automatically downgrades songs (Lullaby II >> I, etc.) if higher tier is on cooldown.
---
--- @file jobs/brd/functions/logic/song_refinement.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local SongRefinement = {}

-- Load configuration
local BRDSongConfig = _G.BRDSongConfig or {}  -- Loaded from character main file

-- Load message formatter for BRD messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- SONG REFINEMENT LOGIC
---============================================================================

--- Check if a song needs refinement (debuff songs with tier system)
--- @param spell_name string The spell name
--- @return boolean needs_refinement
local function needs_refinement(spell_name)
    if not BRDSongConfig.SONG_REFINE or not BRDSongConfig.SONG_REFINE.enabled then
        return false
    end

    return spell_name:match('Lullaby') or spell_name:match('Elegy') or spell_name:match('Requiem') or
        spell_name:match('Threnody')
end

--- Refine song based on recast availability
--- @param spell table Spell being cast
--- @param eventArgs table Event arguments
--- @return boolean refined True if spell was refined/cancelled
function SongRefinement.refine_song(spell, eventArgs)
    -- Only process bard songs
    if not spell or spell.type ~= 'BardSong' then
        return false
    end

    -- Check if refinement is enabled
    if not BRDSongConfig.SONG_REFINE or not BRDSongConfig.SONG_REFINE.enabled then
        return false
    end

    -- Check if this song type needs refinement
    if not needs_refinement(spell.english) then
        return false
    end

    -- Check if spell is on cooldown (use Windower API)
    if spell.recast_id then
        local recasts = windower.ffxi.get_spell_recasts()
        local recast_time = recasts[spell.recast_id] or 0

        if recast_time > 0 then
            -- Look up downgrade in config
            local downgrade = BRDSongConfig.SONG_REFINE.tiers[spell.english]

            if downgrade then
                -- Cancel original spell
                eventArgs.cancel = true

                -- Cast replacement immediately (use <t> since <laststid> doesn't work)
                send_command('input /ma "' .. downgrade .. '" <t>')

                -- Show refinement message
                local recast_seconds = recast_time / 100
                MessageFormatter.show_song_refinement(spell.english, downgrade, recast_seconds)

                return true
            else
                -- No downgrade available, cancel and show message
                eventArgs.cancel = true
                local recast_seconds = recast_time / 100
                MessageFormatter.show_song_refinement_failed(spell.english, recast_seconds)
                return true
            end
        end
    end

    return false
end

--- Get downgrade for a spell (for command usage)
--- @param spell_name string Spell name
--- @return string|nil downgrade Downgrade spell name or nil
function SongRefinement.get_downgrade(spell_name)
    if not BRDSongConfig.SONG_REFINE or not BRDSongConfig.SONG_REFINE.tiers then
        return nil
    end

    return BRDSongConfig.SONG_REFINE.tiers[spell_name]
end

--- Check if refinement system is enabled
--- @return boolean enabled
function SongRefinement.is_enabled()
    return BRDSongConfig.SONG_REFINE and BRDSongConfig.SONG_REFINE.enabled or false
end

return SongRefinement
