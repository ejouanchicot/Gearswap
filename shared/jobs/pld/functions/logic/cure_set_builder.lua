---  ═══════════════════════════════════════════════════════════════════════════
---   Cure Set Builder - Dynamic Cure Set Selection (PLD)
---  ═══════════════════════════════════════════════════════════════════════════
---   Selects optimized cure sets based on spell target (SELF vs OTHER).
---   Only Cure III and Cure IV are handled (called from PLD job_midcast):
---   • SELF  -> sets.midcast.CureSelf
---   • OTHER -> sets.midcast.CureOther
---   Sets are defined in pld_sets.lua.
---
---   @file    shared/jobs/pld/functions/logic/cure_set_builder.lua
---   @author  Tetsouo
---   @version 2.0.0 - Sets moved to pld_sets.lua
---   @date    Created: 2025-10-06 | Updated: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════
local CureSetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CURE SET SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Select dynamic Cure set based on target type
---   @param spell table Spell data from GearSwap
---   @param target_type string 'SELF' or 'OTHER'
---   @return table|nil Cure set optimized for target type, or nil if not applicable
function CureSetBuilder.generate(spell, target_type)
    -- Only handle Cure III/IV (other cure tiers use generic sets.Cure)
    if spell.name ~= 'Cure III' and spell.name ~= 'Cure IV' then
        return nil
    end

    -- Select appropriate set based on target type (sets defined in pld_sets.lua)
    local selected_set = target_type == 'SELF' and sets.midcast.CureSelf or sets.midcast.CureOther

    if not selected_set then
        return nil
    end

    -- Side effect: sets.midcast.Cure keeps this choice afterwards, so Cure and
    -- Cure II (resolved by Mote from sets.midcast.Cure) wear it too.
    sets.midcast.Cure = selected_set

    return sets.midcast.Cure
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return CureSetBuilder
