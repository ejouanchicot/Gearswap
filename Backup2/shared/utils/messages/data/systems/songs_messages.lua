---============================================================================
--- SONGS Message Data - Bard Song Messages
---============================================================================
--- Pure data file for BRD song casting and management messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/songs_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SONG ROTATION MESSAGES
    ---========================================================================

    songs_casting = {
        template = "{lightblue}[{job_tag}] {green}{rotation_type}{gray} Rotation: {cyan}Phase 1 > Phase 2 (dummies) > Phase 3",
        color = 1
    },

    song_pack = {
        template = "{lightblue}[{job_tag}] {green}{pack_name}{gray} Pack: {cyan}{song_list}",
        color = 1
    },

    ---========================================================================
    --- HONOR MARCH PROTECTION MESSAGES
    ---========================================================================

    honor_march_locked = {
        template = "{lightblue}[{job_tag}] {cyan}Honor March{gray} Protection: {green}Marsyas locked",
        color = 1
    },

    honor_march_released = {
        template = "{lightblue}[{job_tag}] {cyan}Honor March{gray} Protection: {green}Released",
        color = 1
    },

    ---========================================================================
    --- INSTRUMENT SELECTION MESSAGES
    ---========================================================================

    daurdabla_dummy = {
        template = "{lightblue}[{job_tag}]{gray} Dummy Song using {green}Daurdabla{gray} to expand song slots",
        color = 1
    },

    ---========================================================================
    --- PIANISSIMO MESSAGES
    ---========================================================================

    pianissimo_used = {
        template = "{lightblue}[{job_tag}] {yellow}Pianissimo{gray}: {green}Single-target song",
        color = 1
    },

    pianissimo_target = {
        template = "{lightblue}[{job_tag}]{gray} [{yellow}Pianissimo{gray}]{gray} Targeting: {green}{target_name}",
        color = 1
    },

    ---========================================================================
    --- MARCATO MESSAGES (Song-Related)
    ---========================================================================

    marcato_honor_march = {
        template = "{lightblue}[{job_tag}]{gray} Using {yellow}Marcato{gray} for {cyan}{song_name}{gray} ({green}Nightingale + Troubadour active{gray})",
        color = 1
    },

    marcato_skip_buffs = {
        template = "{lightblue}[{job_tag}] {yellow}Marcato{gray} skipped: {yellow}Requires Nightingale + Troubadour",
        color = 1
    },

    marcato_skip_soul_voice = {
        template = "{lightblue}[{job_tag}] {yellow}Marcato{gray} skipped: {yellow}Soul Voice active (not needed)",
        color = 1
    },
}
