---============================================================================
--- DUALBOX Message Data - Dual-Boxing System Messages
---============================================================================
--- Pure data file for dualbox manager messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/dualbox_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- INITIALIZATION MESSAGES
    ---========================================================================

    config_loaded = {
        template = "{lightblue}[DUALBOX] Loaded config from: {config_path}",
        color = 122
    },

    role = {
        template = "{lightblue}[DUALBOX] Role: {role}",
        color = 122
    },

    alt_info_this = {
        template = "{lightblue}[DUALBOX] This character (ALT): {this_char}",
        color = 122
    },

    alt_info_target = {
        template = "{lightblue}[DUALBOX] Sending updates to (MAIN): {target_char}",
        color = 122
    },

    main_info_this = {
        template = "{lightblue}[DUALBOX] This character (MAIN): {this_char}",
        color = 122
    },

    main_info_target = {
        template = "{lightblue}[DUALBOX] Receiving updates from (ALT): {target_char}",
        color = 122
    },

    config_not_found = {
        template = "{red}[DUALBOX] WARNING: Config not found at {config_path}, using defaults",
        color = 167
    },

    alt_role_detected = {
        template = "{lightblue}[DUALBOX] ALT role detected, sending initial job update",
        color = 122
    },

    main_role_detected = {
        template = "{lightblue}[DUALBOX] MAIN role detected, requesting job from ALT",
        color = 122
    },

    ---========================================================================
    --- COMMUNICATION MESSAGES
    ---========================================================================

    job_update_sent = {
        template = "{lightblue}[DUALBOX] Sent job update to {target_name}: {main_job}/{sub_job}",
        color = 122
    },

    job_request_received = {
        template = "{lightblue}[DUALBOX] Received job request from {target_name}, sending update",
        color = 122
    },

    requesting_job = {
        template = "{lightblue}[DUALBOX] Requesting job info from {target_name}",
        color = 122
    },

    job_update_received = {
        template = "{lightblue}[DUALBOX] {role} job: {main_job}/{sub_job}",
        color = 122
    },

    reloading_macrobook = {
        template = "{lightblue}[DUALBOX] Reloading macrobook for ALT job change",
        color = 122
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    target_error = {
        template = "{red}[DUALBOX ERROR] Target character not configured",
        color = 167
    },

    not_initialized = {
        template = "{red}[DUALBOX ERROR] System not initialized. Check dualbox_config.lua",
        color = 167
    },

    ---========================================================================
    --- STATUS DISPLAY MESSAGES
    ---========================================================================

    status_header = {
        template = "{lightblue}========== DUALBOX STATUS ==========",
        color = 122
    },

    status_role = {
        template = "{lightblue}Role: {role}",
        color = 122
    },

    status_alt_this = {
        template = "{lightblue}This character (ALT): {this_char}",
        color = 122
    },

    status_alt_target = {
        template = "{lightblue}Target (MAIN): {target_char}",
        color = 122
    },

    status_main_this = {
        template = "{lightblue}This character (MAIN): {this_char}",
        color = 122
    },

    status_main_target = {
        template = "{lightblue}Target (ALT): {target_char}",
        color = 122
    },

    status_enabled = {
        template = "{lightblue}Enabled: {enabled}",
        color = 122
    },

    status_alt_online = {
        template = "{lightblue}ALT online: {online}",
        color = 122
    },

    status_alt_job = {
        template = "{lightblue}ALT job: {job}/{subjob}",
        color = 122
    },

    status_last_update = {
        template = "{lightblue}Last update: {seconds} seconds ago",
        color = 122
    },

    status_footer = {
        template = "{lightblue}====================================",
        color = 122
    },
}
