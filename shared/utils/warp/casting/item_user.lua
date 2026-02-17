---============================================================================
--- Item User - Ring Usage with Auto-Fix (EXTRACTED from cast_warp_spell)
---============================================================================
--- Handles ring equipping, usage checking, and automatic slot fixing.
--- This is the 280-line monster extracted from cast_warp_spell().
---
--- @file item_user.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')
local MessageCore = require('shared/utils/messages/message_core')
local CastHelpers = require('shared/utils/warp/casting/cast_helpers')

-- Cache resources for performance
local res = require('resources')
local res_bags = res.bags

local ItemUser = {}

-- Debug toggle (controlled by //gs c debugwarp)
_G.WARP_DEBUG = _G.WARP_DEBUG or false

--- Helper: Debug logging (only if WARP_DEBUG enabled)
--- @param message string Debug message
local function debug_log(message)
    if _G.WARP_DEBUG then
        MessageWarp.show_item_casting_debug(message)
    end
end

--- Helper: Restore appropriate equipment set (universal for all jobs)
--- Uses Mote-Include's native logic to determine correct set
local function restore_equipment()
    if not player then
        debug_log('Cannot restore equipment - player data unavailable')
        return
    end

    -- METHOD 1: Use status_change to FORCE full set reevaluation
    -- This is the most reliable method to restore disabled slots
    if status_change then
        debug_log('Restoring equipment via status_change() [FORCE REFRESH]')
        status_change(player.status, player.status)
        return
    end

    -- METHOD 2: Fallback - use handle_equipping_gear (if available)
    -- This respects ALL states (HybridMode, IdleMode, CastingMode, etc.)
    if handle_equipping_gear then
        debug_log('Restoring equipment via handle_equipping_gear()')
        handle_equipping_gear(player.status)
        return
    end

    -- METHOD 3: Last resort - construct set name manually
    local base_set = (player.status == 'Engaged') and 'sets.engaged' or 'sets.idle'

    -- Try to detect active modes (HybridMode, IdleMode, etc.)
    if state then
        -- Check common mode states
        local modes_to_check = {'HybridMode', 'IdleMode', 'OffenseMode', 'DefenseMode'}
        for _, mode_name in ipairs(modes_to_check) do
            local mode_state = state[mode_name]
            if mode_state then
                local mode_value = mode_state.value or mode_state.current
                if mode_value and mode_value ~= 'Normal' and mode_value ~= 'None' then
                    base_set = base_set .. '.' .. mode_value
                    debug_log('Detected ' .. mode_name .. ': ' .. mode_value .. ' >> ' .. base_set)
                    break  -- Use first non-default mode found
                end
            end
        end
    end

    debug_log('Restoring equipment manually: ' .. base_set)
    windower.send_command('gs equip ' .. base_set)
end

---============================================================================
--- RING USAGE WITH AUTO-FIX (Main Function)
---============================================================================

--- Use a ring with automatic interrupt detection and slot fixing
--- @param ring_names string|table Ring name(s) to try (priority order)
--- @param context string Context for messages ('warp' or spell name)
--- @return boolean True if ring was used
function ItemUser.use_ring(ring_names, context)
    if not player then
        MessageCore.error('[WARP] Player data not available')
        return false
    end

    -- Normalize ring_names to table
    local ring_list = type(ring_names) == 'table' and ring_names or {ring_names}

    -- Track cooldowns of unavailable rings
    local cooldown_info = {}

    -- Try each ring in order
    for _, ring_name in ipairs(ring_list) do
        local ring_id = CastHelpers.get_ring_id(ring_name)

        if ring_id and CastHelpers.has_item(ring_name, ring_id) then
            -- Check if ring is usable (returns usable, delay, status)
            local usable, delay, status = ItemUser._check_ring_usable(ring_id)

            if usable then
                -- Ring is ready! Use it
                local is_warp_ring = (ring_name == 'Warp Ring')
                local tag = is_warp_ring and 'WARP' or 'TELE'

                debug_log('Item is ready! Status: ' .. tostring(status))

                -- Show equipping message
                if is_warp_ring then
                    MessageWarp.show_warp_equipping(ring_name)
                else
                    MessageWarp.show_tele_equipping(ring_name)
                end

                -- Execute ring usage sequence
                ItemUser._execute_ring_sequence(ring_name, ring_id, is_warp_ring, tag)
                return true
            else
                -- Ring not available, store info
                local reason = status or 'unknown'
                debug_log('Ring ' .. ring_name .. ' not ready - status: ' .. reason .. ' (' .. tostring(delay) .. 's)')
                table.insert(cooldown_info, {name = ring_name, delay = delay, status = reason})
            end
        end
    end

    -- No ring available - show all cooldowns
    if #cooldown_info > 0 then
        ItemUser._show_all_cooldowns(cooldown_info, context)
    else
        MessageCore.error('[WARP] No available rings found')
    end

    return false
end

---============================================================================
--- INTERNAL: Check Ring Usability (COMPLETE - Based on MyHome.lua)
---============================================================================

-- Windower extdata timezone offset (JST server time vs local time)
-- Based on MyHome addon which uses +18000 seconds (5 hours)
local EXTDATA_TIME_OFFSET = 18000

-- Safety delay after item appears ready (lag/desync protection)
local SAFETY_DELAY = 3.5  -- Extra seconds to wait before using item (zone-dependent lag buffer)

--- Check if a warp item is usable right now
--- Handles both 'General' items (scrolls) and 'Enchanted Equipment' (rings/wings)
--- @param item_id number Item ID to check
--- @return boolean, number, string Usable, delay in seconds, status reason
function ItemUser._check_ring_usable(item_id)
    local has_extdata, extdata = pcall(require, 'extdata')
    if not has_extdata then
        debug_log('ERROR: extdata library not available')
        return false, 0, 'extdata_missing'
    end

    local get_items = windower.ffxi.get_items
    local current_time = os.time()

    -- Search all equippable bags for the item
    for bag_id in pairs(res_bags:equippable(true)) do
        local bag = get_items(bag_id)

        -- Check if bag is accessible
        if bag.enabled then
            for _, item in ipairs(bag) do
                if item.id == item_id then
                    -- Decode extdata
                    local ext = extdata.decode(item)
                    if not ext then
                        debug_log('ERROR: extdata.decode() returned nil for item ID ' .. item_id)
                        return false, 0, 'decode_failed'
                    end

                    -----------------------------------------------------------
                    -- CASE 1: General Items (scrolls, etc.) - Always ready
                    -----------------------------------------------------------
                    if ext.type == 'General' then
                        debug_log('Item type: General - ready')
                        return true, 0, 'ready'
                    end

                    -----------------------------------------------------------
                    -- CASE 2: Enchanted Equipment (rings, wings, slips)
                    -----------------------------------------------------------
                    if ext.type == 'Enchanted Equipment' then
                        -- Calculate recast like MyHome.lua does (AUTHORITATIVE METHOD)
                        -- recast = charges_remaining > 0 AND next_use_time delay
                        local has_charges = ext.charges_remaining and ext.charges_remaining > 0
                        local recast_delay = 0

                        if has_charges and ext.next_use_time then
                            recast_delay = math.max((ext.next_use_time + EXTDATA_TIME_OFFSET) - current_time, 0)
                        end

                        -- Item is usable if: has charges AND recast = 0
                        local is_usable = has_charges and recast_delay == 0

                        debug_log(string.format('Enchanted item - charges:%s recast:%ds usable:%s',
                            tostring(ext.charges_remaining), recast_delay, tostring(is_usable)))

                        -----------------------------------------------------------
                        -- CHECK 1: No charges = full cooldown
                        -----------------------------------------------------------
                        if not has_charges then
                            if ext.next_use_time then
                                local cooldown = (ext.next_use_time + EXTDATA_TIME_OFFSET) - current_time
                                debug_log(string.format('No charges - full cooldown: %ds', math.max(0, cooldown)))
                                return false, math.max(0, cooldown), 'cooldown'
                            else
                                return false, 600, 'cooldown'
                            end
                        end

                        -----------------------------------------------------------
                        -- CHECK 2: Has charges but recast not finished
                        -----------------------------------------------------------
                        if recast_delay > 0 then
                            debug_log(string.format('Has charges but recast: %ds', recast_delay))
                            return false, recast_delay, 'cooldown'
                        end

                        -----------------------------------------------------------
                        -- CHECK 3: Ready! (has charges AND recast = 0)
                        -----------------------------------------------------------
                        return true, 0, 'ready'
                    end

                    -----------------------------------------------------------
                    -- CASE 3: Unknown type
                    -----------------------------------------------------------
                    debug_log('WARNING: Unknown item type: ' .. tostring(ext.type))
                    return false, 0, 'unknown_type'
                end
            end
        end
    end

    debug_log('Item not found in any accessible bag')
    return false, 0, 'not_found'
end

--- Show all ring cooldowns when none are available
--- @param cooldown_info table Array of {name, delay}
--- @param context string Context for messages
function ItemUser._show_all_cooldowns(cooldown_info, context)
    -- Find soonest available
    local soonest = nil
    local soonest_delay = 999999

    for _, info in ipairs(cooldown_info) do
        if info.delay > 0 and info.delay < soonest_delay then
            soonest = info.name
            soonest_delay = info.delay
        end
    end

    -- Header message
    MessageWarp.show_all_items_cooldown()

    -- Show each item cooldown
    for _, info in ipairs(cooldown_info) do
        local delay = info.delay
        local time_msg

        if delay > 0 then
            if delay >= 60 then
                -- Show in minutes (for delays > 60s)
                local minutes = math.floor(delay / 60)
                local seconds = delay % 60
                time_msg = seconds > 0 and
                    string.format('%dm %ds', minutes, seconds) or
                    string.format('%dm', minutes)
            else
                -- Show in seconds (for delays <= 60s)
                time_msg = string.format('%ds', delay)
            end
            MessageWarp.show_item_cooldown_time(info.name, time_msg)
        else
            -- Equip delay (just equipped)
            MessageWarp.show_item_equip_delay(info.name)
        end
    end

    -- Show soonest available (only if multiple items)
    if soonest and #cooldown_info > 1 then
        local time_msg
        if soonest_delay >= 60 then
            local minutes = math.floor(soonest_delay / 60)
            local seconds = soonest_delay % 60
            time_msg = seconds > 0 and
                string.format('%dm %ds', minutes, seconds) or
                string.format('%dm', minutes)
        else
            time_msg = string.format('%ds', soonest_delay)
        end

        MessageWarp.show_next_available_item(soonest, time_msg)
    end
end

---============================================================================
--- INTERNAL: Ring Usage Sequence
---============================================================================

--- Execute complete ring usage sequence with auto-fix
--- @param ring_name string Ring name
--- @param ring_id number Ring item ID
--- @param is_warp_ring boolean True if Warp Ring
--- @param tag string Message tag ('WARP' or 'TELE')
function ItemUser._execute_ring_sequence(ring_name, ring_id, is_warp_ring, tag)
    -- STEP 0: Save initial equipment (BEFORE disabling)
    local initial_ring1 = nil
    if player and player.equipment and player.equipment.ring1 then
        initial_ring1 = player.equipment.ring1
        debug_log('Initial ring1 saved: ' .. tostring(initial_ring1))
    else
        debug_log('No initial ring1 detected (empty slot)')
    end

    -- STEP 1: Disable GearSwap for ring1 slot
    send_command('gs disable ring1')
    debug_log('Ring1 slot disabled')

    -- STEP 2: Equip the ring (after delay)
    coroutine.schedule(function()
        send_command('input /equip ring1 "' .. ring_name .. '"')
    end, 0.5)

    -- STEP 3: Wait for ring to be equipped AND usable (longer delay to ensure equip completes)
    coroutine.schedule(function()
        ItemUser._wait_for_ring_usable(ring_name, ring_id, is_warp_ring, tag, initial_ring1)
    end, 2.5)
end

---============================================================================
--- INTERNAL: Wait for Ring Usable
---============================================================================

--- Wait for ring to be usable after equipping, then use it (Based on MyHome.lua)
--- Uses ext.usable flag to detect when item is ready
--- @param ring_name string Ring name
--- @param ring_id number Ring item ID
--- @param is_warp_ring boolean True if Warp Ring
--- @param tag string Message tag
--- @param initial_ring1 string|nil Initial ring1 equipment
function ItemUser._wait_for_ring_usable(ring_name, ring_id, is_warp_ring, tag, initial_ring1)
    local wait_count = 0
    local max_wait = 15
    local check_interval = 1  -- Check every second
    local ready_timestamp = nil  -- Track when item first became ready (for safety delay)

    local function check_usable()
        wait_count = wait_count + 1

        -- Load extdata
        local has_extdata, extdata = pcall(require, 'extdata')
        if not has_extdata then
            MessageWarp.show_extdata_error(tag)
            send_command('gs enable ring1')
            return
        end

        -- Find ring in bags and check usability
        local get_items = windower.ffxi.get_items
        local found_item = nil

        for bag_id in pairs(res_bags:equippable(true)) do
            local bag = get_items(bag_id)
            if bag.enabled then
                for _, item in ipairs(bag) do
                    if item.id == ring_id then
                        found_item = item
                        break
                    end
                end
            end
            if found_item then break end
        end

        if not found_item then
            MessageWarp.show_item_disappeared(tag)
            send_command('gs enable ring1')
            return
        end

        -- Decode extdata to check usability
        local ext = extdata.decode(found_item)
        if not ext then
            MessageWarp.show_item_read_failed(tag)
            send_command('gs enable ring1')
            return
        end

        -----------------------------------------------------------
        -- CHECK 1: Is item on full cooldown? (charges = 0)
        -----------------------------------------------------------
        local has_charges = ext.charges_remaining and ext.charges_remaining > 0

        if not has_charges then
            -- Item is on full recast, no point waiting
            local cooldown_delay = 0
            if ext.next_use_time then
                cooldown_delay = math.max((ext.next_use_time + EXTDATA_TIME_OFFSET) - os.time(), 0)
            end

            MessageWarp.show_item_on_cooldown(tag, cooldown_delay)
            send_command('gs enable ring1')
            return
        end

        -----------------------------------------------------------
        -- CHECK 2: Calculate recast (like MyHome.lua)
        -----------------------------------------------------------
        local recast_delay = 0
        if has_charges and ext.next_use_time then
            recast_delay = math.max((ext.next_use_time + EXTDATA_TIME_OFFSET) - os.time(), 0)
        end

        -- Also check activation time for equip delay
        local activation_delay = 0
        if ext.activation_time then
            activation_delay = math.max((ext.activation_time + EXTDATA_TIME_OFFSET) - os.time(), 0)
        end

        -- Item is truly ready if: has charges AND recast = 0 AND activation = 0
        local is_ready = has_charges and recast_delay == 0 and activation_delay == 0

        debug_log(string.format('Wait check - charges:%s recast:%ds activation:%ds ready:%s',
            tostring(ext.charges_remaining), recast_delay, activation_delay, tostring(is_ready)))

        -----------------------------------------------------------
        -- CHECK 3: Is item ready to use?
        -----------------------------------------------------------
        if is_ready then
            -- SAFETY DELAY: Wait extra time after item appears ready (lag/desync protection)
            if not ready_timestamp then
                -- First time seeing item as ready, record timestamp
                ready_timestamp = os.time()
                debug_log(string.format('Item ready detected, starting safety delay (%.1fs)...', SAFETY_DELAY))
                coroutine.schedule(check_usable, SAFETY_DELAY)
                return
            end

            -- Check if safety delay has elapsed
            local elapsed = os.time() - ready_timestamp
            if elapsed < SAFETY_DELAY then
                -- Still waiting for safety delay - check timeout
                if wait_count >= max_wait then
                    MessageWarp.show_safety_timeout(tag, max_wait, check_interval)
                    send_command('gs enable ring1')
                    return
                end

                debug_log(string.format('Safety delay: %.1fs / %.1fs', elapsed, SAFETY_DELAY))
                coroutine.schedule(check_usable, 0.5)
                return
            end

            -- Safety delay complete, now use the item
            debug_log('Safety delay complete, using item now...')

            -- Show using message
            if is_warp_ring then
                MessageWarp.show_warp_using(ring_name)
            else
                MessageWarp.show_tele_using(ring_name)
            end

            local item_name = res.items[ring_id] and res.items[ring_id].en or ring_name

            -- Get cast time from database for proper timing
            local WarpDatabase = require('shared/utils/warp/warp_item_database')
            local item_data, _ = WarpDatabase.get_item_by_id(ring_id)
            local cast_time = (item_data and item_data.cast_time) or 8
            local cast_delay = (item_data and item_data.cast_delay) or 0
            local cast_duration = cast_time + cast_delay + 5  -- +5s safety buffer (lag protection)

            -- Setup auto-fix system BEFORE sending command
            ItemUser._setup_auto_fix(ring_id, tag, cast_duration, initial_ring1, item_name)

            -- Send item usage command
            send_command('input /item "' .. item_name .. '" <me>')
            return

        -----------------------------------------------------------
        -- CHECK 4: Item not ready yet - retry or timeout
        -----------------------------------------------------------
        elseif wait_count < max_wait then
            -- Show countdown only once at the beginning (use activation_delay for display)
            if wait_count == 1 and activation_delay > 1 then
                local COLORS = MessageCore.COLORS
                local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
                local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
                MessageWarp.show_waiting_safety(tag_color, tag, action_color, math.floor(activation_delay))
            end

            -- Schedule next check
            coroutine.schedule(check_usable, check_interval)

        -----------------------------------------------------------
        -- TIMEOUT: Item never became ready
        -----------------------------------------------------------
        else
            -- Detailed timeout message with item state
            local charges = ext.charges_remaining or 0
            local timeout_msg = string.format('[%s] Timeout after %ds - charges:%d recast:%ds activation:%ds',
                tag, max_wait * check_interval, charges, recast_delay, activation_delay)
            MessageWarp.show_casting_timeout(timeout_msg)

            -- Suggest solution based on state
            if charges == 0 then
                MessageWarp.show_item_needs_recharge(tag, recast_delay)
            elseif recast_delay > 0 then
                MessageWarp.show_item_recast_pending(tag, recast_delay)
            elseif activation_delay > 0 then
                MessageWarp.show_item_equip_delay(tag, activation_delay)
            end

            send_command('gs enable ring1')
        end
    end

    -- Start checking
    check_usable()
end

---============================================================================
--- INTERNAL: Auto-Fix System (SIMPLIFIED - Single Path)
---============================================================================

--- Helper: Detect action name from item name for dynamic messages
--- @param item_name string Item name (e.g., 'Warp Ring', 'Teleport Ring: Holla')
--- @param tag string Fallback tag ('WARP' or 'TELE')
--- @return string Action name ('Warp', 'Teleport', 'Recall', 'Escape')
local function get_action_name(item_name, tag)
    if not item_name then
        return tag == 'WARP' and 'Warp' or 'Teleport'
    end

    local lower_name = item_name:lower()
    if lower_name:find('warp') then return 'Warp' end
    if lower_name:find('teleport') or lower_name:find('tele ') then return 'Teleport' end
    if lower_name:find('recall') then return 'Recall' end
    if lower_name:find('escape') then return 'Escape' end

    -- Fallback based on tag
    return tag == 'WARP' and 'Warp' or 'Teleport'
end

--- Setup automatic ring slot fixing on interrupt
--- @param ring_id number Ring item ID
--- @param tag string Message tag
--- @param cast_duration number Total cast time in seconds (cast_time + cast_delay + buffer)
--- @param initial_ring1 string|nil Initial ring1 equipment (to verify restoration)
--- @param item_name string|nil Item name for dynamic messages
function ItemUser._setup_auto_fix(ring_id, tag, cast_duration, initial_ring1, item_name)
    local cleanup_done = false
    local initial_status = player and player.status or 'Idle'
    local action_listener = nil
    local zone_listener = nil

    -- Detect action name for dynamic messages (Warp, Teleport, Recall, Escape)
    local action_name = get_action_name(item_name, tag)

    local COLORS = MessageCore.COLORS
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local slot_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)

    -- Helper: Verify ring1 equipment was restored (checks warp ring is removed)
    local function verify_ring_restored()
        if not player or not player.equipment then
            return true
        end

        debug_log('Verifying ring1 restoration...')

        -- Get warp item name for comparison
        local warp_item_name = res.items[ring_id] and res.items[ring_id].en or 'unknown'

        coroutine.schedule(function()
            -- Wait for GearSwap to restore equipment
            local max_checks = 4  -- Increased from 3 to allow more retry attempts
            local check_count = 0

            local function check_equipment()
                check_count = check_count + 1

                local current_ring1 = player and player.equipment and player.equipment.ring1 or 'empty'

                -- SUCCESS: Ring1 is no longer the warp ring (and not empty)
                if current_ring1 ~= 'empty' and current_ring1 ~= warp_item_name then
                    MessageWarp.show_ring_restored(tag_color, tag, action_color, slot_color, tostring(current_ring1))
                    return
                end

                -- RETRY: Ring still not restored
                if check_count < max_checks then
                    debug_log(string.format('Ring1 still "%s", forcing restore (attempt %d/%d)', current_ring1, check_count, max_checks))
                    restore_equipment()
                    coroutine.schedule(check_equipment, 1.5)  -- Increased retry interval
                else
                    -- After max attempts, just notify but don't warn (set is correct)
                    if _G.WARP_DEBUG then
                        MessageWarp.show_ring_final_state(tostring(current_ring1), warp_item_name)
                    end
                    -- No warning - restore_equipment() was called, trust Mote logic
                end
            end

            check_equipment()
        end, 1.5)  -- Increased initial delay
    end

    -- SINGLE cleanup function to avoid conflicts
    local function cleanup_and_restore(reason)
        if cleanup_done then
            debug_log('cleanup_and_restore() called but already done, ignoring (reason: ' .. tostring(reason) .. ')')
            return
        end
        cleanup_done = true

        debug_log('Cleanup triggered - Reason: ' .. tostring(reason))

        -- Unregister all listeners
        if action_listener then
            windower.unregister_event(action_listener)
            debug_log('Action listener unregistered')
        end
        if zone_listener then
            windower.unregister_event(zone_listener)
            debug_log('Zone listener unregistered')
        end

        -- Re-enable ring slot
        send_command('gs enable ring1')
        debug_log('Ring1 slot re-enabled')

        -- Restore equipment based on reason
        if reason == 'success' then
            -- Action succeeded, no message needed (already zoning)
            debug_log(action_name .. ' succeeded, player zoning (no restoration needed)')
            return
        elseif reason == 'interrupted' then
            -- Cast interrupted - restore equipment immediately
            debug_log(action_name .. ' interrupted - initiating equipment restoration')
            MessageWarp.show_equipment_unlocked_ring1(tag_color, tag, action_color, slot_color)
            MessageWarp.show_action_interrupted(tag_color, tag, action_color, action_name)
            coroutine.schedule(function()
                if player then
                    restore_equipment()
                    verify_ring_restored()
                end
            end, 1.0)  -- Increased delay to allow GearSwap slot unlock
        elseif reason == 'timeout' then
            -- Timeout - action didn't complete
            debug_log('Timeout reached - ' .. action_name .. ' did not complete')
            MessageWarp.show_equipment_unlocked_ring1(tag_color, tag, action_color, slot_color)
            if player then
                MessageWarp.show_action_incomplete(tag_color, tag, action_color, action_name)
                coroutine.schedule(function()
                    restore_equipment()
                    verify_ring_restored()
                end, 1.0)  -- Increased delay to allow GearSwap slot unlock
            end
        else
            MessageWarp.show_unknown_cleanup_reason(reason)
        end
    end

    -- Register action listener for interruption detection
    action_listener = windower.register_event('action', function(act)
        if cleanup_done or not player or act.actor_id ~= player.id then return end

        -- Category 1 = Melee attack (movement/engaged = interrupted)
        if act.category == 1 then
            debug_log('Action event category 1 detected (melee/movement) - triggering interruption')
            cleanup_and_restore('interrupted')
        end
    end)

    debug_log('Action listener registered (watching for category 1)')

    -- Register zone change listener
    zone_listener = windower.register_event('zone change', function()
        debug_log('Zone change event detected - warp successful')
        cleanup_and_restore('success')
    end)

    debug_log('Zone change listener registered')

    -- Monitor cast status in real-time
    local check_interval = 0.5
    local elapsed = 0

    debug_log(string.format('Starting cast monitoring (duration: %.1fs, interval: %.1fs)', cast_duration, check_interval))

    local function check_cast_status()
        if cleanup_done then return end

        elapsed = elapsed + check_interval
        -- REMOVED: Monitoring tick spam (too verbose)

        -- Check if interrupted by status change (movement during cast)
        if player and player.status ~= initial_status and elapsed < cast_duration then
            debug_log(string.format('Status change detected: %s >> %s (interruption!)',
                tostring(initial_status), tostring(player.status)))
            cleanup_and_restore('interrupted')
            return
        end

        -- Check if player is gone (zoned)
        if not player then
            debug_log('Player data nil - zone change detected')
            cleanup_and_restore('success')
            return
        end

        -- Check if timeout (cast should be done)
        if elapsed >= cast_duration then
            debug_log(string.format('Cast duration reached (%.1fs), triggering timeout', elapsed))
            cleanup_and_restore('timeout')
            return
        end

        -- Continue monitoring
        coroutine.schedule(check_cast_status, check_interval)
    end

    -- Start monitoring after small delay
    coroutine.schedule(check_cast_status, 1)
end

return ItemUser
