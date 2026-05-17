---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Public Entry & Orchestrator
---  ═══════════════════════════════════════════════════════════════════════════
---   Modular structure:
---     lib/config.lua  - Constants (bags, timing, limits)
---     lib/log.lua     - Debug log + bag_name util
---     lib/chat.lua    - In-game FFXI chat helpers (FFXI-style ASCII panels)
---     lib/items.lua   - Item helpers (resource lookup, sets walking)
---     lib/moves.lua   - Move primitives (pull_slot, push_slot, space_in)
---     lib/state.lua   - State recensement (build_state, pin assignment)
---     lib/phases.lua  - Phase 0 unequip + Phase 2/3/4 algorithms
---
---   This file owns:
---     - Public API exposed to COMMON_COMMANDS (organize/preview/verify_global/reset)
---     - Outer-loop retry orchestration (start_organize -> finish_run)
---     - Module-level state (IS_RUNNING, outer_iteration, last_misplaced)
---
---   Algorithm summary:
---     Phase 0  Lock all slots + send //gs c naked
---     Phase 1  Build state (recensement)
---     Phase 2  Empty W1/W2 of unused items   (W8 > W6 > W5 > W4 > W3)
---     Phase 3  Fill W1/W2 with used items    (from overflow)
---     Phase 4  Cleanup any leftover inventory gear (with retries)
---     ----     Re-enable all slots, snapshot final state, auto-retry if needed
---
---   @file    shared/utils/wardrobe/wardrobe_organizer.lua
---   @author  Tetsouo
---   @version 3.0  (modularized)
---   @date    2026-04-30
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')
local Log = require('shared/utils/wardrobe/lib/log')
local Chat = require('shared/utils/wardrobe/lib/chat')
local Items = require('shared/utils/wardrobe/lib/items')
local Moves = require('shared/utils/wardrobe/lib/moves')
local State = require('shared/utils/wardrobe/lib/state')
local Phases = require('shared/utils/wardrobe/lib/phases')

local WardrobeOrganizer = {}

local dlog = Log.dlog

---  ═══════════════════════════════════════════════════════════════════════════
---   Module-level state for the orchestrator
---  ═══════════════════════════════════════════════════════════════════════════

local IS_RUNNING = false
local outer_iteration = 0
local last_misplaced = math.huge
local same_misplaced_count = 0
-- Job tag captured at the very first iteration. If the user changes job
-- during a multi-iteration run, we abort instead of organizing for the wrong job.
local start_job_tag = nil

-- Forward declaration so finish_run can re-enter start_organize for auto-retry
local start_organize

---  ═══════════════════════════════════════════════════════════════════════════
---   Reset all module state (used after success or crash)
---  ═══════════════════════════════════════════════════════════════════════════

local function reset_module_state()
    outer_iteration = 0
    last_misplaced = math.huge
    same_misplaced_count = 0
    start_job_tag = nil
end

--- Detect that the user changed job (or sub-job) since start_organize was first invoked.
local function job_changed()
    if not start_job_tag then return false end
    if not player or not player.main_job then return false end
    local current = player.main_job
    if player.sub_job and player.sub_job ~= 'NON' and player.sub_job ~= '' then
        current = current .. '/' .. player.sub_job
    end
    return current ~= start_job_tag
end

---  ═══════════════════════════════════════════════════════════════════════════
---   Active job tag helper (for the start banner)
---  ═══════════════════════════════════════════════════════════════════════════

local function active_job_tag()
    if not player or not player.main_job then
        return 'JOB'
    end
    if player.sub_job and player.sub_job ~= 'NON' and player.sub_job ~= '' then
        return player.main_job .. '/' .. player.sub_job
    end
    return player.main_job
end

--- Map an array of bag ids to their human labels (for chat display).
local function map_bag_names(bags)
    local out = {}
    for _, b in ipairs(bags) do table.insert(out, Log.bag_name(b)) end
    return out
end

---  ═══════════════════════════════════════════════════════════════════════════
---   Cleanup helpers shared by all exit paths
---  ═══════════════════════════════════════════════════════════════════════════

--- Re-enable slots, reset module state, and clear IS_RUNNING flag.
--- pcall'd so a stale state never prevents enable_slots from firing.
local function clean_exit()
    pcall(Phases.enable_slots)
    reset_module_state()
    IS_RUNNING = false
end

--- Schedule a lockstyle refresh + refill after wo finishes successfully.
--- Why: wardrobe reorganization can leave the equipped lockstyle out of sync
--- with the current gear (FFXI re-evaluates lockstyle from W1/W2 contents).
--- Re-firing //gs c ls after a settle delay restores the intended look.
--- Then //gs c rf refills consumables so the post-organize state is fully ready.
--- How to apply: call only from successful completion paths (NOT abort_run /
--- panic / preview / verify), and only after clean_exit has fired so slots
--- are unlocked before the commands run.
local LOCKSTYLE_AFTER_DELAY = 1.5
local REFILL_AFTER_DELAY = 3.5  -- 1.5s + 2.0s after lockstyle settles
local function schedule_lockstyle()
    coroutine.schedule(function()
        windower.send_command('gs c ls')
    end, LOCKSTYLE_AFTER_DELAY)
    coroutine.schedule(function()
        windower.send_command('gs c rf')
    end, REFILL_AFTER_DELAY)
end

--- Wrap a callback with a panic-handler that GUARANTEES enable_slots fires
--- if the callback errors mid-coroutine. Without this, an uncaught error
--- in a coroutine.schedule() callback leaves macros broken until reload.
local function with_panic_unlock(fn, label)
    return function()
        local ok, err = pcall(fn)
        if not ok then
            dlog(('PANIC in %s: %s'):format(label or '?', tostring(err)))
            Chat.error('Wardrobe error - re-enabling slots. See wardrobe_debug.log.')
            clean_exit()
        end
    end
end

--- Abort the run with a warning chat message and full cleanup.
local function abort_run(reason)
    Chat.warn(reason)
    dlog('ABORT: ' .. reason)
    clean_exit()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   finish_run helpers
---  ═══════════════════════════════════════════════════════════════════════════

--- Count gear items stuck in inventory and return (unused_count, used_count, raw_inv_items).
--- - unused: equipment NOT used by the active job (this is the "real" misplaced count -
---           it should be in overflow, not inv).
--- - used:   equipment used by the active job (fine to sit in inv: GearSwap will equip
---           it on the next gear swap; we don't count this as "misplaced").
--- @param used_names table?  name-set from state (optional). If nil, treats all as unused.
local function count_inv_gear(used_names)
    local unused, used = 0, 0
    local inv_items = windower.ffxi.get_items(Config.INV_BAG)
    if inv_items then
        for _, it in ipairs(inv_items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                if used_names and Items.is_used_name(it.id, used_names) then
                    used = used + 1
                else
                    unused = unused + 1
                end
            end
        end
    end
    return unused, used, inv_items
end

--- Decide if we should auto-retry. Returns true iff conditions allow another iteration.
--- Side effect: updates last_misplaced and same_misplaced_count.
local function should_retry(misplaced)
    if misplaced == last_misplaced then
        same_misplaced_count = same_misplaced_count + 1
    else
        same_misplaced_count = 0
    end
    local truly_stuck = same_misplaced_count >= Config.TRULY_STUCK_THRESHOLD
    local under_cap   = outer_iteration < Config.MAX_OUTER_ITERATIONS
    return (misplaced > 0 and under_cap and not truly_stuck), truly_stuck
end

--- Print the final summary panel to chat.
local function print_summary(final, misplaced, inv_gear, truly_stuck)
    Chat.banner('Wardrobe Organize - Complete')
    Chat.detail('Iterations',     outer_iteration)
    Chat.detail('Inventory free', final.inv_free)
    Chat.detail('W1 / W2 free',   string.format('%d / %d',
        final.wardrobe_free[8] or 0, final.wardrobe_free[10] or 0))
    Chat.detail('W3-W6 free',     string.format('%d / %d / %d / %d',
        final.wardrobe_free[11] or 0, final.wardrobe_free[12] or 0,
        final.wardrobe_free[13] or 0, final.wardrobe_free[14] or 0))
    Chat.detail('W8 free',        final.wardrobe_free[16] or 0)
    if inv_gear > 0 then Chat.detail('Stuck in inventory', inv_gear) end
    if misplaced == 0 then
        Chat.detail('Layout', 'OK (all job items in W1/W2)')
    elseif truly_stuck then
        Chat.detail('Layout', string.format('%d items stuck (no progress %dx, gave up)',
            misplaced, Config.TRULY_STUCK_THRESHOLD))
    else
        Chat.detail('Layout', string.format('%d items off (max iter %d reached)',
            misplaced, Config.MAX_OUTER_ITERATIONS))
    end
    Chat.separator()
    -- Final ALL-CLEAR signal so the user knows it is safe to act again.
    if misplaced == 0 then
        Chat.success('DONE - safe to move, zone, change job.')
    else
        Chat.warn('DONE (with leftovers) - safe to move, zone, change job.')
    end
end

--- Dump every stuck item with its location to the debug log.
local function dump_stuck_items(final, inv_items, misplaced, inv_gear)
    dlog(('STUCK DETAILS: misplaced=%d (w1w2_unused=%d w3w6_used=%d inv_gear=%d)'):format(
        misplaced, #final.w1w2_unused, #final.w3w6_used, inv_gear))
    for _, e in ipairs(final.w1w2_unused) do
        dlog(('    STUCK in W1/W2: %s @%s[%d]'):format(e.name, Log.bag_name(e.bag), e.slot))
    end
    for _, e in ipairs(final.w3w6_used) do
        dlog(('    STUCK in W3-W6: %s @%s[%d] (used by job)'):format(
            e.name, Log.bag_name(e.bag), e.slot))
    end
    if inv_items then
        for slot, it in ipairs(inv_items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                dlog(('    STUCK in inv: %s @inv[%d]'):format(Items.display_name(it.id), slot))
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   finish_run main
---  ═══════════════════════════════════════════════════════════════════════════

local function finish_run()
    -- Settle delay: give FFXI time to confirm the last burst before snapshot.
    coroutine.schedule(with_panic_unlock(function()
        local final = State.build_state()
        if not final then
            Chat.success('Done.')
            dlog('========== WARDROBE ORGANIZE END ==========')
            clean_exit()
            return
        end
        State.dlog_state(final, ('FINAL STATE (iter %d)'):format(outer_iteration))

        -- Split inventory into "real misplaced" (unused-by-job) vs
        -- "OK in inventory" (used-by-job, will be equipped via gear swap).
        local inv_unused, inv_used, inv_items = count_inv_gear(final.used_names)
        local misplaced = #final.w1w2_unused + #final.w3w6_used + inv_unused
        if inv_unused > 0 or inv_used > 0 then
            dlog(('  inv: %d unused (misplaced) + %d used (ok, will be equipped)'):format(
                inv_unused, inv_used))
        end

        local retry, truly_stuck = should_retry(misplaced)
        if retry then
            Chat.warn(string.format('Iter %d done: %d items still off (was %s). Re-running...',
                outer_iteration, misplaced, tostring(last_misplaced)))
            dlog(('AUTO-RETRY: iter %d -> %d misplaced (was %s)'):format(
                outer_iteration, misplaced, tostring(last_misplaced)))
            last_misplaced = misplaced
            -- Keep slots locked through the retry; re-enable only on final exit
            coroutine.schedule(start_organize, Config.RETRY_DELAY)
            return
        end

        -- Last-chance verification: before declaring "stuck/gave up", wait an
        -- extra second for FFXI to settle and re-snapshot. The misplaced count
        -- can be a transient artifact (status flags, in-flight packets); the
        -- layout might already be correct.
        if misplaced > 0 then
            dlog('LAST-CHANCE VERIFY: re-snapshotting after extra settle')
            coroutine.schedule(with_panic_unlock(function()
                local verify = State.build_state()
                if verify then
                    local inv_unused2, _, inv_items2 = count_inv_gear(verify.used_names)
                    local misplaced2 = #verify.w1w2_unused + #verify.w3w6_used + inv_unused2
                    dlog(('LAST-CHANCE VERIFY result: misplaced=%d (was %d)'):format(
                        misplaced2, misplaced))
                    if misplaced2 == 0 then
                        Chat.success(string.format(
                            'Layout converged after %d iteration(s).', outer_iteration))
                        Chat.success('DONE - safe to move, zone, change job.')
                        dlog('========== WARDROBE ORGANIZE END (verify clean) ==========')
                        clean_exit()
                        schedule_lockstyle()
                        return
                    end
                    -- If verify shows progress vs initial, do one more retry
                    if misplaced2 < misplaced
                       and outer_iteration < Config.MAX_OUTER_ITERATIONS then
                        Chat.warn(string.format(
                            'Verify shows %d -> %d, one more pass...', misplaced, misplaced2))
                        last_misplaced = misplaced2
                        same_misplaced_count = 0  -- reset stuck counter on progress
                        coroutine.schedule(start_organize, Config.RETRY_DELAY)
                        return
                    end
                    -- Still misplaced: fall through to give-up summary using verify state
                    print_summary(verify, misplaced2, inv_unused2, truly_stuck)
                    if misplaced2 > 0 then
                        dump_stuck_items(verify, inv_items2, misplaced2, inv_unused2)
                        Chat.warn('Run //gs c wo again to keep trying. Stuck-item details in wardrobe_debug.log.')
                    end
                    dlog('========== WARDROBE ORGANIZE END ==========')
                    clean_exit()
                    schedule_lockstyle()
                    return
                end
                -- Verify state failed: fall back to original snapshot
                print_summary(final, misplaced, inv_unused, truly_stuck)
                dump_stuck_items(final, inv_items, misplaced, inv_unused)
                Chat.warn('Run //gs c wo again to keep trying. Stuck-item details in wardrobe_debug.log.')
                dlog('========== WARDROBE ORGANIZE END ==========')
                clean_exit()
                schedule_lockstyle()
            end, 'finish_run.verify'), Config.SETTLE_DELAY)
            return
        end

        -- Clean exit (misplaced == 0)
        print_summary(final, misplaced, inv_unused, truly_stuck)
        dlog('========== WARDROBE ORGANIZE END ==========')
        clean_exit()
        schedule_lockstyle()
    end, 'finish_run.snapshot'), Config.SETTLE_DELAY)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   Phase chain (start_organize) - flat, named callbacks
---  ═══════════════════════════════════════════════════════════════════════════

--- Phase 4: cleanup leftover inventory gear, then finish_run.
local function start_phase4(state)
    if job_changed() then
        abort_run('Job changed before phase 4.')
        return
    end
    Chat.phase(4, 'Cleanup leftovers', nil)
    Phases.cleanup_inv(state.used_names, state.pinned_bags, finish_run)
end

--- Phase 3: promote used items from overflow to W1/W2.
local function start_phase3(state)
    Chat.phase(3, 'Fill W1/W2', string.format('%d items', #state.w3w6_used))
    Phases.fill_w1w2(state, function()
        coroutine.schedule(function() start_phase4(state) end, Config.PHASE_DELAY)
    end)
end

--- After Phase 2: re-snapshot the world, then run Phase 3.
--- prev_state is reused if re-snapshot fails (we still need used_names + pinned_bags).
local function rebuild_then_phase3(prev_state)
    if job_changed() then
        abort_run('Job changed mid-run, aborting.')
        return
    end
    local state2, err = State.build_state()
    if not state2 then
        dlog('PHASE 2.5 SNAPSHOT FAIL: ' .. tostring(err))
        Chat.warn('Re-snapshot failed, skipping fill phase.')
        Phases.cleanup_inv(prev_state.used_names, prev_state.pinned_bags, finish_run)
        return
    end
    State.dlog_state(state2, 'PHASE 2.5 RE-SNAPSHOT')
    start_phase3(state2)
end

--- Phase 2: evict unused items from W1/W2.
local function start_phase2(state)
    Chat.phase(2, 'Empty W1/W2', string.format('%d items', #state.w1w2_unused))
    Phases.empty_w1w2(state, function()
        coroutine.schedule(function() rebuild_then_phase3(state) end, Config.PHASE_DELAY)
    end)
end

--- Phase 1: build state, decide if we have anything to do, then start Phase 2.
local function build_state_and_dispatch()
    if job_changed() then
        abort_run('Job changed mid-run, aborting.')
        return
    end
    local state, err = State.build_state()
    if not state then
        Chat.error('Failed to build state: ' .. tostring(err))
        dlog('ABORT: ' .. tostring(err))
        clean_exit()
        return
    end
    State.dlog_state(state, 'PHASE 1 STATE')
    -- Inventory split: only "unused" inv items count as cleanup work.
    -- "used" inv items will be auto-equipped at next swap, so they're fine to leave.
    local inv_unused, inv_used = count_inv_gear(state.used_names)
    Chat.phase(1, 'Recensement complete',
        string.format('inv=%d  evict=%d  promote=%d  cleanup=%d',
            state.inv_free, #state.w1w2_unused, #state.w3w6_used, inv_unused))

    if #state.w1w2_unused == 0 and #state.w3w6_used == 0 and inv_unused == 0 then
        if outer_iteration == 1 then
            Chat.success('Wardrobes already optimized for this job.')
        else
            Chat.success(string.format('Layout converged after %d iterations.', outer_iteration))
        end
        Chat.success('DONE - safe to move, zone, change job.')
        clean_exit()
        dlog('========== WARDROBE ORGANIZE END (clean) ==========')
        schedule_lockstyle()
        return
    end

    -- If W1/W2 are already correct but inventory has leftovers, skip Phase 2/3
    -- and jump straight to cleanup.
    if #state.w1w2_unused == 0 and #state.w3w6_used == 0 then
        dlog(('PHASE 1 -> direct PHASE 4 (inv_unused=%d, inv_used=%d, layout already OK)'):format(
            inv_unused, inv_used))
        start_phase4(state)
        return
    end

    start_phase2(state)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   start_organize: entry of the phase chain (called once per outer iteration)
---  ═══════════════════════════════════════════════════════════════════════════

start_organize = function()
    IS_RUNNING = true
    outer_iteration = outer_iteration + 1
    local is_first = outer_iteration == 1

    if is_first then
        start_job_tag = active_job_tag()
        Log.dlog_clear()
        dlog('========== WARDROBE ORGANIZE START ==========')
        Chat.banner('Wardrobe Organize - Started')
        Chat.detail('Active job', start_job_tag)
        Chat.detail('Config',     Config.LOADED_CHAR_CONFIG and 'per-character' or 'defaults')
        Chat.detail('Primary',    table.concat(map_bag_names(Config.PRIMARY_BAGS), ', '))
        Chat.detail('Overflow',   table.concat(map_bag_names(Config.OVERFLOW_BAGS), ', '))
        Chat.alert('PROCESSING - please wait. Do NOT move, zone or change job.')
    else
        if job_changed() then
            abort_run('Job changed before retry, aborting.')
            return
        end
        dlog(('========== ITERATION %d =========='):format(outer_iteration))
        Chat.info(string.format('Iter %d / %d - rebuilding state...',
            outer_iteration, Config.MAX_OUTER_ITERATIONS))
    end

    Chat.phase(0, is_first and 'Unequipping current gear' or 'Unequipping (retry)', nil)
    -- New behaviour: Phases.unequip is async and verifies the player is fully
    -- naked before invoking its callback. This prevents Phase 1 from running on
    -- a stale equipment state where some slots are still occupied.
    Phases.unequip(with_panic_unlock(build_state_and_dispatch, 'build_state_and_dispatch'))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Run the per-job wardrobe organize flow.
function WardrobeOrganizer.organize()
    if IS_RUNNING then
        Chat.warn('Organize already in progress (use //gs c wo reset to clear).')
        return
    end
    if not _G.sets or type(_G.sets) ~= 'table' then
        Chat.error('No sets table found (load a job first).')
        return
    end
    Config.refresh()  -- load per-character WARDROBE_CONFIG.lua overrides
    reset_module_state()
    local ok, err = pcall(start_organize)
    if not ok then
        IS_RUNNING = false
        reset_module_state()
        Phases.enable_slots()
        Chat.error('start_organize crashed: ' .. tostring(err))
        dlog('FATAL: ' .. tostring(err))
    end
end

--- Dry-run preview: shows what WOULD be moved, without actually moving anything.
function WardrobeOrganizer.preview()
    if not _G.sets or type(_G.sets) ~= 'table' then
        Chat.error('No sets table found (load a job first).')
        return
    end
    Config.refresh()
    local state, err = State.build_state()
    if not state then
        Chat.error(tostring(err))
        return
    end

    local pinned_total = 0
    for _, e in ipairs(state.w1w2_unused) do
        if e.is_pinned then
            pinned_total = pinned_total + 1
        end
    end
    for _, e in ipairs(state.w3w6_used) do
        if e.is_pinned then
            pinned_total = pinned_total + 1
        end
    end

    Chat.banner('Wardrobe Preview (active job)')
    Chat.detail('Inventory free', state.inv_free)
    Chat.detail('W1 / W2 free', string.format('%d / %d', state.wardrobe_free[8] or 0, state.wardrobe_free[10] or 0))
    Chat.detail(
        'W3-W6 free',
        string.format(
            '%d / %d / %d / %d',
            state.wardrobe_free[11] or 0,
            state.wardrobe_free[12] or 0,
            state.wardrobe_free[13] or 0,
            state.wardrobe_free[14] or 0
        )
    )
    Chat.detail('W8 free', state.wardrobe_free[16] or 0)
    Chat.detail('Evict from W1/W2', #state.w1w2_unused)
    Chat.detail('Promote from W3-W6', #state.w3w6_used)
    Chat.detail('Pinned moves', pinned_total)
    Chat.separator()
    Chat.info('Run //gs c wo to execute. Details in wardrobe_debug.log.')

    -- Detail every entry to log (chat would be too noisy)
    Log.dlog_clear()
    dlog('===== PREVIEW (no moves) =====')
    State.dlog_state(state, 'PREVIEW STATE')
    for _, e in ipairs(state.w1w2_unused) do
        local tgt = e.is_pinned and Log.bag_name(e.target) or 'overflow'
        dlog(
            ('  EVICT: %s @%s[%d] -> %s%s'):format(
                e.name,
                Log.bag_name(e.bag),
                e.slot,
                tgt,
                e.is_pinned and ' [PIN]' or ''
            )
        )
    end
    for _, e in ipairs(state.w3w6_used) do
        local tgt = e.is_pinned and Log.bag_name(e.target) or 'W1/W2'
        dlog(
            ('  PROMOTE: %s @%s[%d] -> %s%s'):format(
                e.name,
                Log.bag_name(e.bag),
                e.slot,
                tgt,
                e.is_pinned and ' [PIN]' or ''
            )
        )
    end
end

--- Audit the current layout vs what the active job needs.
function WardrobeOrganizer.verify_global()
    Config.refresh()
    local state, err = State.build_state()
    if not state then
        Chat.error(tostring(err))
        return
    end
    local misplaced_w1w2 = #state.w1w2_unused
    local misplaced_w3w6 = #state.w3w6_used
    local total = misplaced_w1w2 + misplaced_w3w6
    Chat.banner('Wardrobe Verify')
    if total == 0 then
        Chat.detail('Layout', 'OK')
        Chat.separator()
        Chat.success('All job items are in W1/W2.')
    else
        Chat.detail('Misplaced (total)', total)
        Chat.detail('Unused in W1/W2', misplaced_w1w2)
        Chat.detail('Used still in W3-W6', misplaced_w3w6)
        Chat.separator()
        Chat.warn('Run //gs c wo to fix.')
    end
end

--- Reset stuck IS_RUNNING state and re-enable slots (use after a crash).
function WardrobeOrganizer.reset()
    IS_RUNNING = false
    reset_module_state()
    Phases.enable_slots()
    Chat.success('State reset. IS_RUNNING=false. Slots re-enabled.')
end

--- Nuclear recovery: send `gs enable` for every slot in 3 spaced passes.
--- Use if `//gs c <anything>` stops doing gear swaps after a wo run.
--- Triggered by `//gs c wo recover`.
function WardrobeOrganizer.recover()
    IS_RUNNING = false
    reset_module_state()
    Phases.force_enable_all()
    Chat.success('Recovery sent: 3 spaced enable passes for all 16 slots.')
end

-- Legacy command compatibility (//gs c wo global / preview)
WardrobeOrganizer.organize_global = WardrobeOrganizer.organize
WardrobeOrganizer.preview_global = WardrobeOrganizer.preview

---  ═══════════════════════════════════════════════════════════════════════════
---   ALT MODE  (4-wardrobe characters: W1-W4 + Sack/Case)
---  ═══════════════════════════════════════════════════════════════════════════
---   Implementation lives in lib/orchestrator_alt.lua. The factory below wires
---   in this module's mutable state (IS_RUNNING / start_job_tag) and shared
---   helpers via dependency injection.

local AltOrchestrator = require('shared/utils/wardrobe/lib/orchestrator_alt').create({
    set_running        = function(v) IS_RUNNING = v end,
    set_start_job_tag  = function(v) start_job_tag = v end,
    active_job_tag     = active_job_tag,
    job_changed        = job_changed,
    reset_module_state = reset_module_state,
    clean_exit         = clean_exit,
    abort_run          = abort_run,
    map_bag_names      = map_bag_names,
    schedule_lockstyle = schedule_lockstyle,
})

--- Run the alt-character wardrobe organize flow (4 wardrobes + Sack/Case).
--- Considers items used by ANY job, not just the active one.
function WardrobeOrganizer.organize_alt()
    if IS_RUNNING then
        Chat.warn('Organize already in progress (use //gs c wo reset to clear).')
        return
    end
    Config.refresh()  -- load per-character WARDROBE_CONFIG.lua overrides
    reset_module_state()
    local ok, err = pcall(AltOrchestrator.start)
    if not ok then
        IS_RUNNING = false
        reset_module_state()
        Phases.enable_slots()
        Chat.error('organize_alt crashed: ' .. tostring(err))
        dlog('FATAL: ' .. tostring(err))
    end
end

return WardrobeOrganizer
