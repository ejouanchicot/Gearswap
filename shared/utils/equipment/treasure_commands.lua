---============================================================================
--- Treasure Commands - //gs c th
---============================================================================
---   //gs c th              mode, sets.TreasureHunter, mobs tagged
---   //gs c th show | hide  Treasure Mode on this job or not
---   //gs c th key <key>    its key on this job (none = no key)
---   //gs c th clear        forget every tag
---   //gs c th help
--- Saved in <Character>/config/treasure_mode.lua (optional_state.lua).
---
--- @file    shared/utils/equipment/treasure_commands.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local TreasureHunter = require('shared/utils/equipment/treasure_hunter')

--- Written at the top of the settings file: the file is rewritten whole by
--- every command, so its explanation has to come from here.
local HEADER = [[
-- Treasure Mode: Treasure Hunter gear (sets.TreasureHunter of the job's set
-- file) until your first action lands on a mob ("tag"), then your normal
-- gear. Off = nothing, Tag = until the mob is tagged, Full = on the engaged
-- set at all times. THF has it by itself (Tag / SATA / Full); on the other
-- jobs it is Off and hidden until shown here. A job without
-- sets.TreasureHunter gets no TH gear whatever the mode.
--
-- shown  = jobs where it appears (HUD row and key). all = true means every job.
-- hidden = jobs where it never appears, even with all = true.
-- keys   = its key per job; all = the key of every job not listed.
--          ^ Ctrl, ! Alt, ~ Shift, @ Win, # Apps (e.g. '!numpad.' = Alt+Numpad .).
-- A job is written in capitals, followed by = true: DNC = true.
--
-- Examples:
--   On DNC and COR too:
--     shown = {COR = true, DNC = true},
--   Alt+F11 on DNC:
--     keys = {DNC = '!f11'},
--
-- In game, on the job concerned:
--   //gs c th             mode, TH set found, mobs tagged
--   //gs c th show        Treasure Mode on this job (starts Off)
--   //gs c th hide        not on this job any more
--   //gs c th key !f11    its key on this job (none = no key)
--   //gs c th clear       forget the mobs already tagged
-- The commands rewrite this file; editing it by hand works too (//gs reload).
]]

return require('shared/utils/core/optional_state_commands').create({
    optional = TreasureHunter.optional,
    command = 'th', label = 'Treasure Mode', tag = 'TH', header = HEADER,
    status = function() return TreasureHunter.status_fields() end,
    subtitle = 'Treasure Hunter gear, per job',
    notes = {'Off by default except on THF. Needs sets.TreasureHunter in the job set file.'},
    extra = function(sub)
        if sub ~= 'clear' then return false end
        TreasureHunter.clear()
        require('shared/utils/messages/message_formatter').show_success('Treasure Hunter: tags forgotten.')
        return true
    end,
    extra_rows = {{'//gs c th clear', '', 'Forget the mobs tagged'}},
})
