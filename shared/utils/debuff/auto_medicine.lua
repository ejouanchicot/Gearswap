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
---   State lives here rather than in the 15 per-job [JOB]_STATES.lua configs:
---   the behaviour is universal, so the state is created once by INIT_SYSTEMS.
---
---   @file    shared/utils/debuff/auto_medicine.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-07
---  ═══════════════════════════════════════════════════════════════════════════

local AutoMedicine = {}

local ON  = 'On'
local OFF = 'Off'

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
--- Called by INIT_SYSTEMS after Mote-Include, so `state` and `M` both exist.
--- @return boolean created True if the state is available after this call
function AutoMedicine.init()
    -- `M` is looked up as a plain global rather than through `_G`: GearSwap
    -- gives each job its own environment, and depending on how it is chained
    -- `_G.M` can read nil while `M` still resolves.
    if not state or not M then
        return false
    end

    local st = M { ['description'] = 'Auto Medicine', ON, OFF }

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
---
--- Mote rebuilds `state` from scratch in init_include(), so a state created
--- outside user_setup() can be wiped by a later re-init - and the keybind HUD
--- then shows N/A for it. Cheap enough to call from a timer.
--- @return boolean True if the state exists after this call
function AutoMedicine.ensure()
    if state and state.AutoMedicine then
        return true
    end
    return AutoMedicine.init()
end

--- Check whether PrecastGuard is allowed to consume a cure item.
--- Falls back to the persisted value when the state is missing (module loaded
--- before INIT_SYSTEMS ran, or a job that never created it).
--- @return boolean enabled True if auto-cure items may be used
function AutoMedicine.is_enabled()
    if _G.state and state.AutoMedicine then
        local value = state.AutoMedicine.value
        -- The keybind cycles the state directly instead of going through
        -- toggle(), so mirror it here: without this a cycled value would be
        -- lost at the next job change, which restores from the windower copy.
        persist_value(value)
        return value == ON
    end
    return load_persisted_value() == ON
end

--- Toggle the state and persist the new value.
--- @return boolean enabled The new value (true = On)
function AutoMedicine.toggle()
    local new_value = AutoMedicine.is_enabled() and OFF or ON

    if _G.state and state.AutoMedicine then
        state.AutoMedicine:set(new_value)
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

    if _G.state and state.AutoMedicine then
        state.AutoMedicine:set(new_value)
    end
    persist_value(new_value)

    return enabled
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.AutoMedicine = AutoMedicine

return AutoMedicine
