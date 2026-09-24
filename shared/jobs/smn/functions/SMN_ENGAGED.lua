---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Engaged Module - Combat Set Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Master melee on SMN is rare. This module exists per architecture
---   requirement (12-module mandate) and returns the base engaged set.
---
---   @file    shared/jobs/smn/functions/SMN_ENGAGED.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

--- Return Mote's engaged set unchanged.
--- @param meleeSet table The engaged set Mote selected
--- @return table The set to equip
function customize_melee_set(meleeSet)
    if not meleeSet then return {} end
    return meleeSet
end

_G.customize_melee_set = customize_melee_set
