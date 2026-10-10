---============================================================================
--- Fight Sheet - what each ability adds to the character sheet, measured at rest
---============================================================================
--- //gs c fights hits sheet                        no fight needed (a Mog House will do)
--- //gs c fights hits sheet without neck [slot...]  the sheet read with those slots emptied, then
---                                                  the pieces given back: what one piece gives
---
--- Writes in the journal of fight_hits.lua the character as it stands (job,
--- pieces worn, attributes, attack, defense, accuracy), then uses each ability
--- of FIGHTS_CONFIG.lua `sheet` that the job and subjob have, one at a time:
--- the ability, the same lines under it, the buff cancelled, the next one.
--- The difference between two MARK blocks is what the ability adds.
---
--- An ability still on recast is left out and named at the end. Cancelling a
--- buff needs the Cancel addon; without it the buffs pile up, and each block
--- still lists the buffs it was read under.
---
--- The run lives on windower._fight_sheet: asked again, the new run replaces
--- the old one, whose pending steps then do nothing.
---
--- @file    shared/utils/combat/fight_sheet.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-10
---============================================================================

local FightSheet = {}

local InfoBlock = require('shared/utils/messages/info_block')

-- seconds: for an ability's buff and stats to arrive, for a block to be written (its /checkparam
-- is sent 3 s after the block starts), for a cancelled buff to be gone
local USE_WAIT, READ_WAIT, CANCEL_WAIT = 3, 6, 2
-- seconds for emptied slots to be empty and locked (fight_hits.lua's own delay for it)
local EMPTY_WAIT = 5

local function hits()
    return require('shared/utils/combat/fight_hits')
end

--- The game's entry of an ability the character has now, or nil.
local function ability(name)
    local ok, res = pcall(require, 'resources')
    local have = (windower.ffxi.get_abilities() or {}).job_abilities or {}
    for _, id in ipairs(have) do
        local entry = ok and res.job_abilities[id]
        if entry and entry.en:lower() == name:lower() then return entry end
    end
    return nil
end

--- True when a buff of that name is on the character.
local function buff_up(name)
    local ok, res = pcall(require, 'resources')
    for _, id in ipairs((windower.ffxi.get_player() or {}).buffs or {}) do
        local buff = ok and res.buffs[id]
        if buff and buff.en:lower() == name:lower() then return true end
    end
    return false
end

--- Runs `fn(run)` after `delay` seconds, unless another run has started since.
local function later(run, delay, fn)
    coroutine.schedule(function()
        if windower._fight_sheet == run then fn(run) end
    end, delay)
end

local function finish(run)
    windower._fight_sheet = nil
    hits().note('SHEET done | measured: ' .. table.concat(run.measured, ', ') .. ' | left out: ' ..
        table.concat(run.left_out, ', '))
    hits().quiet(run.was_on)
    InfoBlock.show({tag = 'FIGHTS', title = 'Sheet', fields = {
        {'Measured', #run.measured > 0 and table.concat(run.measured, ', ') or 'none'},
        {'Left out', #run.left_out > 0 and table.concat(run.left_out, ', ') or 'none'},
        {'Finished', 'change job or subjob, then run it again'}}})
end

local use_next

--- The ability was used USE_WAIT seconds ago: its block, then its buff cancelled.
local function measure(run)
    local name = run.names[run.index]
    if buff_up(name) then
        hits().mark('sheet ' .. name)
        run.measured[#run.measured + 1] = name
    else
        run.left_out[#run.left_out + 1] = name .. ' (no buff)'
    end
    later(run, READ_WAIT, function()
        send_command('cancel ' .. name)
        run.index = run.index + 1
        later(run, CANCEL_WAIT, use_next)
    end)
end

--- Uses the next ability that is ready, or ends the run.
use_next = function(run)
    local name = run.names[run.index]
    if not name then
        -- the sheet with nothing on once more: the game only sends its stats when they change, so the
        -- first block can lack them, and the last cancel has just made it send them
        hits().mark('sheet none again')
        return later(run, READ_WAIT, finish)
    end
    local entry = ability(name)
    local left = entry and (windower.ffxi.get_ability_recasts()[entry.recast_id] or 0) or 0
    if left > 0 then
        run.left_out[#run.left_out + 1] = ('%s (ready in %d s)'):format(name, left)
        run.index = run.index + 1
        return use_next(run)
    end
    send_command('input /ja "' .. name .. '" <me>')
    later(run, USE_WAIT, measure)
end

--- //gs c fights hits sheet without <slot> [slot...]: one block with those slots emptied. The alt is
--- not told, nothing is used.
--- @param slots table Slot names as GearSwap writes them (neck, left_ring, waist...)
function FightSheet.without(slots)
    if not slots[1] then return end
    local run = {was_on = hits().quiet(true)}
    windower._fight_sheet = run
    local label = 'sheet without ' .. table.concat(slots, ' ')
    hits().empty(slots)
    later(run, EMPTY_WAIT, function()
        hits().mark(label)
        later(run, READ_WAIT, function()
            hits().empty(nil)
            hits().quiet(run.was_on)
            windower._fight_sheet = nil
            InfoBlock.show({tag = 'FIGHTS', title = 'Sheet', fields = {{'Read', label}, {'Pieces', 'given back'}}})
        end)
    end)
end

--- //gs c fights hits sheet
--- @param names table|nil FIGHTS_CONFIG.lua `sheet`: ability names, in the order they are measured
function FightSheet.run(names)
    local mine = {}
    for _, name in ipairs(type(names) == 'table' and names or {}) do
        if ability(name) then mine[#mine + 1] = name end
    end
    if #mine == 0 then
        return InfoBlock.show({tag = 'FIGHTS', title = 'Sheet', fields = {
            {'Abilities', 'none of FIGHTS_CONFIG.lua `sheet` on this job'}}})
    end
    local run = {names = mine, index = 1, measured = {}, left_out = {}, was_on = hits().quiet(true)}
    windower._fight_sheet = run
    InfoBlock.show({tag = 'FIGHTS', title = 'Sheet', fields = {{'Abilities', table.concat(mine, ', ')},
        {'Time', ('about %d s, do not use anything'):format(#mine * (USE_WAIT + READ_WAIT + CANCEL_WAIT) + READ_WAIT)}}})
    for _, name in ipairs(mine) do
        if buff_up(name) then send_command('cancel ' .. name) end
    end
    later(run, CANCEL_WAIT, function()
        hits().mark('sheet none')
        later(run, READ_WAIT, use_next)
    end)
end

return FightSheet
