---============================================================================
--- COMMANDS Message Data - System Command Messages
---============================================================================
--- Pure data file for system command messages (testcolors, detectregion, etc.)
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/commands_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- TESTCOLORS COMMAND
    ---========================================================================

    testcolors_header = {
        template = "{header}",  -- Pre-built with inline color codes
        color = 1
    },

    testcolors_sample = {
        template = "{sample}",  -- No color tag - sample already contains inline color code
        color = 1
    },

    testcolors_separator = {
        template = "{separator}",  -- Pre-built with inline color codes
        color = 1
    },

    testcolors_footer = {
        template = "{footer}",  -- Pre-built with inline color codes
        color = 1
    },

    ---========================================================================
    --- DETECTREGION COMMAND
    ---========================================================================

    detectregion_header = {
        template = "{purple}========================================\n{purple}FFXI Region Auto-Detection\n{purple}========================================",
        color = 1
    },

    windower_info_header = {
        template = "{blue}Windower FFXI Info:",
        color = 1
    },

    windower_info_field = {
        template = "{blue}  {key}: {value}",
        color = 1
    },

    detection_results_header = {
        template = " \n{purple}========================================\n{purple}DETECTION RESULTS:\n{purple}========================================",
        color = 1
    },

    region_detected = {
        template = "{green}Region Detected: {region}\n{blue}Detection Method: {method}\n{blue}Recommended Orange Code: {orange_code}",
        color = 1
    },

    region_detection_failed = {
        template = "{red}Region: AUTO-DETECTION FAILED\n \n{blue}MANUAL TEST:\n{blue}Look at the line below:\n{orange}Code 057 SAMPLE - Is this ORANGE or CYAN?\n \n{blue}If ORANGE = US (use code 057)\n{blue}If WHITE/NO COLOR = EU (use code 002 - Rose)\n \n{blue}To set manually:\n{blue}  //gs c setregion us\n{blue}  //gs c setregion eu",
        color = 1
    },

    detectregion_footer = {
        template = "{purple}========================================",
        color = 1
    },

    region_saved = {
        template = "{blue}Region saved to _G.DETECTED_FFXI_REGION",
        color = 1
    },

    ---========================================================================
    --- SETREGION COMMAND
    ---========================================================================

    setregion_usage = {
        template = "{red}Usage: //gs c setregion <eu|us>",
        color = 167
    },

    region_set_us = {
        template = "{green}Region set to: US\n{blue}Orange color code: 057",
        color = 1
    },

    region_set_eu = {
        template = "{green}Region set to: EU\n{blue}Warning color code: 002 (Rose - no orange on EU)",
        color = 1
    },

    region_set_jp = {
        template = "{green}Region set to: JP\n{blue}Orange color code: 057",
        color = 1
    },

    invalid_region = {
        template = "{red}Invalid region: {region}\n{blue}Valid options: us, eu, jp",
        color = 1
    },

    region_reload_required = {
        template = "{blue}Region saved to _G.DETECTED_FFXI_REGION\n{blue}Reload GearSwap to apply changes",
        color = 1
    },

    ---========================================================================
    --- LOCKSTYLE COMMAND
    ---========================================================================

    lockstyle_reapplying = {
        template = "{green}Reapplying lockstyle...",
        color = 158
    },

    ---========================================================================
    --- WARP ERROR MESSAGES
    ---========================================================================

    warp_error_header = {
        template = "{red}========================================\n{red}[WARP] ERROR LOADING WARP COMMANDS:\n{red}========================================",
        color = 167
    },

    warp_error = {
        template = "{red}{error}",
        color = 167
    },

    warp_error_footer = {
        template = "{red}========================================",
        color = 167
    },

    warp_testing_modules = {
        template = "{red}[WARP] Testing individual modules...",
        color = 167
    },

    warp_module_test = {
        template = "{red}  {module}: {status}",
        color = 167
    },

    ---========================================================================
    --- DEBUGSUBJOB COMMAND
    ---========================================================================

    debugsubjob_header = {
        template = "{purple}========================================\n{purple}[DEBUG] Subjob Information\n{purple}========================================",
        color = 1
    },

    debugsubjob_no_player = {
        template = "{red}[DEBUG] Player data not available",
        color = 167
    },

    main_job_info = {
        template = "{blue}Main Job: {job}\n{blue}Main Job Level: {level}",
        color = 1
    },

    sub_job_info = {
        template = "{blue}Sub Job: {job}\n{blue}Sub Job Level: {level}",
        color = 1
    },

    zone_info_header = {
        template = " ",
        color = 1
    },

    zone_id = {
        template = "{blue}Zone ID: {zone_id}",
        color = 1
    },

    zone_name = {
        template = "{blue}Zone Name: {zone_name}",
        color = 1
    },

    zone_info_unavailable = {
        template = " \n{blue}Zone Info: Not available",
        color = 1
    },

    debugsubjob_instructions = {
        template = "{purple}========================================\n \n{blue}TEST INSTRUCTIONS:\n{blue}1. Use this command OUTSIDE Odyssey\n{blue}2. Note your Sub Job Level (should be 1-49)\n{blue}3. Enter Odyssey Sheol Gaol\n{blue}4. Use command again in Odyssey\n{blue}5. Check if Sub Job Level = 0 (subjob disabled)\n{purple}========================================",
        color = 1
    },

    ---========================================================================
    --- JAMSG COMMAND
    ---========================================================================

    jamsg_config_error = {
        template = "{red}[JA_MSG] ERROR: Config file not found\n{red}Path: shared/config/JA_MESSAGES_CONFIG.lua",
        color = 167
    },

    jamsg_status_header = {
        template = "{purple}========================================\n{purple}[JA_MSG] Current Display Mode\n{purple}========================================",
        color = 1
    },

    jamsg_current_mode = {
        template = "{green}Mode: {mode}\n \n{cyan}Available modes:\n{yellow}  full   {gray}- Show name + description\n{yellow}  on     {gray}- Show name only\n{yellow}  off    {gray}- Disable all messages\n \n{cyan}Usage: {white}//gs c jamsg <full|on|off>\n{purple}========================================",
        color = 1
    },

    jamsg_invalid_mode = {
        template = "{red}[JA_MSG] Invalid mode: {mode}\n{blue}Valid modes: full, on, off",
        color = 1
    },

    jamsg_mode_changed_full = {
        template = "{green}[JA_MSG] Display mode changed to: {yellow}full\n \n{cyan}Example output:\n{lightblue}  [DNC/SAM] {yellow}Haste Samba {green}activated! {gray}Attack speed +10%",
        color = 1
    },

    jamsg_mode_changed_on = {
        template = "{green}[JA_MSG] Display mode changed to: {yellow}on\n \n{cyan}Example output:\n{lightblue}  [DNC/SAM] {yellow}Haste Samba {green}activated!",
        color = 1
    },

    jamsg_mode_changed_off = {
        template = "{green}[JA_MSG] Display mode changed to: {yellow}off\n \n{cyan}Example output:\n{gray}  (no message displayed)",
        color = 1
    },

    jamsg_set_failed = {
        template = "{red}[JA_MSG] Failed to set display mode",
        color = 167
    },

    ---========================================================================
    --- SPELLMSG COMMAND
    ---========================================================================

    spellmsg_config_error = {
        template = "{red}[SPELL_MSG] ERROR: Config file not found\n{red}Path: shared/config/ENHANCING_MESSAGES_CONFIG.lua",
        color = 167
    },

    spellmsg_status_header = {
        template = "{purple}========================================\n{purple}[SPELL_MSG] Current Display Mode\n{purple}========================================",
        color = 1
    },

    spellmsg_current_mode = {
        template = "{green}Mode: {mode}\n \n{cyan}Available modes:\n{yellow}  full   {gray}- Show name + description\n{yellow}  on     {gray}- Show name only\n{yellow}  off    {gray}- Disable all messages\n \n{orange}Note: Controls ALL spell types (Enhancing,\n{orange}      Dark, Elemental, Healing, Divine, BRD,\n{orange}      GEO, BLU, SMN, etc.) EXCEPT Enfeebling\n \n{cyan}Usage: {white}//gs c spellmsg <full|on|off>\n{purple}========================================",
        color = 1
    },

    spellmsg_invalid_mode = {
        template = "{red}[SPELL_MSG] Invalid mode: {mode}\n{blue}Valid modes: full, on, off",
        color = 1
    },

    spellmsg_mode_changed_full = {
        template = "{green}[SPELL_MSG] Display mode changed to: {yellow}full\n \n{cyan}Example output:\n{lightblue}  [GEO] {cyan}Aspir {gray}>> Absorbs MP (no undead).\n{lightblue}  [BLM] {cyan}Fire III {gray}>> Deals fire damage.",
        color = 1
    },

    spellmsg_mode_changed_on = {
        template = "{green}[SPELL_MSG] Display mode changed to: {yellow}on\n \n{cyan}Example output:\n{lightblue}  [GEO] {cyan}Aspir\n{lightblue}  [BLM] {cyan}Fire III",
        color = 1
    },

    spellmsg_mode_changed_off = {
        template = "{green}[SPELL_MSG] Display mode changed to: {yellow}off\n \n{cyan}Example output:\n{gray}  (no message displayed)",
        color = 1
    },

    spellmsg_set_failed = {
        template = "{red}[SPELL_MSG] Failed to set display mode",
        color = 167
    },

    ---========================================================================
    --- WSMSG COMMAND
    ---========================================================================

    wsmsg_config_error = {
        template = "{red}[WS_MSG] ERROR: Config file not found\n{red}Path: shared/config/WS_MESSAGES_CONFIG.lua",
        color = 167
    },

    wsmsg_status_header = {
        template = "{purple}========================================\n{purple}[WS_MSG] Current Display Mode\n{purple}========================================",
        color = 1
    },

    wsmsg_current_mode = {
        template = "{green}Mode: {mode}\n \n{cyan}Available modes:\n{yellow}  full   {gray}- Show name + description + TP\n{yellow}  on     {gray}- Show name + TP only\n{yellow}  off    {gray}- Disable all messages\n \n{cyan}Usage: {white}//gs c wsmsg <full|on|off>\n{purple}========================================",
        color = 1
    },

    wsmsg_invalid_mode = {
        template = "{red}[WS_MSG] Invalid mode: {mode}\n{blue}Valid modes: full, on, off",
        color = 1
    },

    wsmsg_mode_changed_full = {
        template = "{green}[WS_MSG] Display mode changed to: {yellow}full\n \n{cyan}Example output:\n{lightblue}  [WAR/SAM] {pink}Upheaval {gray}>> Four hits. Damage varies with TP. {gray}({green}2500 TP{gray})",
        color = 1
    },

    wsmsg_mode_changed_on = {
        template = "{green}[WS_MSG] Display mode changed to: {yellow}on\n \n{cyan}Example output:\n{gray}  {pink}Upheaval {gray}({white}2500 TP{gray})",
        color = 1
    },

    wsmsg_mode_changed_off = {
        template = "{green}[WS_MSG] Display mode changed to: {yellow}off\n \n{cyan}Example output:\n{gray}  (no message displayed)",
        color = 1
    },

    wsmsg_set_failed = {
        template = "{red}[WS_MSG] Failed to set display mode",
        color = 167
    },

    ---========================================================================
    --- DEBUGWARP COMMAND
    ---========================================================================

    warp_debug_toggled = {
        template = "{green}[Warp] Debug mode: {status}",
        color = 158
    },

    ---========================================================================
    --- DEBUGMIDCAST COMMAND
    ---========================================================================

    debugmidcast_toggled = {
        template = "{purple}[{job}_COMMANDS] Debug toggled! Current state: {debug_state}",
        color = 159
    },
}
