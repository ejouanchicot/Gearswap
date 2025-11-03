---============================================================================
--- WHM Buffs Module - Buff Change Handling & Setup
---============================================================================
--- Handles buff gain/loss events for White Mage:
---   • Afflatus Solace tracking
---   • Afflatus Misery tracking
---   • Weakness debuff handling
---   • Divine Caress tracking
---   • Auto-gear swaps based on buff status
---   • Buff tracking initialization (job_setup)
---
--- @file WHM_BUFFS.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- JOB SETUP HOOK
---============================================================================

--- Called during job initialization (before user_setup)
--- Initializes buff tracking for WHM-specific buffs.
---
--- @return void
function job_setup()
    -- Initialize buff tracking for Afflatus Solace/Misery and Divine Caress
    -- Mote-Include uses state.Buff for automatic spell mapping
    state.Buff = {}
    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
    state.Buff['Divine Caress'] = buffactive['Divine Caress'] or false
end

---============================================================================
--- BUFF CHANGE HOOK
---============================================================================

--- Called when a buff is gained or lost
---
--- @param buff string Buff name ('Afflatus Solace', 'Weakness', 'Divine Caress', etc.)
--- @param gain boolean true if buff was gained, false if lost
--- @return void
function job_buff_change(buff, gain, eventArgs)
    -- Doom: HIGHEST PRIORITY - Must override everything
    if buff == 'doom' then
        local is_doomed = buffactive['doom']

        if is_doomed then
            equip(sets.buff.Doom)
            -- Disable slots to prevent other gear swaps from overwriting Doom gear
            disable('neck', 'ring1', 'ring2', 'waist')
            MessageFormatter.show_warning("DOOM detected! Equipping Doom gear.")
        else
            -- Enable slots before restoring gear
            enable('neck', 'ring1', 'ring2', 'waist')
            handle_equipping_gear(player.status)
            MessageFormatter.show_success("Doom removed.")
        end
        return  -- Stop processing - Doom takes absolute priority
    end

    -- ==========================================================================
    -- WEAKNESS HANDLING (Timara WHM pattern)
    -- ==========================================================================
    -- When Weakness is gained and PDT is inactive, equip Weak set
    if buff == 'Weakness' and gain == true then
        if state.IdleMode and state.IdleMode.current ~= 'PDT' then
            equip(sets.idle.Weak)
        else
            -- If PDT is active, use normal idle PDT set
            equip(sets.idle.PDT or sets.idle)
        end
    end

    -- ==========================================================================
    -- AFFLATUS TRACKING
    -- ==========================================================================
    -- Track Afflatus Solace/Misery for Mote-Include spell mapping
    -- (Mote automatically uses state.Buff['Afflatus Solace'] for CureSolace mapping)
    if buff == 'Afflatus Solace' then
        state.Buff['Afflatus Solace'] = gain
    end

    if buff == 'Afflatus Misery' then
        state.Buff['Afflatus Misery'] = gain
    end

    -- ==========================================================================
    -- DIVINE CARESS
    -- ==========================================================================
    -- Track Divine Caress for post-midcast gear application
    if buff == 'Divine Caress' then
        state.Buff['Divine Caress'] = gain
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_setup = job_setup
_G.job_buff_change = job_buff_change

-- Export as module
return {
    job_setup = job_setup,
    job_buff_change = job_buff_change
}
