---============================================================================
--- COR Double-Up Redirect - a roll already up becomes a Double-Up
---============================================================================
--- A Phantom Roll that is already active cannot be rolled again: the game
--- refuses it. Pressing its key again means "double it", so the roll is
--- cancelled and Double-Up sent instead, when that is possible:
---   - Double-Up Chance is up (the window after a roll);
---   - the roll is the last one rolled: Double-Up always goes to that one,
---     so doubling Chaos after Samurai would double Samurai.
--- Otherwise the roll is cancelled with a message saying why.
---
--- Runs before CooldownChecker (COR_PRECAST): the Phantom Roll recast would
--- cancel the roll before it could become a Double-Up, which has its own.
---
--- @file    shared/jobs/cor/functions/logic/double_up.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local DoubleUp = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')

--- Turn a roll that is already up into a Double-Up.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (cancel is set when the roll is redirected)
--- @return boolean True when the roll was taken over (cancelled)
function DoubleUp.redirect(spell, eventArgs)
    if spell.type ~= 'CorsairRoll' or not buffactive[spell.english] then return false end
    eventArgs.cancel = true
    if not buffactive['Double-Up Chance'] then
        MessageFormatter.show_warning(spell.english .. ' is already up, no Double-Up chance.')
        return true
    end
    local last = _G.cor_last_roll and _G.cor_last_roll.name
    if last and last ~= spell.english then
        MessageFormatter.show_warning(('Double-Up goes to %s, the last roll: %s not doubled.'):format(last, spell.english))
        return true
    end
    send_command('input /ja "Double-Up" <me>')
    return true
end

return DoubleUp
