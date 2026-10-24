---============================================================================
--- Synthesis result messages - one block a synthesis, in two times
---============================================================================
--- The block shared/utils/craft/synth_results.lua shows for each of the
--- character's own synthesis, in the look of every data block (info_block.lua)
--- and in the chat window of the synthesis messages (channel 121, the craft
--- addon's). Its title as soon as the animation starts (the server already says
--- NQ, HQ or Break), the rest when the result comes (the HQ tier, the item, what
--- a break lost):
---   =========================================
---     SYNTH :: HQ                          <- animation
---   =========================================
---   Result : HQ 2                          <- result
---   Item   : Bone Hairpin +1 x2
---   =========================================
--- Each result has its own colour (NQ white, HQ green, HQ 2 aqua, HQ 3 gold,
--- Break red), from the chat palette, so the player's own colours apply.
---
--- @file shared/utils/messages/formatters/ui/message_synth.lua
--- @author ejouanchicot
--- @version 1.2
--- @date Created: 2026-10-24
---============================================================================

local ChatPalette = require('shared/utils/messages/chat_palette')
local InfoBlock = require('shared/utils/messages/info_block')

local MessageSynth = {}

-- The chat channel of the craft addon's synthesis messages: the same chat window
local SYNTH_CHANNEL = 121
-- The colour of each result (palette names: shared/utils/messages/chat_palette.lua)
local RESULT_COLOR = {NQ = 'white', HQ = 'green', HQ1 = 'green', HQ2 = 'aqua', HQ3 = 'gold', Break = 'red'}

local function colored(result)
    local label = result:match('^HQ%d$') and ('HQ ' .. result:sub(3)) or result
    return ChatPalette.tag(RESULT_COLOR[result] or 'white') .. label
end

--- The block's title, as the animation starts.
--- @param result string 'NQ', 'HQ' or 'Break'
function MessageSynth.show_start(result)
    InfoBlock.show({tag = 'SYNTH', title = colored(result), channel = SYNTH_CHANNEL, foot = false})
end

--- The rest of the block (the whole block when its title was not shown).
--- @param result string|nil 'NQ', 'HQ1', 'HQ2', 'HQ3', 'Break', nil when cancelled
--- @param item string|nil The item made (nil on a break)
--- @param count number|nil How many were made
--- @param lost table|nil Names of the ingredients lost on a break
--- @param started boolean The title is already in the chat
function MessageSynth.show_result(result, item, count, lost, started)
    local fields = {{'Result', result and colored(result) or 'cancelled', not result and 'dim' or nil}}
    if item then fields[#fields + 1] = {'Item', item .. ((count or 1) > 1 and (' x' .. count) or '')} end
    if result == 'Break' then
        fields[#fields + 1] = (lost and #lost > 0) and {'Lost', table.concat(lost, ', '), 'bad'} or {'Lost', 'the crystal only', 'dim'}
    end
    InfoBlock.show({tag = 'SYNTH', title = result and colored(result) or 'cancelled', fields = fields, channel = SYNTH_CHANNEL, head = not started})
end

return MessageSynth
