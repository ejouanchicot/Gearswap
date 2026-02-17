---============================================================================
--- BRD Commands Module - Custom Command Handling
---============================================================================
--- Handles BRD-specific commands via //gs c [command]
---
--- Job Abilities (6 commands):
---   soul_voice (sv)   - Soul Voice 1hr
---   nightingale (ni)  - Nightingale
---   troubadour (tr)   - Troubadour
---   nt                - Nightingale + Troubadour combo
---   marcato (ma)      - Marcato
---   pianissimo (pi)   - Pianissimo
---
--- Debuff Songs (4 commands):
---   lullaby           - Horde Lullaby (AOE: auto-upgrade to II if I on cooldown)
---   lullaby2, foe     - Foe Lullaby II (Single: auto-downgrade to I if II on cooldown)
---   elegy             - Carnage Elegy (auto-downgrade to Battlefield if on cooldown)
---   requiem           - Foe Requiem VII (auto-downgrade to VI if on cooldown)
---
--- Pack Rotations (10 commands):
---   songs, meleesong, melee, allsongs - Cast current song pack
---   refresh, meleerefresh             - Refresh melee songs (no dummies)
---   tanksong, tank                    - Cast Tank pack
---   tankrefresh                       - Refresh Tank pack (no dummies)
---   healersong, healer                - Cast Healer pack
---   healerrefresh                     - Refresh Healer pack (no dummies)
---
--- Dummy Songs (3 commands):
---   dummy, dummysongs - Cast all dummy songs
---   dummy1            - Cast dummy song 1 (Gold Capriccio)
---   dummy2            - Cast dummy song 2 (Goblin Gavotte)
---
--- Element/Type Songs (3 commands):
---   threnody          - Cast threnody (current ThrenodyElement state)
---   carol             - Cast carol (current CarolElement state)
---   etude             - Cast etude (current EtudeType state)
---
--- Individual Song Slots (5 commands):
---   song1             - Cast song from slot 1 of current pack
---   song2             - Cast song from slot 2 of current pack
---   song3             - Cast song from slot 3 of current pack
---   song4             - Cast song from slot 4 of current pack
---   song5             - Cast song from slot 5 of current pack
---
--- @file BRD_COMMANDS.lua
--- @author Tetsouo
--- @version 3.0 - Complete migration from old system
--- @date Created: 2025-10-13
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local CommonCommands = nil
local UICommands = nil
local WatchdogCommands = nil
local CycleHandler = nil
local MessageCommands = nil
local MessageFormatter = nil
local SongRotationManager = nil
local BRDSongConfig = nil
local BRDTimingConfig = nil

local function ensure_commands_loaded()
    if not UICommands then
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')
        MessageFormatter = require('shared/utils/messages/message_formatter')
        SongRotationManager = require('shared/jobs/brd/functions/logic/song_rotation_manager')
        BRDSongConfig = _G.BRDSongConfig or {}  -- Loaded from character main file
        BRDTimingConfig = _G.BRDTimingConfig or {}  -- Loaded from character main file
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Cast a song by name with optional Pianissimo auto-detection
--- Auto-activates Marcato for Honor March if Nitro active (without Soul Voice)
--- Auto-activates Pianissimo if targeting a party member
--- @param song_name string Song name to cast
--- @param auto_pianissimo boolean Enable auto-detection (default false)
local function cast_song(song_name, auto_pianissimo)
    if not song_name then
        return
    end

    -- NOTE: Pianissimo auto-activation is now handled ONLY by BRD_PRECAST.lua
    -- This prevents double-casting when using song commands
    -- Simply cast the song normally, BRD_PRECAST will auto-add Pianissimo if needed

    -- Auto-Marcato for configured song (state.MarcatoSong) when NOT targeting another player
    local targeting_other_player = false
    if player and player.target then
        local target = player.target
        if target.id and target.id ~= player.id and target.spawn_type == 13 then
            targeting_other_player = true
        end
    end

    if not targeting_other_player and state and state.MarcatoSong then
        local marcato_enabled = state.MarcatoSong.value ~= 'Off'
        local target_song = nil

        if state.MarcatoSong.value == 'HonorMarch' then
            target_song = 'Honor March'
        elseif state.MarcatoSong.value == 'AriaPassion' then
            target_song = 'Aria of Passion'
        end

        if marcato_enabled and target_song and song_name == target_song then
            local has_ni = buffactive['Nightingale'] or false
            local has_tr = buffactive['Troubadour'] or false
            local has_sv = buffactive['Soul Voice'] or false

            if has_ni and has_tr and not has_sv and not buffactive['Marcato'] then
                -- Check if Marcato is available (not on cooldown)
                local marcato_recast = windower.ffxi.get_ability_recasts()[48] or 0

                if marcato_recast == 0 then
                    -- Marcato ready >> use before target song
                    send_command('input /ja "Marcato" <me>')
                    send_command('wait 2; input /ma "' .. song_name .. '" <me>')
                    MessageFormatter.show_marcato_honor_march(target_song)
                    return
                end
                -- If Marcato on cooldown: cast song without it (no spam)
            end
        end
    end

    -- Determine cast target
    if player and player.target then
        local target = player.target

        -- PRIORITY 1: Targeting self explicitly
        if target.id == player.id then
            send_command('input /ma "' .. song_name .. '" <me>')
            return
        end

        -- PRIORITY 2: Targeting another PC (not self)
        if target.spawn_type == 13 then
            send_command('input /ma "' .. song_name .. '" "' .. target.name .. '"')
            return
        end
    end

    -- PRIORITY 3: Default (monstre, no target) - use <stpc> (subtarget or self)
    send_command('input /ma "' .. song_name .. '" <stpc>')
end

--- Use a job ability by name
--- @param ability_name string Ability name
local function use_ability(ability_name)
    if not ability_name then
        return
    end
    send_command('input /ja "' .. ability_name .. '" <me>')
end

--- Get threnody name for current element
--- @return string Threnody spell name
local function get_current_threnody()
    if not state or not state.ThrenodyElement then
        return nil
    end

    local element = state.ThrenodyElement.current
    local threnodies = {
        Fire = 'Fire Threnody II',
        Ice = 'Ice Threnody II',
        Wind = 'Wind Threnody II',
        Earth = 'Earth Threnody II',
        Lightning = 'Lightning Threnody II',
        Water = 'Water Threnody II',
        Light = 'Light Threnody II',
        Dark = 'Dark Threnody II'
    }

    return threnodies[element]
end

--- Get carol name for current element
--- @return string Carol spell name
local function get_current_carol()
    if not state or not state.CarolElement then
        return nil
    end

    local element = state.CarolElement.current
    local carols = {
        Fire = 'Fire Carol II',
        Ice = 'Ice Carol II',
        Wind = 'Wind Carol II',
        Earth = 'Earth Carol II',
        Lightning = 'Lightning Carol II',
        Water = 'Water Carol II',
        Light = 'Light Carol II',
        Dark = 'Dark Carol II'
    }

    return carols[element]
end

--- Get etude name for current type
--- @return string Etude spell name
local function get_current_etude()
    if not state or not state.EtudeType then
        return nil
    end

    local stat = state.EtudeType.current
    local etudes = {
        STR = 'Herculean Etude',
        DEX = 'Uncanny Etude',
        VIT = 'Vital Etude',
        AGI = 'Swift Etude',
        INT = 'Sage Etude',
        MND = 'Logical Etude',
        CHR = 'Bewitching Etude'
    }

    return etudes[stat]
end

---============================================================================
--- COMMAND HANDLERS
---============================================================================

--- Handle custom BRD commands
--- @param cmdParams table Command parameters
--- @param eventArgs table Event arguments
function job_self_command(cmdParams, eventArgs)
    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    if not cmdParams or #cmdParams == 0 then
        return
    end

    local command = cmdParams[1]:lower()

    -- ==========================================================================
    -- DUAL-BOXING: Receive alt job update
    -- ==========================================================================
    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3])
        end
        eventArgs.handled = true
        return
    end

    -- DUAL-BOXING: Handle job request from MAIN
    -- ==========================================================================
    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    -- UI commands (ui save, ui hide, etc.)
    if UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- WARP RING FIX COMMAND
    -- ==========================================================================
    if command == 'forceidle' then
        -- Force equip idle gear (used by warp system to fix stuck rings after interruption)
        -- Uses multiple retry attempts because FFXI equipment lock takes time to clear

        -- Step 1: Re-enable ring1 using SAME method as disable (via gs command)
        send_command('gs enable ring1')

        -- Step 2: Single attempt with proper timing
        -- With the 20+ second delay, equipment lock should be cleared
        coroutine.schedule(function()
            -- Get the target ring from idle set
            local ring_data = nil
            if sets and sets.idle then
                local target_set = sets.idle

                -- Check IdleMode
                if state and state.IdleMode and state.IdleMode.current then
                    local mode = state.IdleMode.current
                    if sets.idle[mode] and sets.idle[mode].left_ring then
                        ring_data = sets.idle[mode].left_ring
                    end
                end

                -- Fallback to base idle set
                if not ring_data and target_set.left_ring then
                    ring_data = target_set.left_ring
                end
            end

            -- Extract ring name (handle both string and table format)
            local ring_name = nil
            if ring_data then
                if type(ring_data) == 'table' and ring_data.name then
                    ring_name = ring_data.name
                elseif type(ring_data) == 'string' then
                    ring_name = ring_data
                end
            end

            -- Force equip using Windower /equip command (bypass GearSwap)
            -- This is more reliable than GearSwap equip() when slot is locked
            if ring_name then
                send_command('input /equip ring1 "' .. ring_name .. '"')
            end
        end, 1.0)

        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- DEBUG COMMANDS
    -- ==========================================================================
    if command == 'debugmidcast' then
        -- Toggle MidcastManager debug mode
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()

        -- Confirmation message
        MessageCommands.show_debugmidcast_toggled('BRD', _G.MidcastManagerDebugState)

        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- CUSTOM CYCLE STATE (UI-aware cycle)
    -- ==========================================================================
    -- Intercepts cycle commands to check UI visibility
    -- If UI visible: custom cycle + UI update (no message)
    -- If UI invisible: delegate to Mote-Include (shows message)

    if command == 'cyclestate' then
        eventArgs.handled = CycleHandler.handle_cyclestate(cmdParams, eventArgs)
        return
    end

    -- Watchdog commands
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    -- Common commands (reload, checksets, warp)
    if CommonCommands.is_common_command(command) then
        if CommonCommands.handle_command(cmdParams, 'BRD') then
            eventArgs.handled = true
        end
        return
    end

    -- BRD-SPECIFIC COMMANDS

    ---========================================================================
    --- JOB ABILITIES
    ---========================================================================

    if command == 'soul_voice' or command == 'sv' then
        use_ability('Soul Voice')
        MessageFormatter.show_ability_command('Soul Voice (1hr)')
        eventArgs.handled = true
        return
    end

    if command == 'nightingale' or command == 'ni' then
        use_ability('Nightingale')
        MessageFormatter.show_ability_command('Nightingale')
        eventArgs.handled = true
        return
    end

    if command == 'troubadour' or command == 'tr' then
        use_ability('Troubadour')
        MessageFormatter.show_ability_command('Troubadour')
        eventArgs.handled = true
        return
    end

    if command == 'nt' then
        -- Nightingale + Troubadour combo
        use_ability('Nightingale')
        local ability_delay = BRDTimingConfig.ABILITY_DELAYS.nt_combo_delay
        coroutine.schedule(
            function()
                use_ability('Troubadour')
            end,
            ability_delay
        )
        -- Message handled by ability_message_handler (shows individual JA descriptions)
        eventArgs.handled = true
        return
    end

    if command == 'marcato' or command == 'ma' then
        use_ability('Marcato')
        MessageFormatter.show_marcato_used()
        eventArgs.handled = true
        return
    end

    if command == 'pianissimo' or command == 'pi' then
        use_ability('Pianissimo')
        MessageFormatter.show_pianissimo_used()
        eventArgs.handled = true
        return
    end

    ---========================================================================
    --- DEBUFF SONGS
    ---========================================================================

    if command == 'lullaby' then
        send_command('input /ma "Horde Lullaby" <stnpc>')
        MessageFormatter.show_lullaby_cast('Horde')
        eventArgs.handled = true
        return
    end

    if command == 'lullaby2' or command == 'foe' then
        send_command('input /ma "Foe Lullaby II" <stnpc>')
        MessageFormatter.show_lullaby_cast('Foe')
        eventArgs.handled = true
        return
    end

    if command == 'elegy' then
        send_command('input /ma "Carnage Elegy" <stnpc>')
        MessageFormatter.show_elegy_cast()
        eventArgs.handled = true
        return
    end

    if command == 'requiem' then
        send_command('input /ma "Foe Requiem VII" <stnpc>')
        MessageFormatter.show_requiem_cast()
        eventArgs.handled = true
        return
    end

    ---========================================================================
    --- SONG CASTING (PACK ROTATIONS)
    ---========================================================================

    if command == 'songs' or command == 'meleesong' or command == 'melee' or command == 'allsongs' then
        -- Cast current song pack using 3-phase rotation
        SongRotationManager.cast_songs_with_phases(false, '<me>')
        eventArgs.handled = true
        return
    end

    if command == 'dummy' or command == 'dummysongs' then
        -- Cast dummy songs (4 or 5 depending on Clarion Call)
        SongRotationManager.cast_dummy_songs()
        eventArgs.handled = true
        return
    end

    if command == 'dummy1' then
        local dummy_songs = SongRotationManager.get_dummy_songs()
        if dummy_songs and dummy_songs[1] then
            cast_song(dummy_songs[1])
            -- DISABLED: Message already shown by BRD_MIDCAST.lua (daurdabla_dummy)
            -- MessageFormatter.show_dummy_cast(dummy_songs[1])
        end
        eventArgs.handled = true
        return
    end

    if command == 'dummy2' then
        local dummy_songs = SongRotationManager.get_dummy_songs()
        if dummy_songs and dummy_songs[2] then
            cast_song(dummy_songs[2])
            -- DISABLED: Message already shown by BRD_MIDCAST.lua (daurdabla_dummy)
            -- MessageFormatter.show_dummy_cast(dummy_songs[2])
        end
        eventArgs.handled = true
        return
    end

    if command == 'threnody' then
        local threnody = get_current_threnody()
        if not threnody then
            MessageFormatter.show_no_element_selected()
            eventArgs.handled = true
            return
        end

        local element = state.ThrenodyElement.current
        send_command('input /ma "' .. threnody .. '" <stnpc>')
        MessageFormatter.show_threnody_cast(element)
        eventArgs.handled = true
        return
    end

    if command == 'carol' then
        local carol = get_current_carol()
        if not carol then
            MessageFormatter.show_no_carol_element()
            eventArgs.handled = true
            return
        end

        local element = state.CarolElement.current
        cast_song(carol)
        MessageFormatter.show_carol_cast(element)
        eventArgs.handled = true
        return
    end

    if command == 'etude' then
        local etude = get_current_etude()
        if not etude then
            MessageFormatter.show_no_etude_type()
            eventArgs.handled = true
            return
        end

        local stat = state.EtudeType.current
        cast_song(etude)
        MessageFormatter.show_etude_cast(stat)
        eventArgs.handled = true
        return
    end

    ---========================================================================
    --- INDIVIDUAL SONG SLOTS (SIMPLE - JUST CAST FROM PACK)
    ---========================================================================

    if command == 'song1' then
        local songs = SongRotationManager.get_songs_with_replacement()
        if songs and songs[1] then
            cast_song(songs[1], true) -- Enable auto-Pianissimo
            MessageFormatter.show_song_cast(1, songs[1])
        else
            MessageFormatter.show_no_song_in_slot(1)
        end
        eventArgs.handled = true
        return
    end

    if command == 'song2' then
        local songs = SongRotationManager.get_songs_with_replacement()
        if songs and songs[2] then
            cast_song(songs[2], true) -- Enable auto-Pianissimo
            MessageFormatter.show_song_cast(2, songs[2])
        else
            MessageFormatter.show_no_song_in_slot(2)
        end
        eventArgs.handled = true
        return
    end

    if command == 'song3' then
        local songs = SongRotationManager.get_songs_with_replacement()
        if songs and songs[3] then
            cast_song(songs[3], true) -- Enable auto-Pianissimo
            MessageFormatter.show_song_cast(3, songs[3])
        else
            MessageFormatter.show_no_song_in_slot(3)
        end
        eventArgs.handled = true
        return
    end

    if command == 'song4' then
        local songs = SongRotationManager.get_songs_with_replacement()
        if songs and songs[4] then
            cast_song(songs[4], true) -- Enable auto-Pianissimo
            MessageFormatter.show_song_cast(4, songs[4])
        else
            MessageFormatter.show_no_song_in_slot(4)
        end
        eventArgs.handled = true
        return
    end

    if command == 'song5' then
        -- Check for Clarion Call
        if not buffactive['Clarion Call'] then
            MessageFormatter.show_clarion_required()
            eventArgs.handled = true
            return
        end

        local songs = SongRotationManager.get_songs_with_replacement()
        if songs and songs[5] then
            cast_song(songs[5], true) -- Enable auto-Pianissimo
            MessageFormatter.show_song_cast(5, songs[5])
        else
            MessageFormatter.show_no_song_in_slot(5)
        end
        eventArgs.handled = true
        return
    end
end

--- Called when a state field changes value
--- @param stateField string The state field that changed
--- @param newValue string The new value
--- @param oldValue string The old value
function job_state_change(stateField, newValue, oldValue)
    -- Skip UI update for Moving state (handled by AutoMove with flag)
    if stateField == 'Moving' then
        return
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

-- Export to global scope
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

-- Export module
local BRD_COMMANDS = {}
BRD_COMMANDS.job_self_command = job_self_command
BRD_COMMANDS.job_state_change = job_state_change

return BRD_COMMANDS
