---============================================================================
--- BRD Message Data - Bard Messages
---============================================================================
--- Pure data file for BRD job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/brd_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- ABILITY MESSAGES
    ---========================================================================

    soul_voice_activated = {
        template = "{lightblue}[{job}] {yellow}Soul Voice{green} activated! {gray}Song power boost!",
        color = 1
    },

    soul_voice_ended = {
        template = "{lightblue}[{job}] {yellow}Soul Voice{gray} ended",
        color = 1
    },

    nightingale_activated = {
        template = "{lightblue}[{job}] {yellow}Nightingale{gray}: {green}Casting Time reduced",
        color = 1
    },

    nightingale_active = {
        template = "{lightblue}[{job}] {yellow}Nightingale{green} active",
        color = 1
    },

    troubadour_activated = {
        template = "{lightblue}[{job}] {yellow}Troubadour{gray}: {green}Song duration extended",
        color = 1
    },

    troubadour_active = {
        template = "{lightblue}[{job}] {yellow}Troubadour{green} active",
        color = 1
    },

    marcato_used = {
        template = "{lightblue}[{job}]{gray} Using {yellow}Marcato",
        color = 1
    },

    marcato_honor_march = {
        template = "{lightblue}[{job}]{gray} Using {yellow}Marcato{gray} for {cyan}{song}{gray} ({green}Nightingale + Troubadour active{gray})",
        color = 1
    },

    marcato_skip_buffs = {
        template = "{lightblue}[{job}] {yellow}Marcato{gray} skipped: {orange}Requires Nightingale + Troubadour",
        color = 1
    },

    marcato_skip_soul_voice = {
        template = "{lightblue}[{job}] {yellow}Marcato{gray} skipped: {orange}Soul Voice active (not needed)",
        color = 1
    },

    pianissimo_used = {
        template = "{lightblue}[{job}] {yellow}Pianissimo{gray}: {green}Single-target song",
        color = 1
    },

    pianissimo_target = {
        template = "{lightblue}[{job}]{gray} [{yellow}Pianissimo{gray}]{gray} Targeting: {green}{target}",
        color = 1
    },

    ability_command = {
        template = "{lightblue}[{job}]{gray} Using {yellow}{ability}",
        color = 1
    },

    ---========================================================================
    --- INSTRUMENT LOCK PROTECTION MESSAGES (GENERIC)
    ---========================================================================

    instrument_locked = {
        template = "{lightblue}[{job}] {cyan}{song}{gray} >> {green}{instrument} locked",
        color = 1
    },

    instrument_released = {
        template = "{lightblue}[{job}] {cyan}{song}{gray} >> {green}{instrument} released",
        color = 1
    },

    ---========================================================================
    --- LEGACY HONOR MARCH MESSAGES (BACKWARD COMPATIBILITY)
    ---========================================================================

    honor_march_locked = {
        template = "{lightblue}[{job}] {cyan}Honor March{gray} Protection: {green}Marsyas locked",
        color = 1
    },

    honor_march_released = {
        template = "{lightblue}[{job}] {cyan}Honor March{gray} Protection: {green}Released",
        color = 1
    },

    ---========================================================================
    --- INSTRUMENT SELECTION MESSAGES
    ---========================================================================

    daurdabla_dummy = {
        template = "{lightblue}[{job}]{gray} Dummy Song using {green}Daurdabla{gray} to expand song slots",
        color = 1
    },

    ---========================================================================
    --- SONG CASTING MESSAGES
    ---========================================================================

    songs_casting = {
        template = "{lightblue}[{job}] {green}{rotation}{gray} Rotation: {cyan}Phase 1 > Phase 2 (dummies) > Phase 3",
        color = 1
    },

    song_pack = {
        template = "{lightblue}[{job}] {green}{pack}{gray} Pack: {cyan}{songs}",
        color = 1
    },

    songs_refresh = {
        template = "{lightblue}[{job}]{gray} Refreshing {green}{count}{gray} melee songs {gray}(no dummies)",
        color = 1
    },

    dummy_casting = {
        template = "{lightblue}[{job}]{gray} Casting {green}{count}{gray} dummy songs",
        color = 1
    },

    dummy_cast = {
        template = "{lightblue}[{job}]{gray} Casting {cyan}{dummy}",
        color = 1
    },

    tank_casting = {
        template = "{lightblue}[{job}]{gray} Casting {green}Tank{gray} Pack {cyan}({count} songs)",
        color = 1
    },

    tank_refresh = {
        template = "{lightblue}[{job}]{gray} Refreshing {green}{count}{gray} Tank songs",
        color = 1
    },

    healer_casting = {
        template = "{lightblue}[{job}]{gray} Casting {green}Healer{gray} Pack {cyan}({count} songs)",
        color = 1
    },

    healer_refresh = {
        template = "{lightblue}[{job}]{gray} Refreshing {green}{count}{gray} Healer songs",
        color = 1
    },

    ---========================================================================
    --- INDIVIDUAL SONG MESSAGES
    ---========================================================================

    song_cast = {
        template = "{lightblue}[{job}]{gray} Casting {green}Song {slot}{gray}: {cyan}{song}",
        color = 1
    },

    song_guidance = {
        template = "{lightblue}[{job}]{gray} Note: {green}Song {slot}{gray} requires songs 1-2 + {orange}{dummy_count} {dummy_text}{gray} to be active",
        color = 1
    },

    clarion_required = {
        template = "{lightblue}[{job}] {red}Song 5{gray} requires {yellow}Clarion Call{gray} active!",
        color = 1
    },

    clarion_help = {
        template = "{lightblue}[{job}]{gray} Use {yellow}Soul Voice{gray} to enable {yellow}Clarion Call",
        color = 1
    },

    ---========================================================================
    --- DEBUFF SONG MESSAGES
    ---========================================================================

    lullaby_cast = {
        template = "{lightblue}[{job}]{gray} Casting {cyan}{type} Lullaby II",
        color = 1
    },

    elegy_cast = {
        template = "{lightblue}[{job}]{gray} Casting {cyan}Carnage Elegy",
        color = 1
    },

    requiem_cast = {
        template = "{lightblue}[{job}]{gray} Casting {cyan}Foe Requiem VII",
        color = 1
    },

    threnody_cast = {
        template = "{lightblue}[{job}]{gray} Casting {green}{element}{cyan} Threnody II",
        color = 1
    },

    ---========================================================================
    --- BUFF SONG MESSAGES
    ---========================================================================

    carol_cast = {
        template = "{lightblue}[{job}]{gray} Casting {green}{element}{cyan} Carol II",
        color = 1
    },

    etude_cast = {
        template = "{lightblue}[{job}]{gray} Casting {green}{stat}{cyan} Etude",
        color = 1
    },

    ---========================================================================
    --- SONG REFINEMENT MESSAGES
    ---========================================================================

    song_refinement = {
        template = "{lightblue}[{job}] {cyan}{original}{gray} on cooldown {orange}({recast}s){gray} > Downgrading to {cyan}{downgrade}",
        color = 1
    },

    song_refinement_failed = {
        template = "{lightblue}[{job}] {cyan}{song}{gray} on cooldown {orange}({recast}s){gray} - {red}No downgrade available",
        color = 1
    },

    ---========================================================================
    --- BUFF STATUS MESSAGES
    ---========================================================================

    doom_gained = {
        template = "{lightblue}[{job}] {red}DOOM!{gray} Use Cursna or Holy Water!",
        color = 1
    },

    doom_removed = {
        template = "{lightblue}[{job}] {green}Doom removed",
        color = 1
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    no_pack_configured = {
        template = "{lightblue}[{job}] {red}No song pack configured",
        color = 1
    },

    tank_not_configured = {
        template = "{lightblue}[{job}] {red}Tank pack not configured",
        color = 1
    },

    healer_not_configured = {
        template = "{lightblue}[{job}] {red}Healer pack not configured",
        color = 1
    },

    no_element_selected = {
        template = "{lightblue}[{job}] {red}No threnody element selected",
        color = 1
    },

    no_carol_element = {
        template = "{lightblue}[{job}] {red}No carol element selected",
        color = 1
    },

    no_etude_type = {
        template = "{lightblue}[{job}] {red}No etude type selected",
        color = 1
    },

    no_song_in_slot = {
        template = "{lightblue}[{job}] {red}No song in slot {orange}{slot}",
        color = 1
    },

    pack_not_found = {
        template = "{lightblue}[{job}] {red}Pack not found: {orange}{pack}",
        color = 1
    }
}
