---  ═══════════════════════════════════════════════════════════════════════════
---   Dual-Boxing Manager - Inter-Character Communication System
---  ═══════════════════════════════════════════════════════════════════════════
---   Manages communication between main and alt characters for dual-boxing.
---   Handles job change notifications and online status tracking.
---
---   Communication Flow:
---     ALT changes job >> send_job_update() >> send tetsouo gs c altjobupdate JOB SUBJOB
---     MAIN receives >> job_self_command() >> receive_alt_job() >> stores in _G.AltJobState
---     MAIN reloads macrobook based on alt job
---
---   @file    shared/utils/dualbox/dualbox_manager.lua
---   @author  Tetsouo
---   @version 1.1 - Style standardization (BRD headers)
---   @date    Created: 2025-10-22 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

-- MessageDualbox lazy-loaded (only when showing messages)
local MessageDualbox = nil
local function get_MessageDualbox()
    if not MessageDualbox then
        MessageDualbox = require('shared/utils/messages/formatters/ui/message_dualbox')
    end
    return MessageDualbox
end

local DualBoxManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Get the target character name based on role
--- For ALT: returns the MAIN character to send updates to
--- For MAIN: returns the ALT character to receive updates from
--- @return string Target character name
local function get_target_character()
    if not _G.DualBoxConfig then
        return nil
    end

    -- Try new clear variable names first
    if _G.DualBoxConfig.role == "alt" then
        -- ALT sends to MAIN
        return _G.DualBoxConfig.main_character or _G.DualBoxConfig.alt_name
    else
        -- MAIN receives from ALT
        return _G.DualBoxConfig.alt_character or _G.DualBoxConfig.alt_name
    end
end

--- Get this character's name
--- @return string This character's name
local function get_this_character()
    if not _G.DualBoxConfig then
        return player and player.name or "Unknown"
    end

    -- Try new clear variable name first, fallback to old name
    return _G.DualBoxConfig.character_name or _G.DualBoxConfig.main_name
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION
---  ═══════════════════════════════════════════════════════════════════════════

--- Initialize dual-boxing system
--- Loads configuration and sets up global state
--- @param config table Optional config override
function DualBoxManager.initialize(config)
    -- Load config if not already loaded
    if not _G.DualBoxConfig then
        -- Detect character name dynamically
        local char_name = "Tetsouo"  -- Default fallback
        if player and player.name then
            char_name = player.name
        end

        local config_path = char_name .. '/config/DUALBOX_CONFIG'
        local success, loaded_config = pcall(require, config_path)

        if success and loaded_config then
            _G.DualBoxConfig = loaded_config
            if _G.DualBoxConfig.debug then
                get_MessageDualbox().show_config_loaded(config_path)
                get_MessageDualbox().show_role(_G.DualBoxConfig.role)

                -- Display names clearly based on role
                local this_char = get_this_character()
                local target_char = get_target_character()

                if _G.DualBoxConfig.role == "alt" then
                    get_MessageDualbox().show_alt_info(this_char, target_char)
                else
                    get_MessageDualbox().show_main_info(this_char, target_char)
                end
            end
        else
            -- Fallback defaults if config not found
            _G.DualBoxConfig = {
                enabled = false,
                role = "main",
                main_name = char_name,
                alt_name = "Unknown",
                timeout = 30,
                debug = false
            }
            get_MessageDualbox().show_config_not_found(config_path)
        end
    end

    -- Override with provided config
    if config then
        for key, value in pairs(config) do
            _G.DualBoxConfig[key] = value
        end
    end

    -- Initialize alt job state if not exists
    if not _G.AltJobState then
        _G.AltJobState = {
            job = nil,
            subjob = nil,
            last_update = 0,
            online = false
        }
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ALT ROLE FUNCTIONS (Kaories >> Tetsouo)
---  ═══════════════════════════════════════════════════════════════════════════

-- De-dup window for send_job_update. Both sides reloading simultaneously
-- triggers two paths to send the same update almost back-to-back:
--   1. ALT auto-init proactively sends once it has player data
--   2. MAIN auto-init sends `requestjob`, ALT responds via handle_job_request
-- Without de-dup MAIN sees two identical altjobupdates per startup, and any
-- additional MAIN reloads pile on more redundant responses. State is stored
-- on `windower` so it survives `gs reload` (which wipes `_G`).
local SEND_DEDUP_WINDOW = 1.5

--- Send job update from ALT to MAIN
--- Called when alt character changes job
--- Uses windower send command to communicate with main character
function DualBoxManager.send_job_update()
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    -- Only alt should send updates
    if _G.DualBoxConfig.role ~= "alt" then
        return
    end

    -- Check if player data is available
    if not player or not player.main_job then
        return
    end

    local main_job = player.main_job
    local sub_job = player.sub_job or "NON"
    local payload = main_job .. '/' .. sub_job

    -- Drop if we just sent the same payload within SEND_DEDUP_WINDOW seconds.
    -- Different payload = real job change, always send through.
    local now = os.clock()
    if windower._dualbox_last_send_payload == payload
       and windower._dualbox_last_send_time
       and (now - windower._dualbox_last_send_time) < SEND_DEDUP_WINDOW then
        return
    end

    -- Get target MAIN character using helper function
    local target_name = get_target_character()

    if not target_name then
        if _G.DualBoxConfig.debug then
            get_MessageDualbox().show_target_error()
        end
        return
    end

    -- Send command to main character
    local command = string.format('send %s gs c altjobupdate %s %s', target_name, main_job, sub_job)
    send_command(command)

    -- Record for de-dup (after we actually sent, so a failed get_target_character
    -- attempt above doesn't poison the window)
    windower._dualbox_last_send_payload = payload
    windower._dualbox_last_send_time = now

    -- Debug message
    if _G.DualBoxConfig.debug then
        get_MessageDualbox().show_job_update_sent(target_name, main_job, sub_job)
    end
end

--- Handle job request from MAIN
--- Called when ALT receives requestjob command
function DualBoxManager.handle_job_request()
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    -- Only alt should respond
    if _G.DualBoxConfig.role ~= "alt" then
        return
    end

    if _G.DualBoxConfig.debug then
        local target_name = get_target_character() or "Unknown"
        get_MessageDualbox().show_job_request_received(target_name)
    end

    -- Send current job info
    DualBoxManager.send_job_update()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN ROLE FUNCTIONS (Tetsouo ← Kaories)
---  ═══════════════════════════════════════════════════════════════════════════

--- Request job info from ALT
--- Called by MAIN on startup to get ALT's current job
function DualBoxManager.request_alt_job()
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    -- Only main should request
    if _G.DualBoxConfig.role ~= "main" then
        return
    end

    local target_name = get_target_character()
    if not target_name then
        return
    end

    -- Send request command to alt
    local command = string.format('send %s gs c requestjob', target_name)
    send_command(command)

    if _G.DualBoxConfig.debug then
        get_MessageDualbox().show_requesting_job(target_name)
    end
end

--- Receive job update from ALT
--- Called when main character receives altjobupdate command
--- Stores alt job info and triggers macrobook reload
--- @param main_job string Alt's main job (e.g., "COR")
--- @param sub_job string Alt's subjob (e.g., "RDM")
function DualBoxManager.receive_alt_job(main_job, sub_job)
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    -- Only main should receive updates
    if _G.DualBoxConfig.role ~= "main" then
        return
    end

    -- Validate parameters
    if not main_job or main_job == "" then
        return
    end

    -- Store alt job state
    _G.AltJobState = {
        job = main_job,
        subjob = sub_job or "NON",
        last_update = os.time(),
        online = true
    }

    -- Always show alt job confirmation (info message)
    local alt_name = get_target_character() or "Alt"
    get_MessageDualbox().show_job_update_received(alt_name, main_job, sub_job or "NON")

    -- Additional debug details (only if debug enabled)
    if _G.DualBoxConfig.debug then
        get_MessageDualbox().show_reloading_macrobook()
    end

    -- Trigger macrobook reload
    if select_default_macro_book then
        coroutine.schedule(function()
            select_default_macro_book()
        end, 0.5)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATUS CHECKING
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if alt character is online
--- Uses timeout to determine if alt is still active
--- @return boolean True if alt is online
function DualBoxManager.is_alt_online()
    if not _G.AltJobState or not _G.AltJobState.online then
        return false
    end

    local timeout = (_G.DualBoxConfig and _G.DualBoxConfig.timeout) or 30
    local time_since_update = os.time() - _G.AltJobState.last_update

    -- Check if timeout exceeded
    if time_since_update > timeout then
        _G.AltJobState.online = false
        return false
    end

    return true
end

--- Get alt character's current job
--- @return string|nil Alt's main job (e.g., "COR"), or nil if offline
function DualBoxManager.get_alt_job()
    if not DualBoxManager.is_alt_online() then
        return nil
    end

    return _G.AltJobState and _G.AltJobState.job or nil
end

--- Get alt character's current subjob
--- @return string|nil Alt's subjob (e.g., "RDM"), or nil if offline
function DualBoxManager.get_alt_subjob()
    if not DualBoxManager.is_alt_online() then
        return nil
    end

    return _G.AltJobState and _G.AltJobState.subjob or nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   UTILITY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Mark alt as offline
--- Called when alt logs out or timeout occurs
function DualBoxManager.mark_alt_offline()
    if _G.AltJobState then
        _G.AltJobState.online = false
    end
end

--- Get time since last alt update
--- @return number Seconds since last update
function DualBoxManager.get_time_since_update()
    if not _G.AltJobState then
        return 9999
    end

    return os.time() - _G.AltJobState.last_update
end

--- Display current dual-boxing status
--- Debug command to show current state
function DualBoxManager.show_status()
    if not _G.DualBoxConfig then
        get_MessageDualbox().show_not_initialized()
        return
    end

    local config = _G.DualBoxConfig
    get_MessageDualbox().show_status_header()
    get_MessageDualbox().show_status_role(config.role)

    local this_char = get_this_character() or "Unknown"
    local target_char = get_target_character() or "Unknown"

    if config.role == "alt" then
        get_MessageDualbox().show_status_alt_info(this_char, target_char)
    else
        get_MessageDualbox().show_status_main_info(this_char, target_char)
    end

    get_MessageDualbox().show_status_enabled(config.enabled)

    if config.role == "main" and _G.AltJobState then
        local online = DualBoxManager.is_alt_online()
        get_MessageDualbox().show_status_alt_online(online)
        if online then
            get_MessageDualbox().show_status_alt_job(_G.AltJobState.job, _G.AltJobState.subjob)
            get_MessageDualbox().show_status_last_update(DualBoxManager.get_time_since_update())
        end
    end

    get_MessageDualbox().show_status_footer()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTO-INITIALIZATION
---  ═══════════════════════════════════════════════════════════════════════════

-- Auto-init runs on every module body execution. The body re-runs on every
-- `gs reload` and also when re-requires bypass `package.loaded` caching
-- (e.g. RDM_COMMANDS doing `require('shared/utils/dualbox/dualbox_manager')`
-- to deliver an altjobupdate message). The former is desired - we want one
-- fresh init per reload. The latter creates a feedback loop:
--   MAIN auto-init -> `requestjob` -> ALT `altjobupdate` -> MAIN command
--   handler re-requires this module -> body re-runs -> schedules a new
--   auto-init coroutine -> 2s later it fires another `requestjob`.
--
-- Tied directly to `windower._gs_reload_count` (incremented by INIT_SYSTEMS.lua
-- on every gs reload, persists on `windower` across reload wipes). The
-- coroutine fires only if the reload counter has advanced since the last
-- fire - "fresh reload" vs "re-require in same session" becomes binary, no
-- timing/threshold guesswork. The per-body counter still debounces multiple
-- bodies queued in the same reload cycle.
windower._dualbox_init_counter = (windower._dualbox_init_counter or 0) + 1
local my_init_counter = windower._dualbox_init_counter

coroutine.schedule(function()
    if my_init_counter ~= windower._dualbox_init_counter then return end
    if not player or not player.name then return end

    local current_reload = windower._gs_reload_count or 0
    if current_reload == windower._dualbox_init_last_reload then return end
    windower._dualbox_init_last_reload = current_reload

    DualBoxManager.initialize()

    if _G.DualBoxConfig and _G.DualBoxConfig.role == "alt" then
        if _G.DualBoxConfig.debug then
            get_MessageDualbox().show_alt_role_detected()
        end
        DualBoxManager.send_job_update()
    elseif _G.DualBoxConfig and _G.DualBoxConfig.role == "main" then
        if _G.DualBoxConfig.debug then
            get_MessageDualbox().show_main_role_detected()
        end
        DualBoxManager.request_alt_job()
    end
end, 2)  -- 2 second delay to ensure player data is loaded

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return DualBoxManager
