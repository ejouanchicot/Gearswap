---  ═══════════════════════════════════════════════════════════════════════════
---   Job Sync Watchdog - detect a job file that no longer matches the job
---  ═══════════════════════════════════════════════════════════════════════════
---   GearSwap swaps the job file on the OUTGOING job-change request, not on the
---   server's answer: packet_parsing.lua:733-751 reacts to `parse.o[0x100]` and
---   fires `load_user_files` the moment you ask. The authoritative incoming
---   0x061 then corrects `player.main_job_id` (packet_parsing.lua:381) but
---   never reloads the file.
---
---   So a request the server refuses or reorders - which is exactly what a
---   burst of job changes produces, FFXI throttles them - leaves GearSwap
---   running the previous job's file: its keybinds are bound, the current
---   job's states do not exist, and nothing in GearSwap ever notices.
---
---   This watchdog compares the job the loaded file was written for against
---   the job the client actually reports, and forces a `gs reload` when the
---   two disagree for two consecutive checks. `gs reload` goes through
---   `refresh_user_env()`, which reads the live job from the client, so the
---   reload lands on the right file.
---
---   Two checks (not one) because the client's own value lags a legitimate
---   job change by a moment; requiring the divergence to survive a full
---   interval keeps a normal change from ever tripping it.
---
---   @file    shared/utils/core/job_sync_watchdog.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-09
---  ═══════════════════════════════════════════════════════════════════════════

local JobSyncWatchdog = {}

local DebugLogger = require('shared/utils/debug/debug_logger')

---  ═══════════════════════════════════════════════════════════════════════════
---   TUNING
---  ═══════════════════════════════════════════════════════════════════════════

local CHECK_INTERVAL  = 5.0   -- seconds between two comparisons
local CONFIRMATIONS   = 2     -- consecutive mismatches before reloading
local RELOAD_COOLDOWN = 30.0  -- floor between two corrective reloads
local FIRST_CHECK     = 8.0   -- grace period after a load, before checking

---  ═══════════════════════════════════════════════════════════════════════════
---   CROSS-RELOAD STATE
---  ═══════════════════════════════════════════════════════════════════════════

-- The `windower` table outlives the sandbox: a gs reload wipes _G but never
-- touches it. The sequence invalidates the watchdog loop of a previous
-- environment, whose scheduled coroutines outlive it; the timestamp keeps a
-- permanently odd state from turning into a reload loop.
--
-- The timestamp stays nil until the first corrective reload. Seeding it with 0
-- would mean "reloaded at clock 0", and os.clock() counts from process start -
-- so early in a Windower session the cooldown would swallow the first
-- correction, which is the one that matters.
windower._job_sync_seq = windower._job_sync_seq or 0

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- The main job the game client itself reports, bypassing GearSwap's own copy.
--- @return string|nil Short job name ('PLD'), or nil while it cannot be read
local function live_main_job()
    if not (windower and windower.ffxi and windower.ffxi.get_player) then
        return nil
    end
    local ok, p = pcall(windower.ffxi.get_player)
    if not ok or type(p) ~= 'table' then
        return nil
    end
    return p.main_job
end

--- @param a string|nil
--- @param b string|nil
--- @return boolean True when both name the same job
local function same_job(a, b)
    if not a or not b then return true end
    return a:upper() == b:upper()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CORRECTION
---  ═══════════════════════════════════════════════════════════════════════════

--- Force the reload that puts the right file back, unless one just happened.
--- @param file_job string Job the loaded file was written for
--- @param actual string Job the client reports
--- @return boolean True when the reload was sent (this loop is then finished)
local function force_reload(file_job, actual)
    local now = os.clock()
    local last = windower._job_sync_last_reload
    if last and (now - last) < RELOAD_COOLDOWN then
        DebugLogger.log_if('JOBCHANGE_DEBUG', 'JSW',
            'mismatch confirmed but reload is on cooldown')
        return false
    end

    windower._job_sync_last_reload = now
    windower._job_sync_seq = windower._job_sync_seq + 1

    local ok, MessageFormatter = pcall(require,
        'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then
        MessageFormatter.show_warning(string.format(
            'Job file is %s but you are %s - reloading.', file_job, actual))
    end

    windower.send_command('gs reload')
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WATCHDOG
---  ═══════════════════════════════════════════════════════════════════════════

--- Watch the loaded file against the client's job until this environment dies.
--- Safe to call on every load: the previous environment's loop is invalidated.
--- @param file_job string Job the currently loaded file was written for
function JobSyncWatchdog.start(file_job)
    if type(file_job) ~= 'string' or file_job == '' or file_job == 'NONE' then
        return
    end

    windower._job_sync_seq = windower._job_sync_seq + 1
    local my_seq = windower._job_sync_seq
    local strikes = 0

    local function check()
        if my_seq ~= windower._job_sync_seq then
            return  -- a newer load owns the watchdog now
        end

        local actual = live_main_job()

        if same_job(actual, file_job) then
            strikes = 0
        else
            strikes = strikes + 1
            DebugLogger.logf_if('JOBCHANGE_DEBUG', 'JSW',
                'mismatch %d/%d: file=%s client=%s',
                strikes, CONFIRMATIONS, file_job, actual)

            if strikes >= CONFIRMATIONS and force_reload(file_job, actual) then
                return
            end
        end

        coroutine.schedule(check, CHECK_INTERVAL)
    end

    coroutine.schedule(check, FIRST_CHECK)
    DebugLogger.logf_if('JOBCHANGE_DEBUG', 'JSW', 'watching %s (seq=%d)',
        file_job, my_seq)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.JobSyncWatchdog = JobSyncWatchdog

return JobSyncWatchdog
