---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Unbridled - Unbridled Learning before an unbridled spell
---  ═══════════════════════════════════════════════════════════════════════════
---   Option blu_unbridled (config/AUTO_ABILITIES.lua, off by default): an
---   unbridled spell (BLU_SPELL_DATABASE `unbridled`) cast without Unbridled
---   Learning or Unbridled Wisdom up is cancelled, Unbridled Learning goes
---   out, and the spell is cast again on the same target once the buff is up
---   (AbilityHelper.try_ability: target by id, at most one attempt per spell,
---   nothing sent while the ability is on cooldown).
---
---   @file    shared/jobs/blu/functions/logic/unbridled.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local BLUUnbridled = {}

local AutoOptions = require('shared/utils/core/auto_options')
local AbilityHelper = require('shared/utils/precast/ability_helper')
local BLUSpellMap = require('shared/jobs/blu/functions/logic/spell_map')

-- Soft delay before the spell goes again (his old chain waited 1.5 s)
local SPELL_DELAY = 1.5

--- Fire Unbridled Learning first when the option is on and the spell needs it.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (handled is set when the ability fires)
function BLUUnbridled.apply(spell, eventArgs)
    if spell.type ~= 'BlueMagic' then return end
    if not AutoOptions.on('blu_unbridled') then return end
    if not BLUSpellMap.is_unbridled(spell.english) then return end
    if AbilityHelper.is_buff_active('Unbridled Wisdom') then return end

    AbilityHelper.try_ability(spell, eventArgs, 'Unbridled Learning', SPELL_DELAY)
    require('shared/utils/debug/trace_log').log('UNBRIDLED', '%s on %s -> %s', spell.english,
        tostring(spell.target and spell.target.name),
        eventArgs.handled and 'Unbridled Learning first, spell again after' or 'cast as is')
end

return BLUUnbridled
