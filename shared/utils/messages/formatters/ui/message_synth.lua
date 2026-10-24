---============================================================================
--- Synthesis result messages - one coloured line a synthesis
---============================================================================
--- The line shared/utils/craft/synth_results.lua writes after each of the
--- character's own synthesis:
---   [Synth] NQ    Bone Hairpin x3
---   [Synth] HQ 2  Bone Hairpin +1
---   [Synth] Break  lost: Giant Femur, Bone Chip
--- Each result has its own colour (NQ white, HQ 1 green, HQ 2 aqua, HQ 3
--- gold, Break red), from the chat palette, so the player's own colours apply.
---
--- @file shared/utils/messages/formatters/ui/message_synth.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-24
---============================================================================

local ChatPalette = require('shared/utils/messages/chat_palette')
local MessageCore = require('shared/utils/messages/message_core')

local MessageSynth = {}

-- The colour of each result (palette names: shared/utils/messages/chat_palette.lua)
local RESULT_COLOR = {NQ = 'white', HQ1 = 'green', HQ2 = 'aqua', HQ3 = 'gold', Break = 'red'}

--- Show one synthesis result.
--- @param result string 'NQ', 'HQ1', 'HQ2', 'HQ3' or 'Break'
--- @param item string|nil The item made (nil on a break)
--- @param count number|nil How many were made
--- @param lost table|nil Names of the ingredients lost on a break
function MessageSynth.show_result(result, item, count, lost)
    local gray, cyan = ChatPalette.tag('gray'), string.char(0x1F, 121)
    local color = ChatPalette.tag(RESULT_COLOR[result] or 'white')
    local label = result:match('^HQ%d$') and ('HQ ' .. result:sub(3)) or result
    local line = gray .. '[' .. cyan .. 'Synth' .. gray .. '] ' .. color .. label
    if item then
        line = line .. gray .. '  ' .. ChatPalette.tag('white') .. item .. ((count or 1) > 1 and (gray .. ' x' .. count) or '')
    end
    if lost and #lost > 0 then
        line = line .. gray .. '  lost: ' .. ChatPalette.tag('red') .. table.concat(lost, gray .. ', ' .. ChatPalette.tag('red'))
    end
    MessageCore.raw(line)
end

return MessageSynth
