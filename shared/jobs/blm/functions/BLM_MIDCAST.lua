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

local function ensure_modules_loaded()
    if modules_loaded then return end

    -- PROFILING: Measure lazy-load time on first spell
    local start_time = os.clock()
    local last_time = start_time
    local profiling_enabled = _G.PERFORMANCE_PROFILING and _G.PERFORMANCE_PROFILING.enabled

    -- Load MessageFormatter first so it's available inside mark()
    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local function mark(name)
        if profiling_enabled then
            local now = os.clock()
            local elapsed = (now - last_time) * 1000
            MessageFormatter.show_debug('MIDCAST', string.format('    [MIDCAST] %s: %.0fms', name, elapsed))
            last_time = now
        end
    end

    -- Router (loads MidcastManager + ElementalMatcher internally)
    local _, mr = pcall(require, 'shared/jobs/blm/functions/logic/midcast_router')
    MidcastRouter = mr
    mark('MidcastRouter')

    -- BLM Midcast Debug Messages
    local _, mbm = pcall(require, 'shared/utils/messages/formatters/jobs/message_blm_midcast')
    MessageBLMMidcast = mbm
    mark('MessageBLMMidcast')

    -- ENHANCING_MAGIC_DATABASE for spell_family routing (used by Enfeebling)
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
    mark('ENHANCING_DB')

    -- MP conservation configuration
    local mp_config_success, mp_config = pcall(require, 'Tetsouo/config/blm/BLM_MP_CONFIG')
    if not mp_config_success or not mp_config then
        BLMMPConfig = { mp_threshold = 1000 }  -- Fallback default
    else
        BLMMPConfig = mp_config
    end
    mark('BLM_MP_CONFIG')

    -- Elemental matching configuration
    local elemental_config_success, elemental_config = pcall(require, 'Tetsouo/config/blm/BLM_ELEMENTAL_CONFIG')
    if not elemental_config_success or not elemental_config then
        BLMElementalConfig = {  -- Fallback defaults
            auto_hachirin = true,
            check_storm = true,
            check_day = true,
            check_weather = true,
        }
    else
        BLMElementalConfig = elemental_config
    end
    mark('BLM_ELEMENTAL_CONFIG')

    modules_loaded = true

    -- PROFILING: Show total lazy-load time
    if profiling_enabled then
        local elapsed = (os.clock() - start_time) * 1000
        MessageFormatter.show_debug('MIDCAST', string.format('[PERF:LAZY] BLM_MIDCAST TOTAL: %.0fms', elapsed))
    end
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
