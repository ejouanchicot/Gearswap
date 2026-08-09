---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Midcast Module - Spell Skill Dispatcher
---  ═══════════════════════════════════════════════════════════════════════════
---   Routes spells to the appropriate handler in midcast_router.lua. The actual
---   gear logic (Impact Twilight Cloak lock, Elemental MagicBurst + MP/Match/
---   Quanpur overrides, Dark/Enfeebling MidcastManager calls) lives in the
---   router module so this file stays small and focused on orchestration.
---
---   Architecture:
---     BLM_MIDCAST (dispatcher) -> midcast_router.lua (handlers)
---                              -> MidcastManager (universal set selection)
---                              -> ElementalMatcher (Hachirin-no-Obi detection)
---
---   @file    BLM_MIDCAST.lua
---   @author  Tetsouo
---   @version 2.0 - Extracted handlers to logic/midcast_router.lua
---   @date    Created: 2025-10-05 | Refactored: 2026-05-09
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil
local MessageBLMMidcast = nil
local MidcastRouter = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local BLMMPConfig = nil
local BLMElementalConfig = nil

local modules_loaded = false

--- Load a per-character config, falling back to a built-in default.
---
--- The path carries the character name so a clone reads its own settings
--- rather than Tetsouo's. A missing file is normal, not an error: a fresh
--- clone has none until the player writes one, and the defaults have to be
--- good enough to play with.
--- @param char_name string Character whose config directory to read
--- @param config_name string File under <char>/config/blm/
--- @param fallback table Defaults when the file is absent or fails to load
--- @return table
local function load_blm_config(char_name, config_name, fallback)
    local ok, config = pcall(require, char_name .. '/config/blm/' .. config_name)
    if ok and config then
        return config
    end
    return fallback
end

--- Timing probe for the lazy load, active only under //gs c perf.
---
--- This runs on the first spell of a job, so a slow require here is felt as a
--- hitch at exactly the wrong moment. The per-module marks say which one.
--- @return function mark(name), function total()
local function lazy_load_timer()
    local enabled = _G.PERFORMANCE_PROFILING and _G.PERFORMANCE_PROFILING.enabled
    local start_time = os.clock()
    local last_time = start_time

    local function mark(name)
        if not enabled then return end
        local now = os.clock()
        MessageFormatter.show_debug('MIDCAST',
            string.format('    [MIDCAST] %s: %.0fms', name, (now - last_time) * 1000))
        last_time = now
    end

    local function total()
        if not enabled then return end
        MessageFormatter.show_debug('MIDCAST',
            string.format('[PERF:LAZY] BLM_MIDCAST TOTAL: %.0fms',
                          (os.clock() - start_time) * 1000))
    end

    return mark, total
end

local function ensure_modules_loaded()
    if modules_loaded then return end

    -- MessageFormatter first: the timer below reports through it.
    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local mark, total = lazy_load_timer()

    -- Pulls in MidcastManager and ElementalMatcher itself.
    local _, mr = pcall(require, 'shared/jobs/blm/functions/logic/midcast_router')
    MidcastRouter = mr
    mark('MidcastRouter')

    local _, mbm = pcall(require, 'shared/utils/messages/formatters/jobs/message_blm_midcast')
    MessageBLMMidcast = mbm
    mark('MessageBLMMidcast')

    -- Enfeebling routes on spell_family, which lives in the enhancing database.
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
    mark('ENHANCING_DB')

    local char_name = (player and player.name) or 'Tetsouo'

    BLMMPConfig = load_blm_config(char_name, 'BLM_MP_CONFIG',
        { mp_threshold = 1000 })
    mark('BLM_MP_CONFIG')

    BLMElementalConfig = load_blm_config(char_name, 'BLM_ELEMENTAL_CONFIG', {
        auto_hachirin = true,
        check_storm = true,
        check_day = true,
        check_weather = true,
    })
    mark('BLM_ELEMENTAL_CONFIG')

    modules_loaded = true
    total()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook (job-specific logic before set selection).
--- All gear handling happens in job_post_midcast via the router.
function job_midcast(spell, action, spellMap, eventArgs)
    -- Handled by MidcastRouter in job_post_midcast
end

--- Post-midcast dispatcher: route spell to the appropriate router handler.
--- Each handler owns the gear selection + BLM-specific overrides for its skill.
function job_post_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Build context passed to each handler
    local ctx = {
        debug_enabled       = _G.MidcastManagerDebugState == true,
        messages            = MessageBLMMidcast,
        mp_config           = BLMMPConfig,
        elemental_config    = BLMElementalConfig,
        enfeebling_database = EnhancingSPELLS_success and EnhancingSPELLS
                              and EnhancingSPELLS.get_spell_family or nil,
    }

    -- Impact: special handling (Twilight Cloak body lock) - checked BEFORE skill
    if spell.english == 'Impact' then
        MidcastRouter.handle_impact(spell, ctx)
        return
    end

    -- Skill-based dispatch
    if spell.skill == 'Elemental Magic' then
        MidcastRouter.handle_elemental(spell, ctx)
        return
    end

    if spell.skill == 'Dark Magic' then
        MidcastRouter.handle_dark(spell, ctx)
        return
    end

    if spell.skill == 'Enfeebling Magic' then
        MidcastRouter.handle_enfeebling(spell, ctx)
        return
    end

    -- Unknown skill - just log it
    if ctx.debug_enabled then
        MessageBLMMidcast.show_skill_not_handled(spell.skill or 'Unknown')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}
