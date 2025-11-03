---============================================================================
--- BLM Storm Management Module - Automated Storm Casting with Klimaform
---============================================================================
--- Professional storm management providing automated Klimaform + Storm casting,
--- cooldown monitoring, and intelligent buff maintenance for Black Mage.
---
--- Features:
---   • Automated Klimaform + Storm Casting (smart sequence)
---   • Buff Status Checking (skip Klimaform if already active)
---   • Cooldown Monitoring (grouped display for both spells)
---   • Lag Compensation (anti-spam protection)
---
--- Dependencies:
---   • MessageCooldowns (for recast display)
---   • BLMMessages (for status messages)
---
--- @file jobs/blm/functions/logic/storm_manager.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

local StormManager = {}

-- Load dependencies
local MessageCooldowns = require('shared/utils/messages/message_cooldowns')
local BLMMessages = require('shared/utils/messages/message_blm')

---============================================================================
--- CONFIGURATION
---============================================================================

--- Anti-spam protection: Track last cast time
--- @type number
local last_cast_time = 0

--- Minimum delay between casts (in seconds)
local CAST_COOLDOWN = 2.0

--- Delay between Klimaform and Storm (in seconds)
local KLIMAFORM_STORM_DELAY = 4.5

---============================================================================
--- ANTI-SPAM PROTECTION
---============================================================================

--- Check if spell is safe to cast (anti-spam protection)
--- @param currentTime number Current timestamp
--- @return boolean true if safe to cast
local function isSafeToCast(currentTime)
    return (currentTime - last_cast_time) >= CAST_COOLDOWN
end

--- Update last cast time
--- @param currentTime number Current timestamp
local function updateLastCastTime(currentTime)
    last_cast_time = currentTime
end

---============================================================================
--- SPELL RECAST CHECKING
---============================================================================

--- Get spell recast time in seconds
--- @param spell_name string Name of the spell
--- @return number|nil Recast time in seconds, or nil if spell not found
local function get_spell_recast(spell_name)
    -- Use global res if available, otherwise require
    local res = _G.res or windower.res
    if not res then
        local success, resources = pcall(require, 'resources')
        if not success or not resources then
            return nil
        end
        res = resources
    end

    local spell_data = res.spells:with('en', spell_name)
    if not spell_data then
        return nil
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then
        return nil
    end

    local recast_raw = spell_recasts[spell_data.recast_id]
    if not recast_raw or recast_raw == 0 then
        return 0
    end

    -- Convert centiseconds to seconds
    return recast_raw / 100
end

---============================================================================
--- STORM CASTING LOGIC
---============================================================================

--- Cast Storm with automatic Klimaform if needed
--- @param storm_name string Name of the storm spell (e.g., "Firestorm", "Hailstorm")
--- @return boolean true if casting was initiated, false if on cooldown
function StormManager.cast_storm_with_klimaform(storm_name)
    local currentTime = os.clock()

    -- Anti-spam check
    if not isSafeToCast(currentTime) then
        return false
    end

    -- Check if Klimaform is already active
    local klimaform_active = buffactive and buffactive['Klimaform'] or false

    -- Get recast times
    local klimaform_recast = get_spell_recast('Klimaform')
    local storm_recast = get_spell_recast(storm_name)

    if not klimaform_recast or not storm_recast then
        BLMMessages.show_spell_recasts_error()
        return false
    end

    -- CASE 1: Both spells ready
    if klimaform_recast == 0 and storm_recast == 0 then
        if klimaform_active then
            -- Klimaform already active, just cast Storm
            send_command('input /ma "' .. storm_name .. '" <me>')
            updateLastCastTime(currentTime)
            return true
        else
            -- Cast Klimaform, then Storm after delay
            send_command('input /ma "Klimaform" <me>')
            send_command('wait ' .. KLIMAFORM_STORM_DELAY .. '; input /ma "' .. storm_name .. '" <me>')
            updateLastCastTime(currentTime)
            return true
        end
    end

    -- CASE 2: Storm ready, Klimaform on cooldown
    if storm_recast == 0 and klimaform_recast > 0 then
        if klimaform_active then
            -- Klimaform already active, cast Storm
            send_command('input /ma "' .. storm_name .. '" <me>')
            updateLastCastTime(currentTime)
            return true
        else
            -- Need Klimaform but it's on cooldown - show both recasts
            local cooldowns = {
                {
                    type = "cooldown",
                    name = "Klimaform",
                    value = klimaform_recast,
                    action_type = "Magic"
                }
            }
            MessageCooldowns.show_multi_status(cooldowns)
            return false
        end
    end

    -- CASE 3: Klimaform ready, Storm on cooldown
    if klimaform_recast == 0 and storm_recast > 0 then
        -- Storm on cooldown - show recast
        local cooldowns = {
            {
                type = "cooldown",
                name = storm_name,
                value = storm_recast,
                action_type = "Magic"
            }
        }
        MessageCooldowns.show_multi_status(cooldowns)
        return false
    end

    -- CASE 4: Both spells on cooldown
    if klimaform_recast > 0 and storm_recast > 0 then
        -- Both on cooldown - show both recasts in single block
        local cooldowns = {
            {
                type = "cooldown",
                name = "Klimaform",
                value = klimaform_recast,
                action_type = "Magic"
            },
            {
                type = "cooldown",
                name = storm_name,
                value = storm_recast,
                action_type = "Magic"
            }
        }
        MessageCooldowns.show_multi_status(cooldowns)
        return false
    end

    return false
end

--- Cast Storm only (without Klimaform check)
--- Used for manual Storm casting
--- @param storm_name string Name of the storm spell
--- @return boolean true if casting was initiated, false if on cooldown
function StormManager.cast_storm_only(storm_name)
    local currentTime = os.clock()

    -- Anti-spam check
    if not isSafeToCast(currentTime) then
        return false
    end

    -- Get recast time
    local storm_recast = get_spell_recast(storm_name)

    if not storm_recast then
        BLMMessages.show_spell_recasts_error()
        return false
    end

    if storm_recast == 0 then
        -- Cast Storm
        send_command('input /ma "' .. storm_name .. '" <me>')
        updateLastCastTime(currentTime)
        return true
    else
        -- Storm on cooldown - show recast
        MessageCooldowns.show_spell_cooldown(storm_name, storm_recast * 100)  -- Convert to centiseconds
        return false
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return StormManager
