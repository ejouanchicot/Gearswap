---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Alt-mode Orchestrator
---  ═══════════════════════════════════════════════════════════════════════════
---   Phase chain for 4-wardrobe characters (e.g. Kaories): scans every job
---   in data/<charname>/sets/, treats W1-W4 as primary, Sack/Case/Satchel as
---   overflow. Triggered by `//gs c wo alt`.
---
---   This module is created via `OrchestratorAlt.create(ctx)` so the main
---   wardrobe_organizer can inject mutable-state setters and shared helpers
---   without exposing them globally.
---
---   ctx (required fields):
---     set_running(boolean)           - update IS_RUNNING flag
---     set_start_job_tag(string)      - record job at run start (job_changed guard)
---     active_job_tag() -> string     - current MAIN/SUB tag
---     job_changed() -> boolean       - true if main/sub changed since start
---     reset_module_state()           - reset outer-loop counters
---     clean_exit()                   - enable slots + reset + IS_RUNNING=false
---     abort_run(reason: string)      - chat warn + clean_exit
---     map_bag_names(list) -> list    - bag-id list to human labels
---
---   @file shared/utils/wardrobe/lib/orchestrator_alt.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')
local Log    = require('shared/utils/wardrobe/lib/log')
local Chat   = require('shared/utils/wardrobe/lib/chat')
local Moves  = require('shared/utils/wardrobe/lib/moves')
local Phases = require('shared/utils/wardrobe/lib/phases')

local OrchestratorAlt = {}

local dlog = Log.dlog

--- Build a minimal alt-mode state object: scans W1-W4 + Sack/Case bag info,
--- gathers used_names from ALL jobs in the active char's sets folder.
local function build_alt_state()
    local Auditor_ok, Auditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
    if not Auditor_ok or not Auditor.collect_all_used_names then
        return nil, 'Auditor.collect_all_used_names not available'
    end
    local used_names = Auditor.collect_all_used_names()
    if not used_names or not next(used_names) then
        return nil, 'no used items found - is the sets folder populated?'
    end
    local wardrobe_free = {}
    for _, b in ipairs(Config.ALT_ALL_BAGS) do
        wardrobe_free[b] = Moves.space_in(b)
    end
    return {
        used_names    = used_names,
        pinned_bags   = {},  -- ignored in alt mode
        inv_free      = Moves.space_in(Config.INV_BAG),
        wardrobe_free = wardrobe_free,
    }
end

--- Factory: build the alt orchestrator with the given context.
--- @param ctx table  See file header for required fields
--- @return table     { start = function(): nil }
function OrchestratorAlt.create(ctx)
    local Orch = {}

    -- Forward declarations so each step can reference the next one.
    local alt_phase2, alt_phase3, alt_phase4, alt_finish

    -- Final report panel + clean exit.
    alt_finish = function()
        coroutine.schedule(function()
            local final = build_alt_state()
            Phases.enable_slots()
            Chat.banner('Wardrobe Organize Alt - Complete')
            if final then
                Chat.detail('Inventory free', final.inv_free)
                Chat.detail('W1 / W2 free',   string.format('%d / %d',
                    final.wardrobe_free[8] or 0, final.wardrobe_free[10] or 0))
                Chat.detail('W3 / W4 free',   string.format('%d / %d',
                    final.wardrobe_free[11] or 0, final.wardrobe_free[12] or 0))
                Chat.detail('Sack / Case / Satchel', string.format('%d / %d / %d',
                    final.wardrobe_free[6] or 0, final.wardrobe_free[7] or 0,
                    final.wardrobe_free[5] or 0))
            end
            Chat.separator()
            dlog('========== WARDROBE ORGANIZE ALT END ==========')
            ctx.reset_module_state()
            ctx.set_running(false)
        end, Config.SETTLE_DELAY)
    end

    -- Phase 4: cleanup any leftover gear in inv, then schedule the final report.
    alt_phase4 = function(state)
        Chat.phase(4, 'Cleanup leftovers', nil)
        Phases.cleanup_inv(state.used_names, state.pinned_bags, alt_finish)
    end

    -- Phase 3: fill W1-W4 with used items (after re-snapshot).
    -- Falls back to the pre-Phase-2 state if re-snapshot fails.
    alt_phase3 = function(prev_state)
        if ctx.job_changed() then
            ctx.abort_run('Job changed mid-run, aborting.')
            return
        end
        local state = build_alt_state() or prev_state
        Chat.phase(3, 'Fill W1-W4 with used items', nil)
        Phases.fill_alt(state, function()
            coroutine.schedule(function() alt_phase4(state) end, Config.PHASE_DELAY)
        end)
    end

    -- Phase 2: empty W1-W4 of unused items, then re-snapshot for Phase 3.
    alt_phase2 = function(state)
        if ctx.job_changed() then
            ctx.abort_run('Job changed mid-run, aborting.')
            return
        end
        Chat.phase(2, 'Empty W1-W4 of unused items', nil)
        Phases.empty_alt(state, function()
            coroutine.schedule(function() alt_phase3(state) end, Config.PHASE_DELAY)
        end)
    end

    --- Entry point. Captures start_job_tag, builds initial state, prints the
    --- banner and kicks off Phase 0 (unequip) then Phase 2.
    function Orch.start()
        ctx.set_running(true)
        local job_tag = ctx.active_job_tag()
        ctx.set_start_job_tag(job_tag)
        Log.dlog_clear()
        dlog('========== WARDROBE ORGANIZE ALT START ==========')
        Chat.banner('Wardrobe Organize Alt - Started')
        Chat.detail('Active char', job_tag)
        Chat.detail('Config',      Config.LOADED_CHAR_CONFIG and 'per-character' or 'defaults')
        Chat.detail('Primary',     table.concat(ctx.map_bag_names(Config.ALT_PRIMARY_BAGS or {}), ', '))
        Chat.detail('Overflow',    table.concat(ctx.map_bag_names(Config.ALT_OVERFLOW_BAGS or {}), ', '))

        local state, err = build_alt_state()
        if not state then
            Chat.error('Failed to build alt state: ' .. tostring(err))
            ctx.clean_exit()
            return
        end

        local n_used = 0
        for _ in pairs(state.used_names) do n_used = n_used + 1 end
        Chat.detail('Used items (all jobs)', n_used)

        Chat.phase(0, 'Unequipping current gear', nil)
        -- Async unequip with self-verification: callback fires only when the
        -- player is actually naked (or all retry strategies exhausted).
        Phases.unequip(function() alt_phase2(state) end)
    end

    return Orch
end

return OrchestratorAlt
