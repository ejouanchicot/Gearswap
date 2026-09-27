---  ═══════════════════════════════════════════════════════════════════════════
---   Roll Hold - keep the roll set on until the roll lands
---  ═══════════════════════════════════════════════════════════════════════════
---   A Phantom Roll or Double-Up takes effect when its action completes, a
---   moment after the precast set went on. A gear update in between - AutoMove
---   sends `gs c update` when movement starts or stops, a status change after
---   a kill - re-equipped the idle / engaged set, and the roll landed without
---   its "Phantom Roll +" piece (Regal Necklace): a weaker Bolter's Roll right
---   after a boss, while running to the next.
---
---   start() in job_post_precast opens the hold; while it is open,
---   job_handle_equipping_gear marks the update handled so Mote swaps
---   nothing; stop() in job_aftercast (the roll landed or failed) closes it.
---   HOLD_MAX closes it anyway if no aftercast ever comes.
---
---   @file    shared/jobs/cor/functions/logic/roll_hold.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-28
---  ═══════════════════════════════════════════════════════════════════════════

local RollHold = {}

local HOLD_MAX = 5.0   -- seconds; a roll lands in about 1-2

--- Whether this action is a roll the hold protects.
--- @param spell table Spell from GearSwap
--- @return boolean
function RollHold.is_roll(spell)
    return spell ~= nil and (spell.type == 'CorsairRoll' or spell.english == 'Double-Up')
end

--- Open the hold for a roll (job_post_precast).
--- @param spell table Spell from GearSwap
function RollHold.start(spell)
    if RollHold.is_roll(spell) then
        _G.cor_roll_hold = {name = spell.english, until_time = os.clock() + HOLD_MAX}
    end
end

--- Close the hold (job_aftercast of the roll).
--- @param spell table Spell from GearSwap
function RollHold.stop(spell)
    if RollHold.is_roll(spell) then
        _G.cor_roll_hold = nil
    end
end

--- Mark a gear update handled while a roll is under way (job_handle_equipping_gear).
--- @param eventArgs table Mote event args
--- @return boolean True when the update was held
function RollHold.hold_update(eventArgs)
    local hold = rawget(_G, 'cor_roll_hold')
    if not hold then return false end
    if os.clock() > hold.until_time then
        _G.cor_roll_hold = nil
        return false
    end
    eventArgs.handled = true
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok and Trace then
        Trace.log('ROLL', 'gear update held during %s (roll set kept on)', hold.name)
    end
    return true
end

return RollHold
