---  ═══════════════════════════════════════════════════════════════════════════
---   Auto Medicine - Universal Toggle for Automatic Debuff Cure Items
---  ═══════════════════════════════════════════════════════════════════════════
---   Owns `state.AutoMedicine`, the on/off switch read by PrecastGuard before
---   it spends an Echo Drops / Remedy on a blocking debuff.
---
---   Turning it Off does NOT unblock the action: paralysis still cancels a JA
---   (firing one while paralyzed burns the recast on a failed use) and silence
---   is a server-side block anyway. Off only stops the item consumption, which
---   is what matters against unremovable debuff auras where every cure is
---   immediately reapplied.
---
---   The state is created from each job's [JOB]_STATES.lua, in user_setup(),
---   like every other state. It cannot be created centrally from INIT_SYSTEMS:
---   the keybind HUD renders during user_setup and caches what it read, so a
---   state added afterwards displays as N/A until something forces a redraw.
---
---   @file    shared/utils/debuff/auto_medicine.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-07
---  ═══════════════════════════════════════════════════════════════════════════

local AutoMedicine = {}

local ON  = 'On'
local OFF = 'Off'

--- Mote's globals, handed in by the caller rather than read off _G.
---
--- This module is loaded with require(), and a required module does not
--- reliably see the job sandbox's globals - `state` and `M` can both read nil
--- here while being perfectly available to the file that includes us. That is
--- why AutoMove, which creates state.Moving the same way, is loaded with
--- include() instead. Taking them as arguments works either way.
local Mote = { state = nil, M = nil }

--- The state table we were given, if any.
--- @return table|nil
local function mote_state()
    return Mote.state or _G.state
end

--- Read the value that survived the last job change.
--- @return string 'On' or 'Off' (defaults to 'On' on a cold load)
local function load_persisted_value()
    if windower._auto_medicine == false then
        return OFF
    end
    return ON
end

--- Store the value in the windower table so it survives the GearSwap reload
--- triggered by a job change (a fresh sandbox loses every _G flag).
--- @param value string 'On' or 'Off'
local function persist_value(value)
    windower._auto_medicine = (value == ON)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Create state.AutoMedicine and restore its previous value.
--- Called by INIT_SYSTEMS, which is include()d and therefore has the sandbox
--- globals to hand us.
--- @param state_table table|nil Mote's `state` table
--- @param mode_ctor function|nil Mote's `M` constructor
--- @return boolean created True if the state is available after this call
function AutoMedicine.init(state_table, mode_ctor)
    Mote.state = state_table or Mote.state or _G.state
    Mote.M     = mode_ctor  or Mote.M     or _G.M


    if not Mote.state or not Mote.M then
        return false
    end

    local state = Mote.state
    local st = Mote.M { ['description'] = 'Auto Medicine', ON, OFF }

    -- Persist on every change, whoever makes it. The keybind runs
    -- `cyclestate AutoMedicine`, which calls cycle() straight on the Mote
    -- object without going through this module - so wrap the mutators rather
    -- than hoping something reads the value before the next job change.
    for _, name in ipairs({ 'cycle', 'set', 'reset', 'toggle' }) do
        local original = st[name]
        if type(original) == 'function' then
            st[name] = function(self, ...)
                local result = original(self, ...)
                persist_value(self.value)
                return result
            end
        end
    end

    state.AutoMedicine = st
    st:set(load_persisted_value())


    return true
end

--- Create the state if it is missing, keeping the current value if it is not.
--- @return boolean True if the state exists after this call
function AutoMedicine.ensure()
    local st = mote_state()

    if st and st.AutoMedicine then
        return true
    end
    return AutoMedicine.init()
end


--- Check whether PrecastGuard is allowed to consume a cure item.
--- Falls back to the persisted value when the state is missing (module loaded
--- before INIT_SYSTEMS ran, or a job that never created it).
--- @return boolean enabled True if auto-cure items may be used
function AutoMedicine.is_enabled()
    local st = mote_state()
    if st and st.AutoMedicine then
        return st.AutoMedicine.value == ON
    end
    return load_persisted_value() == ON
end

--- Toggle the state and persist the new value.
--- @return boolean enabled The new value (true = On)
function AutoMedicine.toggle()
    local new_value = AutoMedicine.is_enabled() and OFF or ON

    local st = mote_state()
    if st and st.AutoMedicine then
        st.AutoMedicine:set(new_value)
    end
    persist_value(new_value)

    return new_value == ON
end

--- Entry point used by CommonCommands: toggle, or force with 'on' / 'off'.
--- @param arg string|nil Optional explicit value
--- @return boolean True (the command is always handled)
function AutoMedicine.handle_command(arg)
    local value = arg and arg:lower() or nil
    local enabled

    if value == 'on' then
        enabled = AutoMedicine.set(true)
    elseif value == 'off' then
        enabled = AutoMedicine.set(false)
    else
        enabled = AutoMedicine.toggle()
    end

    local MessageDebuffs = require('shared/utils/messages/formatters/magic/message_debuffs')
    MessageDebuffs.show_auto_medicine_toggled(enabled)
    return true
end

--- Force the state to an explicit value.
--- @param enabled boolean True for On, false for Off
--- @return boolean enabled The applied value
function AutoMedicine.set(enabled)
    local new_value = enabled and ON or OFF

    local st = mote_state()
    if st and st.AutoMedicine then
        st.AutoMedicine:set(new_value)
    end
    persist_value(new_value)

    return enabled
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.AutoMedicine = AutoMedicine

return AutoMedicine
