---  ═══════════════════════════════════════════════════════════════════════════
---   Cure Set Builder - Dynamic Cure Set Selection (RUN)
---  ═══════════════════════════════════════════════════════════════════════════
---   Selects optimized cure sets based on spell target (SELF vs OTHER).
---   Provides intelligent automation for:
---   • Target-based set selection (CureSelf vs CureOther)
---   • Cure III/IV only
---
---   Sets: sets.midcast.CureSelf / sets.midcast.CureOther from the job's
---   sets file. When the chosen one is missing, generate() returns nil.
---
---   @file    shared/jobs/run/functions/logic/cure_set_builder.lua
---   @author  Tetsouo
---   @version 2.0.0 - Sets moved to the job sets file
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
    -- Only handle Cure III/IV (other tiers keep Mote's sets.midcast.Cure)
    if spell.name ~= 'Cure III' and spell.name ~= 'Cure IV' then
        return nil
    end

    -- Select appropriate set based on target type
    local selected_set = target_type == 'SELF' and sets.midcast.CureSelf or sets.midcast.CureOther

    if not selected_set then
        return nil
    end

    -- Side effect: sets.midcast.Cure is overwritten, so later casts Mote maps
    -- to 'Cure' (Cure I/II) also get the last CureSelf/CureOther set.
    sets.midcast.Cure = selected_set

    return sets.midcast.Cure
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return CureSetBuilder
