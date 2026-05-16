---  ═══════════════════════════════════════════════════════════════════════════
---   Special Handlers - Magic Burst announce + replacement exec + Breakga
---  ═══════════════════════════════════════════════════════════════════════════
---   Three independent specialised handlers:
---
---   1. announce_magic_burst()
---      Sends a /p message announcing the spell when MagicBurstMode is On
---      and the spell is Elemental Magic. Wait time is tier-aware
---      (-ja and tier VI need 2s, others 1s).
---
---   2. execute_replacement()
---      Sends the @input /ma command to actually cast the replacement spell,
---      stamps the timing guard, and shows the refinement message.
---
---   3. handle_breakga_to_break()
---      Special Breakga -> Break fallback with lag protection (per-spell
---      timing guard prevents repeated triggering during high latency).
---
---   @file    jobs/blm/functions/logic/refiner/special_handlers.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from spell_refiner.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local TimingGuards     = require('shared/jobs/blm/functions/logic/refiner/timing_guards')
local BLMMessages      = require('shared/utils/messages/formatters/jobs/message_blm')
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')

local SpecialHandlers = {}

--- Announce the spell to the party chat when MagicBurstMode = On.
--- No-op for non-elemental spells or when burst mode is off.
---
--- @param originalSpell table  Original spell object from GearSwap
--- @param finalSpellName string Final spell name after refinement
function SpecialHandlers.announce_magic_burst(originalSpell, finalSpellName)
    if not (state and state.MagicBurstMode and state.MagicBurstMode.value == 'On'
            and originalSpell.skill == 'Elemental Magic') then
        return
    end

    -- Guard against the double-announce that happens when refinement fires a
    -- replacement: original spell precast announces "Fire V", then the
    -- `@input /ma Fire V` from execute_replacement triggers a SECOND precast
    -- which would announce again 0.2-0.4s later. Two /p in <5s gets rejected
    -- by FFXI's anti-spam ("Cannot send messages so often").
    local now = os.clock()
    if not TimingGuards.is_announce_safe(now) then
        return
    end
    TimingGuards.update_announce_time(now)

    -- Parse final name to get category and level
    local finalCategory, finalLevel = finalSpellName:match('(%a+)%s*(%a*)')

    -- Build display name based on spell type
    local displayName
    if finalSpellName:find('ja') then
        -- -ja spells: full name (no tier appended)
        displayName = finalSpellName
    elseif not finalLevel or finalLevel == '' then
        -- Base tier spells: just the category
        displayName = finalCategory
    else
        -- Tiered spells: category + level
        displayName = finalCategory .. ' ' .. finalLevel
    end

    -- Wait time depends on tier/type (-ja and tier VI need extra time)
    local wait_time
    if finalSpellName:find('ja') then
        wait_time = 'wait 2; '
    elseif finalLevel == 'VI' then
        wait_time = 'wait 2; '
    else
        wait_time = 'wait 1; '
    end

    send_command(wait_time .. 'input /p Casting: [' .. displayName .. '] => Nuke')
end

--- Execute a refined spell replacement: cancel the original, fire the new
--- one via @input (so GearSwap hooks run), stamp the timing guard, and show
--- the refinement message.
---
--- @param originalSpell table  Original spell object
--- @param newSpell string      Refined spell name to cast
--- @param eventArgs table      Event args (.cancel will be set to true)
--- @param currentTime number   Result of os.clock() for timing stamp
function SpecialHandlers.execute_replacement(originalSpell, newSpell, eventArgs, currentTime)
    -- Stamp the global replacement guard
    TimingGuards.update_replacement_time(currentTime)

    -- Send the replacement spell command (small delay + @input to trigger hooks)
    send_command('wait 0.1; @input /ma "' .. newSpell .. '" ' .. tostring(originalSpell.target.raw))
    eventArgs.cancel = true

    -- Show refinement message with original spell's recast for context
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local res = res or windower.res or require('resources')
    local originalSpellData = res and res.spells:with('en', originalSpell.english)
    local recast_seconds = 0

    if originalSpellData and spell_recasts and spell_recasts[originalSpellData.recast_id] then
        recast_seconds = spell_recasts[originalSpellData.recast_id] / 100
    end

    BLMMessages.show_spell_refinement(originalSpell.english, newSpell, recast_seconds)
end

--- Handle the special Breakga -> Break fallback. When Breakga is on cooldown:
---   - If Break is also on cooldown: show its cooldown message
---   - If Break is ready: cast it via @input
---   - If lag-protected: cancel and show "blocked" warning
---
--- @param spell table          Original spell (must be 'Breakga')
--- @param spell_recasts table  Recast data
--- @param eventArgs table      Event args
--- @param currentTime number   Result of os.clock()
function SpecialHandlers.handle_breakga_to_break(spell, spell_recasts, eventArgs, currentTime)
    if spell.english ~= 'Breakga' or spell_recasts[spell.recast_id] <= 0 then
        return
    end

    local breakKey = "Breakga_to_Break"
    if not TimingGuards.is_spell_safe_to_cast(breakKey, currentTime) then
        -- Lag protection triggered - block to prevent rapid retries
        eventArgs.cancel = true
        BLMMessages.show_breakga_blocked()
        return
    end

    cancel_spell()
    local newSpell = 'Break'

    local res = res or windower.res or require('resources')
    if not res then
        return
    end

    local break_spell = res.spells:with('en', 'Break')
    local break_id = break_spell and break_spell.id or 255

    if spell_recasts[break_id] > 0 then
        cancel_spell()
        eventArgs.cancel = true
        MessageCooldowns.show_spell_cooldown(newSpell, spell_recasts[break_id])
    else
        send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        eventArgs.cancel = true
        TimingGuards.update_cast_time(breakKey, currentTime)
    end
end

return SpecialHandlers
