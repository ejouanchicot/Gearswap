---  ═══════════════════════════════════════════════════════════════════════════
---   Cure Set Builder - Dynamic Cure Set Selection (RUN)
---  ═══════════════════════════════════════════════════════════════════════════
---   RUN has no Cure of its own: Cure to Cure IV come from the subjob
---   (/WHM /RDM: I-IV, /PLD /SCH: I-III). Every tier picks its set by target:
---   • SELF  -> sets.midcast.CureSelf
---   • OTHER -> sets.midcast.CureOther
---   The self cure is entered from sets.precast.FC.CureSelf (low max HP, see
---   RUN_PRECAST), the same HP-gap setup as PLD.
---
---   Sets: from the job's sets file. When the chosen one is missing,
---   generate() returns nil and the cure goes through MidcastManager.
---
---   @file    shared/jobs/run/functions/logic/cure_set_builder.lua
---   @author  ejouanchicot
---   @version 3.0.0 - Every Cure tier, sets.midcast.Cure left untouched
---   @date    Created: 2025-10-06 | Updated: 2026-09-27
---  ═══════════════════════════════════════════════════════════════════════════
local CureSetBuilder = {}

local CURES = {
    ['Cure'] = true,
    ['Cure II'] = true,
    ['Cure III'] = true,
    ['Cure IV'] = true,
}

---  ═══════════════════════════════════════════════════════════════════════════
---   CURE SET SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

--- True for the single-target Cures (Cure to Cure IV).
--- @param spell table Spell data from GearSwap
--- @return boolean
function CureSetBuilder.is_cure(spell)
    return spell ~= nil and CURES[spell.name] == true
end

---   Select the Cure set by target type
---   @param spell table Spell data from GearSwap
---   @param target_type string 'SELF' or 'OTHER'
---   @return table|nil CureSelf / CureOther, or nil when not a Cure or the set is missing
function CureSetBuilder.generate(spell, target_type)
    if not CureSetBuilder.is_cure(spell) then
        return nil
    end
    if target_type == 'SELF' then
        return sets.midcast.CureSelf
    end
    return sets.midcast.CureOther
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return CureSetBuilder
