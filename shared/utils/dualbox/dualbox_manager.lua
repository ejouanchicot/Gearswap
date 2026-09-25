---============================================================================
--- Dual-Boxing Manager - Inter-Character Communication System
---============================================================================
--- Manages communication between main and alt characters for dual-boxing.
--- Handles job change notifications and online status tracking.
---
--- Communication Flow (both roles; "alt" = the other box):
---   auto-init >> send_job_update() >> send <other> gs c altjobupdate JOB SUB MLVL SLVL NAME WEAPON
---   auto-init >> request_alt_job() >> send <each other box> gs c requestjob
---   requestjob >> handle_job_request() >> send_job_update(true)
---   main hand changes weapon type >> send_job_update() (alt_states.lua)
---   altjobupdate >> receive_alt_job() >> stores in _G.AltJobState (tracked
---     partner) and alt_states.lua (every sender), reloads macrobook
---
--- @file shared/utils/dualbox/dualbox_manager.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2025-10-22
---============================================================================

local AltStates = require('shared/utils/dualbox/alt_states')

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

--- Get the other box's character name based on role
--- For ALT: returns the MAIN character
--- For MAIN: returns the ALT character
--- @return string|nil Target character name
local function get_target_character()
    if not _G.DualBoxConfig then
        return nil
    end

    -- New variable names first, legacy alt_name as fallback
    if _G.DualBoxConfig.role == "alt" then
        return _G.DualBoxConfig.main_character or _G.DualBoxConfig.alt_name
    else
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
            -- A role switched with //gs c main overrides the file's.
            local role_ok, DualBoxRole = pcall(require, 'shared/utils/dualbox/dualbox_role')
            if role_ok and DualBoxRole then DualBoxRole.apply_saved() end
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
---   SEND (both roles)
---  ═══════════════════════════════════════════════════════════════════════════

-- De-dup window for send_job_update: an identical payload sent less than
-- SEND_DEDUP_WINDOW seconds after the previous send is dropped. A reply to
-- requestjob bypasses it (see send_job_update). State is stored on `windower`
-- so it survives `gs reload` (which wipes `_G`).
local SEND_DEDUP_WINDOW = 1.5

--- Send this character's job to the other box (either role)
--- Called at auto-init and in reply to a requestjob
--- Uses windower send command to communicate with the other character
--- @param force boolean|nil Skip the de-dup window. A reply to requestjob is
---   forced: the other box asked because it has nothing, even if this box sent
---   the same payload a moment ago (that send may have landed before the other
---   box had initialised, and been dropped).
function DualBoxManager.send_job_update(force)
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    -- Both sides report. It used to be alt-to-main only, which left the alt
    -- with no idea what the main was playing - and COR needs exactly that to
    -- credit a roll's job bonus. The other character's job is otherwise only
    -- learnable from a 0xDD packet, which the server sends when a party member
    -- changes state; a character standing still is invisible.
    -- get_target_character already resolves the opposite side for both roles.

    -- Check if player data is available
    if not player or not player.main_job then
        return
    end

    local main_job = player.main_job
    local sub_job = player.sub_job or "NON"

    -- Levels travel with the job: the main needs them to pick a spell tier
    -- the alt can actually cast. A subjob caps well below the main (Master
    -- Level 50 reaches sub 58), so "best tier" is a different question on
    -- each side.
    local main_level = player.main_job_level or 0
    local sub_level  = player.sub_job_level or 0

    local weapon_ok, weapon = pcall(AltStates.weapon_skill)
    if not weapon_ok then weapon = 'None' end

    local payload = main_job .. '/' .. sub_job .. '/' .. main_level .. '/' .. sub_level .. '/' .. weapon

    -- Drop if we just sent the same payload within SEND_DEDUP_WINDOW seconds.
    -- Different payload = real job change, always send through.
    local now = os.clock()
    if not force
       and windower._dualbox_last_send_payload == payload
       and windower._dualbox_last_send_time
       and (now - windower._dualbox_last_send_time) < SEND_DEDUP_WINDOW then
        return
    end

    local target_name = get_target_character()

    if not target_name then
        if _G.DualBoxConfig.debug then
            get_MessageDualbox().show_target_error()
        end
        return
    end

    -- New fields go last so a receiver that ignores them still reads the
    -- ones it knows.
    local command = string.format('send %s gs c altjobupdate %s %s %d %d %s %s',
        target_name, main_job, sub_job, main_level, sub_level, player.name or '', weapon)
    send_command(command)

    -- Record for de-dup (after we actually sent, so a failed get_target_character
    -- attempt above doesn't poison the window)
    windower._dualbox_last_send_payload = payload
    windower._dualbox_last_send_time = now

    if _G.DualBoxConfig.debug then
        get_MessageDualbox().show_job_update_sent(target_name, main_job, sub_job)
    end
end

--- Handle a job request from the other box (either role)
--- Called when this character receives the requestjob command
function DualBoxManager.handle_job_request()
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    if _G.DualBoxConfig.debug then
        local target_name = get_target_character() or "Unknown"
        get_MessageDualbox().show_job_request_received(target_name)
    end

    DualBoxManager.send_job_update(true)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   REQUEST / RECEIVE (both roles: "alt" below means "the other box")
---  ═══════════════════════════════════════════════════════════════════════════

--- Ask the other box for its job
--- Called by both roles at auto-init: a reload wipes _G.AltJobState, and the
--- other box only sends on its own reload or when asked.
function DualBoxManager.request_alt_job()
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end

    -- Every other box of the group: a main with several alts keys some
    -- binds on each one's job (alt_states.lua).
    local group_ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    local targets = group_ok and AltGroup and AltGroup.get_alts() or {}
    if #targets == 0 then targets = {get_target_character()} end

    for _, target_name in ipairs(targets) do
        send_command(string.format('send %s gs c requestjob', target_name))
        if _G.DualBoxConfig.debug then
            get_MessageDualbox().show_requesting_job(target_name)
        end
    end
end

--- Receive a job update from the other box (either role)
--- Called when this character receives the altjobupdate command
--- Stores the other box's job and, on a change, reloads the macrobook
--- @param main_job string Other box's main job (e.g., "COR")
--- @param sub_job string|nil Other box's subjob (e.g., "RDM")
--- @param main_level string|number|nil Main job level (0 when not sent)
--- @param sub_level string|number|nil Subjob level (0 when not sent)
--- @param sender string|nil Name of the box that sent it (nil from an older box)
--- @param weapon string|nil Its main hand's weapon type (nil from an older box)
function DualBoxManager.receive_alt_job(main_job, sub_job, main_level, sub_level, sender, weapon)
    if not _G.DualBoxConfig or not _G.DualBoxConfig.enabled then
        return
    end
    if not main_job or main_job == "" then
        return
    end
    if weapon == "" then weapon = nil end

    -- _G.AltJobState holds one box: with three or more in the group, only
    -- the tracked partner's update may write it. Every sender is recorded
    -- in alt_states.lua.
    local tracked = get_target_character()
    if sender and sender ~= '' and tracked and sender:lower() ~= tracked:lower() then
        AltStates.record(sender, main_job, sub_job or "NON", weapon)
        return
    end

    -- Both sides receive, mirroring the send. _G.AltJobState means "the other
    -- box's job" on either character - the alt's job when read on the main,
    -- the main's job when read on the alt. Rejecting it here left the alt
    -- with nothing, which made the symmetric send added alongside inert.

    -- Both boxes send at every reload, so most updates repeat what this box
    -- already holds: only a new job is announced and re-selects the macro book.
    local previous = _G.AltJobState
    local job_changed = not previous or previous.job ~= main_job
        or previous.subjob ~= (sub_job or "NON")

    _G.AltJobState = {
        job = main_job,
        subjob = sub_job or "NON",
        -- 0 when an older alt sends the two-argument form; consumers treat
        -- 0 as "unknown" and fall back to the main-job tier.
        main_level = tonumber(main_level) or 0,
        sub_level = tonumber(sub_level) or 0,
        weapon = weapon,
        last_update = os.time(),
        online = true
    }
    -- After _G.AltJobState: the keys it refreshes read that too
    AltStates.record((sender ~= '' and sender) or tracked, main_job, sub_job or "NON", weapon)

    local win_ok, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
    if win_ok and AltWindow then AltWindow.refresh() end

    -- Correct the packet-derived party cache for this character.
    --
    -- That cache is only refreshed when the server sends a 0xDD, so after a
    -- job change it keeps claiming the old job until one arrives. COR reads it
    -- to credit a roll's job bonus, and would credit the wrong one. The
    -- character has just told us what it is playing, so trust that over a
    -- packet that may be minutes old.
    local other = get_target_character()
    if other and _G.cor_party_jobs then
        for _, entry in pairs(_G.cor_party_jobs) do
            if entry.name == other then
                entry.main_job = main_job
                entry.sub_job = sub_job or "NON"
                entry.timestamp = os.time()
            end
        end
    end

    if not job_changed then
        return
    end

    local alt_name = other or "Alt"
    get_MessageDualbox().show_job_update_received(alt_name, main_job, sub_job or "NON")

    -- Additional debug details (only if debug enabled)
    if _G.DualBoxConfig.debug then
        get_MessageDualbox().show_reloading_macrobook()
    end

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

--- Mark alt as offline (no caller today)
function DualBoxManager.mark_alt_offline()
    if _G.AltJobState then
        _G.AltJobState.online = false
    end
end

--- Get time since last alt update (used by show_status)
--- @return number Seconds since last update
function DualBoxManager.get_time_since_update()
    if not _G.AltJobState then
        return 9999
    end

    return os.time() - _G.AltJobState.last_update
end

--- Display current dual-boxing status (no caller today)
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
-- `gs reload`, and also on every re-require when the require cache
-- (shared/utils/core/module_cache.lua) is not in place (e.g. a job's COMMANDS
-- doing `require('shared/utils/dualbox/dualbox_manager')` to deliver an
-- altjobupdate message). The former is desired - we want one fresh init per
-- reload. The latter creates a feedback loop:
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

-- Retried rather than tested once. Two seconds is usually enough for player
-- data to land, but when it is not, giving up here meant the exchange never
-- happened at all for that session and the other box's job stayed unknown
-- until someone changed job. COR reads that to credit a roll's job bonus, so
-- the symptom was the bonus going missing after some reloads and not others.
local INIT_FIRST_DELAY = 2
local INIT_RETRY_DELAY = 1
local INIT_MAX_ATTEMPTS = 8

local function run_auto_init(attempt)
    if my_init_counter ~= windower._dualbox_init_counter then return end

    if not player or not player.name then
        if attempt < INIT_MAX_ATTEMPTS then
            coroutine.schedule(function() run_auto_init(attempt + 1) end, INIT_RETRY_DELAY)
        end
        return
    end

    local current_reload = windower._gs_reload_count or 0
    if current_reload == windower._dualbox_init_last_reload then return end
    windower._dualbox_init_last_reload = current_reload

    DualBoxManager.initialize()

    local role = _G.DualBoxConfig and _G.DualBoxConfig.role
    if role ~= "alt" and role ~= "main" then
        return
    end

    if _G.DualBoxConfig.debug then
        if role == "alt" then
            get_MessageDualbox().show_alt_role_detected()
        else
            get_MessageDualbox().show_main_role_detected()
        end
    end

    -- Both directions, from both roles. This reload wiped this box's copy of
    -- the other box's job, and the other box may have missed this box's job:
    -- a send that lands before the receiver's own init is dropped.
    DualBoxManager.send_job_update()
    DualBoxManager.request_alt_job()
    AltStates.watch_weapon(function() DualBoxManager.send_job_update() end)

    if role == "alt" then
        -- Also announce which tracked buffs are already up, otherwise the main
        -- starts blind until the next gain/loss.
        local abr_ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if abr_ok and AltBuffReporter then
            AltBuffReporter.report_all()
        end
    end

    -- The alts' state window (main only; hides itself elsewhere)
    local win_ok, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
    if win_ok and AltWindow then AltWindow.start() end
end

coroutine.schedule(function() run_auto_init(1) end, INIT_FIRST_DELAY)

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return DualBoxManager
