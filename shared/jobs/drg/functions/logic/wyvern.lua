---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Wyvern - Healing Breath trigger and breath gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Game rules used here (BG-Wiki "Wyvern (Dragoon Pet)", "Healing Breath"):
---   • The wyvern's kind follows the Dragoon's subjob. A defensive wyvern
---     (/WHM /BLM /RDM /SMN /BLU /SCH /GEO) cures when the Dragoon casts a
---     spell with HP under 33.3%, 50% with the artifact head on; a hybrid
---     wyvern (/PLD /DRK /BRD /NIN /RUN) under 25%, 33.3% with the head. An
---     offensive wyvern (any other subjob, or none) never cures on a spell.
---   • The HP checked is the Dragoon's at the END of the cast, when the
---     midcast gear is on: sets.midcast.HealingBreathTrigger (the artifact
---     head) goes on top of the spell's set when the HP is under the
---     "head on" line.
---   • "Enhances Breath" gear counts when worn as the breath goes off:
---     sets.midcast.HealingBreath / ElementalBreath on the wyvern's breath.
---
---   @file    shared/jobs/drg/functions/logic/wyvern.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Wyvern = {}

--- HP% line (artifact head on) under which a spell makes the wyvern cure,
--- by subjob. A subjob not listed never triggers it.
Wyvern.TRIGGER_HPP = {
    WHM = 50, BLM = 50, RDM = 50, SMN = 50, BLU = 50, SCH = 50, GEO = 50,
    PLD = 33.3, DRK = 33.3, BRD = 33.3, NIN = 33.3, RUN = 33.3,
}

--- The wyvern's elemental breaths (res/job_abilities.lua 646-651).
local ELEMENTAL_BREATHS = {
    ['Flame Breath'] = true, ['Frost Breath'] = true, ['Gust Breath'] = true,
    ['Sand Breath'] = true, ['Lightning Breath'] = true, ['Hydro Breath'] = true,
}

--- The trigger line of the current subjob.
--- @return number|nil HP% line, nil when the subjob cannot trigger
function Wyvern.trigger_line()
    if not player or (player.sub_job_level or 0) == 0 then return nil end
    return Wyvern.TRIGGER_HPP[player.sub_job]
end

--- Whether a spell cast now would make the wyvern use Healing Breath (with
--- the trigger set on).
--- @param spell table The master's spell
--- @return boolean
function Wyvern.spell_triggers_breath(spell)
    if not spell or spell.action_type ~= 'Magic' then return false end
    if spell.skill == 'Summoning Magic' then return false end
    if not (pet and pet.isvalid) then return false end
    local line = Wyvern.trigger_line()
    return line ~= nil and player.hpp ~= nil and player.hpp < line
end

--- The set a wyvern breath wears, by its name.
--- @param name string|nil The wyvern's action (English)
--- @return table|nil set, string|nil set name
function Wyvern.breath_set(name)
    if type(name) ~= 'string' or not sets.midcast then return nil end
    if name:sub(1, 14) == 'Healing Breath' then
        return sets.midcast.HealingBreath, 'HealingBreath'
    end
    if ELEMENTAL_BREATHS[name] then
        return sets.midcast.ElementalBreath, 'ElementalBreath'
    end
    return nil
end

return Wyvern
