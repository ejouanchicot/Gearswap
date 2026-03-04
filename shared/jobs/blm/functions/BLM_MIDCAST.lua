---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Midcast Module - MagicBurst, MP Conservation & Elemental Matching
---  ═══════════════════════════════════════════════════════════════════════════
---   MagicBurst mode, MP conservation override, elemental matching (Hachirin-no-Obi).
---
---   @file    BLM_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local ElementalMatcher = nil
local MessageFormatter = nil
local MessageBLMMidcast = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local ENFEEBLING_MESSAGES_CONFIG = nil
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

    local _, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    MidcastManager = mm
    mark('MidcastManager')

    local _, em = pcall(require, 'shared/jobs/blm/functions/logic/elemental_matcher')
    ElementalMatcher = em
    mark('ElementalMatcher')

    -- NOTE: BLM_SPELL_DATABASE removed (was dead code - never used)

    mark('MessageFormatter')  -- already loaded above

    -- BLM Midcast Debug Messages
    local _, mbm = pcall(require, 'shared/utils/messages/formatters/jobs/message_blm_midcast')
    MessageBLMMidcast = mbm
    mark('MessageBLMMidcast')

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
    mark('ENHANCING_DB')

    -- Load Enfeebling Messages Config
    local _, config = pcall(require, 'shared/config/ENFEEBLING_MESSAGES_CONFIG')
    if not config then
        ENFEEBLING_MESSAGES_CONFIG = {
            display_mode = 'on',
            is_enabled = function() return true end,
            show_description = function() return false end
        }
    else
        ENFEEBLING_MESSAGES_CONFIG = config
    end
    mark('ENFEEBLING_CONFIG')

    -- Load MP conservation configuration
    local mp_config_success, mp_config = pcall(require, 'Tetsouo/config/blm/BLM_MP_CONFIG')
    if not mp_config_success or not mp_config then
        -- Fallback defaults if config not found
        BLMMPConfig = { mp_threshold = 1000 }
    else
        BLMMPConfig = mp_config
    end
    mark('BLM_MP_CONFIG')

    -- Load elemental matching configuration
    local elemental_config_success, elemental_config = pcall(require, 'Tetsouo/config/blm/BLM_ELEMENTAL_CONFIG')
    if not elemental_config_success or not elemental_config then
        -- Fallback defaults if config not found
        BLMElementalConfig = {
            auto_hachirin = true,
            check_storm = true,
            check_day = true,
            check_weather = true
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


---   Pre-midcast hook (job-specific logic before set selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- Handled by MidcastManager in job_post_midcast
end

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first spell cast
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Check debug state from global
    local debug_enabled = _G.MidcastManagerDebugState == true

    -- ══════════════════════════════════════════════════════════════════════════
    -- IMPACT - Special handling (Twilight Cloak Required)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Impact requires Twilight Cloak to cast - handled separately from other
    -- Elemental Magic to ensure the body slot is NEVER overwritten
    if spell.english == 'Impact' then
        -- Use dedicated Impact set (includes Twilight Cloak)
        local impact_set = sets.midcast['Impact'] or sets.midcast['Elemental Magic']

        -- Apply MagicBurst mode if enabled
        if state.MagicBurstMode and state.MagicBurstMode.current == 'On' then
            if sets.midcast['Impact'] and sets.midcast['Impact'].MagicBurst then
                impact_set = sets.midcast['Impact'].MagicBurst
            end
        end

        equip(impact_set)

        -- CRITICAL: Force Twilight Cloak protection (like Marsyas for BRD)
        -- This ensures body is NEVER overwritten during cast
        if _G.casting_impact and _G.impact_body then
            equip({body = _G.impact_body})
            if debug_enabled then
                MessageBLMMidcast.show_elemental_routing('Impact (Twilight Cloak locked)')
            end
        end

        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- ELEMENTAL MAGIC - Use MidcastManager with MagicBurst mode
    -- ══════════════════════════════════════════════════════════════════════════
    if spell.skill == 'Elemental Magic' then
        if debug_enabled then
            MessageBLMMidcast.show_elemental_routing(tostring(state.MagicBurstMode and state.MagicBurstMode.current or 'nil'))
        end

        -- Special handling for Death spell
        if spell.english == 'Death' then
            MidcastManager.select_set({
                skill = 'Death',
                spell = spell
            })
        else
            -- Select base set (MagicBurst mode or base)
            local mb_mode = nil
            if state.MagicBurstMode and state.MagicBurstMode.current == 'On' then
                mb_mode = 'MagicBurst'
            end

            if debug_enabled then
                MessageBLMMidcast.show_mode_value(tostring(mb_mode or 'nil (base set)'))
            end

            local base_set = nil
            if mb_mode and sets.midcast['Elemental Magic'].MagicBurst then
                base_set = sets.midcast['Elemental Magic'].MagicBurst
            else
                base_set = sets.midcast['Elemental Magic']
            end

            -- MP conservation override (low MP threshold)
            local current_mp = player and player.mp or 9999
            local mp_threshold = BLMMPConfig.mp_threshold or 1000
            local final_set = base_set

            if current_mp < mp_threshold then
                if debug_enabled then
                    MessageBLMMidcast.show_mp_conservation(current_mp, mp_threshold)
                end
                if sets.midcast.MPConservation then
                    final_set = set_combine(base_set, sets.midcast.MPConservation)
                end
            else
                if debug_enabled then
                    MessageBLMMidcast.show_normal_mp(current_mp, mp_threshold)
                end
            end

            -- Elemental matching (Hachirin-no-Obi day/weather)
            if BLMElementalConfig.auto_hachirin then
                local has_match, reason = ElementalMatcher.has_elemental_match(spell, BLMElementalConfig)
                if has_match and sets.midcast.ElementalMatch then
                    final_set = set_combine(final_set, sets.midcast.ElementalMatch)
                    if debug_enabled then
                        MessageBLMMidcast.show_elemental_match(reason)
                    end
                end
            end

            equip(final_set)

        end

        if debug_enabled then
            MessageBLMMidcast.show_elemental_return()
        end
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- DARK MAGIC - Use MidcastManager (Drain/Aspir)
    -- ══════════════════════════════════════════════════════════════════════════
    if spell.skill == 'Dark Magic' then
        if debug_enabled then
            MessageBLMMidcast.show_dark_routing()
        end

        MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })

        if debug_enabled then
            MessageBLMMidcast.show_dark_return()
        end
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- ENFEEBLING MAGIC - Use MidcastManager
    -- ══════════════════════════════════════════════════════════════════════════
    if spell.skill == 'Enfeebling Magic' then
        if debug_enabled then
            MessageBLMMidcast.show_enfeebling_routing()
        end

        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })

        if debug_enabled then
            MessageBLMMidcast.show_enfeebling_return()
        end

        -- Note: Spell messages handled by universal spell message system
        return
    end

    if debug_enabled then
        MessageBLMMidcast.show_skill_not_handled(spell.skill or 'Unknown')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

