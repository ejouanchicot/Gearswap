---============================================================================
--- BLM Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast gear for Black Mage using centralized MidcastManager.
---
--- Features:
---   - Elemental Magic with MagicBurst mode support
---   - Dark Magic (Drain/Aspir)
---   - Enfeebling Magic
---   - MP Conservation (SaveMP integration)
---
--- @file BLM_MIDCAST.lua
--- @author Tetsouo
--- @version 3.0 - Added spell_family database support
--- @date Created: 2025-10-15 | Updated: 2025-11-05
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MidcastManager = nil
local ElementalMatcher = nil
local BLMSpells = nil
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

    MidcastManager = require('shared/utils/midcast/midcast_manager')
    ElementalMatcher = require('shared/jobs/blm/functions/logic/elemental_matcher')

    -- Load BLM Spell Database (for spell descriptions)
    BLMSpells = require('shared/data/magic/BLM_SPELL_DATABASE')

    -- Load Message Formatter
    MessageFormatter = require('shared/utils/messages/message_formatter')

    -- BLM Midcast Debug Messages
    MessageBLMMidcast = require('shared/utils/messages/formatters/jobs/message_blm_midcast')

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

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

    -- Load MP conservation configuration
    local mp_config_success, mp_config = pcall(require, 'Tetsouo/config/blm/BLM_MP_CONFIG')
    if not mp_config_success or not mp_config then
        -- Fallback defaults if config not found
        BLMMPConfig = { mp_threshold = 1000 }
    else
        BLMMPConfig = mp_config
    end

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

    modules_loaded = true
end

---============================================================================
--- MIDCAST HOOKS
---============================================================================

function job_midcast(spell, action, spellMap, eventArgs)
    -- MP Conservation for Elemental Magic
    -- ⚠️ DISABLED: SaveMP() overwrites sets.midcast['Elemental Magic'].MagicBurst
    -- MidcastManager now handles set selection directly (no need to mutate global sets)
    -- if spell.skill == 'Elemental Magic' then
    --     if SaveMP and player and player.mp and state.CastingMode then
    --         SaveMP()
    --     end
    -- end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first spell cast
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Check debug state from global
    local debug_enabled = _G.MidcastManagerDebugState == true

    -- ==========================================================================
    -- ELEMENTAL MAGIC - Use MidcastManager with MagicBurst mode
    -- ==========================================================================
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
            -- =====================================================================
            -- STEP 1: Use MidcastManager to select base set
            -- =====================================================================
            local mb_mode = nil
            if state.MagicBurstMode and state.MagicBurstMode.current == 'On' then
                mb_mode = 'MagicBurst'
            end

            if debug_enabled then
                MessageBLMMidcast.show_mode_value(tostring(mb_mode or 'nil (base set)'))
            end

            -- Get base set from static sets
            local base_set = nil
            if mb_mode and sets.midcast['Elemental Magic'].MagicBurst then
                base_set = sets.midcast['Elemental Magic'].MagicBurst
            else
                base_set = sets.midcast['Elemental Magic']
            end

            -- =====================================================================
            -- STEP 2: Apply MP-based overrides (SaveMP logic)
            -- =====================================================================
            local current_mp = player and player.mp or 9999
            local mp_threshold = BLMMPConfig.mp_threshold or 1000  -- Load from config
            local final_set = base_set

            if current_mp < mp_threshold then
                -- Low MP: Override with MP conservation gear
                if debug_enabled then
                    MessageBLMMidcast.show_mp_conservation(current_mp, mp_threshold)
                end

                -- Override specific pieces for MP conservation using sets.midcast.MPConservation
                if sets.midcast.MPConservation then
                    final_set = set_combine(base_set, sets.midcast.MPConservation)
                else
                    -- Fallback if MPConservation set not defined
                    final_set = base_set
                end
            else
                if debug_enabled then
                    MessageBLMMidcast.show_normal_mp(current_mp, mp_threshold)
                end
            end

            -- =====================================================================
            -- STEP 3: Apply elemental matching overrides
            -- =====================================================================
            if BLMElementalConfig.auto_hachirin then
                local has_match, reason = ElementalMatcher.has_elemental_match(spell, BLMElementalConfig)

                if has_match then
                    -- Override with ElementalMatch set (user-configurable)
                    if sets.midcast.ElementalMatch then
                        final_set = set_combine(final_set, sets.midcast.ElementalMatch)

                        if debug_enabled then
                            MessageBLMMidcast.show_elemental_match(reason)
                        end
                    end
                end
            end

            -- =====================================================================
            -- STEP 4: Equip final combined set
            -- =====================================================================
            equip(final_set)

        end

        if debug_enabled then
            MessageBLMMidcast.show_elemental_return()
        end
        return
    end

    -- ==========================================================================
    -- DARK MAGIC - Use MidcastManager (Drain/Aspir)
    -- ==========================================================================
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

    -- ==========================================================================
    -- ENFEEBLING MAGIC - Use MidcastManager
    -- ==========================================================================
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

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Export module
local BLM_MIDCAST = {}
BLM_MIDCAST.job_midcast = job_midcast
BLM_MIDCAST.job_post_midcast = job_post_midcast

return BLM_MIDCAST
