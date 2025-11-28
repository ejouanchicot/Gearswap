---============================================================================
--- Cure Set Builder - Dynamic Cure Set Selection (RUN)
---============================================================================
--- Selects optimized cure sets based on spell target (SELF vs OTHER).
--- Provides intelligent automation for:
---   • Target-based set selection (CureSelf vs CureOther)
---   • Cure III/IV optimization
---   • Dynamic midcast gear updates
---
--- Features:
---   • Self-cure: Focus on Enmity + Cure Potency
---   • Other-cure: Focus on Cure Potency + Cast Time
---   • Sets defined in pld_sets.lua (external configuration)
---
--- @file    jobs/run/functions/logic/cure_set_builder.lua
--- @author  Tetsouo
--- @version 2.0.0 - Sets moved to pld_sets.lua
--- @date    Created: 2025-10-06 | Updated: 2025-10-06
---============================================================================
local CureSetBuilder = {}

---============================================================================
--- CURE SET SELECTION
---============================================================================

--- Select dynamic Cure set based on target type
--- @param spell table Spell data from GearSwap
--- @param target_type string 'SELF' or 'OTHER'
--- @return table|nil Cure set optimized for target type, or nil if not applicable
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

    -- Update global midcast cure set (used by GearSwap)
    sets.midcast.Cure = selected_set

    return sets.midcast.Cure
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return CureSetBuilder
