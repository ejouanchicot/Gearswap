---============================================================================
--- Warp Equipment Manager - Equipment Lock During Warp/Teleport
---============================================================================
--- Prevents equipment swaps during warp to avoid:
---   - Ring being swapped off during warp >> warp cancels
---   - Main weapon being swapped off during warp >> warp cancels
---
--- @file shared/utils/warp/warp_equipment.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-26
---============================================================================

local WarpEquipment = {}

local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

---============================================================================
--- STATE TRACKING
---============================================================================

local is_locked = false
local lock_timer = nil
local current_warp_type = nil  -- 'spell' or 'item'
local current_slot = nil  -- Track which slot is locked

---============================================================================
--- EQUIPMENT LOCK/UNLOCK
---============================================================================

--- Lock equipment slots to prevent swaps during warp
--- @param warp_type string Type of warp ('spell' or 'item')
--- @param duration number Duration to keep locked (seconds)
--- @param tag string Optional tag to display ([WARP] or [TELE])
--- @param slot string Optional slot being used ('ring1', 'main', etc.)
function WarpEquipment.lock(warp_type, duration, tag, slot)
    if is_locked then
        -- Dropping the reference does not cancel the previous auto-unlock:
        -- it still fires at its own time.
        lock_timer = nil
    end

    -- Lock specific slot or all equipment slots
    local success, err = pcall(function()
        if slot then
            disable(slot)
        else
            disable('main', 'sub', 'range', 'ammo',
                    'head', 'neck', 'ear1', 'ear2',
                    'body', 'hands', 'ring1', 'ring2',
                    'back', 'waist', 'legs', 'feet')
        end
    end)

    if not success then
        MessageWarp.show_equipment_lock_error(err)
        return
    end

    is_locked = true
    current_warp_type = warp_type
    current_slot = slot or 'all'

    local display_tag = tag or 'WARP'
    local display_slot = slot or 'all slots'
    MessageWarp.show_equipment_locked(display_tag, display_slot)

    -- Schedule auto-unlock after duration + safety buffer
    local unlock_delay = (duration or 15) + 3  -- +3s safety buffer
    lock_timer = coroutine.schedule(function()
        WarpEquipment.unlock(true)  -- true = timeout unlock
    end, unlock_delay)
end

--- Unlock equipment slots after warp completes
--- @param is_timeout boolean True if unlocking due to timeout (optional)
--- @param tag string Optional tag to display ([WARP] or [TELE])
function WarpEquipment.unlock(is_timeout, tag)
    if not is_locked then
        return
    end

    -- The scheduled auto-unlock is not cancelled; it no-ops once unlocked.
    lock_timer = nil

    -- Unlock specific slot or all equipment slots
    local success, err = pcall(function()
        if current_slot and current_slot ~= 'all' then
            enable(current_slot)
        else
            enable('main', 'sub', 'range', 'ammo',
                   'head', 'neck', 'ear1', 'ear2',
                   'body', 'hands', 'ring1', 'ring2',
                   'back', 'waist', 'legs', 'feet')
        end
    end)

    if not success then
        MessageWarp.show_equipment_unlock_error(err)
        return
    end

    local display_tag = tag or 'WARP'
    local display_slot = current_slot or 'all slots'
    MessageWarp.show_equipment_unlocked(display_tag, display_slot)

    is_locked = false
    current_warp_type = nil
    current_slot = nil

    -- Put the job's set back. Not equip() here: from a scheduled callback it
    -- runs outside a GearSwap event and is dropped; `gs c update` goes through
    -- a real event (Mote's handle_update).
    coroutine.schedule(function()
        if player then
            send_command('gs c update')
        end
    end, 0.5)
end

---============================================================================
--- AUTOMATIC WARP DETECTION
---============================================================================

--- Handle warp spell cast (called from precast)
--- @param spell table The warp spell object
function WarpEquipment.on_warp_spell(spell)
    -- Spells don't need equipment lock (they can't be unequipped)
    -- This function is kept for compatibility but does nothing
    return
end

--- Handle warp item usage (called from action event)
--- @param warp_data table The warp item data
function WarpEquipment.on_warp_item(warp_data)
    if not warp_data then return end

    local duration = warp_data.duration or 12
    local slot = warp_data.slot

    -- Database slot names are not GearSwap slot names: only 'ring' is mapped.
    -- 'main' is valid; 'ears', 'item' and the others are passed through as-is.
    if slot == 'ring' then
        slot = 'ring1'
    end

    -- Determine tag based on item name
    local tag = 'WARP'
    if warp_data.name and (warp_data.name:find('Teleport') or warp_data.name:find('Dim') or
                            warp_data.name:find('Holla') or warp_data.name:find('Dem') or
                            warp_data.name:find('Mea') or warp_data.name:find('Vahzl') or
                            warp_data.name:find('Yhoat') or warp_data.name:find('Altep')) then
        tag = 'TELE'
    end

    WarpEquipment.lock('item', duration, tag, slot)
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize the warp equipment system (called by WarpInit.init on every load)
function WarpEquipment.init()
    local WarpDetector = require('shared/utils/warp/warp_detector')

    -- Inactive on purpose: init_action_listener() below clears every callback
    -- first, so this one never fires. Do not just swap the two calls - the
    -- auto-lock has never run and is not ready: the detector reads the item id
    -- from act.param (for category 9 that is a start/interrupt code, the id is
    -- in targets[1].actions[1].param), database slots such as 'ears' and 'item'
    -- are not GearSwap slot names, and the ring commands already lock ring1
    -- themselves, so a second timed lock would fight them.
    WarpDetector.register_callback(function(warp_type, warp_data)
        if warp_type == 'item' then
            WarpEquipment.on_warp_item(warp_data)
        end
    end)

    WarpDetector.init_action_listener()

    MessageWarp.show_equipment_initialized()
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Check if equipment is currently locked
--- @return boolean True if locked
function WarpEquipment.is_locked()
    return is_locked
end

--- Get current warp type
--- @return string|nil Current warp type ('spell', 'item', or nil)
function WarpEquipment.get_warp_type()
    return current_warp_type
end

--- Force unlock (emergency use only)
--- @param tag string Optional tag to display ([WARP] or [TELE])
function WarpEquipment.force_unlock(tag)
    WarpEquipment.unlock(false, tag)
end

return WarpEquipment
