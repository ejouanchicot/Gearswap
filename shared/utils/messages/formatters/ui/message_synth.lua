---============================================================================
--- Synthesis result messages - one block a synthesis
---============================================================================
--- The block shared/utils/craft/synth_results.lua shows after each of the
--- character's own synthesis, in the look of every data block (info_block.lua)
--- and in the chat window of the synthesis messages (channel 121, the craft
--- addon's):
---   =========================================
---     SYNTH :: HQ 2
---   =========================================
---   Item : Bone Hairpin +1 x2
---   =========================================
--- A break says what it lost (Lost : Giant Femur, Bone Chip). Each result has
--- its own colour (NQ white, HQ 1 green, HQ 2 aqua, HQ 3 gold, Break red),
--- from the chat palette, so the player's own colours apply.
---
--- @file shared/utils/messages/formatters/ui/message_synth.lua
--- @author ejouanchicot
--- @version 1.1
--- @date Created: 2026-10-24
---============================================================================

local ChatPalette = require('shared/utils/messages/chat_palette')
local InfoBlock = require('shared/utils/messages/info_block')

local MessageSynth = {}

-- The chat channel of the craft addon's synthesis messages: the same chat window
local SYNTH_CHANNEL = 121
-- The colour of each result (palette names: shared/utils/messages/chat_palette.lua)
local RESULT_COLOR = {NQ = 'white', HQ1 = 'green', HQ2 = 'aqua', HQ3 = 'gold', Break = 'red'}

--- Show one synthesis result.
--- @param result string 'NQ', 'HQ1', 'HQ2', 'HQ3' or 'Break'
--- @param item string|nil The item made (nil on a break)
--- @param count number|nil How many were made
--- @param lost table|nil Names of the ingredients lost on a break
function MessageSynth.show_result(result, item, count, lost)
    local label = result:match('^HQ%d$') and ('HQ ' .. result:sub(3)) or result
    local fields = {}
    if item then fields[#fields + 1] = {'Item', item .. ((count or 1) > 1 and (' x' .. count) or '')} end
    if result == 'Break' then
        fields[#fields + 1] = (lost and #lost > 0) and {'Lost', table.concat(lost, ', '), 'bad'} or {'Lost', 'the crystal only', 'dim'}
    end
    InfoBlock.show({tag = 'SYNTH', title = ChatPalette.tag(RESULT_COLOR[result] or 'white') .. label, fields = fields, channel = SYNTH_CHANNEL})
end

return MessageSynth
