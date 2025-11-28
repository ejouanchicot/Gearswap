---============================================================================
--- WHM Setup Module - Job Initialization & State Management
---============================================================================
--- Handles WHM-specific initialization:
---   • Buff tracking setup (Afflatus Solace/Misery)
---   • AutoMove integration
---   • State variable initialization
---   • Weapon lock management
---
--- @file WHM_SETUP.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- JOB SETUP HOOK
---============================================================================

--- Called during job initialization (before user_setup)
--- Sets up job-specific variables and buff tracking.
---
--- @return void
function job_setup()
    -- ==========================================================================
    -- AUTOMOVE INTEGRATION
    -- ==========================================================================
    -- AutoMove is already loaded in main file, just acknowledge it here
    if AutoMove then
        -- AutoMove registered in WHM_MOVEMENT.lua
    end

    -- ==========================================================================
    -- BUFF TRACKING
    -- ==========================================================================
    -- Initialize buff tracking for Afflatus Solace/Misery
    -- Mote-Include uses state.Buff for automatic spell mapping
    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
    state.Buff['Divine Caress'] = buffactive['Divine Caress'] or false
end

---============================================================================
--- NOTE: job_state_change is now in WHM_COMMANDS.lua
---============================================================================
--- The job_state_change hook has been moved to WHM_COMMANDS.lua for consistency
--- with other jobs (WAR, PLD, DNC, SAM).
---
---============================================================================
--- SPELL MAP CUSTOMIZATION
---============================================================================

--- Custom spell mapping for WHM-specific behavior
--- Called by Mote-Include before spell is cast.
---
--- @param spell table Spell data
--- @param default_spell_map string Default mapping from Mote-Include
--- @return string|nil Custom spell map or nil to use default
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        -- ==========================================================================
        -- CURE MAPPING (with Afflatus Solace detection)
        -- ==========================================================================
        -- Map Cure/Curaga to CureSolace if Afflatus Solace is active
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and state.Buff['Afflatus Solace'] then
            return 'CureSolace'
        end

        -- Map Cure/Curaga to CureMelee if engaged (optional - Timara WHM pattern)
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and player.status == 'Engaged' then
            return 'CureMelee'
        end

        -- ==========================================================================
        -- ENFEEBLING MAPPING (MND vs INT)
        -- ==========================================================================
        -- Map enfeebling spells based on primary stat
        if spell.skill == 'Enfeebling Magic' then
            if spell.type == 'WhiteMagic' then
                return 'MndEnfeebles'  -- Slow, Paralyze, Silence, etc.
            else
                return 'IntEnfeebles'  -- Blind, Poison (rare for WHM)
            end
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_setup = job_setup
_G.job_get_spell_map = job_get_spell_map

-- Export as module
return {
    job_setup = job_setup,
    job_get_spell_map = job_get_spell_map
}
