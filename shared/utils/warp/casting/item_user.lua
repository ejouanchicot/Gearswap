---============================================================================
--- Item User - Warp/teleport ring sequence
---============================================================================
--- Equips a warp or teleport ring in ring1, waits until its extdata says it
--- can be used, fires /item, watches the cast until the character zones, and
--- releases ring1 on every exit (success, interruption, timeout, failure).
---
--- @file shared/utils/warp/casting/item_user.lua
--- @author Tetsouo
--- @version 4.0
--- @date Created: 2025-10-28
---============================================================================

local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')
local MessageCore = require('shared/utils/messages/message_core')
local CastHelpers = require('shared/utils/warp/casting/cast_helpers')

local res = require('resources')
local res_bags = res.bags

local ItemUser = {}

-- Debug toggle (controlled by //gs c debugwarp)
_G.WARP_DEBUG = _G.WARP_DEBUG or false

--- Helper: Debug logging (only if WARP_DEBUG enabled)
local function debug_log(message)
    if _G.WARP_DEBUG then
        MessageWarp.show_item_casting_debug(message)
    end
end

--- Helper: Put the job's current set back on (universal for all jobs).
--- Every caller runs from a coroutine.schedule callback, outside any GearSwap
--- event, where equip() is dropped: GearSwap only sends the equip list at the
--- end of an event. `gs c update` goes through a real event (Mote's
--- handle_update -> handle_equipping_gear), so the gear is actually sent.
--- Callers release ring1 (`gs enable ring1`) a second before calling this.
local function restore_equipment()
    if not player then
        debug_log('Cannot restore equipment - player data unavailable')
        return
    end

    debug_log('Restoring equipment via gs c update')
    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok_t and Trace then
        Trace.log('WARP', 'restore: gs c update (ring1 now %s)', player.equipment and player.equipment.ring1)
    end
    windower.send_command('gs c update')
end

--- Use the first owned and ready ring of a list; report cooldowns otherwise.
--- @param ring_names string|table Ring name or ordered list of ring names
--- @param context any Forwarded to _show_all_cooldowns, which ignores it
--- @return boolean True once a ring sequence has started
function ItemUser.use_ring(ring_names, context)
    if not player then
        MessageCore.error('[WARP] Player data not available')
        return false
    end

    local ring_list = type(ring_names) == 'table' and ring_names or {ring_names}

    -- Track cooldowns of unavailable rings
    local cooldown_info = {}

    for _, ring_name in ipairs(ring_list) do
        local ring_id = CastHelpers.get_ring_id(ring_name)

        if ring_id and CastHelpers.has_item(ring_name, ring_id) then
            local usable, delay, status = ItemUser._check_ring_usable(ring_id)

            if usable then
                local is_warp_ring = (ring_name == 'Warp Ring')
                local tag = is_warp_ring and 'WARP' or 'TELE'

                debug_log('Item is ready! Status: ' .. tostring(status))

                if is_warp_ring then
                    MessageWarp.show_warp_equipping(ring_name)
                else
                    MessageWarp.show_tele_equipping(ring_name)
                end

                ItemUser._execute_ring_sequence(ring_name, ring_id, is_warp_ring, tag)
                return true
            else
                local reason = status or 'unknown'
                debug_log('Ring ' .. ring_name .. ' not ready - status: ' .. reason .. ' (' .. tostring(delay) .. 's)')
                table.insert(cooldown_info, {name = ring_name, delay = delay, status = reason})
            end
        end
    end

    if #cooldown_info > 0 then
        ItemUser._show_all_cooldowns(cooldown_info, context)
    else
        MessageCore.error('[WARP] No available rings found')
    end

    return false
end

-- Added to extdata timestamps before comparing them with os.time().
-- Same constant as the MyHome addon (MyHome.lua uses +18000).
local EXTDATA_TIME_OFFSET = 18000

-- Safety delay after item appears ready (lag/desync protection)
local SAFETY_DELAY = 3.5  -- Hold after the first "ready" reading before using the item

-- Bounds for the activation wait, in seconds.
--
-- A ring equipped from cold reports an activation delay of around twenty
-- seconds. The wait used to be a flat budget of fifteen one-second polls, so
-- it gave up while the item was still counting down - "Timeout after 15s -
-- charges:1 recast:0 activation:6s" was the ring working exactly as intended
-- and the loop running out of patience. The deadline now follows what the item
-- reports, between a floor (an item that reads ready straight away still gets
-- a chance) and a ceiling (ring1 is never held hostage by a stuck item).
local WAIT_FLOOR   = 15
local WAIT_CEILING = 60
local WAIT_GRACE   = 5    -- slack on top of the delay the item reports

-- Absolute stop for every path, including the ones that retry on their own
-- (safety delay, missing mob record). Without it a path that never resolves
-- leaves the ring1 slot disabled until a reload.
local WAIT_HARD_CEILING = 90

local POLL_INTERVAL  = 1.0
local MAX_POLL_SLEEP = 5.0

--- Check if a warp item is usable right now (charges and recast only; the
--- activation delay is read later by the wait loop).
--- Handles both 'General' items (scrolls) and 'Enchanted Equipment' (rings/wings)
--- @param item_id number Item id
--- @return boolean usable
--- @return number delay Seconds until usable (0 when unknown)
--- @return string status 'ready', 'cooldown', 'not_found', 'decode_failed', 'unknown_type' or 'extdata_missing'
function ItemUser._check_ring_usable(item_id)
    local has_extdata, extdata = pcall(require, 'extdata')
    if not has_extdata then
        debug_log('ERROR: extdata library not available')
        return false, 0, 'extdata_missing'
    end

    local get_items = windower.ffxi.get_items
    local current_time = os.time()

    for bag_id in pairs(res_bags:equippable(true)) do
        local bag = get_items(bag_id)

        if bag.enabled then
            for _, item in ipairs(bag) do
                if item.id == item_id then
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
                        -- Same recast formula as MyHome.lua:
                        -- recast = charges_remaining > 0 AND next_use_time delay
                        local has_charges = ext.charges_remaining and ext.charges_remaining > 0
                        local recast_delay = 0

                        if has_charges and ext.next_use_time then
                            recast_delay = math.max((ext.next_use_time + EXTDATA_TIME_OFFSET) - current_time, 0)
                        end

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
--- @param cooldown_info table List of {name, delay, status}
--- @param context any Unused
function ItemUser._show_all_cooldowns(cooldown_info, context)
    local soonest = nil
    local soonest_delay = 999999

    for _, info in ipairs(cooldown_info) do
        if info.delay > 0 and info.delay < soonest_delay then
            soonest = info.name
            soonest_delay = info.delay
        end
    end

    MessageWarp.show_all_items_cooldown()

    for _, info in ipairs(cooldown_info) do
        local delay = info.delay
        local time_msg

        if delay > 0 then
            if delay >= 60 then
                local minutes = math.floor(delay / 60)
                local seconds = delay % 60
                time_msg = seconds > 0 and
                    string.format('%dm %ds', minutes, seconds) or
                    string.format('%dm', minutes)
            else
                time_msg = string.format('%ds', delay)
            end
            MessageWarp.show_item_cooldown_time(info.name, time_msg)
        else
            -- delay 0 is not a cooldown: decode failure, unknown type, missing
            -- extdata, or no charges with next_use_time already past.
            MessageWarp.show_item_not_ready(info.name)
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

--- Lock ring1, equip the ring (+0.5 s) and start the wait (+2.5 s).
--- @param ring_name string Ring name
--- @param ring_id number Ring item id
--- @param is_warp_ring boolean True for the Warp Ring (message wording)
--- @param tag string 'WARP' or 'TELE'
function ItemUser._execute_ring_sequence(ring_name, ring_id, is_warp_ring, tag)
    local initial_ring1 = nil
    if player and player.equipment and player.equipment.ring1 then
        initial_ring1 = player.equipment.ring1
        debug_log('Initial ring1 saved: ' .. tostring(initial_ring1))
    else
        debug_log('No initial ring1 detected (empty slot)')
    end

    send_command('gs disable ring1')
    debug_log('Ring1 slot disabled')

    coroutine.schedule(function()
        send_command('input /equip ring1 "' .. ring_name .. '"')
    end, 0.5)

    coroutine.schedule(function()
        ItemUser._wait_for_ring_usable(ring_name, ring_id, is_warp_ring, tag, initial_ring1)
    end, 2.5)
end

--- Give the ring slot back and stop waiting.
---
--- Every failure path here has to release ring1, or the slot stays locked and
--- the player cannot equip anything in it until a reload. It was written out
--- five times; forgetting it once is a stuck slot with no error.
local function abandon_wait()
    send_command('gs enable ring1')

    -- The warp ring is still on the finger here. Releasing the slot without
    -- putting the normal set back leaves the player wearing it until the next
    -- unrelated gear swap. Same 1s delay as cleanup_and_restore, to let
    -- GearSwap process the unlock first.
    coroutine.schedule(function()
        if player then
            restore_equipment()
        end
    end, 1.0)
end

--- Find a ring by id in any equippable, enabled bag.
--- @param ring_id number Item id
--- @return table|nil The item as the bag reports it
local function find_equippable_item(ring_id)
    local get_items = windower.ffxi.get_items
    for bag_id in pairs(res_bags:equippable(true)) do
        local bag = get_items(bag_id)
        if bag.enabled then
            for _, item in ipairs(bag) do
                if item.id == ring_id then
                    return item
                end
            end
        end
    end
    return nil
end

--- How long until the ring can actually be used.
---
--- Three separate things gate it: charges left, the recast on the item, and an
--- activation delay that runs from the moment it was equipped. All three have
--- to be clear, and the timestamps are in the game's epoch so they need the
--- offset before they mean anything.
--- @param ext table Decoded extdata for the item
--- @return boolean has_charges, number recast seconds, number activation seconds, boolean ready
local function usability(ext)
    local has_charges = ext.charges_remaining and ext.charges_remaining > 0

    local recast_delay = 0
    if has_charges and ext.next_use_time then
        recast_delay = math.max((ext.next_use_time + EXTDATA_TIME_OFFSET) - os.time(), 0)
    end

    local activation_delay = 0
    if ext.activation_time then
        activation_delay = math.max((ext.activation_time + EXTDATA_TIME_OFFSET) - os.time(), 0)
    end

    return has_charges, recast_delay, activation_delay,
           (has_charges and recast_delay == 0 and activation_delay == 0) or false
end

--- Say why the wait ran out, and what the player can do about it.
local function report_timeout(tag, ext, waited, recast_delay, activation_delay)
    local charges = ext.charges_remaining or 0
    MessageWarp.show_casting_timeout(string.format(
        '[%s] Timeout after %ds - charges:%d recast:%ds activation:%ds',
        tag, waited, charges, recast_delay, activation_delay))

    if charges == 0 then
        MessageWarp.show_item_needs_recharge(tag, recast_delay)
    elseif recast_delay > 0 then
        MessageWarp.show_item_recast_pending(tag, recast_delay)
    elseif activation_delay > 0 then
        MessageWarp.show_item_equip_delay(tag, activation_delay)
    end
end

--- Fire the item, once everything has cleared.
local function use_now(ring_name, ring_id, is_warp_ring, tag, initial_ring1)
    if is_warp_ring then
        MessageWarp.show_warp_using(ring_name)
    else
        MessageWarp.show_tele_using(ring_name)
    end

    local item_name = res.items[ring_id] and res.items[ring_id].en or ring_name

    local WarpDatabase = require('shared/utils/warp/warp_item_database')
    local item_data, _ = WarpDatabase.get_item_by_id(ring_id)
    local cast_time = (item_data and item_data.cast_time) or 8
    local cast_delay = (item_data and item_data.cast_delay) or 0
    local cast_duration = cast_time + cast_delay + 5  -- +5s buffer against lag

    ItemUser._setup_auto_fix(ring_id, tag, cast_duration, initial_ring1, item_name)
    send_command('input /item "' .. item_name .. '" <me>')
end

--- Poll the ring until it can be used, then use it; release ring1 on any failure.
--- @param ring_name string Ring name
--- @param ring_id number Ring item id
--- @param is_warp_ring boolean True for the Warp Ring (message wording)
--- @param tag string 'WARP' or 'TELE'
--- @param initial_ring1 string|nil ring1 before the sequence (forwarded, unused)
function ItemUser._wait_for_ring_usable(ring_name, ring_id, is_warp_ring, tag, initial_ring1)
    local started = os.time()
    local deadline = started + WAIT_FLOOR
    local ready_timestamp = nil
    local announced = false

    local function check_usable()
        if os.time() - started > WAIT_HARD_CEILING then
            MessageWarp.show_casting_timeout(string.format(
                '[%s] Gave up after %ds', tag, os.time() - started))
            return abandon_wait()
        end

        local has_extdata, extdata = pcall(require, 'extdata')
        if not has_extdata then
            MessageWarp.show_extdata_error(tag)
            return abandon_wait()
        end

        local found_item = find_equippable_item(ring_id)
        if not found_item then
            MessageWarp.show_item_disappeared(tag)
            return abandon_wait()
        end

        local ext = extdata.decode(found_item)
        if not ext then
            MessageWarp.show_item_read_failed(tag)
            return abandon_wait()
        end

        local has_charges, recast_delay, activation_delay, is_ready = usability(ext)

        if not has_charges then
            -- No charges at all: waiting cannot help, say when it recharges.
            local cooldown_delay = 0
            if ext.next_use_time then
                cooldown_delay = math.max((ext.next_use_time + EXTDATA_TIME_OFFSET) - os.time(), 0)
            end
            MessageWarp.show_item_on_cooldown(tag, cooldown_delay)
            return abandon_wait()
        end

        debug_log(string.format('Wait check - charges:%s recast:%ds activation:%ds ready:%s',
            tostring(ext.charges_remaining), recast_delay, activation_delay, tostring(is_ready)))

        if is_ready then
            -- The item can read as ready a moment before the server agrees, so
            -- hold for SAFETY_DELAY after first seeing it rather than firing.
            if not ready_timestamp then
                ready_timestamp = os.time()
                debug_log(string.format('Item ready detected, starting safety delay (%.1fs)...', SAFETY_DELAY))
                coroutine.schedule(check_usable, SAFETY_DELAY)
                return
            end

            local elapsed = os.time() - ready_timestamp
            if elapsed < SAFETY_DELAY then
                debug_log(string.format('Safety delay: %.1fs / %.1fs', elapsed, SAFETY_DELAY))
                coroutine.schedule(check_usable, 0.5)
                return
            end

            debug_log('Safety delay complete, using item now...')

            -- GearSwap throws inside band() when spawn_type is nil, which
            -- happens on a zone edge. Wait for the mob record rather than fire.
            local me = windower.ffxi.get_mob_by_target('me')
            if not me or not me.spawn_type then
                debug_log('Player mob data unavailable, retrying in 1s...')
                coroutine.schedule(check_usable, 1.0)
                return
            end

            use_now(ring_name, ring_id, is_warp_ring, tag, initial_ring1)
            return
        end

        -- Not ready yet. Stretch the deadline to cover what the item now says
        -- it needs; it only ever grows, and never past the ceiling.
        local wanted = os.time() + math.max(recast_delay, activation_delay) + SAFETY_DELAY + WAIT_GRACE
        if wanted > deadline then
            deadline = math.min(wanted, started + WAIT_CEILING)
        end

        if os.time() >= deadline then
            report_timeout(tag, ext, os.time() - started, recast_delay, activation_delay)
            return abandon_wait()
        end

        -- Announce the wait once, not every second.
        if not announced and activation_delay > 1 then
            announced = true
            local COLORS = MessageCore.COLORS
            local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
            local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
            MessageWarp.show_waiting_safety(tag_color, tag, action_color, math.floor(activation_delay))
        end

        -- Sleep for what is actually left instead of polling once a second.
        local remaining = math.max(recast_delay, activation_delay)
        coroutine.schedule(check_usable, math.min(math.max(remaining, POLL_INTERVAL), MAX_POLL_SLEEP))
    end

    check_usable()
end

local function get_action_name(item_name, tag)
    if not item_name then
        return tag == 'WARP' and 'Warp' or 'Teleport'
    end

    local lower_name = item_name:lower()
    if lower_name:find('warp') then return 'Warp' end
    if lower_name:find('teleport') or lower_name:find('tele ') then return 'Teleport' end
    if lower_name:find('recall') then return 'Recall' end
    if lower_name:find('escape') then return 'Escape' end

    return tag == 'WARP' and 'Warp' or 'Teleport'
end

--- Drop the auto-fix listeners left over from a previous sequence.
---
--- Only one ring sequence runs at a time, so a new sequence clears the pair
--- the previous one may have left. The ids are parked on `windower.*` with the
--- load that registered them (windower._gs_reload_count), the same convention
--- as the IPC listener. Across a `gs reload` the engine has already
--- unregistered every sandbox event (GearSwap refresh.lua:69-71) and an old id
--- could now belong to another listener, so only ids from this load are
--- unregistered.
--- @return nil
local function drop_stale_autofix_listeners()
    local same_load = windower._warp_autofix_load == windower._gs_reload_count
    for _, key in ipairs({ '_warp_autofix_action_id', '_warp_autofix_zone_id' }) do
        if windower[key] and same_load then
            pcall(windower.unregister_event, windower[key])
        end
        windower[key] = nil
    end
end

--- Watch the item cast: zone -> success, own melee round or status change ->
--- interrupted, cast_duration elapsed -> timeout. Every outcome re-enables ring1.
--- @param ring_id number Item id
--- @param tag string 'WARP' or 'TELE'
--- @param cast_duration number Seconds to monitor
--- @param initial_ring1 string|nil Unused
--- @param item_name string Item name (message wording)
function ItemUser._setup_auto_fix(ring_id, tag, cast_duration, initial_ring1, item_name)
    local cleanup_done = false
    local initial_status = player and player.status or 'Idle'
    local action_listener = nil
    local zone_listener = nil
    local my_load = windower._gs_reload_count

    drop_stale_autofix_listeners()

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

        local warp_item_name = res.items[ring_id] and res.items[ring_id].en or 'unknown'

        coroutine.schedule(function()
            local max_checks = 4
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
                    coroutine.schedule(check_equipment, 1.5)
                else
                    -- After max attempts: debug line only, no warning to the player
                    if _G.WARP_DEBUG then
                        MessageWarp.show_ring_final_state(tostring(current_ring1), warp_item_name)
                    end
                end
            end

            check_equipment()
        end, 1.5)
    end

    -- SINGLE cleanup function to avoid conflicts
    local function cleanup_and_restore(reason)
        if cleanup_done then
            debug_log('cleanup_and_restore() called but already done, ignoring (reason: ' .. tostring(reason) .. ')')
            return
        end
        cleanup_done = true

        debug_log('Cleanup triggered - Reason: ' .. tostring(reason))

        -- Unregister all listeners. After a reload (the timeout path keeps
        -- running) the engine already removed them, and their ids and the
        -- windower slots may belong to the new load: leave those alone.
        if my_load == windower._gs_reload_count then
            if action_listener then
                windower.unregister_event(action_listener)
                windower._warp_autofix_action_id = nil
                debug_log('Action listener unregistered')
            end
            if zone_listener then
                windower.unregister_event(zone_listener)
                windower._warp_autofix_zone_id = nil
                debug_log('Zone listener unregistered')
            end
        end

        send_command('gs enable ring1')
        debug_log('Ring1 slot re-enabled')

        if reason == 'success' then
            debug_log(action_name .. ' succeeded, player zoning (no restoration needed)')
            return
        elseif reason == 'interrupted' then
            debug_log(action_name .. ' interrupted - initiating equipment restoration')
            MessageWarp.show_equipment_unlocked_ring1(tag_color, tag, action_color, slot_color)
            MessageWarp.show_action_interrupted(tag_color, tag, action_color, action_name)
            coroutine.schedule(function()
                if player then
                    restore_equipment()
                    verify_ring_restored()
                end
            end, 1.0)  -- let GearSwap process the slot unlock first
        elseif reason == 'timeout' then
            debug_log('Timeout reached - ' .. action_name .. ' did not complete')
            MessageWarp.show_equipment_unlocked_ring1(tag_color, tag, action_color, slot_color)
            if player then
                MessageWarp.show_action_incomplete(tag_color, tag, action_color, action_name)
                coroutine.schedule(function()
                    restore_equipment()
                    verify_ring_restored()
                end, 1.0)
            end
        else
            MessageWarp.show_unknown_cleanup_reason(reason)
        end
    end

    action_listener = windower.register_event('action', function(act)
        if cleanup_done or not player or act.actor_id ~= player.id then return end

        -- Category 1 = the player's own melee round
        if act.category == 1 then
            debug_log('Action event category 1 detected (melee/movement) - triggering interruption')
            cleanup_and_restore('interrupted')
        end
    end)

    windower._warp_autofix_action_id = action_listener
    debug_log('Action listener registered (watching for category 1)')

    zone_listener = windower.register_event('zone change', function()
        debug_log('Zone change event detected - warp successful')
        cleanup_and_restore('success')
    end)

    windower._warp_autofix_zone_id = zone_listener
    windower._warp_autofix_load = my_load
    debug_log('Zone change listener registered')

    local check_interval = 0.5
    local elapsed = 0

    debug_log(string.format('Starting cast monitoring (duration: %.1fs, interval: %.1fs)', cast_duration, check_interval))

    local function check_cast_status()
        if cleanup_done then return end

        elapsed = elapsed + check_interval

        -- A status change (e.g. engaging) during the cast counts as an interruption
        if player and player.status ~= initial_status and elapsed < cast_duration then
            debug_log(string.format('Status change detected: %s >> %s (interruption!)',
                tostring(initial_status), tostring(player.status)))
            cleanup_and_restore('interrupted')
            return
        end

        -- Defensive only: GearSwap's player table is never nil
        if not player then
            debug_log('Player data nil - zone change detected')
            cleanup_and_restore('success')
            return
        end

        if elapsed >= cast_duration then
            debug_log(string.format('Cast duration reached (%.1fs), triggering timeout', elapsed))
            cleanup_and_restore('timeout')
            return
        end

        coroutine.schedule(check_cast_status, check_interval)
    end

    coroutine.schedule(check_cast_status, 1)
end

return ItemUser