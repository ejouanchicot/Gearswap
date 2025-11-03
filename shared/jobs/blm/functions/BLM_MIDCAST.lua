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
--- @version 2.0 - Migrated to MidcastManager
--- @date Created: 2025-10-15 | Updated: 2025-10-25
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')
local ElementalMatcher = require('shared/jobs/blm/functions/logic/elemental_matcher')

-- Load BLM Spell Database (for spell descriptions)
local BLMSpells = require('shared/data/magic/BLM_SPELL_DATABASE')

-- Load Message Formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load Enfeebling Messages Config
local _, ENFEEBLING_MESSAGES_CONFIG = pcall(require, 'shared/config/ENFEEBLING_MESSAGES_CONFIG')
if not ENFEEBLING_MESSAGES_CONFIG then
    ENFEEBLING_MESSAGES_CONFIG = {
        display_mode = 'on',
        is_enabled = function() return true end,
        show_description = function() return false end
    }
end

-- Load MP conservation configuration
local mp_config_success, BLMMPConfig = pcall(require, 'Tetsouo/config/blm/BLM_MP_CONFIG')
if not mp_config_success or not BLMMPConfig then
    -- Fallback defaults if config not found
    BLMMPConfig = { mp_threshold = 1000 }
end

-- Load elemental matching configuration
local elemental_config_success, BLMElementalConfig = pcall(require, 'Tetsouo/config/blm/BLM_ELEMENTAL_CONFIG')
if not elemental_config_success or not BLMElementalConfig then
    -- Fallback defaults if config not found
    BLMElementalConfig = {
        auto_hachirin = true,
        check_storm = true,
        check_day = true,
        check_weather = true
    }
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
            add_to_chat(158, '[BLM_MIDCAST] -> Routing to MidcastManager (Elemental)')
            add_to_chat(158, '[BLM_MIDCAST]   * MagicBurstMode: ' .. tostring(state.MagicBurstMode and state.MagicBurstMode.current or 'nil'))
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
                add_to_chat(158, '[BLM_MIDCAST]   * mode_value: ' .. tostring(mb_mode or 'nil (base set)'))
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
                    add_to_chat(158, '[BLM_MIDCAST]   * MP Conservation: ' .. current_mp .. ' < ' .. mp_threshold .. ' (applying MPConservation set)')
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
                    add_to_chat(158, '[BLM_MIDCAST]   * Normal MP: ' .. current_mp .. ' >= ' .. mp_threshold .. ' (no MP conservation)')
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
                            add_to_chat(159, '[BLM_MIDCAST]   * Elemental Match: ' .. reason)
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
            add_to_chat(158, '[BLM_MIDCAST] <- MidcastManager returned')
        end
        return
    end

    -- ==========================================================================
    -- DARK MAGIC - Use MidcastManager (Drain/Aspir)
    -- ==========================================================================
    if spell.skill == 'Dark Magic' then
        if debug_enabled then
            add_to_chat(158, '[BLM_MIDCAST] -> Routing to MidcastManager (Dark Magic)')
        end

        MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })

        if debug_enabled then
            add_to_chat(158, '[BLM_MIDCAST] <- MidcastManager returned')
        end
        return
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC - Use MidcastManager
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        if debug_enabled then
            add_to_chat(158, '[BLM_MIDCAST] -> Routing to MidcastManager (Enfeebling)')
        end

        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell
        })

        if debug_enabled then
            add_to_chat(158, '[BLM_MIDCAST] <- MidcastManager returned')
        end

        -- Note: Spell messages handled by universal spell message system
        return
    end

    if debug_enabled then
        add_to_chat(206, '[BLM_MIDCAST] !! Spell skill not handled by MidcastManager: ' .. (spell.skill or 'Unknown'))
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
