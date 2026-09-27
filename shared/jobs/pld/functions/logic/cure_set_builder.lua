---  ═══════════════════════════════════════════════════════════════════════════
---   Cure Set Builder - Dynamic Cure Set Selection (PLD)
---  ═══════════════════════════════════════════════════════════════════════════
---   Selects the cure set by target for Cure to Cure IV (called from PLD
---   job_midcast):
---   • SELF  -> sets.midcast.CureSelf
---   • OTHER -> sets.midcast.CureOther
---   Sets are defined in pld_sets.lua. Only Cure III/IV get the low-HP Fast
---   Cast set and Majesty in precast (PLD_PRECAST).
---
---   @file    shared/jobs/pld/functions/logic/cure_set_builder.lua
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
