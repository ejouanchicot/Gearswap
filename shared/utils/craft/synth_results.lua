---============================================================================
--- Synth Results - a coloured line after each of the character's synthesis
---============================================================================
--- NQ, HQ 1, HQ 2, HQ 3 or Break, with the item made and, on a break, the
--- ingredients lost (shared/utils/messages/formatters/ui/message_synth.lua).
--- Shown for every synthesis, by hand or through the craft addon, crafting
--- gear on or not; the game's own messages and battlemod's stay as they are.
---
--- Two packets (Windower addons/libs/packets/fields.lua):
---   0x030 Synth Animation: the player, then at 0x0C 0 NQ, 1 break, 2 HQ
---   0x06F Self Synth Result: result at 0x04 (0 success, 1 and 5 fail, 3 4 6 7
---         cancelled), quality at 0x05 (the HQ tier), count at 0x06, the item
---         at 0x08, the 8 lost ingredients from 0x0A
--- What the tier reads is not measured in game yet: every packet goes to
--- <Character>/logs/craft/synth.log as it came, to check the lines against.
---
--- @file shared/utils/craft/synth_results.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-24
---============================================================================

local SynthResults = {}

-- 0x06F results that are a cancelled synthesis (wrong recipe, skill too low...):
-- the game says why, nothing was made or lost
local CANCELLED = {[3] = true, [4] = true, [6] = true, [7] = true}
-- An animation older than this is not the one of the result that arrives
local ANIMATION_MAX_AGE = 30

-- The animation seen last: what 0x030 said of this character's synthesis
local animation = nil

local function res_items()
    local ok, r = pcall(function() return (type(gearswap) == 'table' and gearswap.res) or require('resources') end)
    return ok and r and r.items or {}
end

local function item_name(id)
    local it = id and id ~= 0 and res_items()[id]
    return it and it.en or (id and id ~= 0 and ('item ' .. id)) or nil
end

--- One line of the journal, every packet as it came (<Character>/logs/craft/synth.log).
local function journal(fmt, ...)
    local line = fmt:format(...)
    pcall(function()
        local path = require('shared/utils/core/char_paths').log('craft', 'synth.log')
        local file = path and io.open(path, 'a')
        if not file then return end
        file:write(os.date('%Y-%m-%d %H:%M:%S'), ' ', line, '\n')
        file:close()
    end)
end

--- The result to show for a 0x06F, from it and the animation before it:
--- 'NQ', 'HQ1'..'HQ3', 'Break', or nil when nothing was made (a cancel).
--- @param result number 0x06F result
--- @param quality number 0x06F quality (signed)
--- @param lost table Ingredients lost
--- @param param number|nil 0x030 param of the same synthesis (0 NQ, 1 break, 2 HQ)
--- @return string|nil
function SynthResults.classify(result, quality, lost, param)
    if CANCELLED[result] then return nil end
    if result == 1 or result == 5 or param == 1 or #lost > 0 then return 'Break' end
    if quality > 0 or param == 2 then return 'HQ' .. math.min(3, math.max(1, quality)) end
    return 'NQ'
end

local function on_animation(original)
    local me = windower.ffxi.get_player()
    if not me or original:unpack('I', 0x05) ~= me.id then return end
    animation = {param = original:byte(0x0D), at = os.time()}
    journal('0x030 param=%d', animation.param)
end

local function on_result(original)
    local result, quality = original:byte(0x05), original:byte(0x06)
    if quality > 127 then quality = quality - 256 end
    local count, item = original:byte(0x07), original:unpack('H', 0x09)
    local lost, lost_ids = {}, {}
    for i = 0, 7 do
        local id = original:unpack('H', 0x0B + 2 * i)
        if id ~= 0 then lost[#lost + 1] = item_name(id); lost_ids[#lost_ids + 1] = id end
    end
    local param = animation and os.time() - animation.at <= ANIMATION_MAX_AGE and animation.param or nil
    animation = nil
    local shown = SynthResults.classify(result, quality, lost, param)
    journal('0x06F result=%d quality=%d count=%d item=%d (%s) lost=[%s] animation=%s -> %s', result, quality, count, item,
        item_name(item) or '-', table.concat(lost_ids, ','), tostring(param), tostring(shown))
    if not shown then return end
    local MessageSynth = require('shared/utils/messages/formatters/ui/message_synth')
    MessageSynth.show_result(shown, shown ~= 'Break' and item_name(item) or nil, count, lost)
end

--- Listen to the synthesis packets, once per load (a raw event: a plain one
--- from GearSwap runs its gear refresh on every packet).
function SynthResults.init()
    if rawget(_G, '_synth_results_on') then return end
    _G._synth_results_on = true
    windower.raw_register_event('incoming chunk', function(id, original)
        if id == 0x030 then pcall(on_animation, original)
        elseif id == 0x06F then pcall(on_result, original) end
    end)
    -- the journal says the listener is on before any synthesis (nothing in the chat
    -- after one then tells "not listening" from "packet not seen")
    journal('init: listening')
end

return SynthResults
