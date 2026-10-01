---  ═══════════════════════════════════════════════════════════════════════════
---   Universal Systems Initialization
---  ═══════════════════════════════════════════════════════════════════════════
---   Starts the systems every job needs. Included by each entry point's
---   get_sets(), after include('Mote-Include.lua') has returned, so Mote has
---   already run user_setup() and init_gear_sets() by the time this file runs.
---
---   Usage in an entry point (e.g. Tetsouo_WAR.lua):
---     include('../shared/utils/core/INIT_SYSTEMS.lua')
---
---   Order of what it starts:
---     immediate  debug flags restored from windower._gs_debug, reload counter,
---                ModuleCache, HP priority, LagDebugger, AutoMedicine,
---                JobSyncWatchdog, DualBox sync IPC, KeybindGuard, Stealth
---                timers, custom states hooks
---     +0.5 s     WarpInit, AutoMove, StateDisplayOverride
---     +2.0 s     MidcastWatchdog
---     +3.0 s     load check of the PrecastGuard / CooldownChecker /
---                WSPrecastHandler chain
---     +5.0 s     GlobalProbe baseline snapshot
---
---   @file    shared/utils/core/INIT_SYSTEMS.lua
---   @author  ejouanchicot
---   @version 1.4
---   @date    Created: 2025-10-28 | Updated: 2026-09-25
---  ═══════════════════════════════════════════════════════════════════════════

pcall(function() require('shared/utils/debug/trace_log').log('LOAD', 'INIT_SYSTEMS start (Mote and user_setup done)') end)

---  ═══════════════════════════════════════════════════════════════════════════
---   RESTORE PERSISTENT DEBUG FLAGS (survives job changes)
---  ═══════════════════════════════════════════════════════════════════════════

-- Restore debug flags from the windower table, which outlives the sandbox.
-- Each toggle owns its own field: AUTOMOVE used to be restored from UPDATE,
-- so `//gs c automovedebug` was undone at the next job load.
if windower._gs_debug then
    _G.UPDATE_DEBUG       = windower._gs_debug.UPDATE
    _G.AUTOMOVE_DEBUG     = windower._gs_debug.AUTOMOVE
    _G.WARP_DEBUG         = windower._gs_debug.WARP
    _G.PrecastDebugState  = windower._gs_debug.PRECAST
    _G.JOBCHANGE_DEBUG    = windower._gs_debug.JOBCHANGE
end

-- Track total gs reload count (persists across reloads via windower table)
windower._gs_reload_count = (windower._gs_reload_count or 0) + 1

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE CACHE (first, so everything below is loaded once instead of N times)
---  ═══════════════════════════════════════════════════════════════════════════

-- GearSwap's require never populates package.loaded, so without this every
-- require re-reads and re-executes the file. config_loader, which every entry
-- file requires at file level, normally installed it already, before Mote's
-- user_setup(); this call covers an entry file that does not load it.
pcall(function()
    local ok, ModuleCache = pcall(require, 'shared/utils/core/module_cache')
    if ok and ModuleCache then
        ModuleCache.install()
    end
end)

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR HOOKS: doubled items, HP priority (the sets are loaded: Mote ran init_gear_sets before this file)
---  ═══════════════════════════════════════════════════════════════════════════

-- Impact's cloak (Crepuscular / Twilight) stays on through the cast, every job.
pcall(function()
    local ok, ImpactLock = pcall(require, 'shared/utils/equipment/impact_lock')
    if ok and ImpactLock then ImpactLock.install() end
end)

-- Each side of a doubled ring / earring / weapon takes its own copy.
pcall(function()
    local ok, DuplicateGear = pcall(require, 'shared/utils/equipment/duplicate_gear')
    if ok and DuplicateGear then DuplicateGear.install() end
end)

-- Each swap ranks its pieces by the HP they gain over the worn ones (HPPriority).
pcall(function()
    local ok, HPPriority = pcall(require, 'shared/utils/equipment/hp_priority')
    if ok and HPPriority then
        HPPriority.apply()
    end
end)

---  ═══════════════════════════════════════════════════════════════════════════
---   LAG DEBUGGER (loaded immediately, lightweight - only active when toggled)
---  ═══════════════════════════════════════════════════════════════════════════

-- LagDebugger is always loaded so //gs c lagdebug works immediately on any job
-- It does nothing unless explicitly started with //gs c lagdebug
if not _G.LagDebugger then
    pcall(require, 'shared/utils/debug/lag_debugger')
end

-- Log reload completion (marks when GearSwap finished loading after job change)
if _G.LagDebugger then
    local job = player and player.main_job or 'UNK'
    local sub = player and player.sub_job  or 'UNK'
    _G.LagDebugger.on_reload_complete(job, sub, windower._automove_seq)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES (LAZY LOADING for performance)
---  ═══════════════════════════════════════════════════════════════════════════

-- MessageInit loaded on-demand (only when showing errors)
local MessageInit = nil

-- Never returns nil. Every caller below is `ensure_message_init().show_*(...)`
-- with no guard, and several of them sit inside a coroutine.schedule block: if the
-- formatter failed to load, indexing nil would throw there and take the rest of
-- that block's initialisations down with it. The one case where this reporter is
-- needed most - the message chain itself being broken - was the one case where
-- it made things worse. The fallback writes straight to chat for the same
-- reason the diagnostic tools are allowed to (CODE_QUALITY section 6): a
-- reporter that cannot speak because the thing it reports on is broken is no
-- reporter at all.
local function ensure_message_init()
    if not MessageInit then
        local success, module = pcall(require, 'shared/utils/messages/formatters/system/message_init')
        if success and module then
            MessageInit = module
        else
            MessageInit = {
                show_module_load_failed = function(module_name, error_msg)
                    add_to_chat(167, ('[INIT] %s failed to load: %s')
                        :format(tostring(module_name), tostring(error_msg)))
                end,
            }
        end
    end
    return MessageInit
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST WATCHDOG (+2.0 s, kept off the cold-load path)
---  ═══════════════════════════════════════════════════════════════════════════
-- Deferred load work goes through LoadGate: a newer load or a job change
-- in the meantime cancels it (shared/utils/core/load_gate.lua)
local LoadGate = require('shared/utils/core/load_gate')


LoadGate.defer(2.0, function()
    local watchdog_success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')

    if watchdog_success and MidcastWatchdog then
        -- Expose globally for command access (e.g., //gs c watchdog status)
        _G.MidcastWatchdog = MidcastWatchdog
        MidcastWatchdog.start()
    else
        ensure_message_init().show_module_load_failed('Watchdog', MidcastWatchdog)
    end
end, 'watchdog')

---  ═══════════════════════════════════════════════════════════════════════════
---   IMMEDIATE: AUTO MEDICINE STATE
---  ═══════════════════════════════════════════════════════════════════════════
-- state.AutoMedicine is normally created by each job's [JOB]_STATES.lua, in
-- user_setup(), alongside every other state. It has to be: the keybind HUD
-- renders from user_setup and caches what it read, so a state created here -
-- after `include('Mote-Include.lua')` has returned - arrives too late and
-- shows as N/A.
--
-- ensure() is the safety net for a job whose states config predates the state.
-- It runs synchronously because PrecastGuard reads the state on the very first
-- action, which can land before a deferred block would have run.
local am_ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
if am_ok and AutoMedicine then
    AutoMedicine.ensure()
else
    ensure_message_init().show_module_load_failed('Auto Medicine', AutoMedicine)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IMMEDIATE: JOB SYNC WATCHDOG
---  ═══════════════════════════════════════════════════════════════════════════
-- GearSwap picks the job file from the job-change REQUEST, so a refused or
-- reordered request leaves the wrong file loaded - wrong keybinds, missing
-- states - and nothing corrects it. The job read here is the one this file was
-- loaded for; the watchdog compares it against the client from then on.
local jsw_ok, JobSyncWatchdog = pcall(require, 'shared/utils/core/job_sync_watchdog')
if jsw_ok and JobSyncWatchdog then
    JobSyncWatchdog.start(player and player.main_job)
else
    ensure_message_init().show_module_load_failed('Job Sync Watchdog', JobSyncWatchdog)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IMMEDIATE: DUAL-BOX SYNC IPC
---  ═══════════════════════════════════════════════════════════════════════════
-- Registers a Windower IPC listener and the per-command hooks. Loaded
-- synchronously (NOT in the deferred 0.5s block below) so the listener is
-- available immediately after get_sets() returns - otherwise a broadcast
-- arriving in the 0-0.5s window after a job change would be silently dropped
-- (the new job's hooks wouldn't be registered yet, and the previous job's
-- `select_default_lockstyle` closure would no longer match the new job).
--
-- Hooks are re-registered every load (cheap; replaces if present) so the
-- captured `select_default_lockstyle` always points at the freshly-loaded
-- GearSwap globals for the current job.
local sync_ok, SyncIPC = pcall(require, 'shared/utils/dualbox/dualbox_sync_ipc')
if sync_ok and SyncIPC then
    -- The same "reapplying" line as the box that pressed the key, so this
    -- window shows the order arrived (the style itself may not change)
    local lockstyle_hook = function()
        if not select_default_lockstyle then return end
        local ok, MessageCommands = pcall(require, 'shared/utils/messages/formatters/ui/message_commands')
        if ok and MessageCommands then MessageCommands.show_lockstyle_reapplying() end
        select_default_lockstyle()
    end
    SyncIPC.register_hook('ls', lockstyle_hook)
    SyncIPC.register_hook('lockstyle', lockstyle_hook)
    -- Refill: each instance pulls its own consumables from Case/Sack.
    local refill_hook = function()
        local ok, RefillManager = pcall(require, 'shared/utils/inventory/refill_manager')
        if ok and RefillManager and RefillManager.refill then RefillManager.refill() end
    end
    SyncIPC.register_hook('rf', refill_hook)
    SyncIPC.register_hook('refill', refill_hook)
    SyncIPC.init_listener()
else
    ensure_message_init().show_module_load_failed('DualBox Sync IPC', SyncIPC)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEFERRED SYSTEMS (+0.5 s, kept off the cold-load path)
---  ═══════════════════════════════════════════════════════════════════════════

LoadGate.defer(0.5, function()
    ---  ─────────────────────────────────────────────────────────────────────────
    ---   WARP SYSTEM (with IPC multi-boxing support)
    ---  ─────────────────────────────────────────────────────────────────────────

    local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')

    if warp_success and WarpInit then
        local ok_init, err_init = pcall(WarpInit.init)
        if not ok_init then
            ensure_message_init().show_module_load_failed('Warp System init()', err_init)
        end
    else
        ensure_message_init().show_module_load_failed('Warp System', WarpInit)
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   AUTOMOVE (movement detection)
    ---  ─────────────────────────────────────────────────────────────────────────

    -- A job can opt out by setting _G.DISABLE_AUTOMOVE = true (no entry point
    -- sets it at the moment).
    if _G.DISABLE_AUTOMOVE ~= true then
        -- automove.lua is loaded with include(), not require(): it publishes
        -- itself as _G.AutoMove instead of returning a module.
        local automove_success, automove_error = pcall(include, '../shared/utils/movement/automove.lua')

        if automove_success then
            -- The include does not start it (avoids a double start on reload).
            if AutoMove and AutoMove.start then
                AutoMove.start()
            end
        else
            ensure_message_init().show_module_load_failed('AutoMove', automove_error)
        end
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   STATE DISPLAY OVERRIDE (conditional state messages)
    ---  ─────────────────────────────────────────────────────────────────────────

    local state_display_success, StateDisplayOverride = pcall(require, 'shared/utils/core/state_display_override')

    if state_display_success and StateDisplayOverride then
        -- Replaces Mote-Include's display_current_state
        StateDisplayOverride.init()
    else
        ensure_message_init().show_module_load_failed('State Display Override', StateDisplayOverride)
    end
end, 'deferred systems')

-- Template for adding a new universal system:
--
-- local system_success, SystemModule = pcall(require, 'shared/utils/path/to/system')
-- if system_success and SystemModule then
--     SystemModule.init()
-- else
--     ensure_message_init().show_module_load_failed('System Name', SystemModule)
-- end

---  ═══════════════════════════════════════════════════════════════════════════
---   KEYBINDS - re-assert once the console has gone quiet
---  ═══════════════════════════════════════════════════════════════════════════

-- Mote has already run user_setup(), so bind_all() has fired by now. Its
-- commands are not always the last word: the outgoing job file queued its own
-- unbind burst from file_unload a moment earlier, and the order in which a
-- dying sandbox's commands and a new one's reach Windower is decided in
-- Hook.dll. See keybind_guard.lua for what was observed and ruled out.
local kg_ok, KeybindGuard = pcall(require, 'shared/utils/core/keybind_guard')
if kg_ok and KeybindGuard then
    KeybindGuard.schedule()
else
    ensure_message_init().show_module_load_failed('Keybind Guard', KeybindGuard)
end

-- Sneak / Invisible timers: this character's end times (packet 0x063), sent
-- to the box group, wear-off warnings (//gs c stealth)
local st_ok, StealthTimers = pcall(require, 'shared/utils/stealth/stealth_timers')
if st_ok and StealthTimers then
    StealthTimers.start()
else
    ensure_message_init().show_module_load_failed('Stealth Timers', StealthTimers)
end

-- Time left on every buff (packet 0x063): //gs c buff recasts one under
-- BUFF_CONFIG.lua refresh_below
local bt_ok, BuffTimers = pcall(require, 'shared/utils/buffs/buff_timers')
if bt_ok and BuffTimers then
    BuffTimers.start()
else
    ensure_message_init().show_module_load_failed('Buff Timers', BuffTimers)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CUSTOM STATES - hook the player's own gear (<JOB>_CUSTOM.lua)
---  ═══════════════════════════════════════════════════════════════════════════

-- Hachirin-no-Obi / Orpheus's Sash on elemental damage (elemental_belt.lua).
-- Laid first, so the midcast fallback below (its set) and the custom states
-- (the player's own gear) wrap it: set, then belt, then custom gear.
pcall(function()
    local ok, ElementalBelt = pcall(require, 'shared/utils/equipment/elemental_belt')
    if ok and ElementalBelt then
        ElementalBelt.install()
    end
end)

-- Dual Wield tier pieces by magic haste on the engaged set (dual_wield.lua).
-- Wraps handle_equipping_gear before the custom states do, so the player's
-- custom gear still goes on last.
pcall(function()
    local ok, DualWield = pcall(require, 'shared/utils/equipment/dual_wield')
    if ok and DualWield then
        DualWield.install()
    end
end)

-- Treasure Hunter on the engaged set and on the first action against a
-- mob not tagged yet (treasure_hunter.lua). After the Dual Wield and belt
-- hooks (TH wins, once per mob), before the custom states.
pcall(function()
    local ok, TreasureHunter = pcall(require, 'shared/utils/equipment/treasure_hunter')
    if ok and TreasureHunter then
        TreasureHunter.install()
    end
end)

-- Spells a job's midcast does not route (a subjob's magic) go through
-- MidcastManager anyway. Laid before the custom states hook below, which
-- wraps it, so the player's custom gear still goes on last.
pcall(function()
    local ok, MidcastFallback = pcall(require, 'shared/utils/midcast/midcast_fallback')
    if ok and MidcastFallback then
        MidcastFallback.install()
    end
end)

-- Not from user_setup(): Mote calls it from the middle of Mote-Include, before
-- defining handle_equipping_gear and cleanup_precast/midcast, and those
-- definitions then replace any hook laid on them. By now they all exist.
pcall(function()
    local ok, CustomStates = pcall(require, 'shared/utils/custom/custom_states')
    if ok and CustomStates then
        CustomStates.install_hooks()
    end
end)

-- Cast time of every spell from the precast set actually sent (watchdog, BRD
-- song queue), and the game's "cast started" packets.
pcall(function()
    local ok_t, CastTime = pcall(require, 'shared/utils/precast/cast_time')
    if ok_t and CastTime then CastTime.install_hook() end
    local ok_c, CastTracker = pcall(require, 'shared/utils/core/cast_tracker')
    if ok_c and CastTracker then CastTracker.start() end
end)

-- Combat Mode lock, every job. Laid after the custom hooks so it wraps them:
-- the lock is set before any gear goes on.
pcall(function()
    local ok, CombatMode = pcall(require, 'shared/utils/core/combat_mode')
    if ok and CombatMode then
        CombatMode.install_hook()
    end
end)

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST SAFETY MODULES - confirm they load, once per job load
---  ═══════════════════════════════════════════════════════════════════════════

-- Every [JOB]_PRECAST.lua pcalls these three and carries on with nil when one
-- fails, then sets modules_loaded = true regardless - so the failure is
-- permanent for the session and completely silent. What disappears is not a
-- nicety: PrecastGuard is the Silence/Amnesia/death block, CooldownChecker is
-- every recast message, WSPrecastHandler is the range check and the TP bonus
-- gear. Worse, precast_guard requires message_core without a pcall, so the very
-- error that removes the guard on all 16 jobs also takes MessageFormatter down
-- with it - the channel that would have said so.
--
-- Checked here rather than in the 16 job files, and on a delay rather than
-- inline: ModuleCache means this require is the same one the job will get, so
-- an answer here is the answer there, and waiting keeps the cost of loading
-- the chain off the cold-load path.
LoadGate.defer(3.0, function()
    local critical = {
        { 'PrecastGuard',     'shared/utils/debuff/precast_guard' },
        { 'CooldownChecker',  'shared/utils/precast/cooldown_checker' },
        { 'WSPrecastHandler', 'shared/utils/precast/ws_precast_handler' },
    }
    for _, entry in ipairs(critical) do
        local ok, mod = pcall(require, entry[2])
        if not ok or not mod then
            ensure_message_init().show_module_load_failed(entry[1], mod)
        end
    end
end, 'critical modules check')

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL PROBE BASELINE (last, so it sees everything the load created)
---  ═══════════════════════════════════════════════════════════════════════════

-- Snapshot _G now. Anything that appears afterwards was created during play,
-- and //gs c syscheck will name it. This is what catches a helper writing to a
-- variable it never declared - valid Lua that silently drops the value.
-- On a delay: the deferred blocks above run at 0.5s and 2s, and job modules
-- load later still. Snapshotting synchronously here caught none of them and
-- reported every one as a leak.
-- //gs c trace: end of the synchronous part, and ALIVE lines from now on
pcall(function()
    local TraceLog = require('shared/utils/debug/trace_log')
    TraceLog.log('LOAD', 'INIT_SYSTEMS end')
    if TraceLog.enabled() then TraceLog.start_heartbeat() end
end)
-- //gs c atelier on: export this job for data/atelier.html once it is loaded
pcall(function() require('shared/utils/atelier/atelier_export').after_load() end)
-- //gs c trace dead on: second try, in case the character was not known when
-- config_loader.lua ran (it wraps what is already loaded too)
pcall(function() require('shared/utils/debug/tombstones').install() end)

LoadGate.defer(5.0, function()
    local ok, GlobalProbe = pcall(require, 'shared/utils/debug/global_probe')
    if ok and GlobalProbe then
        GlobalProbe.snapshot()
    end
end, 'global probe')
