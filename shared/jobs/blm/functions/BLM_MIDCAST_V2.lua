---============================================================================
--- BLM Midcast Module - Spell Midcast Handling (Powered by MidcastManager)
---============================================================================
--- Handles midcast gear for Black Mage job using centralized MidcastManager:
---   - Elemental Magic spells (MAB/MACC + Magic Burst modes)
---   - Death spell (HP-based damage special gear)
---   - Enfeebling spells (MACC)
---   - Dark Magic spells (Drain/Aspir)
---   - MP Conservation (dynamic gear switching based on current MP)
---
--- @file BLM_MIDCAST.lua
--- @author Tetsouo
--- @version 2.0 - Migrated to MidcastManager
--- @date Created: 2025-10-15 | Updated: 2025-10-24
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Centralized Midcast Manager
local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- BLM logic functions (loaded globally via blm_functions.lua)
-- SaveMP() - MP conservation gear switching

---============================================================================
--- MIDCAST HOOKS
---============================================================================

function job_midcast(spell, action, spellMap, eventArgs)
    -- BLM-SPECIFIC PRE-MIDCAST LOGIC

    -- Apply MP conservation for Elemental Magic
    if spell.skill == 'Elemental Magic' then
        -- SaveMP() applies dynamic gear switching based on current MP and casting mode
        if SaveMP and player and player.mp and state.CastingMode then
            SaveMP()
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- ==========================================================================
    -- ELEMENTAL MAGIC - Use MidcastManager with MagicBurstMode
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        -- Select set using MidcastManager
        -- Priority: .MagicBurst > base
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell,
            mode_state = state.MagicBurstMode and state.MagicBurstMode.value == 'On' and {value = 'MagicBurst'} or nil
        })

        return
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC - Use MidcastManager
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell
        })

        return
    end

    -- ==========================================================================
    -- DARK MAGIC - Use MidcastManager
    -- ==========================================================================
    if spell.skill == 'Dark Magic' then
        MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })

        return
    end

    -- ==========================================================================
    -- DEATH SPECIAL HANDLING
    -- ==========================================================================
    if spell.english == 'Death' then
        if sets.midcast['Death'] then
            equip(sets.midcast['Death'])
        end
        return
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
