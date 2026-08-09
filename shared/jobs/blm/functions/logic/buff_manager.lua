---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Buff Management Module - Automated Self-Buffing System
---  ═══════════════════════════════════════════════════════════════════════════
---   Professional buff management providing automated self-buffing, buff monitoring,
---   and intelligent buff maintenance for Black Mage characters.
---
---   Features:
---   • Automated Self-Buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
---   • Lag Compensation (anti-spam protection with secure casting)
---   • Buff Duration Tracking (intelligent refresh timing)
---   • Performance Optimization (cached lookups and efficient processing)
---   • Status Reporting (unified buff status display)
---   • Recast Management (smart cooldown handling and queue processing)
---
---   Dependencies:
---   • CooldownChecker (for recast validation)
---   • MessageFormatter (for status display)
---
---   @file    jobs/blm/functions/logic/buff_manager.lua
---   @author  Tetsouo
---   @version 2.0 (Migrated from old BUFF_MANAGEMENT.lua)
---   @date    Migrated: 2025-10-15
---  ═══════════════════════════════════════════════════════════════════════════

local BuffManager = {}

-- Load dependencies (centralized systems - no SafeLoader needed)
local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageBuffs = require('shared/utils/messages/formatters/magic/message_buffs')
local CooldownChecker = require('shared/utils/precast/cooldown_checker')
local BLMMessages = require('shared/utils/messages/formatters/jobs/message_blm')

---  ═══════════════════════════════════════════════════════════════════════════
---   BUFF CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Buff spell configuration data
---   Contains all necessary information for automated buff management
---   @type table<number, table> Array of buff spell definitions
local BUFF_SPELLS = {
    { name = 'Stoneskin',  delay = 0, buffName = 'Stoneskin',  duration = 488 },
    { name = 'Blink',      delay = 6, buffName = 'Blink',      duration = 488 },
    { name = 'Aquaveil',   delay = 6, buffName = 'Aquaveil',   duration = 914 },
    { name = 'Ice Spikes', delay = 6, buffName = 'Ice Spikes', duration = 274 }
}

---   Anti-spam protection: Track last cast time for each spell
---   @type table<string, number> Map of spell name to last cast timestamp
local last_cast_times = {}

---   Minimum delay between casts (in seconds) to prevent spam
local CAST_COOLDOWN = 2.0

---  ═══════════════════════════════════════════════════════════════════════════
---   ANTI-SPAM PROTECTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Check if spell is safe to cast (anti-spam protection)
---   @param spellName string Name of the spell to check
---   @param currentTime number Current timestamp
---   @return boolean true if safe to cast
local function isSpellSafeToCast(spellName, currentTime)
    local lastCast = last_cast_times[spellName]
    if not lastCast then
        return true
    end

    return (currentTime - lastCast) >= CAST_COOLDOWN
end

---   Update last cast time for a spell
---   @param spellName string Name of the spell
---   @param currentTime number Current timestamp
local function updateLastCastTime(spellName, currentTime)
    last_cast_times[spellName] = currentTime
end

---  ═══════════════════════════════════════════════════════════════════════════
---   BUFF MANAGEMENT CORE
---  ═══════════════════════════════════════════════════════════════════════════

--- The buff list with a recast id attached to each entry.
---
--- The id comes from resources by name, with a hardcoded fallback for the
--- three that matter most: without one, a missing id would read as recast 0
--- and the spell would be cast on every call.
--- @param res table Windower resources
--- @return table Spells, in the order BUFF_SPELLS declares them
local function spells_with_recast_ids(res)
    local spells = {}
    for i, spellDef in ipairs(BUFF_SPELLS) do
        spells[i] = {
            name = spellDef.name,
            delay = spellDef.delay,
            buffName = spellDef.buffName,
            duration = spellDef.duration
        }

        local spell_data = res.spells:with('en', spellDef.name)
        spells[i].recastId = spell_data and spell_data.id or
            (spellDef.name == 'Stoneskin' and 54 or
                spellDef.name == 'Blink' and 53 or
                spellDef.name == 'Aquaveil' and 55 or 251)
    end
    return spells
end

--- Which buffs are worth casting right now, and how long to wait for each.
---
--- The delay accumulates across the queue rather than being per spell: the
--- second cast waits for the first to finish, the third for both. The first
--- one carries no delay at all, which is why the counter is checked before it
--- is incremented.
--- @param spells table From spells_with_recast_ids
--- @param spellRecasts table windower.ffxi.get_spell_recasts()
--- @param buffActive table buffactive
--- @param currentTime number os.clock()
--- @return table List of {spell, delay}
local function queue_ready_buffs(spells, spellRecasts, buffActive, currentTime)
    local ready = {}
    local totalDelay = 0

    for i = 1, #spells do
        local spell = spells[i]
        local recastTime = spellRecasts[spell.recastId] or 0

        -- duration 0 means the entry is not a timed buff; an active buff needs
        -- no recast. Neither is a candidate.
        if spell.duration > 0 and not buffActive[spell.buffName] then
            if recastTime == 0 and isSpellSafeToCast(spell.name, currentTime) then
                if #ready > 0 then
                    totalDelay = totalDelay + spell.delay
                end
                ready[#ready + 1] = { spell = spell, delay = totalDelay }
            end
        end
    end

    return ready
end

--- Send the queue, each cast waiting out the ones before it.
--- @param ready table From queue_ready_buffs
--- @param currentTime number os.clock(), recorded to keep the anti-spam honest
local function cast_queue(ready, currentTime)
    for i = 1, #ready do
        local readySpell = ready[i]
        local spellName = readySpell.spell.name

        local command = readySpell.delay > 0 and
            ('wait ' .. readySpell.delay .. '; input /ma "' .. spellName .. '" <me>') or
            ('input /ma "' .. spellName .. '" <me>')

        send_command(command)
        updateLastCastTime(spellName, currentTime)
    end
end

function BuffManager.BuffSelf()
    -- os.clock rather than os.time: the anti-spam window is shorter than a
    -- second, so whole seconds would let a double press through.
    local currentTime = os.clock()
    local spellRecasts = windower.ffxi.get_spell_recasts()
    local buffActive = buffactive

    if type(spellRecasts) ~= "table" then
        BLMMessages.show_buffself_recasts_error()
        return false
    end

    local res = res or windower.res or require('resources')
    if not res then
        BLMMessages.show_buffself_resources_error()
        return false
    end

    local spells = spells_with_recast_ids(res)
    local ready = queue_ready_buffs(spells, spellRecasts, buffActive, currentTime)

    if #ready > 0 then
        cast_queue(ready, currentTime)
        return true
    end

    -- Nothing to cast: say what is already up instead of staying silent.
    return BuffManager._displayBuffStatus(spells, buffActive, spellRecasts)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATUS DISPLAY SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

---   Display unified buff status using the message system
---   Uses same format as WAR (MessageBuffs.show_buff_status)
---   @param spells table Array of spell definitions
---   @param buffActive table Current active buffs
---   @param spellRecasts table Current spell recast times (UNUSED - no cooldowns displayed)
---   @return boolean true if status was displayed
function BuffManager._displayBuffStatus(spells, buffActive, spellRecasts)
    if not MessageBuffs then
        return false
    end

    local status_data = {}

    -- For each spell, show ONLY ACTIVE status (no cooldowns ever)
    for _, spell in ipairs(spells) do
        if buffActive[spell.buffName] then
            -- Buff is active
            table.insert(status_data, {
                name = spell.name,
                status = 'active'
            })
        end
        -- NO cooldown tracking - cooldowns are never displayed
    end

    -- Display using MessageBuffs format ONLY if we have active buffs
    -- If no buffs are active, return false silently (no messages)
    if #status_data > 0 then
        MessageBuffs.show_buff_status(status_data, "Magic")
        return true
    end

    -- No active buffs - return false without displaying anything
    return false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   BUFF QUERY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

---   Check if a specific buff is active
---   @param buffName string Name of the buff to check
---   @return boolean true if buff is active
function BuffManager.isBuffActive(buffName)
    return buffactive and buffactive[buffName] or false
end

---   Get all currently active buffs from our managed set
---   @return table<string, boolean> Map of buff names to active status
function BuffManager.getActiveBuffs()
    local activeBuffs = {}
    if not buffactive then
        return activeBuffs
    end

    for _, spell in ipairs(BUFF_SPELLS) do
        activeBuffs[spell.buffName] = buffactive[spell.buffName] or false
    end

    return activeBuffs
end

---   Get recast times for all managed buffs
---   @return table<string, number> Map of spell names to recast times (in centiseconds)
function BuffManager.getBuffRecasts()
    local recasts = {}
    local spellRecasts = windower.ffxi.get_spell_recasts()

    if type(spellRecasts) ~= "table" then
        return recasts
    end

    -- Get resources for spell ID resolution
    local res = res or windower.res or require('resources')
    if not res then
        return recasts
    end

    for _, spellDef in ipairs(BUFF_SPELLS) do
        local spell_data = res.spells:with('en', spellDef.name)
        local recastId = spell_data and spell_data.id or
            (spellDef.name == 'Stoneskin' and 54 or
                spellDef.name == 'Blink' and 53 or
                spellDef.name == 'Aquaveil' and 55 or 251)

        recasts[spellDef.name] = spellRecasts[recastId] or 0
    end

    return recasts
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MANUAL BUFF CONTROL
---  ═══════════════════════════════════════════════════════════════════════════

---   Cast a specific buff spell manually
---   @param spellName string Name of the spell to cast
---   @return boolean true if spell was queued for casting
function BuffManager.castBuff(spellName)
    -- Find spell definition
    local spellDef = nil
    for _, spell in ipairs(BUFF_SPELLS) do
        if spell.name == spellName then
            spellDef = spell
            break
        end
    end

    if not spellDef then
        BLMMessages.show_unknown_buff_error(spellName)
        return false
    end

    -- Check if buff is already active
    if buffactive and buffactive[spellDef.buffName] then
        BLMMessages.show_buff_already_active(spellName)
        return false
    end

    -- Check recast and cast if available
    local currentTime = os.clock()
    if isSpellSafeToCast(spellName, currentTime) then
        local command = 'input /ma "' .. spellName .. '" <me>'
        send_command(command)
        updateLastCastTime(spellName, currentTime)

        BLMMessages.show_manual_buff_cast(spellName)
        return true
    end

    return false
end

---   Get list of available buff spells
---   @return table<string> Array of spell names that can be managed
function BuffManager.getAvailableBuffs()
    local buffs = {}
    for i, spell in ipairs(BUFF_SPELLS) do
        buffs[i] = spell.name
    end
    return buffs
end

return BuffManager
