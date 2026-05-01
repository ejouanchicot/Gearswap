---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Phases
---  ═══════════════════════════════════════════════════════════════════════════
---   The five sequential phases that the orchestrator chains together:
---
---     Phase 0  unequip          - send //gs c naked + lock all slots
---             enable_slots      - re-enable slots after the run completes
---     Phase 2  empty_w1w2       - evict unused items from W1/W2 to overflow
---     Phase 3  fill_w1w2        - promote used items from overflow to W1/W2
---     Phase 4  cleanup_inv      - flush leftover inventory gear (with retries)
---
---   Phase 2 and Phase 3 share `run_burst_loop()` (strict FILL/DRAIN burst
---   alternation with re-discovery + cycle detection). Each phase only supplies
---   its own discover_pending() and discover_drainable() closures.
---
---   @file shared/utils/wardrobe/lib/phases.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')
local Log    = require('shared/utils/wardrobe/lib/log')
local Items  = require('shared/utils/wardrobe/lib/items')
local Moves  = require('shared/utils/wardrobe/lib/moves')
local State  = require('shared/utils/wardrobe/lib/state')

local Phases = {}

local dlog             = Log.dlog
local bag_name         = Log.bag_name
local space_in         = Moves.space_in
local pull_slot        = Moves.pull_slot
local push_slot        = Moves.push_slot
local first_pinned_bag    = Moves.first_pinned_bag
local all_pinned_bags     = Moves.all_pinned_bags
local unclaimed_pins_first = Moves.unclaimed_pins_first

-- Static constants (never change at runtime).
local INV_BAG          = Config.INV_BAG
local BURST_SIZE       = Config.BURST_SIZE
local STUCK_LIMIT      = Config.STUCK_LIMIT
local MAX_STEPS        = Config.MAX_STEPS
local MOVE_DELAY       = Config.MOVE_DELAY
local POST_BURST_DELAY = Config.POST_BURST_DELAY
local CYCLE_THRESHOLD  = Config.TRULY_STUCK_THRESHOLD

-- NOTE: Bag lists (PRIMARY_BAGS / OVERFLOW_BAGS / FILL_FALLBACK / ALT_*) are
-- read directly from Config.X inside each function. They get refreshed by
-- Config.refresh() at the start of every command, so per-character overrides
-- (data/<char>/config/WARDROBE_CONFIG.lua) take effect immediately.

---  ═══════════════════════════════════════════════════════════════════════════
---   PHASE 0  -  UNEQUIP / RE-ENABLE
---  ═══════════════════════════════════════════════════════════════════════════

--- FFXI equipment-API slot names (used to read windower.ffxi.get_items().equipment).
local NAKED_SLOTS = {
    'main','sub','range','ammo','head','neck','left_ear','right_ear',
    'body','hands','left_ring','right_ring','back','waist','legs','feet',
}

--- Public: nuclear unlock for manual recovery (`//gs c wo recover`).
--- Sends `gs enable all` 3 times spaced out, in case any pass got dropped.
function Phases.force_enable_all()
    dlog('FORCE ENABLE: nuclear unlock (3x gs enable all)')
    windower.send_command('gs enable all')
    coroutine.schedule(function() windower.send_command('gs enable all') end, 0.5)
    coroutine.schedule(function() windower.send_command('gs enable all') end, 1.5)
end

--- Return the list of slots that are STILL equipped (id ~= 0).
local function still_equipped()
    local items = windower.ffxi.get_items()
    if not items or not items.equipment then return {} end
    local left = {}
    for _, slot in ipairs(NAKED_SLOTS) do
        local id = items.equipment[slot]
        if id and id ~= 0 then table.insert(left, slot) end
    end
    return left
end

--- Unequip everything, verify, THEN lock all slots.
--- ORDER MATTERS: //gs c naked calls equip(sets.naked) internally, which
--- respects gs disable. If we lock first, naked can't change anything!
--- Sequence:
---   1. gs c naked (slots still unlocked)
---   2. settle + verify still_equipped() == empty
---   3. retry strategies if not empty
---   4. gs disable all  (lock the now-empty state to block idle/engaged hooks)
---
--- @param on_done function  called when the player is verified naked AND
---                          slots are locked, OR strategies exhausted.
function Phases.unequip(on_done)
    dlog('PHASE 0: //gs c naked FIRST (slots must be unlocked for equip() to work)')
    -- Note: if a previous run crashed and left slots locked, run //gs c wo recover.

    local SETTLE = 1.2  -- seconds between attempts (server gear-swap window)
    local attempt = 0
    local strategies = {
        function() windower.send_command('gs c naked')        end,  -- 1: job-defined naked
        function() windower.send_command('gs c naked')        end,  -- 2: retry same
        function() windower.send_command('gs equip naked')    end,  -- 3: GS direct equip
        function()                                                  -- 4: native FFXI /equip
            local left = still_equipped()
            for _, slot in ipairs(left) do
                windower.send_command(('input /equip %s empty'):format(slot))
            end
        end,
    }

    local function lock_and_finish()
        -- NOW it's safe to lock the empty state so idle/engaged hooks can't
        -- re-equip during phases 2-4.
        dlog('PHASE 0: locking slots after successful naked (gs disable all)')
        windower.send_command('gs disable all')
        coroutine.schedule(on_done, 0.3)  -- tiny settle for the disable to register
    end

    local function try_next()
        attempt = attempt + 1
        if attempt > #strategies then
            local left = still_equipped()
            if #left > 0 then
                dlog(('PHASE 0 GIVE UP: still equipped after %d attempts: %s'):format(
                    #strategies, table.concat(left, ',')))
            end
            lock_and_finish()
            return
        end
        dlog(('PHASE 0 attempt %d/%d'):format(attempt, #strategies))
        strategies[attempt]()
        coroutine.schedule(function()
            local left = still_equipped()
            if #left == 0 then
                dlog(('PHASE 0 OK after attempt %d (fully naked)'):format(attempt))
                lock_and_finish()
            else
                dlog(('PHASE 0 attempt %d incomplete - %d slot(s) still equipped: %s'):format(
                    attempt, #left, table.concat(left, ',')))
                try_next()
            end
        end, SETTLE)
    end

    try_next()
end

--- Re-enable all slots so normal idle/engaged swaps resume.
function Phases.enable_slots()
    dlog('FINAL: re-enabling all slots (gs enable all)')
    windower.send_command('gs enable all')
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SHARED BURST LOOP (used by Phase 2 and Phase 3)
---  ═══════════════════════════════════════════════════════════════════════════
---   Strict FILL/DRAIN mode alternation. On each step:
---     FILL  : discover items needing to leave the source; pull a burst into inv
---     DRAIN : discover inv items pushable to dst; push a burst out
---   Mode switches when the current side is empty/saturated.
---
---   Stop conditions:
---     - source AND inv both clean         -> normal completion
---     - same pending count >= 2 samples   -> cycle detection
---     - STUCK_LIMIT no-progress bursts    -> give up
---     - MAX_STEPS reached                 -> safety cap
---
---   @param opts.label              string ('PHASE 2', 'PHASE 3')
---   @param opts.discover_pending   function() -> list of source entries to pull
---   @param opts.discover_drainable function() -> list of {slot, dst_list} inv entries
---   @param opts.on_done            function (called once when phase completes)

local function run_burst_loop(opts)
    local label              = opts.label
    local discover_pending   = opts.discover_pending
    local discover_drainable = opts.discover_drainable
    local on_done            = opts.on_done

    local mode = 'FILL'
    local steps = 0
    local stuck = 0
    local total_pulled = 0
    local total_pushed = 0
    local last_pending_count = nil
    local same_pending_count = 0

    local function done(reason)
        dlog(('%s DONE: pulled=%d pushed=%d (%s in %d steps)'):format(
            label, total_pulled, total_pushed, reason, steps))
        on_done()
    end

    local function step()
        steps = steps + 1
        if steps > MAX_STEPS then
            dlog(('[%s] MAX_STEPS reached (%d)'):format(label, MAX_STEPS))
            on_done()
            return
        end

        if mode == 'FILL' then
            local pending = discover_pending()
            local inv_free = space_in(INV_BAG)

            -- Cycle detection: pending count stuck = no net progress
            if #pending > 0 then
                if last_pending_count == #pending then
                    same_pending_count = same_pending_count + 1
                    if same_pending_count >= CYCLE_THRESHOLD then
                        dlog(('[%s] CYCLE: pending stuck at %d for %d samples'):format(
                            label, #pending, same_pending_count + 1))
                        done(('cycle exit, %d still pending'):format(#pending))
                        return
                    end
                else
                    same_pending_count = 0
                end
                last_pending_count = #pending
            end

            if #pending == 0 then
                if #discover_drainable() > 0 then
                    dlog(('[%s] mode -> DRAIN (pending empty)'):format(label))
                    mode = 'DRAIN'
                    coroutine.schedule(step, MOVE_DELAY)
                    return
                end
                done('clean')
                return
            end

            if inv_free <= 0 then
                dlog(('[%s] mode -> DRAIN (inv full)'):format(label))
                mode = 'DRAIN'
                coroutine.schedule(step, MOVE_DELAY)
                return
            end

            -- BURST PULL
            local burst_cap = math.min(BURST_SIZE, inv_free, #pending)
            local pulls = 0
            for i = 1, burst_cap do
                local entry = pending[i]
                if pull_slot(entry.bag, entry.slot) then pulls = pulls + 1 end
            end
            total_pulled = total_pulled + pulls
            dlog(('[%s] FILL burst: %d pulls (cap=%d, inv_free=%d, pending=%d)'):format(
                label, pulls, burst_cap, inv_free, #pending))

            stuck = (pulls == 0) and (stuck + 1) or 0
            if stuck >= STUCK_LIMIT then
                dlog(('%s STUCK after %d no-progress bursts'):format(label, stuck))
                on_done()
                return
            end
            coroutine.schedule(step, POST_BURST_DELAY)

        elseif mode == 'DRAIN' then
            local drainable = discover_drainable()
            if #drainable == 0 then
                if #discover_pending() > 0 then
                    dlog(('[%s] mode -> FILL (inv drained)'):format(label))
                    mode = 'FILL'
                    coroutine.schedule(step, MOVE_DELAY)
                    return
                end
                done('clean')
                return
            end

            -- BURST PUSH
            local burst_cap = math.min(BURST_SIZE, #drainable)
            local pushes = 0
            for i = 1, burst_cap do
                local d = drainable[i]
                for _, dst in ipairs(d.dst_list) do
                    if space_in(dst) > 0 then
                        if push_slot(d.slot, dst) then
                            pushes = pushes + 1
                            break
                        end
                    end
                end
            end
            total_pushed = total_pushed + pushes
            dlog(('[%s] DRAIN burst: %d pushes (cap=%d, drainable=%d)'):format(
                label, pushes, burst_cap, #drainable))

            stuck = (pushes == 0) and (stuck + 1) or 0
            if stuck >= STUCK_LIMIT then
                dlog(('%s STUCK after %d no-progress bursts'):format(label, stuck))
                on_done()
                return
            end
            coroutine.schedule(step, POST_BURST_DELAY)
        end
    end

    coroutine.schedule(step, 0)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PHASE 2  -  EMPTY W1/W2  (W1/W2 unused  >>  overflow chain)
---  ═══════════════════════════════════════════════════════════════════════════

function Phases.empty_w1w2(state, on_done)
    dlog('===== PHASE 2: EMPTY W1/W2 (unused -> overflow) =====')

    --- Items currently in W1/W2 that need to leave (unused or pinned-elsewhere).
    local function discover_pending()
        local list = {}
        local claim_pool = {}
        for _, b in ipairs(Config.PRIMARY_BAGS) do
            local items = windower.ffxi.get_items(b)
            if items then
                for slot, it in ipairs(items) do
                    if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                        local entry = {bag = b, slot = slot, id = it.id, name = Items.display_name(it.id)}
                        local pin = State.pin_target_for(entry, state.pinned_bags, claim_pool)
                        local used = Items.is_used_name(it.id, state.used_names)
                        if pin and pin ~= b then
                            entry.target = pin
                            table.insert(list, entry)
                        elseif not pin and not used then
                            table.insert(list, entry)
                        end
                    end
                end
            end
        end
        return list
    end

    --- Inv items pushable to overflow (unused or pinned-elsewhere).
    --- Used items stay in inv (Phase 3 will route them to W1/W2).
    local function discover_drainable()
        local list = {}
        local items = windower.ffxi.get_items(INV_BAG)
        if not items then return list end
        for slot, it in ipairs(items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                -- Multi-pin: all candidates so dst_list can fall back if full.
                local pins = unclaimed_pins_first(it.id, state.pinned_bags)
                local used = Items.is_used_name(it.id, state.used_names)
                if #pins > 0 then
                    table.insert(list, {slot = slot, dst_list = pins, name = Items.display_name(it.id)})
                elseif not used then
                    table.insert(list, {slot = slot, dst_list = Config.OVERFLOW_BAGS, name = Items.display_name(it.id)})
                end
            end
        end
        return list
    end

    run_burst_loop({
        label              = 'PHASE 2',
        discover_pending   = discover_pending,
        discover_drainable = discover_drainable,
        on_done            = on_done,
    })
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PHASE 3  -  FILL W1/W2  (used items <- overflow)
---  ═══════════════════════════════════════════════════════════════════════════
---   USED items go ONLY to W1/W2 (no overflow fallback) to prevent the
---   "used in overflow re-pulls forever" cycle. If W1/W2 are full, items
---   wait in inv and Phase 4 / outer-retry handles them.

function Phases.fill_w1w2(state, on_done)
    dlog('===== PHASE 3: FILL W1/W2 (used <- overflow) =====')

    --- Items in overflow needing promotion to W1/W2.
    local function discover_pending()
        local list = {}
        local claim_pool = {}
        for _, b in ipairs(Config.OVERFLOW_BAGS) do
            local items = windower.ffxi.get_items(b)
            if items then
                for slot, it in ipairs(items) do
                    if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                        local entry = {bag = b, slot = slot, id = it.id, name = Items.display_name(it.id)}
                        local pin = State.pin_target_for(entry, state.pinned_bags, claim_pool)
                        local used = Items.is_used_name(it.id, state.used_names)
                        if pin and pin ~= b then
                            entry.target = pin
                            table.insert(list, entry)
                        elseif not pin and used then
                            table.insert(list, entry)
                        end
                    end
                end
            end
        end
        return list
    end

    --- Inv items routable to W1/W2 (used or pinned-to-primary).
    local function discover_drainable()
        local list = {}
        local items = windower.ffxi.get_items(INV_BAG)
        if not items then return list end
        for slot, it in ipairs(items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                -- Multi-pin items (e.g. Chirich Ring +1 in W1 AND W2) get all
                -- pin candidates so drain can fall back if one is full.
                local pins = unclaimed_pins_first(it.id, state.pinned_bags)
                local used = Items.is_used_name(it.id, state.used_names)
                if #pins > 0 then
                    table.insert(list, {slot = slot, dst_list = pins, name = Items.display_name(it.id)})
                elseif used then
                    table.insert(list, {slot = slot, dst_list = Config.PRIMARY_BAGS, name = Items.display_name(it.id)})
                end
            end
        end
        return list
    end

    run_burst_loop({
        label              = 'PHASE 3',
        discover_pending   = discover_pending,
        discover_drainable = discover_drainable,
        on_done            = on_done,
    })
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PHASE 4  -  CLEANUP INVENTORY  (push leftover gear out, with retries)
---  ═══════════════════════════════════════════════════════════════════════════
---   FFXI silently rejects some put_item calls under sustained load.
---   Up to CLEANUP_MAX_PASSES re-runs let stuck items get another chance.

function Phases.cleanup_inv(used_names, pinned_bags, on_done)
    dlog('===== PHASE 4: CLEANUP INVENTORY =====')

    --- Snapshot inv and build a per-item plan with destination priority.
    local function build_plan()
        local items = windower.ffxi.get_items(INV_BAG)
        if not items then return {} end
        local plan = {}
        for slot_idx, it in ipairs(items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                -- Multi-pin items get ALL their pin candidates (e.g. Chirich
                -- Ring +1 -> {W1, W2}). Falls back to other primaries / fills
                -- when every pin is full.
                local pins = unclaimed_pins_first(it.id, pinned_bags)
                local is_used = Items.is_used_name(it.id, used_names)
                local dst_priority = {}
                local seen = {}
                local function add(b)
                    if not seen[b] then seen[b] = true; table.insert(dst_priority, b) end
                end
                if #pins > 0 then
                    for _, b in ipairs(pins) do add(b) end
                    if is_used then
                        for _, b in ipairs(Config.PRIMARY_BAGS) do add(b) end
                    end
                    for _, b in ipairs(Config.FILL_FALLBACK) do add(b) end
                elseif is_used then
                    for _, b in ipairs(Config.PRIMARY_BAGS) do add(b) end
                    for _, b in ipairs(Config.FILL_FALLBACK) do add(b) end
                else
                    -- Unused: ONLY OVERFLOW. Never primary (would cycle).
                    for _, b in ipairs(Config.OVERFLOW_BAGS) do add(b) end
                end
                table.insert(plan, {
                    slot         = slot_idx,
                    dst_priority = dst_priority,
                    name         = Items.display_name(it.id),
                    id           = it.id,
                })
            end
        end
        return plan
    end

    local pass_num     = 0
    local total_pushed = 0

    local function run_pass()
        pass_num = pass_num + 1
        local plan = build_plan()
        dlog(('  [PHASE 4] pass %d: %d items to cleanup'):format(pass_num, #plan))

        if #plan == 0 then
            dlog(('PHASE 4 DONE: %d leftovers pushed across %d pass(es)'):format(
                total_pushed, pass_num - 1))
            on_done()
            return
        end

        if pass_num > Config.CLEANUP_MAX_PASSES then
            dlog(('PHASE 4 GIVE UP: %d items still in inv after %d passes'):format(
                #plan, Config.CLEANUP_MAX_PASSES))
            for _, p in ipairs(plan) do
                dlog(('    LEFTOVER: %s @inv[%d]'):format(p.name, p.slot))
            end
            on_done()
            return
        end

        local pushed_this_pass = 0
        local idx = 0
        local function step()
            idx = idx + 1
            if idx > #plan then
                total_pushed = total_pushed + pushed_this_pass
                dlog(('  [PHASE 4] pass %d done: pushed %d, retry in %.1fs'):format(
                    pass_num, pushed_this_pass, MOVE_DELAY * 2))
                coroutine.schedule(run_pass, MOVE_DELAY * 2)
                return
            end
            local p = plan[idx]
            -- Verify slot still has the same item before pushing
            local items_now = windower.ffxi.get_items(INV_BAG)
            if items_now and items_now[p.slot] and items_now[p.slot].id == p.id
               and items_now[p.slot].status == 0 then
                for _, dst in ipairs(p.dst_priority) do
                    if space_in(dst) > 0 then
                        if push_slot(p.slot, dst) then
                            pushed_this_pass = pushed_this_pass + 1
                            break
                        end
                    end
                end
            end
            coroutine.schedule(step, MOVE_DELAY)
        end
        coroutine.schedule(step, 0)
    end

    run_pass()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ALT MODE (4-wardrobe characters: W1-W4 primary, Sack/Case overflow)
---  ═══════════════════════════════════════════════════════════════════════════
---   Phase A2 / A3 mirror Phase 2 / 3 but operate on the alt bag set.
---   `state.used_names` here comes from Auditor.collect_all_used_names()
---   (union across ALL jobs in data/<charname>/sets/), not just the active one.
---   Pinned items are intentionally ignored in alt mode (4-wardrobe chars
---   typically don't have multi-instance pin constraints to worry about).

--- Empty W1-W4 of items NOT used by any job  ->  Sack/Case.
function Phases.empty_alt(state, on_done)
    dlog('===== PHASE A2: EMPTY W1-W4 (any-job-unused -> Sack/Case) =====')

    --- Items currently in W1-W4 that are not used by any job.
    local function discover_pending()
        local list = {}
        for _, b in ipairs(Config.ALT_PRIMARY_BAGS) do
            local items = windower.ffxi.get_items(b)
            if items then
                for slot, it in ipairs(items) do
                    if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                        if not Items.is_used_name(it.id, state.used_names) then
                            table.insert(list, {
                                bag = b, slot = slot, id = it.id,
                                name = Items.display_name(it.id),
                            })
                        end
                    end
                end
            end
        end
        return list
    end

    --- Inv items pushable to Sack/Case (any unused gear we just pulled).
    local function discover_drainable()
        local list = {}
        local items = windower.ffxi.get_items(INV_BAG)
        if not items then return list end
        for slot, it in ipairs(items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id)
               and not Items.is_used_name(it.id, state.used_names) then
                table.insert(list, {
                    slot = slot, dst_list = Config.ALT_OVERFLOW_BAGS,
                    name = Items.display_name(it.id),
                })
            end
        end
        return list
    end

    run_burst_loop({
        label              = 'PHASE A2',
        discover_pending   = discover_pending,
        discover_drainable = discover_drainable,
        on_done            = on_done,
    })
end

--- Promote items used by any job from Sack/Case  ->  W1-W4.
function Phases.fill_alt(state, on_done)
    dlog('===== PHASE A3: FILL W1-W4 (any-job-used <- Sack/Case) =====')

    --- Items currently in Sack/Case that ARE used by any job.
    local function discover_pending()
        local list = {}
        for _, b in ipairs(Config.ALT_OVERFLOW_BAGS) do
            local items = windower.ffxi.get_items(b)
            if items then
                for slot, it in ipairs(items) do
                    if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id) then
                        if Items.is_used_name(it.id, state.used_names) then
                            table.insert(list, {
                                bag = b, slot = slot, id = it.id,
                                name = Items.display_name(it.id),
                            })
                        end
                    end
                end
            end
        end
        return list
    end

    --- Inv items routable to W1-W4 (used by any job).
    local function discover_drainable()
        local list = {}
        local items = windower.ffxi.get_items(INV_BAG)
        if not items then return list end
        for slot, it in ipairs(items) do
            if it.id and it.id > 0 and it.status == 0 and Items.is_equipment(it.id)
               and Items.is_used_name(it.id, state.used_names) then
                table.insert(list, {
                    slot = slot, dst_list = Config.ALT_PRIMARY_BAGS,
                    name = Items.display_name(it.id),
                })
            end
        end
        return list
    end

    run_burst_loop({
        label              = 'PHASE A3',
        discover_pending   = discover_pending,
        discover_drainable = discover_drainable,
        on_done            = on_done,
    })
end

return Phases
