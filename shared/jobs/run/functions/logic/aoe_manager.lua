---============================================================================
--- AOE Manager - Blue Magic AOE Spell Rotation (RUN/BLU)
---============================================================================
--- Manages AOE Blue Magic spell casting for RUN/BLU subjob combination.
--- Provides intelligent automation for:
---   • Spell rotation management (Geist Wall, Stinking Gas, Sound Blast, etc.)
---   • Cooldown tracking and validation
---   • Anti-spam protection (prevents duplicate casts)
---   • Auto-targeting (<stnpc> fallback)
---
--- Features:
---   • First-available spell selection
---   • Professional cooldown display
---   • Unknown spell detection (wrong subjob)
---   • Recent cast tracking (5s threshold)
---
--- @file    jobs/run/functions/logic/aoe_manager.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-06
---============================================================================
local AOEManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrappers for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast == 0)
    end
end

local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)
    end
end

local BluMagicConfig = _G.BluMagicConfig or {}  -- Loaded from character main file

-- Spell tracking to prevent spam when FFXI doesn't send cast confirmation
local SpellTracker = {}
local RECENT_CAST_THRESHOLD = 5 -- seconds before allowing re-cast

---============================================================================
--- SPELL TRACKING (Anti-Spam Protection)
---============================================================================

--- Cleanup old spell tracking entries
local function cleanup_spell_tracking()
    local now = os.time()
    for spell_name, timestamp in pairs(SpellTracker) do
        if (now - timestamp) > 60 then -- Remove entries older than 60s
            SpellTracker[spell_name] = nil
        end
    end
end

--- Check if spell was recently cast (prevents spam)
--- @param spell_name string Spell name
--- @return boolean recently_cast, number wait_time
local function was_recently_cast(spell_name)
    local now = os.time()
    if SpellTracker[spell_name] then
        local time_since_cast = now - SpellTracker[spell_name]
        if time_since_cast < RECENT_CAST_THRESHOLD then
            return true, RECENT_CAST_THRESHOLD - time_since_cast
        end
    end
    return false, 0
end

--- Mark spell as cast
--- @param spell_name string Spell name
local function mark_spell_cast(spell_name)
    SpellTracker[spell_name] = os.time()
end

---============================================================================
--- SPELL CASTING LOGIC
---============================================================================

--- Check if a spell can be cast (not on cooldown)
--- @param spell_name string Spell name
--- @return boolean can_cast, string reason, number time_value
local function can_cast_spell(spell_name)
    local res = require('resources')
    local spell_data = res.spells:with('en', spell_name)
    if not spell_data then
        return false, "unknown_spell"
    end

    -- Check if recently cast (anti-spam protection)
    local recently_cast, wait_time = was_recently_cast(spell_name)
    if recently_cast then
        return false, "recently_cast", wait_time
    end

    local recasts = windower.ffxi.get_spell_recasts()
    local recast_id = spell_data.recast_id or spell_data.id
    local recast_centiseconds = recasts[recast_id] or 0
    local recast_seconds = recast_centiseconds / 100

    if is_on_cooldown(recast_seconds) then
        return false, "on_cooldown", recast_seconds
    end

    return true, nil, 0
end

---============================================================================
--- AOE COMMAND HANDLER
---============================================================================

--- Handle AOE command - cast first available BLU AOE spell
function AOEManager.execute_aoe()
    cleanup_spell_tracking()
    local spells_on_cooldown = {}
    local AOE_SPELLS = BluMagicConfig.get_rotation()

    -- Try to cast first available spell
    local unknown_spells = 0
    for _, spell_name in ipairs(AOE_SPELLS) do
        local can_cast, reason, time_value = can_cast_spell(spell_name)
        if can_cast then
            -- Show casting message using centralized formatter (displays [MAIN/SUB])
            MessageFormatter.show_spell_cast(spell_name)
            mark_spell_cast(spell_name) -- Track cast to prevent spam
            send_command('@input /ma "' .. spell_name .. '" <stnpc>')
            return
        elseif reason == "on_cooldown" and time_value then
            table.insert(spells_on_cooldown, {
                name = spell_name,
                recast = time_value
            })
        elseif reason == "recently_cast" then
            -- Skip recently cast spells silently
        elseif reason == "unknown_spell" then
            unknown_spells = unknown_spells + 1
        end
    end

    -- Check if all spells are unknown (not equipped or wrong subjob)
    if unknown_spells == #AOE_SPELLS then
        MessageFormatter.show_error('No Blue Magic AOE spells equipped! (Need RUN/BLU subjob)')
        MessageFormatter.show_info('Available spells: Geist Wall, Stinking Gas, Sound Blast, Sheep Song, Soporific')
        return
    end

    -- All spells on cooldown - display recast info + fallback stnpc
    if #spells_on_cooldown > 0 then
        -- Top separator
        MessageFormatter.show_separator()

        -- Each spell with professional formatting (no separators per line)
        local job_tag = MessageFormatter.get_job_tag()
        for _, spell in ipairs(spells_on_cooldown) do
            MessageCooldowns.show_cooldown_message(job_tag, "Magic", spell.name, spell.recast, nil, true)
        end

        -- Bottom separator
        MessageFormatter.show_separator()

        -- Fallback: target stnpc without opening menu (prevents macro spam issues)
        send_command('@input /target <stnpc>')
    else
        MessageFormatter.show_warning('No AOE spell available')
        -- Fallback: target stnpc even if no spells available
        send_command('@input /target <stnpc>')
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return AOEManager
