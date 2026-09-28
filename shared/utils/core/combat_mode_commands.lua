---============================================================================
--- Combat Mode Commands - //gs c combatmode
---============================================================================
---   //gs c combatmode              status on this job
---   //gs c combatmode show | hide  Combat Mode on this job or not
---   //gs c combatmode key <key>    its key on this job (none = no key)
---   //gs c combatmode help
--- Saved in <Character>/config/combat_mode.lua (combat_mode.lua reads it).
---
--- @file    shared/utils/core/combat_mode_commands.lua
--- @author  ejouanchicot
--- @version 1.1 - on optional_state_commands.lua
--- @date    Created: 2026-09-25
---============================================================================

local CombatMode = require('shared/utils/core/combat_mode')

--- Written at the top of the settings file: the file is rewritten whole by
--- every command, so its explanation has to come from here.
local HEADER = [[
-- Combat Mode: locks the weapons (main, sub, range) so a spell or a set
-- never swaps them and the TP stays. The GearSwap adds it by itself: no job
-- file defines it. This file decides on which jobs it appears (HUD row, key
-- and lock) and its key. The //gs c combatmode commands rewrite it; editing
-- it by hand works too (reload after: //gs reload).
--
-- shown  = jobs where it appears. all = true means every job.
-- hidden = jobs where it never appears, even with all = true.
-- keys   = its key per job; all = the key of every job not listed.
--          ^ Ctrl, ! Alt, ~ Shift, @ Win, # Apps (e.g. '~f9' = Shift+F9).
-- A job is written in capitals, followed by = true: THF = true.
--
-- Examples:
--   Every job except THF and BLU:
--     shown = {all = true},
--     hidden = {BLU = true, THF = true},
--   Only on WAR and SAM:
--     shown = {SAM = true, WAR = true},
--     hidden = {},
--   Shift+F9 everywhere, Alt+F10 on THF:
--     keys = {THF = '!f10', all = '~f9'},
--
-- In game, on the job concerned:
--   //gs c combatmode             what it does on this job
--   //gs c combatmode hide        not on this job any more (hidden)
--   //gs c combatmode show        back on this job
--   //gs c combatmode key !f10    its key on this job (none = no key)
-- Delete this file to go back to the defaults: only BLM, GEO, RDM and WHM
-- have it, with their own key.
]]

return require('shared/utils/core/optional_state_commands').create({
    optional = CombatMode._optional,
    command = 'combatmode', label = 'Combat Mode', tag = 'COMBAT', header = HEADER,
    status = function() return {{'Weapons locked', CombatMode.is_on()}} end,
    subtitle = 'Weapon lock, per job',
    notes = {'On: main, sub and range stay where they are (ammo too on BLM, GEO, WHM).'},
})
