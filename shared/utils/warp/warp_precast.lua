---============================================================================
--- Warp Precast - Force Fast Cast for warp/teleport spells
---============================================================================
--- Equips sets.precast.FC when a warp, teleport, recall, retrace or escape
--- spell is cast, for every job. WarpInit wraps _G.precast so this runs
--- before Mote's own precast.
---
--- @file shared/utils/warp/warp_precast.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-26
---============================================================================

local WarpPrecast = {}

local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

---============================================================================
--- PRECAST FORCE FC
---============================================================================

--- Force Fast Cast gear for warp spells
--- @param spell table The spell object
--- @return boolean True if FC was applied
function WarpPrecast.force_fc(spell)
    if not spell or not spell.name then
        return false
    end

    local WarpDetector = require('shared/utils/warp/warp_detector')
    local is_warp = WarpDetector.is_warp_spell(spell)

    if not is_warp then
        return false
    end

    if not sets or not sets.precast or not sets.precast.FC then
        MessageWarp.show_precast_fc_warning(spell.name)
        return false
    end

    equip(sets.precast.FC)
    MessageWarp.show_force_fc(spell.name)

    return true
end

---============================================================================
--- INTEGRATION HOOK
---============================================================================

--- Precast entry point, called by the _G.precast wrapper (warp_init.lua)
--- @param spell table The spell object
--- @param eventArgs table Event arguments (optional)
--- @return boolean True if handled
function WarpPrecast.handle_precast(spell, eventArgs)
    if not spell or spell.action_type ~= 'Magic' then
        return false
    end

    local WarpDetector = require('shared/utils/warp/warp_detector')
    local is_warp = WarpDetector.is_warp_spell(spell)

    if not is_warp then
        return false
    end

    local fc_applied = WarpPrecast.force_fc(spell)

    -- on_warp_spell() is a no-op today (spells need no slot lock)
    local WarpEquipment = require('shared/utils/warp/warp_equipment')
    WarpEquipment.on_warp_spell(spell)

    return fc_applied
end

---============================================================================
--- MOTE HOOK (Global Precast Override)
---============================================================================

--- Alternative entry point for a Mote precast handler (no caller today;
--- WarpInit wraps _G.precast instead)
--- @param spell table The spell object
--- @param eventArgs table Event arguments
function WarpPrecast.global_precast_hook(spell, eventArgs)
    if not spell or spell.action_type ~= 'Magic' then
        return
    end

    WarpPrecast.handle_precast(spell, eventArgs)
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize warp precast system (only shows the init message)
function WarpPrecast.init()
    MessageWarp.show_precast_initialized()
end

return WarpPrecast
